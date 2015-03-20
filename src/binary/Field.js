// Generated by CoffeeScript 1.8.0
(function() {
  var Field;

  module.exports = Field = (function() {
    var Type;

    function Field(name, type) {
      this.optional = false;
      if (name[name.length - 1] === '?') {
        this.optional = true;
        name = name.substr(0, name.length - 1);
      }
      this.name = name;
      this.array = Array.isArray(type);
      if (this.array) {
        if (type.length !== 1) {
          throw new TypeError('Invalid array type, it must have exactly one element');
        }
        type = type[0];
      }
      this.type = new Type(type);
    }

    Type = require('./Type');

    return Field;

  })();

}).call(this);

//# sourceMappingURL=Field.js.map