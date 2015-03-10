# @cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;
# @escapable = /[\\\"\u0000-\u001f\u007f-\u009f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;

#        @meta = {    # table of character substitutions
#                '\b': '\\b',
#                '\t': '\\t',
#                '\n': '\\n',
#                '\f': '\\f',
#                '\r': '\\r',
#                '"': '\\"',
#                '\\': '\\\\'
#        }
# This method produces a IOTON text from a JavaScript value.
#
#    value       any JavaScript value, usually an object or array.
#
#    When an object value is found, if the object contains a toJSON
#    method, its toIOTON method will be called and the result will be
#    stringified. A toJSON method does not serialize: it returns the
#    value represented by the name/value pair that should be serialized,
#    or undefined if nothing should be serialized. The toJSON method
#    will be passed the key associated with the value, and this will be
#    bound to the value
#

#    replace = (replacer, value) ->
#        if replacer?
#            if typeof replacer is 'string'
#                return replacer
#            else if typeof replacer is 'function'
#                return replacer.call(value)
#        return value

