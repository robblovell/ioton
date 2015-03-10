Stack = require('stackjs')

module.exports = class IOTON
    constructor: (encoding = "ascii") ->
        @encoding = encoding
        @meta = {    # table of characters to remove
            '\x00': '',
            '\x01': '',
            '\x02': '',
            '\x03': '',
            '\x04': '',
            '\x05': '',
            '\x06': '',
            '\x10': '',
            '\x17': '',
            '\x19': '',
            '\x1A': '',
            '\x1B': '',
            '\x1C': '',
            '\x1D': '',
            '\x1E': '',
            '\x1F': '',
        }
        @schema = null

    stringify: (value) ->
        stringUTF8 = convertToString(value);
        return new Buffer(stringUTF8, @encoding)

    convertToString = (value) ->
        if value and typeof value == 'object' and typeof value.toIOTON == 'function'
            return value.toIOTON(key)

        if value is undefined
            return '\x19'
        if value is null
            return '\x0E'
        switch (typeof value)
            when 'number'
                return number(value)
            when 'boolean'
                if (value) then return "T" else return "F"
            when 'string'
                return '\x0F'+unreserve(value)
            when 'object' # , 'array'
                return 'null' if !value
                # Make an array to hold the partial results of stringifying this object value.

                partial = []
                if (value instanceof Array)
                    # The value is an array. Stringify every element. Use null as a placeholder for non-IOTON values.
                    for v in value
                        partial.push(convertToString(v))
                    return '\x02' + partial.join('\x1F') + '\x03'
                    # return '\x02' + partial.join('\x031') + '\x03'
                else
                    # The value is an object.
                    for k,v of value
                        partial.push(convertToString(v))
                    return '\x01' + partial.join('\x1F') + '\x04'
                    # return '\x01' + partial.join('\x031') + '\x04'

            else # never taken
                return String(value);

    # This method parses an IOTON text to produce an object or array.
    #
    # It can throw a SyntaxError exception.

    parse: (buffer, schema) ->
        text = new Buffer(buffer)
        text = @uncontrol(text)
        objects = objectify(buffer, schema)

        return objects

    objectifyStr = (text) ->
        stack = new Stack()
        indexStack = new Stack()

        # helper functions.
        push = (value, type, index=null) ->
            stack.push([value, type])
            if (index?)
                indexStack.push(index)

        pop = () ->
            [value, na, na] = stack.pop()
            indexStack.pop()
            return value

        setObject = (value) ->
            index = indexStack.pop()
            [na, na, schema] = stack.peek()
            stack.peek()[0][index++] = value
            indexStack.push(index)

        setArray = (value) ->
            stack.peek()[0].push(value)

        set = (value) ->
            if (!stack.isEmpty())
                [na, type] = stack.peek()
                if (type is "object")
                    setObject(value)
                else
                    setArray(value)

        findEnd = (token, i) ->
            j = i
            while i < token.length and token[i] != '}' and token[i] != ']'
                i++
            return [j,i-1,i]

        # the main algorithm.
        objects = null
        tokens = text.split(',')
        j=0

        index = 0
        for token in tokens
            i = 0
            while i < token.length
                # arrays and objects.
                if (token[i] is '{') # new object
                    # push down new object
                    push({}, "object", 0)
                    i++
                else if token[i] is '}'
                    # pop out one object
                    objects = pop()
                    set(objects)
                    i++

                else if (token[i] is '[') # new array
                    # push down new array
                    push([], "array")
                    i++
                else if token[i] is ']'
                    # pop out one array
                    [objects, na] = stack.pop()
                    set(objects)
                    i++

                else # elements of the object or array.
                    [na, type] = stack.peek()
                    if (type is "object")
                        [start, end, i] = findEnd(token, i)
                        setObject(token[start..end])
                    else
                        # push into top array
                        [start, end, i] = findEnd(token, i)
                        setArray(token[start..end])

        return objects

    objectify = (text, schema) ->
        stack = new Stack()
        indexStack = new Stack()

        split = (buffer, character) ->
            tokens = []
            tempString = ""
            for i in [0...buffer.length] by 1
                if (buffer[i] is character)
                    tempBuffer = new Buffer(tempString, @encoding)
                    tokens.push(tempBuffer)
                    tempString = ""
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
            else #if (typeof stack.peek()[2] is "string" )
                if type is "object"
                    keys = (stack.peek()[2])[(indexStack.peek())*2+1]
                else
                    keys = (stack.peek()[2])[(indexStack.peek())*2+1]
            indexStack.push(index)
            stack.push([value, type, keys])


        pop = () ->
            top = stack.pop()
            indexStack.pop()
            return top

        makeBoolean = (value) ->
            switch(value[0])
                when 84
                    return true
                when 70
                    return false
                else
                    return null

        makeTyped = (value) ->
            switch (value[0])
                when 78, 84
                    return makeBoolean(value)
                when 15
                    return value.toString()
                else
                    return parseInt(value)

        makeValue = (value, type, tag) ->
            if (value[0] is 14)
                return null
            if (value[0] is 25)
                return undefined
            switch (type)
                when "string"
                    return value.toString().slice(1,-1)
                when "number"
                    return parseInt(value)
                when "boolean"
                    return makeBoolean(value)
                when "typed"
                    return makeTyped(value)
                else
                    return makeTyped(value)
