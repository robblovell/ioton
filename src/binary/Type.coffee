types = require('./Types')
ioton = require('../ioton')

module.exports = class Type

    constructor: (schema) ->

        if (typeof schema == 'string')
            if (schema in Type.TYPE && schema != Type.TYPE.ARRAY && schema != Type.TYPE.OBJECT)
                throw new TypeError('Unknown basic type: ' + schema)

            @type = schema
        else if (Array.isArray(schema))
            if (schema.length != 1)
                throw new TypeError('Invalid array type, it must have exactly one element')

            @type = Type.TYPE.ARRAY
            @subType = new Type(schema[0])
        else
            if (!schema || typeof schema != 'object')
                throw new TypeError('Invalid type: ' + schema)

            @type = Type.TYPE.OBJECT
            @fields = Object.keys(schema).map( (name) ->
                if typeof name == 'object'
                    return new Field(name.type,  schema[name.type])
                else
                    return new Field(name,  schema[name])
            )

    types: types

    stringify: (value) ->
        IOTON = new ioton()
        return ioton.stringify(value)

    parse: (buffer) ->


    # @param * value
    # @return Buffer
    # @throws if the value is invalid
    encode: (value) ->
        data = new Data
        @write(value, data, '')
        return data.toBuffer()

    # @param Buffer buffer
    # @return *
    # @throws if fails
    decode:  (buffer) ->
        return @read(new ReadState(buffer))

    # @param * value
    # @param Data data
    # @param string path
    # @throws if the value is invalid
     
    write: (value, data, path) ->
        if (@type == Type.TYPE.ARRAY)
            # Array field
            return @_writeArray(value, data, path, @subType)
         else if (@type != Type.TYPE.OBJECT)
            # Simple type
            return types[@type].write(value, data, path)

        # Check for object type
        if (!value || typeof value != 'object')
            throw new TypeError('Expected an object at ' + path)

        # Write each field
        i=0
        for len in [0...@fields.length]
            field = @fields[i++]
            subpath = if path then path + '.' + field.name else field.name
            subValue = value[field.name]

            if (field.optional)
                # Add 'presence' flag
                if (subValue == undefined || subValue == null)
                    types.boolean.write(false, data)
                    continue
                else
                    types.boolean.write(true, data)

            if (!field.array)
                # Scalar field
                field.type.write(subValue, data, subpath)
                continue
            # Array field
            @_writeArray(subValue, data, subpath, field.type)

    # @param * value
    # @param Data data
    # @param string path
    # @param Type type
    # @throws if the value is invalid
    # @private
    _writeArray: (value, data, path, type) ->
        if (!Array.isArray(value)) 
            throw new TypeError('Expected an Array at ' + path)
        
        len = value.length
        types.uint.write(len, data)
        for i in [0...len]
            type.write(value[i], data, path + '.' + i)

    # This funciton will be executed only the first time
    # After that, we'll compile the read routine and add it directly to the instance
    # @param ReadState state
    # @return *
    # @throws if fails
    read: (state) ->
        @read = @_compileRead()
        return @read(state)

    # Return a signature for this type. Two types that resolve to the same hash can be said as equivalents
    # @return Buffer
    getHash: () ->
        hash = new Data
        hashType(this, false, false)
        return hash.toBuffer()

        # @param Type type
        # @param boolean array
        # @param boolean optional
         
        hashType = (type, array, optional) ->
            # Write type (first char + flags)
            # AOxx xxxx
            hash.writeUInt8((type.type.charCodeAt(0) & 0x3f) | (if array then 0x80 else 0) | (if optional then 0x40 else 0))
            
            if (type.type == Type.TYPE.ARRAY)
                hashType(type.subType, false, false)
            else if (type.type == Type.TYPE.OBJECT)
                types.uint.write(type.fields.length, hash)
                type.fields.forEach( (field) ->
                    hashType(field.type, field.array, field.optional)
                )

    # Compile the decode method for this object
    # @return function(ReadState):*
    # @private
    _compileRead: () ->
        if (@type != Type.TYPE.OBJECT && @type != Type.TYPE.ARRAY)
            # Scalar type
            # In this case, there is no need to write custom code
            return types[@type].read
         else if (@type == Type.TYPE.ARRAY)
            return @_readArray.bind(this, @subType)

        # As an example, compiling code to new Type(a:'int', 'b?':['string']) will result in:
        # return 
        #     a: @fields[0].type.read(state),
        #     b: @types.boolean.read(state) ? @_readArray(state, @fields[1].type) : undefined
        # 
        code = 'return {' + @fields.map((field, i) ->
            name = JSON.stringify(field.name)
            fieldStr = 'this.fields[' + i + ']'

            if (field.array)
                readCode = 'this._readArray(' + fieldStr + '.type, state)'
            else
                readCode = fieldStr + '.type.read(state)'
        
        
            if (!field.optional)
                code = name + ': ' + readCode
            else
                code = name + ': this.types.boolean.read(state) ? ' + readCode + ' : undefined'
        
            return code
        ).join(',') + '}'
        
        return new Function('state', code)

    # @param Type type
    # @param ReadState state
    # @return Array
    # @throws - if invalid
    # @private
    _readArray: (type, state) ->
        arr = new Array(types.uint.read(state))
        
        for j in [0...arr.length]
            arr[j] = type.read(state)
        
        return arr

Data = require('./Data')
ReadState = require('./ReadState')
Field = require('./Field')

Type.TYPE = {
        UINT: 'uint',
        INT: 'int',
        FLOAT: 'float',
        NUMBER: 'float',
        STRING: 'string',
        BUFFER: 'Buffer',
        BOOLEAN: 'boolean',
        JSON: 'json',
        OID: 'oid',
        REGEX: 'regex',
        DATE: 'date',
        ARRAY: '[array]',
        OBJECT: 'object'
    }