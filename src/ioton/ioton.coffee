Stack = require('stackjs')

# TODO:: Throw on errors.
module.exports = class IOTON

    constructor: (rle = false, encoding = "ascii") ->
        @encoding = encoding
        @rle = rle
        @lastValue = undefined

    separators = { skip0: '\x1F', skip: ['\x1E', '\x1D','\x1C'], skipN: '\x1A' }

    reset: () ->
        @lastValue = undefined

    stringify: (value) ->
        stringUTF8 = convertToString(value, @lastValue, true)
        @lastValue = value
        return new Buffer(stringUTF8, @encoding)

    runLengthEncode = (partials, enclosures, rle) ->
        if !rle
            return enclosures.start + partials.join(separators.skip0) + enclosures.stop
        else
            encoded = enclosures.start
            skip = -1
            for value, i in partials
                if value == '\x10'
                    skip++
                else
                    if (skip == -1)
                        encoded += (if i != 0 then separators.skip0 else "") + value
                    else if (skip <= 2)
                        encoded += separators.skip[skip] + value
                    else
                        encoded += separators.skipN + skip.toString() + separators.skip0 + value
                    skip = -1
            if (skip != -1)
                if (skip <= 2)
                    encoded += separators.skip[skip]
                else
                    encoded += separators.skipN + skip.toString() + separators.skip0
            return encoded + enclosures.stop

    convertToString = (value, lastValue, rle) ->
        if (rle and lastValue != undefined and value is lastValue)
            return '\x10' # temporarily use DLE to mark unchanged values.
        if value is null or value is undefined
            return '\x19'

        switch (typeof value)
            when 'number'
                return value.toString()
            when 'boolean'
                if (value) then return "T" else return "F"
            when 'string'
                return '\x0F'+unreserve(value)
            when 'object' # , 'array'
                # Make an array to hold the partial results of stringifying this object value.
                partial = []
                if (value instanceof Array)
                    # The value is an array. Stringify every element. Use null as a placeholder for non-IOTON values.
                    if lastValue? and rle
                        for v, i in value
                            partial.push(convertToString(v, lastValue[i], rle))
                    else
                        for v in value
                            partial.push(convertToString(v, undefined, rle))

                    enclosures = {start: '\x02', stop: '\x03'}
                else
                    # The value is an object.
                    if lastValue? and rle
                        for k,v of value
                            partial.push(convertToString(v, lastValue[k], rle))
                    else
                        for k,v of value
                            partial.push(convertToString(v, undefined, rle))
                    enclosures = {start: '\x01', stop: '\x04'}

                return runLengthEncode(partial, enclosures, rle)
            else # should be never taken  TODO:: decide if it should throw an error here.
                return String(value);

    # This method parses an IOTON text to produce an object or array.
    #
    # It can throw a SyntaxError exception.
    parse: (buffer, schema) ->
        objects = objectify(buffer, schema)
        return objects

    objectify = (text, schema) ->
        stack = new Stack()
        indexStack = new Stack()

        split = (buffer, characters) ->
            tokens = []
            separator = "\x1F"
            tempString = ""+separator
            for i in [0...buffer.length] by 1
                if (buffer[i] in characters)
                    tempBuffer = new Buffer(tempString, @encoding)
                    tokens.push(tempBuffer)
                    separator = String.fromCharCode(buffer[i])
                    tempString = ""+separator
                else
                    tempString+=String.fromCharCode(buffer[i])
            tempBuffer = new Buffer(tempString, @encoding)
            tokens.push(tempBuffer)
            return tokens

        # helper functions.
        push = (value, type, index=null) ->
            keys = null
            if (indexStack.isEmpty())
                keys = schema
            else
                if type is "object"
                    keys = (stack.peek()[2])[(indexStack.peek())*2+1]
                else
                    # TODO:: unexpected array of arrays could cause index issue into the schema.
                    if (indexStack.peek())*2+1 < (stack.peek()[2]).length
                        keys = (stack.peek()[2])[(indexStack.peek())*2+1]

                    else keys = stack.peek()[2]
                    if (typeof keys == "string")
                        keys = stack.peek()[2]

            indexStack.push(index)
            stack.push([value, type, keys])
