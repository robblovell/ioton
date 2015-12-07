Ioton = require('./Ioton')
module.exports = class Bioton extends Ioton

    encode: (object) ->
        return @_type.encode(object)

    decode: (buffer) ->
        return @_type.decode(buffer)
