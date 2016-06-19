
module.exports = class Field
    constructor: (name, type) ->
        @optional = false
        if (name[name.length - 1] == '?')
            @optional = true
            name = name.substr(0, name.length - 1)

        # @member {string} *
        @name = name

        # @member {boolean}
        @array = Array.isArray(type)

        if (@array)
            if (type.length != 1)
                throw new TypeError('Invalid array type, it must have exactly one element')

            type = type[0]

        # @member {Type}
        @type = new Type(type)

    Type = require './Type'