#            stack.push({value: value, type: type, schema: keys})

        pop = () ->
            top = stack.pop()
            indexStack.pop()
            return top

        makeBoolean = (value) ->
            switch(value[0])
                when 0x54 # T
                    return true
                when 0x46 # F
                    return false
                else
                    return null

        makeString = (value) ->
            if (value[0] is 0x0F)
                return value.toString().substring(1)
            return value.toString()

        makeTyped = (value) ->
            switch (value[0])
                when 0x46, 0x54  # F, T
                    return makeBoolean(value)
                when 0x0F
                    return makeString(value)
                else
                    return number(value) # convert buffer to number.

        makeValue = (value, type, tag) ->
            if (value[0] is 0x19) # Null or undefined
                return null
            switch (type)
                when "string"
                    return makeString(value)
                when "number"
                    return number(value)
                when "boolean"
                    return makeBoolean(value)
                when "typed"
                    return makeTyped(value)
                else
                    return makeTyped(value)

        makeContainerValueInObject = (value) ->
            index = indexStack.pop()
            tag = stack.peek()[2][(index)*2]
            type = stack.peek()[2][(index)*2+1]
            index++
            stack.peek()[0][tag] = value
            indexStack.push(index)

        makeObjectValue = (value) ->
            index = indexStack.pop()
            tag = stack.peek()[2][(index)*2]
            type = stack.peek()[2][(index)*2+1]
            index++
            value = makeValue(value,type, tag)
            stack.peek()[0][tag] = value #[value, value.toString(), tag, type]
            indexStack.push(index)

        setObject = (value, separator) ->
            if (!(value instanceof Buffer) and (typeof value is 'array' or typeof value is 'object'))
                makeContainerValueInObject(value)
            else
                if (separator == 0x1E) # fill 1
                    value = makeObjectValue(lastValue[0])
                else if (separator == 0x1D) # fill 2
                    value = makeObjectValue(lastValue[i]) for i in [0...1]
                else if (separator == 0x1C) # fill 3
                    value = makeObjectValue(lastValue[i]) for i in [0...2]
                else if (separator == 0x1A) # fill N
                    n = value #
                    value = makeObjectValue(lastValue[i]) for i in [0...n]

                value = makeObjectValue(value)

        makeContainerValueInArray = (value) ->
            tag = stack.peek()[2][0] #[(index)*2]
            type = stack.peek()[2][1] #[(index)*2+1]
            if (tag isnt "")
                console.log("have tag in array! : "+tag+"  from: "+stack.peek()[2])
            stack.peek()[0].push(value)

        makeArrayValue = (value) ->
            tag = stack.peek()[2][0] #[(index)*2]
            type = stack.peek()[2][1] #[(index)*2+1]
            if (tag isnt "")
                console.log("have tag in array! : "+tag+"  from: "+stack.peek()[2])
            value = makeValue(value, type, tag)
            stack.peek()[0].push(value) # [value, value.toString(), tag, type])

        setArray = (value, separator) ->
            if (!(value instanceof Buffer) and (typeof value is 'array' or typeof value is 'object'))
                makeContainerValueInArray(value)
            else
                makeArrayValue(value)

        set = (value) ->
            if (!stack.isEmpty())
                [na, type] = stack.peek()
                if (type is "object")
                    setObject(value, null)
                else
                    setArray(value, null)

        findEnd = (token, i) ->
            j = i
            while i < token.length and token[i] != 0x03 and token[i] != 0x04
                i++
            return [j,i-1,i]

        # the main algorithm.
        objects = null
        characters = [0x1F,0x1E,0x1D,0x1C,0x1A,0x1F]
        tokens = split(text, characters)
        j=0

        for token in tokens
            i = 0
            while i < token.length
                # arrays and objects.
                if token[i] in characters
                    separator = token[i]
                    i++
                if (token[i] is 0x01) # new object
                    # push down new object
                    push({}, "object", 0)
                    i++
                else if token[i] is 0x04
                    # pop out one object
                    [objects, na, na] = pop()
                    set(objects)
                    i++
                else if (token[i] is 0x02) # new array
                    # push down new array
                    push([], "array", 0)
                    i++
                else if token[i] is 0x03
                    # pop out one array
                    [objects, na, na] = pop()
                    set(objects)
                    i++
                else # elements of the object or array.
                    [na, type, na] = stack.peek()
                    if (type is "object")
                        [start, end, i] = findEnd(token, i)
                        setObject(token[(start)..end], separator)
                    else
                        # push into top array
                        [start, end, i] = findEnd(token, i)
                        setArray(token[(start)..end], separator)
        return objects

    convertToJavascript = (text) ->
        console.log(text.toString())
        obj = eval('(' + sanatize(text.toString()) + ')');
        return obj

    # This method produces a JSON from an IOTON.
    # TODO JSON from IOTON
    JSON: (value, schema) ->
        if (schema)
            @uncontrol(value)
        else
            @uncontrol(value)

    # TODO IOTON from JSON
    # This method produces a IOTON from a JSON.
    IOTON: (value) ->
        value

    unreserve = (text) ->
        return text.replace(/[\u0000-\u0006|\u000E-\u0010|\u0012|\u0014-\u001A|\u001C-\u001F]/g,'')

    sanatize = (text) ->
        #TODO:: Santize for attacks.
        return text

    uncontrol: (ioton) ->
        text = new Buffer(ioton)
        for i in [0...text.length]
            # TODO:: change to switch?
            if (text[i] is 0x01)
                text[i] = 0x7B # {
            else if (text[i] is 0x02)
                text[i] = 0x5B # [
            else if (text[i] is 0x03)
                text[i] = 0x5D # ]
            else if (text[i] is 0x04)
                text[i] = 0x7D # }
            else if (text[i] is 0x0E)
                text[i] = 0x7D # :
            else if (text[i] is 0x0F)
                text[i] = 0x22 # "
            else if (text[i] is 0x1A)
                text[i] = 0x2C # ,N
            else if (text[i] is 0x1C)
                text[i] = 0x2C # ,3
            else if (text[i] is 0x1D)
                text[i] = 0x2C # ,2
            else if (text[i] is 0x1E)
                text[i] = 0x2C # ,1
            else if (text[i] is 0x1F)
                text[i] = 0x2C # ,
            else if (text[i] is 0x19)
                text[i] = 0x40 # @ -> null or undefined
        return String(text)

    number = (value) ->
        # TODO:: validate numbers?
        return parseInt(value.toString())