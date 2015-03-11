// Generated by CoffeeScript 1.8.0
(function() {
  var assert, ioton, should;

  assert = require('assert');

  should = require('should');

  ioton = require('../src/ioton/ioton');

  describe('IOTON', function() {
    var IOTON;
    IOTON = new ioton();
    it('It can Stringify but not Parse string', function(done) {
      var object, schema;
      IOTON.reset();
      object = "hello world";
      schema = ["string"];
      ioton = IOTON.stringify(object);
      ioton.toString().should.be.equal('\u000fhello world');
      IOTON.parse.bind(null, ioton, schema).should["throw"]();
      return done();
    });
    it('It can Stringify but not Parse number', function(done) {
      var object, schema;
      IOTON.reset();
      object = 666;
      schema = ["number"];
      ioton = IOTON.stringify(object);
      ioton.toString().should.be.equal('666');
      IOTON.parse.bind(null, ioton, schema).should["throw"]();
      return done();
    });
    it('It can Stringify but not Parse boolean', function(done) {
      var object, schema;
      IOTON.reset();
      object = true;
      schema = ["boolean"];
      ioton = IOTON.stringify(object);
      ioton.toString().should.be.equal('T');
      IOTON.parse.bind(null, ioton, schema).should["throw"]();
      object = false;
      schema = ["boolean"];
      ioton = IOTON.stringify(object);
      ioton.toString().should.be.equal('F');
      IOTON.parse.bind(null, ioton, schema).should["throw"]();
      return done();
    });
    it('It can Stringify but not Parse null', function(done) {
      var object, schema;
      IOTON.reset();
      object = null;
      schema = ["boolean"];
      ioton = IOTON.stringify(object);
      IOTON.parse.bind(null, ioton, schema).should["throw"]();
      return done();
    });
    it('It can PARSE array of strings', function(done) {
      var object, schema;
      IOTON.reset();
      object = ["one", "two", "three"];
      schema = ["", "string"];
      ioton = IOTON.stringify(object);
      object = IOTON.parse(ioton, schema);
      object.should.not.be["null"];
      object.should.be.array;
      object[0].should.be.string;
      object[0].should.be.equal("one");
      object[1].should.be.string;
      object[1].should.be.equal("two");
      object[2].should.be.string;
      object[2].should.be.equal("three");
      return done();
    });
    it('It can PARSE array of numbers', function(done) {
      var object, schema;
      IOTON.reset();
      object = [1, 2, 4];
      schema = ["", "number"];
      ioton = IOTON.stringify(object);
      object = IOTON.parse(ioton, schema);
      object.should.not.be["null"];
      object.should.be.array;
      object[0].should.be.number;
      object[0].should.be.equal(1);
      object[1].should.be.number;
      object[1].should.be.equal(2);
      object[2].should.be.number;
      object[2].should.be.equal(4);
      return done();
    });
    it('It can PARSE array of booleans', function(done) {
      var object, schema;
      IOTON.reset();
      object = [true, true, false];
      schema = ["", "boolean"];
      ioton = IOTON.stringify(object);
      object = IOTON.parse(ioton, schema);
      object.should.not.be["null"];
      object.should.be.array;
      object[0].should.be.boolean;
      object[0].should.be.equal(true);
      object[1].should.be.boolean;
      object[1].should.be.equal(true);
      object[2].should.be.boolean;
      object[2].should.be.equal(false);
      return done();
    });
    it('It can PARSE array of typed', function(done) {
      var object, schema;
      IOTON.reset();
      object = [1, true, "purpose"];
      schema = ["", "typed"];
      ioton = IOTON.stringify(object);
      object = IOTON.parse(ioton, schema);
      object.should.not.be["null"];
      object.should.be.array;
      object[0].should.be.number;
      object[0].should.be.equal(1);
      object[1].should.be.boolean;
      object[1].should.be.equal(true);
      object[2].should.be.string;
      object[2].should.be.equal("purpose");
      return done();
    });
    it('It can PARSE object', function(done) {
      var object, schema;
      IOTON.reset();
      object = {
        field1: "stuff",
        field2: 2,
        field3: true,
        field4: null,
        field5: null,
        field6: ["element1", 1, false, null],
        field26: {
          field15: "string",
          field16: 100
        }
      };
      schema = ["field1", "string", "field2", "number", "field3", "boolean", "field4", "boolean", "field5", "string", "field6", ["", "typed"], "field26", ["field15", "string", "field16", "number"]];
      ioton = IOTON.stringify(object);
      object = IOTON.parse(ioton, schema);
      object.should.not.be["null"];
      object.field1.should.be.string;
      object.field1.should.be.equal("stuff");
      object.field2.should.be.number;
      object.field2.should.be.equal(2);
      object.field3.should.be.boolean;
      object.field3.should.be.equal(true);
      (object.field4 === null).should.be["true"];
      (object.field5 === null).should.be["true"];
      object.field6.should.be.array;
      object.field6[0].should.be.equal("element1");
      object.field6[1].should.be.equal(1);
      object.field6[2].should.be.equal(false);
      (object.field6[3] === null).should.be["true"];
      object.field26.should.be.object;
      return done();
    });
    it('It can PARSE array of arrays', function(done) {
      var field, object, schema, _i, _len, _ref;
      IOTON.reset();
      console.log("Schema 1:" + JSON.stringify(schema));
      object = {
        field1: [[4, 5, 6], [1, 4], [[7], [8]]]
      };
      schema = ["field1", ["", ["", "number"]]];
      console.log("Schema:" + JSON.stringify(schema));
      ioton = IOTON.stringify(object);
      object = IOTON.parse(ioton, schema);
      object.should.not.be["null"];
      object.field1.should.be.array;
      _ref = object.field1;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        field = _ref[_i];
        field.should.be.array;
      }
      object.field1[0][0].should.be.equal(4);
      object.field1[0][1].should.be.equal(5);
      object.field1[0][2].should.be.equal(6);
      object.field1[1][0].should.be.equal(1);
      object.field1[1][1].should.be.equal(4);
      object.field1[2][0].should.be.array;
      object.field1[2][0][0].should.be.equal(7);
      object.field1[2][1][0].should.be.equal(8);
      return done();
    });
    it('It can PARSE array of arrays, mismatched schema', function(done) {
      var field, object, schema, _i, _len, _ref;
      IOTON.reset();
      object = {
        field1: [[4, 5, 6], [1, 4], [[[[[[[[7]]]]]]], [8]]]
      };
      schema = ["field1", ["", ["", "number"]]];
      console.log("Schema:" + JSON.stringify(schema));
      ioton = IOTON.stringify(object);
      object = IOTON.parse(ioton, schema);
      object.should.not.be["null"];
      object.field1.should.be.array;
      _ref = object.field1;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        field = _ref[_i];
        field.should.be.array;
      }
      object.field1[0][0].should.be.equal(4);
      object.field1[0][1].should.be.equal(5);
      object.field1[0][2].should.be.equal(6);
      object.field1[1][0].should.be.equal(1);
      object.field1[1][1].should.be.equal(4);
      object.field1[2][0].should.be.array;
      object.field1[2][0][0].should.be.array;
      object.field1[2][0][0][0].should.be.array;
      object.field1[2][0][0][0][0].should.be.array;
      object.field1[2][0][0][0][0][0].should.be.array;
      object.field1[2][0][0][0][0][0][0].should.be.array;
      object.field1[2][0][0][0][0][0][0][0].should.be.array;
      object.field1[2][0][0][0][0][0][0][0][0].should.be.equal(7);
      object.field1[2][1][0].should.be.equal(8);
      return done();
    });
    it('It cannot properly PARSE object with array of mismatched objects', function(done) {
      var field, object, schema, _i, _len, _ref;
      IOTON.reset();
      console.log("Schema 1:" + JSON.stringify(schema));
      object = {
        field3: [
          {
            field17: "goop",
            field18: true
          }, {
            field20: false,
            field21: 1
          }
        ]
      };
      schema = ["field3", ["", ["field17", "string", "field18", "boolean"]]];
      console.log("Schema:" + JSON.stringify(schema));
      ioton = IOTON.stringify(object);
      object = IOTON.parse(ioton, schema);
      object.should.not.be["null"];
      object.field3.should.be.array;
      _ref = object.field3;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        field = _ref[_i];
        field.should.be.object;
      }
      object.field3[0].field17.should.be.equal("goop");
      object.field3[0].field18.should.be.equal(true);
      object.field3[1].field17.should.be.equal("F");
      (object.field3[1].field18 === null).should.be["true"];
      return done();
    });
    it('It can PARSE object with arrays of objects', function(done) {
      var field, object, schema, _i, _j, _len, _len1, _ref, _ref1;
      IOTON.reset();
      console.log("Schema 1:" + JSON.stringify(schema));
      object = {
        field1: [
          {
            field15: "baff",
            field16: 100
          }, {
            field15: "zap",
            field16: 101
          }, {
            field15: "biff",
            field16: 102
          }
        ],
        field2: [
          {
            field17: "hello",
            field18: true
          }, {
            field17: "world",
            field18: false
          }
        ],
        field3: [
          {
            field20: true,
            field21: 1
          }, {
            field20: false,
            field21: 1
          }
        ]
      };
      schema = ["field1", ["", ["field15", "string", "field16", "number"]], "field2", ["", ["field17", "string", "field18", "boolean"]], "field3", ["", ["field20", "boolean", "field21", "number"]]];
      console.log("Schema:" + JSON.stringify(schema));
      ioton = IOTON.stringify(object);
      object = IOTON.parse(ioton, schema);
      object.should.not.be["null"];
      object.field1.should.be.array;
      object.field2.should.be.array;
      _ref = object.field1;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        field = _ref[_i];
        field.should.be.object;
      }
      _ref1 = object.field2;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        field = _ref1[_j];
        field.should.be.object;
      }
      object.field1[0].field15.should.be.equal("baff");
      object.field1[0].field16.should.be.equal(100);
      object.field1[1].field15.should.be.equal("zap");
      object.field1[1].field16.should.be.equal(101);
      object.field1[2].field15.should.be.equal("biff");
      object.field1[2].field16.should.be.equal(102);
      object.field2[0].field17.should.be.equal("hello");
      object.field2[0].field18.should.be.equal(true);
      object.field2[1].field17.should.be.equal("world");
      object.field2[1].field18.should.be.equal(false);
      object.field3[0].field20.should.be.equal(true);
      object.field3[0].field21.should.be.equal(1);
      object.field3[1].field20.should.be.equal(false);
      object.field3[1].field21.should.be.equal(1);
      return done();
    });
    return it('It can Stringify and Parse a complex object', function(done) {
      var i, object, schema, test, _i, _ref;
      IOTON.reset();
      object = {
        field1: "string",
        field2: 2,
        field3: true,
        field4: void 0,
        field5: null,
        field6: ["element1", 1, true, null],
        field26: {
          field15: "string",
          field16: 100
        },
        field7: {
          field8: "value8",
          field9: 9,
          field10: false,
          field11: null,
          field12: [1, 2, 3],
          field13: [true, false, true],
          field14: {
            field15: "string",
            field16: 100
          }
        },
        field17: [true, false],
        field18: [[4, 5, 6], [1, 4], [7, 8]],
        field19: {
          field20: "string",
          field21: 9
        },
        field22: true,
        field23: [
          {
            field24: "string",
            field25: "number"
          }, {
            field24: "hello",
            field25: "there"
          }
        ]
      };
      schema = ["field1", "string", "field2", "number", "field3", "boolean", "field4", "boolean", "field5", "string", "field6", ["", "typed"], "field26", ["field15", "string", "field16", "number"], "field7", ["field8", "string", "field9", "number", "field10", "boolean", "field11", "string", "field12", ["", "number"], "field13", ["", "boolean"], "field14", ["field15", "string", "field16", "number"]], "field17", ["", "boolean"], "field18", ["", ["", "number"]], "field19", ["field20", "string", "field21", "number"], "field22", "boolean", "field23", ["", ["field24", "string", "field25", "number"]]];
      console.log("Schema:" + JSON.stringify(schema) + "\n");
      ioton = IOTON.stringify(object);
      test = new Buffer("\u0001\u000Fstring\u001F2\u001FT\u001F\u0019\u001F\u0019\u001F\u0002\u000Felement1\u001F1\u001FT\u001F\u0019\u0003\u001F\u0001\u000Fstring\u001F100\u0004\u001F\u0001\u000Fvalue8\u001F9\u001FF\u001F\u0019\u001F\u00021\u001F2\u001F3\u0003\u001F\u0002T\u001FF\u001FT\u0003\u001F\u0001\u000Fstring\u001F100\u0004\u0004\u001F\u0002T\u001FF\u0003\u001F\u0002\u00024\u001F5\u001F6\u0003\u001F\u00021\u001F4\u0003\u001F\u00027\u001F8\u0003\u0003\u001F\u0001\u000Fstring\u001F9\u0004\u001FT\u001F\u0002\u0001\u000Fstring\u001F\u000Fnumber\u0004\u001F\u0001\u000Fhello\u001F\u000Fthere\u0004\u0003\u0004", "ascii");
      for (i = _i = 0, _ref = test.length; _i < _ref; i = _i += 1) {
        console.log("Expect:" + test[i] + " Got:" + ioton[i]);
        ioton[i].should.equal(test[i]);
      }
      ioton.toString().should.equal(test.toString());
      object = IOTON.parse(ioton, schema);
      object.should.not.be["null"];
      return done();
    });
  });

}).call(this);

//# sourceMappingURL=ioton_test.js.map