#                   return [value, value.toString(), tag, type]

        setObject = (value) ->
            index = indexStack.pop()
            tag = stack.peek()[2][(index)*2]
            type = stack.peek()[2][(index)*2+1]
            index++
            if (!(value instanceof Buffer) and (typeof value is 'array' or typeof value is 'object'))
                stack.peek()[0][tag] = value
            else
                value = makeValue(value,type, tag)
                stack.peek()[0][tag] = value #[value, value.toString(), tag, type]

            indexStack.push(index)

        setArray = (value) ->
            index = indexStack.peek()
            tag = stack.peek()[2][0] #[(index)*2]
            type = stack.peek()[2][1] #[(index)*2+1]
            if (tag isnt "")
                console.log("have tag in array! : "+tag+"  from: "+stack.peek()[2])
            if (!(value instanceof Buffer) and (typeof value is 'array' or typeof value is 'object'))
                stack.peek()[0].push(value)
            else
                value = makeValue(value,type, tag)
                stack.peek()[0].push(value) # [value, value.toString(), tag, type])
#            indexStack.push(index)

        set = (value) ->
            if (!stack.isEmpty())
                [na, type] = stack.peek()
                if (type is "object")
                    setObject(value)
                else
                    setArray(value)

        findEnd = (token, i) ->
            j = i
            while i < token.length and token[i] != 0x03 and token[i] != 0x04
                i++
            return [j,i-1,i]

        # the main algorithm.
        objects = null
        tokens = split(text, 0x1F)
        j=0

        index = null
        keys = null
        for token in tokens
            i = 0
            while i < token.length
                # arrays and objects.
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
                    [na, type] = stack.peek()
                    if (type is "object")
                        [start, end, i] = findEnd(token, i)
                        setObject(token[start..end])
                    else
                        # push into top array
                        [start, end, i] = findEnd(token, i)
                        setArray(token[start..end])

        return objects

    #            if (token[0] is '\x15')
    #                token[0] = "\""
    #                token += "\""
    #            else if (token[0] is '\x0E')
    #                token = null
    #            else if (token[0] is 'T')
    #                token = true
    #            else if (token[0] is 'F')
    #                token = false
    #            else if (token[0] is '\x19')
    #                token = undefined

    convertToJavascript = (text) ->
        console.log(text.toString())
        obj = eval('(' + sanatize(text.toString()) + ')');
        return obj

    # This method produces a JSON from an IOTON.
    JSON: (value, schema) ->
        if (schema)
            @uncontrol(value)
        else
            @uncontrol(value)


    # This method produces a IOTON from a JSON.
    IOTON: (value) ->
        value

    unreserve = (text) ->
        return text.replace(/[\u0000-\u0006|\u000E-\u0010|\u0012|\u0014-\u0017|\u0019-\u001A|\u001C-\u001F]/g,'')

    sanatize = (text) ->
        #TODO:: Santize for attacks.
        return text

    uncontrol: (ioton) ->
        text = new Buffer(ioton)
        for i in [0...text.length]
            text[i] = 123 if text[i] is 0x1  # '{'
            text[i] = 125 if text[i] is 0x4  # '}'
            text[i] = 91 if text[i] is 0x2  # '['
            text[i] = 93 if text[i] is 0x3  # ']'
            text[i] = 44 if text[i] is 0x1F # ','
            text[i] = 34 if text[i] is 0xF # ','
#            text[i] = 34 if text[i] is 0xF # '"' leading quote for strings.
            if text[i] is 0xE # 'null'
                text[i] = 64 # @
            if text[i] is 0x19 # 'undefined'
                text[i] = 63 # ?

        return String(text)

    number = (text) ->
        # TODO:: validate numbers.
        return String(text)