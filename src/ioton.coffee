Stack = require('stackjs')
Type = require('./binary/Type')

# TODO:: Throw on errors.
# TODO:: namespace schemas,
# TODO:: management of schemas
# TODO:: Avro style encoding of nulls, numbers (int/long/float/double), booleans, and strings.
# TODO:: To/From Avro.


module.exports = class Ioton

    constructor: (schema='string', encoding = "ascii") ->
        @encoding = encoding
        @separatorCharacters = { skip0: '\x1F' }
        @separators = []
        @separators[0] = @separatorCharacters.skip0.charCodeAt(0)

        @containerCharacters = { objectBegin: '\x01', objectEnd: '\x04', arrayBegin: '\x02', arrayEnd: '\x03' }
        @containers = []
        for k,v of @containerCharacters
            @containers.push(v)
        @nullCharacter = '\x19'
        @undefinedCharacter = '\x07'
        @quoteCharacter = '\x0F'
        @nullHextet = 0x19
        @undefinedHextet = 0x07
        @quoteHextet = 0x0F
        @trueHextet = 0x54
        @falseHextet = 0x46
        @schema(schema)

    schema: (schema=null) ->
        return @schema if (schema is null)
        @_type = new Type(schema)
        @parser_schema = makeSchema(schema)
        @_schema = schema
        return @_schema

    reset: () ->
        return true

    stringify: (value) ->
        stringUTF8 = @convertToString(value)
        return new Buffer(stringUTF8, @encoding)

    convertToString: (value) =>
        if value is null
            return @nullCharacter
        if value is undefined
            return @undefinedCharacter

        switch (typeof value)
            when 'number', 'uint', 'int', 'float'
                return value.toString()
            when 'boolean'
                if (value) then return "T" else return "F"
            when 'string'
                return @quoteCharacter+unreserve(value)
            when 'object' # , 'array'
                # Make an array to hold the partial results of stringifying this object value.
                partial = []
                if (value instanceof Array)
                    # The value is an array. Stringify every element. Use null as a placeholder for non-IOTON values.
                    for v in value
                        partial.push(@convertToString(v))

                    enclosures = {start: @containerCharacters.arrayBegin, stop: @containerCharacters.arrayEnd}
                else
                    # The value is an object.
                    for k,v of value
                        partial.push(@convertToString(v))
                    enclosures = {start: @containerCharacters.objectBegin, stop: @containerCharacters.objectEnd}

                return enclosures.start + partial.join(@separatorCharacters.skip0) + enclosures.stop
            else # should be never taken  TODO:: decide if it should throw an error here.
                return String(value);

    #
    printSchema = (schema, tab="", prefix="") ->
        if Array.isArray(schema)
            console.log(prefix+"["+tab)
            for v, i in schema
                if (typeof v is 'object' or Array.isArray(v))
                    printSchema(v, tab+"    ", tab+"["+i+"]=")
                else
                    console.log(tab+"["+i+"]="+v)
            console.log("]"+tab)
        else if (typeof schema is 'object')
            console.log(prefix+"{" +tab)

            for p,v of schema
                if (typeof v is 'object' or Array.isArray(v))
                    printSchema(v, tab+"    ", p+": ")
                else
                    console.log(tab+p+": "+v)

            console.log("}" +tab)

        else
            console.log(tab+"value:" + schema)

    translate = (value) ->
        switch(value)
            when 'uint', 'int', 'float'
                'number'
            else
                value

    makeSchema = (schema) ->
        result = []
        if Array.isArray(schema)
            result.push("")
            for v, i in schema
                if (typeof v is 'object' or Array.isArray(v))
                    result.push(makeSchema(v))
                else
                    result.push(translate(v))
                break

        else if (typeof schema is 'object')
            for p,v of schema
                result.push(p)
                if (typeof v is 'object' or Array.isArray(v))
                    result.push(makeSchema(v))
                else
                    result.push(translate(v))
        else
            result.push(translate(schema))
        return result

    # This method parses an IOTON text to produce an object or array.
    parse: (text, schema = null) ->
        @schema(schema) if schema
        schema = @parser_schema
        stack = new Stack()
        indexStack = new Stack()

        splitCharacter = @separatorCharacters.skip0
        quoteHextet = @quoteHextet
        trueHextet = @trueHextet
        falseHextet = @falseHextet
        nullHextet = @nullHextet
        undefinedHextet = @undefinedHextet

        split = (buffer, characters) ->
            tokens = []
            separator = splitCharacter
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
                    keys = (stack.peek().schema)[(indexStack.peek())*2+1]
                else
                    if (indexStack.peek())*2+1 < stack.peek().schema.length
                        keys = stack.peek().schema[(indexStack.peek())*2+1]
                    else
                        keys = stack.peek().schema
                    if (typeof keys == "string")
                        keys = stack.peek().schema

            indexStack.push(index)
            stack.push({value: value, type: type, schema: keys})

        pop = () ->
            top = stack.pop()
            indexStack.pop()
            return top

        makeBoolean = (value) ->
            switch(value[0])
                when trueHextet # T
                    return true
                when falseHextet # F
                    return false
                else
                    return null

        makeString = (value) ->
            if (value[0] is quoteHextet)
                return value.toString().substring(1)
            return value.toString()

        makeTyped = (value) ->
            switch (value[0])
                when nullHextet
                    return null
                when undefinedHextet
                    return undefined
                when trueHextet, falseHextet  # F, T
                    return makeBoolean(value)
                when quoteHextet
                    return makeString(value)
                else
                    return number(value) # convert buffer to number.

        makeValue = (value, type, tag) ->
            if (value[0] is nullHextet) # Null or undefined
                return null
            if (value[0] is undefinedHextet) # Null or undefined
                return undefined
            switch (type)
                when "string"
                    return makeString(value)
                when 'number', 'uint', 'int', 'float'
                    return number(value)
                when "boolean"
                    return makeBoolean(value)
                when "dynamic"
                    return makeTyped(value)
                else
                    return makeTyped(value)

        makeContainerValueInObject = (value) ->
            index = indexStack.pop()
            tag = stack.peek().schema[(index)*2]
            type = stack.peek().schema[(index)*2+1]
            index++
            stack.peek().value[tag] = value

            indexStack.push(index)

        makeObjectValue = (value=null) ->
            index = indexStack.pop()
            tag = stack.peek().schema[(index)*2]
            type = stack.peek().schema[(index)*2+1]
            index++
            value = makeValue(value, type, tag)
            stack.peek().value[tag] = value
            indexStack.push(index)

        setObject = (value, separator) ->
            if (!(value instanceof Buffer) and (Array.isArray(value) or typeof value is 'object'))
                makeContainerValueInObject(value)
            else
                makeObjectValue(value)

        makeContainerValueInArray = (value) ->
            tag = stack.peek().schema[0] #[(index)*2]
            type = stack.peek().schema[1] #[(index)*2+1]

            stack.peek().value.push(value)

        makeArrayValue = (value) ->
            tag = stack.peek().schema[0] #[(index)*2]
            type = stack.peek().schema[1] #[(index)*2+1]
            if (tag isnt "")
                console.log("have tag in array! : "+tag+"  from: "+stack.peek().schema)

            value = makeValue(value, type, tag)
            stack.peek().value.push(value) # [value, value.toString(), tag, type])

        setArray = (value, separator) ->
            if (!(value instanceof Buffer) and (Array.isArray(value) or typeof value is 'object'))
                makeContainerValueInArray(value)
            else
                makeArrayValue(value)

        set = (value) ->
            if (!stack.isEmpty())
                top = stack.peek()
                if (top.type is "object")
                    setObject(value, null)
                else
                    setArray(value, null)

        findEnd = (token, i) =>
            j = i
            while i < token.length and token[i] != @containerCharacters.arrayEnd.charCodeAt(0) and
            token[i] != @containerCharacters.objectEnd.charCodeAt(0)
                i++
            return [j,i-1,i]

        # the main algorithm.
        objects = null
        tokens = split(text, @separators)
        if (tokens[1] == undefined) # simple types, non-array, non-object
            return makeTyped(text)
        j=0

        for token in tokens
            i = 0
            while i < token.length
                # arrays and objects.
                if token[i] in @separators
                    separator = token[i]
                    i++
                if (token[i] is @containerCharacters.objectBegin.charCodeAt(0)) # new object
                    # push down new object
                    push({}, "object", 0, {})
                    i++
                else if token[i] is @containerCharacters.objectEnd.charCodeAt(0)
                    # pop out one object
                    top = pop()
                    objects = top.value
                    set(objects)
                    i++
                else if (token[i] is @containerCharacters.arrayBegin.charCodeAt(0)) # new array
                    # push down new array
                    push([], "array", 0, [])
                    i++
                else if token[i] is @containerCharacters.arrayEnd.charCodeAt(0)
                    # pop out one array
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
        obj = eval('(' + sanatize(text.toString()) + ')');
        return obj

    # This method produces a JSON from an IOTON.
    JSON: (iotonStr, schema=null) ->
        @schema(schema) if schema
        object = @parse(iotonStr)
        return JSON.stringify(object)

    # This method produces a IOTON from a JSON.
    IOTON: (jsonStr, schema=null) ->
        @schema(schema) if schema
        object = JSON.parse(jsonStr)
        return @stringify(object)

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
                text[i] = 0x40 # @ -> null
            else if (text[i] is 0x16)
                text[i] = 0x3F # ? -> undefined       return String(text)

    number = (value) ->
        # TODO:: validate numbers?
        str = value.toString()
        if (~str.indexOf('.'))
            return parseFloat(str)
        else
            return parseInt(str)

    makeObject: (object, schema, maker = 0) ->
        if (schema is 'number' or schema is 'uint' or schema is 'int' or schema is 'float')
            return maker++
        else if (schema is 'boolean')
            return (maker%2 is 0)
        else if (schema is 'string')
            return (maker++).toString()
        else if (typeof schema is 'object') # , 'array'
            # Make an array to hold the partial results of stringifying this object value.
            if (schema instanceof Array)
                tmp = []
                for i in [0..2]
                    tmp.push(@makeObject({}, schema[0]))
                return tmp
            else
                for property, value of schema
                    object[property] = @makeObject({}, value)

        return object

    make: (schema=null) ->
        @schema(schema) if schema
        object = @makeObject({}, @_schema)
        return object

    makeify: () ->
        object = @make()
        return @stringify(object)
