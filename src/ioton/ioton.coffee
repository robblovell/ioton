Stack = require('stackjs')

# TODO:: Throw on errors.
module.exports = class IOTON

    constructor: (encoding = "ascii") -> #, rle=false) ->
        @encoding = encoding
#        @rle = rle
#        @lastValue = undefined
#        @lastParsedValues = undefined

    separators = { skip0: '\x1F', skip: ['\x1E', '\x1D','\x1C'], skipN: '\x1A' }

    reset: () ->
        return true
#        @lastValue = undefined

    stringify: (value) ->
        stringUTF8 = convertToString(value) #, @lastValue, true)
#        @lastValue = value
        return new Buffer(stringUTF8, @encoding)

    runLengthEncode = (partials, enclosures) -> #, rle) ->
#        if !rle
        return enclosures.start + partials.join(separators.skip0) + enclosures.stop
#        else
#            encoded = enclosures.start
#            skip = -1
#            for value, i in partials
#                if value == '\x10'
#                    skip++
#                else
#                    if (skip == -1)
#                        encoded += (if i != 0 then separators.skip0 else "") + value
#                    else if (skip <= 2)
#                        encoded += separators.skip[skip] + value
#                    else
#                        encoded += separators.skipN + skip.toString() + separators.skip0 + value
#                    skip = -1
#            if (skip != -1)
#                if (skip <= 2)
#                    encoded += separators.skip[skip]
#                else
#                    encoded += separators.skipN + skip.toString() + separators.skip0
#            return encoded + enclosures.stop

    convertToString = (value) -> #, lastValue, rle) ->
#        if (rle and lastValue != undefined and value is lastValue)
#            return '\x10' # temporarily use DLE to mark unchanged values.
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
#                    if lastValue? and rle
#                        for v, i in value
#                            partial.push(convertToString(v, lastValue[i], rle))
#                    else
                    for v in value
                        partial.push(convertToString(v)) #, undefined, rle))

                    enclosures = {start: '\x02', stop: '\x03'}
                else
                    # The value is an object.
#                    if lastValue? and rle
#                        for k,v of value
#                            partial.push(convertToString(v, lastValue[k], rle))
#                    else
                    for k,v of value
                        partial.push(convertToString(v)) #, undefined, rle))
                    enclosures = {start: '\x01', stop: '\x04'}

                return runLengthEncode(partial, enclosures) #, rle)
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
        push = (value, type, index=null) -> # TODO:: pass in last here.
            keys = null
#            last = null if @rle
            if (indexStack.isEmpty())
                keys = schema
#                if @rle
#                    if @lastParsedValues?
#                        @haveLast = true
#                        last = @lastParsedValues
#                    else
#                        @haveLast = false
#                        last = []
            else
                if type is "object"
                    keys = (stack.peek().schema)[(indexStack.peek())*2+1]
#                    last = (stack.peek().last)[(indexStack.peek())] if @rle and @haveLast
                else
                    # TODO:: unexpected array of arrays could cause index issue into the schema.
                    if (indexStack.peek())*2+1 < stack.peek().schema.length
                        keys = stack.peek().schema[(indexStack.peek())*2+1]
#                        last = (stack.peek().last)[(indexStack.peek())] if @rle and @haveLast
                    else
                        keys = stack.peek().schema
#                        last = stack.peek().last if @rle and @haveLast
                    if (typeof keys == "string")
                        keys = stack.peek().schema
#                        last = stack.peek().last if @rle and @haveLast

            indexStack.push(index)
            stack.push({value: value, type: type, schema: keys}) #, last: last})

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
            tag = stack.peek().schema[(index)*2]
            type = stack.peek().schema[(index)*2+1]
            index++
            stack.peek().value[tag] = value
#            if (@rle and !@haveLast) # Construct the container to hold last values the first time through.
#                stack.peek().last[index] = value

            indexStack.push(index)

        makeObjectValue = (value=null) ->
            index = indexStack.pop()
            tag = stack.peek().schema[(index)*2]
            type = stack.peek().schema[(index)*2+1]
#            if (@rle)
#                if (value == null and !stack.peek().last[index]?)
#                    throw new Error("must have full object from the other party to reconstruct partial object.  Send Inqury 0x05 to obtain a schema")
#                else if (value == null)
#                    if (@haveLast)
#                        value = stack.peek().last[index]
#                    else
#                        throw new Error("Parse does not have the last value set for field, make sure all fields of a full object are set before using run length encoding (rle flag)")
#                else
#                    # set the last value
#                    stack.peek().last[index] = value # save the value in the schema for next time.
            index++
            value = makeValue(value,type, tag)
            stack.peek().value[tag] = value #[value, value.toString(), tag, type]
            indexStack.push(index)

        setObject = (value, separator) ->
            if (!(value instanceof Buffer) and (typeof value is 'array' or typeof value is 'object'))
                makeContainerValueInObject(value)
            else
                if (separator == 0x1A) # fill N
                    n = value #
                    makeObjectValue() for i in [0...n]
                else
                    n = 0x1F-separator
                    makeObjectValue() for i in [0...n]
                    makeObjectValue(value)

        makeContainerValueInArray = (value) ->
            tag = stack.peek().schema[0] #[(index)*2]
            type = stack.peek().schema[1] #[(index)*2+1]

            stack.peek().value.push(value)
#            if (@rle and !@haveLast) # Construct the container to hold last values the first time through.
#                stack.peek().last.push(value)

        makeArrayValue = (value) ->
            tag = stack.peek().schema[0] #[(index)*2]
            type = stack.peek().schema[1] #[(index)*2+1]
            if (tag isnt "")
                console.log("have tag in array! : "+tag+"  from: "+stack.peek().schema)
#            if (@rle)
#                if (value == null and value == null and
#                (!stack.peek().last? or stack.peek().last.length == 0 or !stack.peek().last[stack.peek().index]?))
#                    throw new Error("must have full object from the other party to reconstruct partial object.  Send Inqury 0x05 to obtain a schema")
#                else if (value == null)
#                    if (@haveLast)
#                        value = stack.peek().last[stack.peek().index]
#                    else
#                        throw new Error("Parse does not have the last value set for field, make sure all fields of a full object are set before using run length encoding (rle flag)")
#                else
#                    # set the last value
#                    stack.peek().last[stack.peek().index] = value # save the value in the schema for next time.

            value = makeValue(value, type, tag)
            stack.peek().value.push(value) # [value, value.toString(), tag, type])

        setArray = (value, separator) ->
            if (!(value instanceof Buffer) and (typeof value is 'array' or typeof value is 'object'))
                makeContainerValueInArray(value)
            else
#                if (separator == 0x1A) # fill N
#                    n = value #
#                    makeArrayValue() for i in [0...n]
#                else
#                    n = 0x1F-separator
#                    makeArrayValue() for i in [0...n]
#                    makeArrayValue(value)
                makeArrayValue(value)

        set = (value) ->
            if (!stack.isEmpty())
                top = stack.peek()
                if (top.type is "object")
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
                    push({}, "object", 0, {})
                    i++
                else if token[i] is 0x04
                    # pop out one object
#                    [objects, na, na]
                    top = pop()
                    objects = top.value
                    set(objects)
                    i++
                else if (token[i] is 0x02) # new array
                    # push down new array
                    push([], "array", 0, [])
                    i++
                else if token[i] is 0x03
                    # pop out one array
#                    [objects, na, na]
                    top = pop()
                    objects = top.value
                    set(objects)
                    i++
                else # elements of the object or array.
                    top = stack.peek()
                    if (top.type is "object")
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