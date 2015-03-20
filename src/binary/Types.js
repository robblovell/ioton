// Generated by CoffeeScript 1.8.0
(function() {
  var MAX_DOUBLE_INT, MAX_INT16, MAX_INT32, MAX_INT8, MAX_UINT16, MAX_UINT32, MAX_UINT8, POW, POW_32, i, n;

  n = 1;

  POW = [1].concat((function() {
    var _i, _results;
    _results = [];
    for (i = _i = 0; _i <= 56; i = ++_i) {
      _results.push(n *= 2);
    }
    return _results;
  })());

  MAX_DOUBLE_INT = POW[53];

  MAX_UINT8 = POW[7];

  MAX_UINT16 = POW[14];

  MAX_UINT32 = POW[29];

  MAX_INT8 = POW[6];

  MAX_INT16 = POW[13];

  MAX_INT32 = POW[28];

  POW_32 = POW[32];

  module.exports.uint = {
    write: function(u, data, path) {
      if (Math.round(u) !== u || u > MAX_DOUBLE_INT || u < 0) {
        throw new TypeError('Expected unsigned integer at ' + path + ', got ' + u);
      }
      if (u < MAX_UINT8) {
        return data.writeUInt8(u);
      } else if (u < MAX_UINT16) {
        return data.writeUInt16(u + 0x8000);
      } else if (u < MAX_UINT32) {
        return data.writeUInt32(u + 0xc0000000);
      } else {
        data.writeUInt32(Math.floor(u / POW_32) + 0xe0000000);
        return data.writeUInt32(u >>> 0);
      }
    },
    read: function(state) {
      var firstByte;
      firstByte = state.peekUInt8();
      if (!(firstByte & 0x80)) {
        state._offset++;
        return firstByte;
      } else if (!(firstByte & 0x40)) {
        return state.readUInt16() - 0x8000;
      } else if (!(firstByte & 0x20)) {
        return state.readUInt32() - 0xc0000000;
      } else {
        return (state.readUInt32() - 0xe0000000) * POW_32 + state.readUInt32();
      }
    }
  };

  module.exports.int = {
    write: function(ix, data, path) {
      if (Math.round(ix) !== ix || ix > MAX_DOUBLE_INT || ix < -MAX_DOUBLE_INT) {
        throw new TypeError('Expected signed integer at ' + path + ', got ' + ix);
      }
      if (ix >= -MAX_INT8 && ix < MAX_INT8) {
        return data.writeUInt8(ix & 0x7f);
      } else if (ix >= -MAX_INT16 && ix < MAX_INT16) {
        return data.writeUInt16((ix & 0x3fff) + 0x8000);
      } else if (ix >= -MAX_INT32 && ix < MAX_INT32) {
        return data.writeUInt32((ix & 0x1fffffff) + 0xc0000000);
      } else {
        data.writeUInt32((Math.floor(ix / POW_32) & 0x1fffffff) + 0xe0000000);
        return data.writeUInt32(ix >>> 0);
      }
    },
    read: function(state) {
      var firstByte, ix;
      firstByte = state.peekUInt8();
      if (!(firstByte & 0x80)) {
        state._offset++;
        if (firstByte & 0x40) {
          return firstByte | 0xffffff80;
        } else {
          return firstByte;
        }
      } else if (!(firstByte & 0x40)) {
        ix = state.readUInt16() - 0x8000;
        if (ix & 0x2000) {
          return ix | 0xffffc000;
        } else {
          return ix;
        }
      } else if (!(firstByte & 0x20)) {
        ix = state.readUInt32() - 0xc0000000;
        if (ix & 0x10000000) {
          return ix | 0xe0000000;
        } else {
          return ix;
        }
      } else {
        ix = state.readUInt32() - 0xe0000000;
        ix = ix & 0x10000000 ? ix | 0xe0000000 : ix;
        return ix * POW_32 + state.readUInt32();
      }
    }
  };

  module.exports.float = {
    write: function(f, data, path) {
      if (typeof f !== 'number') {
        throw new TypeError('Expected a number at ' + path + ', got ' + f);
      }
      return data.writeDouble(f);
    },
    read: function(state) {
      return state.readDouble();
    }
  };

  module.exports.number = {
    write: function(f, data, path) {
      if (typeof f !== 'number') {
        throw new TypeError('Expected a number at ' + path + ', got ' + f);
      }
      return data.writeDouble(f);
    },
    read: function(state) {
      return state.readDouble();
    }
  };

  module.exports.string = {
    write: function(s, data, path) {
      if (typeof s !== 'string') {
        throw new TypeError('Expected a string at ' + path + ', got ' + s);
      }
      return exports.Buffer.write(new Buffer(s), data, path);
    },
    read: function(state) {
      return exports.Buffer.read(state).toString();
    }
  };

  module.exports.Buffer = {
    write: function(B, data, path) {
      if (!Buffer.isBuffer(B)) {
        throw new TypeError('Expected a Buffer at ' + path + ', got ' + B);
      }
      exports.uint.write(B.length, data, path);
      return data.appendBuffer(B);
    },
    read: function(state) {
      var length;
      length = exports.uint.read(state);
      return state.readBuffer(length);
    }
  };

  module.exports.boolean = {
    write: function(b, data, path) {
      if (typeof b !== 'boolean') {
        throw new TypeError('Expected a boolean at ' + path + ', got ' + b);
      }
      return data.writeUInt8(b != null ? b : {
        1: 0
      });
    },
    read: function(state) {
      var b;
      b = state.readUInt8();
      if (b > 1) {
        throw new Error('Invalid boolean value');
      }
      return Boolean(b);
    }
  };

  module.exports.json = {
    write: function(j, data, path) {
      return exports.string.write(JSON.stringify(j), data, path);
    },
    read: function(state) {
      return JSON.parse(exports.string.read(state));
    }
  };

  module.exports.oid = {
    write: function(o, data, path) {
      var buffer;
      buffer = new Buffer(String(o), 'hex');
      if (buffer.length !== 12) {
        throw new TypeError('Expected an object id (12 bytes) at ' + path + ', got ' + o);
      }
      return data.appendBuffer(buffer);
    },
    read: function(state) {
      return state.readBuffer(12).toString('hex');
    }
  };

  module.exports.regex = {
    write: function(r, data, path) {
      var g, m;
      if (!(r instanceof RegExp)) {
        throw new TypeError('Expected an instance of RegExp at ' + path + ', got ' + r);
      }
      exports.string.write(r.source, data, path);
      g = r.global ? 1 : 0;
      i = r.ignoreCase ? 2 : 0;
      m = r.multiline ? 4 : 0;
      return data.writeUInt8(g + i + m);
    },
    read: function(state) {
      var flags, g, m, source;
      source = exports.string.read(state);
      flags = state.readUInt8();
      g = flags & 0x1 ? 'g' : '';
      i = flags & 0x2 ? 'i' : '';
      m = flags & 0x4 ? 'm' : '';
      return new RegExp(source, g + i + m);
    }
  };

  module.exports.date = {
    write: function(d, data, path) {
      if (!(d instanceof Date)) {
        throw new TypeError('Expected an instance of Date at ' + path + ', got ' + d);
      } else if (isNaN(d.getTime())) {
        throw new TypeError('Expected a valid Date at ' + path + ', got ' + d);
      }
      return exports.uint.write(d.getTime(), data, path);
    },
    read: function(state) {
      return new Date(exports.uint.read(state));
    }
  };

}).call(this);

//# sourceMappingURL=Types.js.map
