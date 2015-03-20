module.exports = class Data
    constructor: (capacity) ->
        # Internal buffer
        # @member {Buffer}
        # @private
        @_buffer = new Buffer(capacity || 128)
        #  Number of used bytes
        #  @member {number}
        #  @private
        @_length = 0

    # Alloc the given number of bytes
    # @param {number} bytes
    # @private
    _alloc: (bytes) =>
        buffLen = @_buffer.length

        if (@_length + bytes > buffLen)
            loop
                buffLen *= 2
                break unless (@_length + bytes > buffLen)

            newBuffer = new Buffer(buffLen)
            @_buffer.copy(newBuffer, 0, 0, @_length)
            @_buffer = newBuffer

    # @param {Buffer} data
    appendBuffer: (data) ->
        @_alloc(data.length)
        data.copy(@_buffer, @_length)
        @_length += data.length

    # @param {number} value
    writeUInt8: (value) ->
        @_alloc(1)
        @_buffer.writeUInt8(value, @_length)
        @_length++

    # @param {number} value
    writeUInt16: (value) ->
        @_alloc(2)
        @_buffer.writeUInt16BE(value, @_length)
        @_length += 2

    # @param {number} value
    writeUInt32: (value) ->
        @_alloc(4)
        @_buffer.writeUInt32BE(value, @_length)
        @_length += 4

    # @param {number} value
    writeDouble: (value) ->
        @_alloc(8)
        @_buffer.writeDoubleBE(value, @_length)
        @_length += 8

    # Return the data as a Buffer.
    # Note: the returned Buffer and the internal Buffer share the same memory
    # @return {Buffer}
    toBuffer: () ->
        return @_buffer.slice(0, @_length)


