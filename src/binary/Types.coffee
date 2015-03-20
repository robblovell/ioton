
# Stores 2^i from i=0 to i=56
n=1
POW = [1].concat (n*=2 for i in [0..56])

# Pre-calculated constants
MAX_DOUBLE_INT = POW[53]
MAX_UINT8 = POW[7]
MAX_UINT16 = POW[14]
MAX_UINT32 = POW[29]
MAX_INT8 = POW[6]
MAX_INT16 = POW[13]
MAX_INT32 = POW[28]
POW_32 = POW[32]

# Formats (big-endian):
# 7b	0xxx xxxx
# 14b	10xx xxxx  xxxx xxxx
# 29b	110x xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx
# 61b	111x xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx
module.exports.uint = {
    write: (u, data, path) ->
        # Check the input
        if (Math.round(u) != u || u > MAX_DOUBLE_INT || u < 0)
            throw new TypeError('Expected unsigned integer at ' + path + ', got ' + u)

        if (u < MAX_UINT8)
            data.writeUInt8(u)
        else if (u < MAX_UINT16)
            data.writeUInt16(u + 0x8000)
        else if (u < MAX_UINT32)
            data.writeUInt32(u + 0xc0000000)
        else # Split in two 32b uints
            data.writeUInt32(Math.floor(u / POW_32) + 0xe0000000)
            data.writeUInt32(u >>> 0)

    read: (state) ->
        firstByte = state.peekUInt8()

        if (!(firstByte & 0x80))
            state._offset++
            return firstByte
        else if (!(firstByte & 0x40))
            return state.readUInt16() - 0x8000
        else if (!(firstByte & 0x20))
            return state.readUInt32() - 0xc0000000
        else
            return (state.readUInt32() - 0xe0000000) * POW_32 + state.readUInt32()
}
# Same format as uint
module.exports.int = {
    write: (ix, data, path) ->
        # Check the input
        if (Math.round(ix) != ix || ix > MAX_DOUBLE_INT || ix < -MAX_DOUBLE_INT)
            throw new TypeError('Expected signed integer at ' + path + ', got ' + ix)

        if (ix >= -MAX_INT8 && ix < MAX_INT8)
            data.writeUInt8(ix & 0x7f)
        else if (ix >= -MAX_INT16 && ix < MAX_INT16)
            data.writeUInt16((ix & 0x3fff) + 0x8000)
        else if (ix >= -MAX_INT32 && ix < MAX_INT32)
            data.writeUInt32((ix & 0x1fffffff) + 0xc0000000)
        else
            # Split in two 32b uints
            data.writeUInt32((Math.floor(ix / POW_32) & 0x1fffffff) + 0xe0000000)
            data.writeUInt32(ix >>> 0)

    read: (state) ->
        firstByte = state.peekUInt8()

        if (!(firstByte & 0x80))
            state._offset++
            return if (firstByte & 0x40) then (firstByte | 0xffffff80) else firstByte
        else if (!(firstByte & 0x40))
            ix = state.readUInt16() - 0x8000
            return if (ix & 0x2000) then (ix | 0xffffc000) else ix
        else if (!(firstByte & 0x20))
            ix = state.readUInt32() - 0xc0000000
            return if (ix & 0x10000000) then (ix | 0xe0000000) else ix
        else
            ix = state.readUInt32() - 0xe0000000
            ix = if (ix & 0x10000000) then (ix | 0xe0000000) else ix
            return ix * POW_32 + state.readUInt32()
}
# 64bit double
module.exports.float = {
    write: (f, data, path) ->
        if (typeof f != 'number')
            throw new TypeError('Expected a number at ' + path + ', got ' + f)

        data.writeDouble(f)

    read: (state) ->
        return state.readDouble()
}

# 64bit double alternate
module.exports.number = {
    write: (f, data, path) ->
        if (typeof f != 'number')
            throw new TypeError('Expected a number at ' + path + ', got ' + f)

        data.writeDouble(f)

    read: (state) ->
        return state.readDouble()
}

# <uint_length> <buffer_data>
module.exports.string = {
    write: (s, data, path) ->
        if (typeof s != 'string')
            throw new TypeError('Expected a string at ' + path + ', got ' + s)

        exports.Buffer.write(new Buffer(s), data, path)

    read: (state) ->
        return exports.Buffer.read(state).toString()
}
# <uint_length> <buffer_data>
module.exports.Buffer = {
    write: (B, data, path) ->
        if (!Buffer.isBuffer(B))
            throw new TypeError('Expected a Buffer at ' + path + ', got ' + B)

        exports.uint.write(B.length, data, path)
        data.appendBuffer(B)

    read: (state) ->
        length = exports.uint.read(state)
        return state.readBuffer(length)
}
# either 0x00 or 0x01
module.exports.boolean = {
    write: (b, data, path) ->
        if (typeof b != 'boolean')
            throw new TypeError('Expected a boolean at ' + path + ', got ' + b)

        data.writeUInt8(b ? 1: 0)

    read: (state) ->
        b = state.readUInt8()
        if (b > 1)
            throw new Error('Invalid boolean value')

        return Boolean(b)
}
# <uint_length> <buffer_data>
module.exports.json = {
    write: (j, data, path) ->
        exports.string.write(JSON.stringify(j), data, path)

    read: (state) ->
        return JSON.parse(exports.string.read(state))
}
# <12B_buffer_data>
module.exports.oid = {
    write: (o, data, path) ->
        buffer = new Buffer(String(o), 'hex')
        if (buffer.length != 12)
            throw new TypeError('Expected an object id (12 bytes) at ' + path + ', got ' + o)

        data.appendBuffer(buffer)

    read: (state) ->
        return state.readBuffer(12).toString('hex')
}
# <uint_source_length> <buffer_source_data> <flags>
# flags is a bit-mask: g=1, i=2, m=4
module.exports.regex = {
    write: (r, data, path) ->
        if (!(r instanceof RegExp))
            throw new TypeError('Expected an instance of RegExp at ' + path + ', got ' + r)

        exports.string.write(r.source, data, path)
        g = if r.global then 1 else 0
        i = if r.ignoreCase then 2 else 0
        m = if r.multiline then 4 else 0
        data.writeUInt8(g + i + m)

    read: (state) ->
        source = exports.string.read(state)
        flags = state.readUInt8()
        g = if flags & 0x1 then 'g' else ''
        i = if flags & 0x2 then 'i' else ''
        m = if flags & 0x4 then 'm' else ''
        return new RegExp(source, g + i + m)
}
# <uint_time_ms>
module.exports.date = {
    write: (d, data, path) ->
        if (!(d instanceof Date))
            throw new TypeError('Expected an instance of Date at ' + path + ', got ' + d)
        else if (isNaN(d.getTime()))
            throw new TypeError('Expected a valid Date at ' + path + ', got ' + d)

        exports.uint.write(d.getTime(), data, path)

    read: (state) ->
        return new Date(exports.uint.read(state))
}