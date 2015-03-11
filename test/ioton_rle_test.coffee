assert = require('assert')
should = require('should')
ioton = require('../src/ioton/ioton')

describe 'IOTON Run Length Encoding', ->

    IOTON = new ioton()

    it 'It can Stringify with RLE and Parse array of strings', (done) ->
        IOTON.reset()

        object = ["one", "two", "three", "four", "five", "six"]
        schema = ["", "string"]
        ioton = IOTON.stringify(object)

        object = IOTON.parse(ioton, schema)
        object.should.not.be.null
        object.should.be.array
        object[0].should.be.string
        object[0].should.be.equal("one")
        object[1].should.be.string
        object[1].should.be.equal("two")
        object[2].should.be.string
        object[2].should.be.equal("three")

        object = ["one", "two", "seven", "four", "five", "six"]
        ioton = IOTON.stringify(object)
        ioton.toString().should.be.equal("\u0002\u001d\u000fseven\u001c\u0003")

        console.log(ioton.toString())
        object = IOTON.parse(ioton, schema)
        #TODO:: Asserts for parse of rle string.

        done()

    it 'It can Stringify with RLE and Parse object', (done) ->
        IOTON.reset()

        object = {one: "one", two: "two", three: "three", four: "four", five: "five", six: "six"}
        schema = ["one", "string", "two", "string", "three", "string", "four", "string", "five", "string", "six", "string"]

        ioton = IOTON.stringify(object)
        ioton.length.should.be.equal(35)
        ioton.toString().should.be.equal("\u0001\u000Fone\u001F\u000Ftwo\u001F\u000Fthree\u001F\u000Ffour\u001F\u000Ffive\u001F\u000Fsix\u0004")

        object = IOTON.parse(ioton, schema)
        object.should.not.be.null
        object.should.be.object
        object.one.should.be.string
        object.one.should.be.equal("one")
        object.two.should.be.string
        object.two.should.be.equal("two")
        object.three.should.be.string
        object.three.should.be.equal("three")
        object.four.should.be.string
        object.four.should.be.equal("four")
        object.five.should.be.string
        object.five.should.be.equal("five")
        object.six.should.be.string
        object.six.should.be.equal("six")

        object = {one: "one", two: "two", three: "seven", four: "four", five: "five", six: "six"}

        ioton = IOTON.stringify(object)
        ioton.length.should.be.equal(10)
        ioton.toString().should.be.equal("\u0001\u001d\u000fseven\u001c\u0004")

        object = IOTON.parse(ioton, schema)
        #TODO:: Asserts for parse of rle string.

        done()

    it 'It can do run length encoding', (done) ->
        IOTON.reset()
        object = {
            field1: "stuff"
            field2: 2
            field3: true
            field4: undefined
            field5: null
            field6: ["element1", 1, false, null]
            field26: {field15: "string", field16: 100}
        }
        schema = [
            "field1", "string",
            "field2", "number",
            "field3", "boolean",
            "field4", "boolean",
            "field5", "string",
            "field6", ["", "typed"],
            "field26", [ "field15", "string", "field16", "number" ]
        ]

        ioton = IOTON.stringify(object)
        ioton.length.should.be.equal(48)
        ioton.toString().should.be.equal("\u0001\u000Fstuff\u001F2\u001FT\u001F\u0019\u001F\u0019\u001F\u0002\u000Felement1\u001F1\u001FF\u001F\u0019\u0003\u001F\u0001\u000Fstring\u001F100\u0004\u0004")

        object = IOTON.parse(ioton, schema)
        object.should.not.be.null
        object.field1.should.be.string
        object.field1.should.be.equal("stuff")
        object.field2.should.be.number
        object.field2.should.be.equal(2)
        object.field3.should.be.boolean
        object.field3.should.be.equal(true)
        (object.field4 is null).should.be.true
        (object.field5 is null).should.be.true
        object.field6.should.be.array
        object.field6[0].should.be.equal("element1")
        object.field6[1].should.be.equal(1)
        object.field6[2].should.be.equal(false)
        (object.field6[3] is null).should.be.true
        object.field26.should.be.object

        ioton = IOTON.stringify(object)
        ioton.length.should.be.equal(14)
        ioton.toString().should.be.equal("\u0001\u001c\u0019\u001e\u0002\u001a3\u001f\u0003\u001f\u0001\u001d\u0004\u0004")

        object = IOTON.parse(ioton, schema)
        #TODO:: Asserts for parse of rle string.

        object = {
            field1: "stuff"
            field2: 2
            field3: true
            field4: "thing"
            field5: "stuff"
            field6: ["element1", 1, false, null]
            field26: {field15: "string", field16: 100}
        }
        schema = [
            "field1", "string",
            "field2", "number",
            "field3", "boolean",
            "field4", "boolean",
            "field5", "string",
            "field6", ["", "typed"],
            "field26", [ "field15", "string", "field16", "number" ]
        ]

        ioton = IOTON.stringify(object)
        ioton.length.should.be.equal(26)
        ioton.toString().should.be.equal("\u0001\u001c\u000fthing\u001f\u000fstuff\u001f\u0002\u001a3\u001f\u0003\u001f\u0001\u001d\u0004\u0004")

        object = IOTON.parse(ioton, schema)
        #TODO:: Asserts for parse of rle string.

        done()