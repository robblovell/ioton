module.exports = class ReadState
    constructor: (buffer) ->
        @_buffer = buffer
        @_offset = 0

     # Read one byte but don't advance the read pointer
     # @returns {number}
    peekUInt8: () ->
        return @_buffer.readUInt8(@_offset)

     # Read one byte and advance the read pointer
     # @returns {number}
    readUInt8: () ->
        return @_buffer.readUInt8(@_offset++)

     # @returns {number}
    readUInt16: () ->
        r = @_buffer.readUInt16BE(@_offset)
        @_offset += 2
        return r
   
     # @returns {number}
    readUInt32: () ->
        r = @_buffer.readUInt32BE(@_offset)
        @_offset += 4
        return r

     # @returns {number}
    readDouble: () ->
        r = @_buffer.readDoubleBE(@_offset)
        @_offset += 8
        return r
 
     # @param {number} length
     # @returns {Buffer}
    readBuffer: (length) ->
        if (@_offset + length > @_buffer.length)
            throw new RangeError('Trying to access beyond buffer length')

        r = @_buffer.slice(@_offset, @_offset + length)
        @_offset += length
        return r

     # @return {boolean}
    hasEnded: () ->
        return @_offset == @_buffer.length
