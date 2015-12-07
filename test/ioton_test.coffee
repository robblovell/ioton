assert = require('assert')
should = require('should')
Ioton = require('../src/Ioton')
Bioton = require('../src/Bioton')


Type = require('../src/binary/Type')

describe 'IOTON', ->

    IOTON = new Ioton()

    it 'It can Stringify and Parse string', (done) ->
        IOTON.reset()
        object = "hello world"
        schema =  "string"

        console.log(Type.TYPE)

        iotonStr = IOTON.stringify(object)
        iotonStr.toString().should.be.equal('\u000fhello world')
        json = JSON.stringify(object)
        objectOut = IOTON.parse(iotonStr, schema)
        objectOut.should.be.equal(object)

        BIOTON = new Bioton('string')
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)
        console.log("string        savings-> binary: "+((100-100*encoded.length/json.length)).toPrecision(2)+"% "+" ioton:"+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"binary length:"+encoded.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")
        done()

    it 'It can Stringify and Parse int number', () ->
        IOTON.reset()
        object = -666
        schema =  "number"
        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)
        iotonStr.toString().should.be.equal('-666')
        objectOut = IOTON.parse(iotonStr, schema)
        objectOut.should.be.equal(object)

        BIOTON = new Bioton('int')
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)
        console.log("int           savings-> binary: "+((100-100*encoded.length/json.length)).toPrecision(2)+"% "+" ioton:"+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"binary length:"+encoded.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

    it 'It can Stringify and Parse float number', (done) ->

        IOTON.reset()
        object = 666.66
        schema =  "number"
        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)
        iotonStr.toString().should.be.equal('666.66')
        objectOut = IOTON.parse(iotonStr, schema)
        objectOut.should.be.equal(object)

        BIOTON = new Bioton('number')
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)
        console.log("float         savings-> binary: "+((100-100*encoded.length/json.length)).toPrecision(2)+"% "+" ioton:"+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"binary length:"+encoded.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

        done()

    it 'It can Stringify and Parse boolean', (done) ->
        IOTON.reset()
        object = true
        schema =  "boolean"
        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)

        iotonStr.toString().should.be.equal('T')
        objectOut = IOTON.parse(iotonStr, schema)
        objectOut.should.be.equal(object)

        BIOTON = new Bioton('boolean')
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)
        console.log("boolean true  savings-> binary: "+((100-100*encoded.length/json.length)).toPrecision(2)+"% "+" ioton:"+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"binary length:"+encoded.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")


        object = false
        schema = "boolean"
        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)
        iotonStr.toString().should.be.equal('F')
        objectOut = IOTON.parse(iotonStr, schema)
        objectOut.should.be.equal(object)

        BIOTON = new Bioton('boolean')
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)
        console.log("boolean false savings-> binary: "+((100-100*encoded.length/json.length)).toPrecision(2)+"% "+" ioton:"+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"binary length:"+encoded.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

        done()

    it 'It can Stringify but not Parse null', (done) ->
        IOTON.reset()
        object = null
        schema =  "boolean"
        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)
        console.log("savings-> "+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")
        objectOut = IOTON.parse(iotonStr, schema)
        (objectOut==object).should.be.true

        done()

    it 'It can PARSE array of strings', (done) ->
        IOTON.reset()
        object = ["one", "two", "three"]
        schema = ['string']
        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)

        object = IOTON.parse(iotonStr, schema)
        object.should.not.be.null
        object.should.be.array
        object[0].should.be.string
        object[0].should.be.equal("one")
        object[1].should.be.string
        object[1].should.be.equal("two")
        object[2].should.be.string
        object[2].should.be.equal("three")

        BIOTON = new Bioton(['string'])
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)
        console.log("[ strings ]   savings-> binary: "+((100-100*encoded.length/json.length)).toPrecision(2)+"% "+" ioton:"+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"binary length:"+encoded.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

        done()

    it 'It can PARSE array of numbers', (done) ->
        IOTON.reset()
        object = [1, 2, 4]
        schema = ["number"]
        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)

        object = IOTON.parse(iotonStr, schema)
        object.should.not.be.null
        object.should.be.array
        object[0].should.be.number
        object[0].should.be.equal(1)
        object[1].should.be.number
        object[1].should.be.equal(2)
        object[2].should.be.number
        object[2].should.be.equal(4)

        BIOTON = new Bioton(['int'])
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)
        console.log("[ int ]       savings-> binary: "+((100-100*encoded.length/json.length)).toPrecision(2)+"% "+" ioton:"+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"binary length:"+encoded.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

        done()

    it 'It can PARSE array of booleans', (done) ->
        IOTON.reset()
        object = [true, true, false]
        schema = ["boolean"]
        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)

        object = IOTON.parse(iotonStr, schema)
        object.should.not.be.null
        object.should.be.array
        object[0].should.be.boolean
        object[0].should.be.equal(true)
        object[1].should.be.boolean
        object[1].should.be.equal(true)
        object[2].should.be.boolean
        object[2].should.be.equal(false)

        BIOTON = new Bioton(['boolean'])
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)
        console.log("[ boolean ]   savings-> binary: "+((100-100*encoded.length/json.length)).toPrecision(2)+"% "+" ioton:"+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"binary length:"+encoded.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

        done()

    it 'It can PARSE array of dynamic', (done) ->
        IOTON.reset()
        object = [1, true, "purpose"]
        schema = ["dynamic"]
        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)
        console.log("savings-> "+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")
        object = IOTON.parse(iotonStr, schema)
        object.should.not.be.null
        object.should.be.array
        object[0].should.be.number
        object[0].should.be.equal(1)
        object[1].should.be.boolean
        object[1].should.be.equal(true)
        object[2].should.be.string
        object[2].should.be.equal("purpose")
        done()

    it 'It can PARSE object with strings fields', (done) ->
        IOTON.reset()
        object = {one: "one", two: "two", three: "three"}
        schema = {one: "string", two: "string", three: "string"}
        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)

        IOTON.schema({ one: 'string', two: 'string', three: 'string'})
        object = IOTON.parse(iotonStr, schema)
        object.should.not.be.null
        object.should.be.array
        object.one.should.be.string
        object.one.should.be.equal("one")
        object.two.should.be.string
        object.two.should.be.equal("two")
        object.three.should.be.string
        object.three.should.be.equal("three")

        BIOTON = new Bioton({ one: 'string', two: 'string', three: 'string'})
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)
        console.log("{ object }    savings-> binary: "+((100-100*encoded.length/json.length)).toPrecision(2)+"% "+" ioton:"+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"binary length:"+encoded.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

        done()

    it 'It can PARSE object', (done) ->

        object = {
            field1: "stuff"
            field2: 2
            field3: true
            field4: false
            field5: "hello there"
            field6: ["element1", "1", "false", "null"]
            field26: {field15: "string", field16: 100}
        }

        schema = {
            field1: "string"
            field2: 'uint'
            field3: 'boolean'
            field4: 'boolean'
            field5: 'string'
            field6: ["string"]
            field26: {field15: "string", field16: 'uint'}
        }

        IOTON.schema(schema)
        BIOTON = new Bioton(schema)

        IOTON.reset()
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)

        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)

        object = IOTON.parse(iotonStr, schema)
        object.should.not.be.null
        object.field1.should.be.string
        object.field1.should.be.equal("stuff")
        object.field2.should.be.number
        object.field2.should.be.equal(2)
        object.field3.should.be.boolean
        object.field3.should.be.equal(true)
        object.field4.should.be.equal(false)
        object.field5.should.be.equal("hello there")

        object.field6.should.be.array
        object.field6[0].should.be.equal("element1")
        object.field6[1].should.be.equal("1")
        object.field6[2].should.be.equal("false")
        object.field6[3].should.be.equal("null")
        object.field26.should.be.object

        object = {
            field1: "stuff"
            field2: 2
            field3: true
            field4: false
            field5: "more"
            field6: ["element1", '1', 'false', 'null']
            field26: {field15: "string", field16: 100}
        }
        BIOTON = new Bioton({
            field1: "string"
            field2: 'uint'
            field3: 'boolean'
            field4: 'boolean'
            field5: 'string'
            field6: ["string"]
            field26: {field15: "string", field16: 'uint'}
        })
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)
        console.log("{ object }    savings-> binary: "+((100-100*encoded.length/json.length)).toPrecision(2)+"% "+" ioton:"+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"binary length:"+encoded.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

        done()

    it 'It can PARSE array of arrays', (done) ->
        IOTON.reset()
        object = {
            field1: [ [4, 5, 6], [1, 4], [[7], [8]] ]
        }
        schema = { field1: [['int']]}
        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)

        object = IOTON.parse(iotonStr, schema)
        object.should.not.be.null
        object.field1.should.be.array
        field.should.be.array for field in object.field1
        object.field1[0][0].should.be.equal(4)
        object.field1[0][1].should.be.equal(5)
        object.field1[0][2].should.be.equal(6)
        object.field1[1][0].should.be.equal(1)
        object.field1[1][1].should.be.equal(4)
        object.field1[2][0].should.be.array
        object.field1[2][0][0].should.be.equal(7)
        object.field1[2][1][0].should.be.equal(8)

        object = {
            field1: [ [4, 5, 6], [1, 4], [7, 8] ]
        }
        BIOTON = new Bioton({ field1: [['int']]})
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)
        console.log("{ object }    savings-> binary: "+((100-100*encoded.length/json.length)).toPrecision(2)+"% "+" ioton:"+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"binary length:"+encoded.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

        done()

    it 'It can PARSE array of arrays, mismatched schema', (done) ->
        IOTON.reset()
        object = {
            field1: [ [4, 5, 6], [1, 4], [[[[[[[[7]]]]]]], [8]] ]
        }
        schema = {field1: [["number"]]}

        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)
        console.log("savings-> "+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

        object = IOTON.parse(iotonStr, schema)
        object.should.not.be.null
        object.field1.should.be.array
        field.should.be.array for field in object.field1
        object.field1[0][0].should.be.equal(4)
        object.field1[0][1].should.be.equal(5)
        object.field1[0][2].should.be.equal(6)
        object.field1[1][0].should.be.equal(1)
        object.field1[1][1].should.be.equal(4)
        object.field1[2][0].should.be.array
        object.field1[2][0][0].should.be.array
        object.field1[2][0][0][0].should.be.array
        object.field1[2][0][0][0][0].should.be.array
        object.field1[2][0][0][0][0][0].should.be.array
        object.field1[2][0][0][0][0][0][0].should.be.array
        object.field1[2][0][0][0][0][0][0][0].should.be.array
        object.field1[2][0][0][0][0][0][0][0][0].should.be.equal(7)
        object.field1[2][1][0].should.be.equal(8)
        done()

    it 'It cannot properly PARSE object with array of mismatched objects', (done) ->
        IOTON.reset()
        object = {
            field3: [ {field17: "goop", field18: true}, {field20: false, field21: 1} ]
        }
        schema = { field3: [{field17: "string", field18: "boolean"}]}

        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)
        console.log("savings-> "+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

        object = IOTON.parse(iotonStr, schema)
        object.should.not.be.null
        object.field3.should.be.array

        field.should.be.object for field in object.field3

        object.field3[0].field17.should.be.equal("goop")
        object.field3[0].field18.should.be.equal(true)
        # Degnerative cases:
        object.field3[1].field17.should.be.equal("F")
        (object.field3[1].field18 is null).should.be.true
        done()

    it 'It can PARSE object with arrays of objects', (done) ->
        IOTON.reset()
        object = {
            field1: [ {field15: "baff", field16: 100.0}, {field15: "zap", field16: 101.0}, {field15: "biff", field16: 102.0} ]
            field2: [ {field17: "hello", field18: true}, {field17: "world", field18: false} ]
            field3: [ {field20: true, field21: 1.0}, {field20: false, field21: 2.0} ]
        }
        schema = [
            "field1", ["", ["field15", "string", "field16", "number"]]
            "field2", ["", ["field17", "string", "field18", "boolean"]]
            "field3", ["", ["field20", "boolean", "field21", "number"]]
        ]
        schema = {
            field1: [ {field15: "string", field16: 'float'} ]
            field2: [ {field17: "string", field18: 'boolean'}]
            field3: [ {field20: 'boolean', field21: 'float'} ]
        }
        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)

        object = IOTON.parse(iotonStr, schema)
        object.should.not.be.null
        object.field1.should.be.array
        object.field2.should.be.array
        field.should.be.object for field in object.field1
        field.should.be.object for field in object.field2

        object.field1[0].field15.should.be.equal("baff")
        object.field1[0].field16.should.be.equal(100.0)
        object.field1[1].field15.should.be.equal("zap")
        object.field1[1].field16.should.be.equal(101.0)
        object.field1[2].field15.should.be.equal("biff")
        object.field1[2].field16.should.be.equal(102.0)

        object.field2[0].field17.should.be.equal("hello")
        object.field2[0].field18.should.be.equal(true)
        object.field2[1].field17.should.be.equal("world")
        object.field2[1].field18.should.be.equal(false)

        object.field3[0].field20.should.be.equal(true)
        object.field3[0].field21.should.be.equal(1.0)
        object.field3[1].field20.should.be.equal(false)
        object.field3[1].field21.should.be.equal(2.0)

        BIOTON = new Bioton(
            {
                field1: [ {field15: "string", field16: 'float'} ]
                field2: [ {field17: "string", field18: 'boolean'}]
                field3: [ {field20: 'boolean', field21: 'float'} ]
            }
        )
        encoded = BIOTON.encode(object)
        BIOTON.decode(encoded).should.be.eql(object)
        console.log("{ object }    savings-> binary: "+((100-100*encoded.length/json.length)).toPrecision(2)+"% "+" ioton:"+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"binary length:"+encoded.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

        done()

    it 'It can Stringify and Parse a complex object', (done) ->
        IOTON.reset()
        object = {
            field1: "string"
            field2: 2
            field3: true
            field4: undefined
            field5: null
            field6: ["element1", 1, true, null]
            field26: { field15: "string", field16: 100 }
            field7: {
                field8: "value8",
                field9: 9,
                field10: false,
                field11: null,
                field12: [1, 2, 3],
                field13: [true, false, true]
                field14: { field15: "string", field16: 100 }
            }
            field17: [true, false]
            field18: [ [4, 5, 6], [1, 4], [7, 8] ]
            field19: {
                field20: "string"
                field21: 9
            }
            field22: true
            field23: [{
                field24: "string"
                field25: "number"
            },
                {
                    field24: "hello"
                    field25: "there"
                }
            ]
        }

#        schema = [
#            "field1", "string",
#            "field2", "number",
#            "field3", "boolean",
#            "field4", "boolean",
#            "field5", "string",
#            "field6", ["", "dynamic"],
#            "field26", [ "field15", "string", "field16", "number" ],
#            "field7", [
#                "field8", "string",
#                "field9", "number",
#                "field10", "boolean",
#                "field11", "string",
#                "field12", ["", "number"],
#                "field13", ["", "boolean"],
#                "field14", [ "field15", "string", "field16", "number" ]
#            ],
#            "field17", ["", "boolean"],
#            "field18", ["", ["", "number"]],
#            "field19", [
#                "field20", "string",
#                "field21", "number"
#            ],
#            "field22", "boolean",
#            "field23", ["", [
#                "field24", "string",
#                "field25", "number"
#            ]]
#        ]
        schema = {
            field1: "string"
            field2: "number"
            field3: "boolean"
            field4: "boolean"
            field5: "string"
            field6: ["dynamic"]
            field26: { field15: "string", field16: "number" }
            field7: {
                field8: "value8",
                field9: "uint",
                field10: "boolean",
                field11: "float",
                field12: ["number"],
                field13: ["boolean"]
                field14: { field15: "string", field16: "long" }
            }
            field17: ["boolean"]
            field18: [ ["number"] ]
            field19: {
                field20: "string"
                field21: "number"
            }
            field22: "boolean"
            field23: [{
                field24: "string"
                field25: "string"
            }
            ]
        }

        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)
        console.log("savings-> "+((100-100*iotonStr.length/json.length)).toPrecision(2)+"% "+"  json length:"+json.length+" vs "+"iotonStr.length:"+iotonStr.length+"\n")

        test = new Buffer("\u0001\u000Fstring\u001F2\u001FT\u001F\u0016\u001F\u0019\u001F\u0002\u000Felement1\u001F1\u001FT\u001F\u0019\u0003\u001F\u0001\u000Fstring\u001F100\u0004\u001F\u0001\u000Fvalue8\u001F9\u001FF\u001F\u0019\u001F\u00021\u001F2\u001F3\u0003\u001F\u0002T\u001FF\u001FT\u0003\u001F\u0001\u000Fstring\u001F100\u0004\u0004\u001F\u0002T\u001FF\u0003\u001F\u0002\u00024\u001F5\u001F6\u0003\u001F\u00021\u001F4\u0003\u001F\u00027\u001F8\u0003\u0003\u001F\u0001\u000Fstring\u001F9\u0004\u001FT\u001F\u0002\u0001\u000Fstring\u001F\u000Fnumber\u0004\u001F\u0001\u000Fhello\u001F\u000Fthere\u0004\u0003\u0004","ascii")
        for i in [0...test.length] by 1
            iotonStr[i].should.equal(test[i])
        iotonStr.toString().should.equal(test.toString())
        object = IOTON.parse(iotonStr, schema)
        object.should.not.be.null

        jsonStr = IOTON.JSON(iotonStr)
        jsonStr.should.be.equal(json)

        done()

    it 'It can Stringify to and from JSON', (done) ->
        IOTON.reset()
        object = {
            field1: "string"
            field2: 2
            field3: true
            field4: false
            field5: "null"
            field6: ["element1", "1", "true", "null"]
            field26: { field15: "string", field16: 100 }
            field7: {
                field8: "value8",
                field9: 9,
                field10: false,
                field11: 1.1,
                field12: [1, 2, 3],
                field13: [true, false, true]
                field14: { field15: "string", field16: 100 }
            }
            field17: [true, false]
            field18: [ [4, 5, 6], [1, 4], [7, 8] ]
            field19: {
                field20: "string"
                field21: 9
            }
            field22: true
            field23: [{
                field24: "string"
                field25: "number"
            },
                {
                    field24: "hello"
                    field25: "there"
                }
            ]
        }

        schema = {
            field1: "string"
            field2: "number"
            field3: "boolean"
            field4: "boolean"
            field5: "string"
            field6: ["dynamic"]
            field26: { field15: "string", field16: "number" }
            field7: {
                field8: "value8",
                field9: "uint",
                field10: "boolean",
                field11: "float",
                field12: ["number"],
                field13: ["boolean"]
                field14: { field15: "string", field16: "long" }
            }
            field17: ["boolean"]
            field18: [ ["number"] ]
            field19: {
                field20: "string"
                field21: "number"
            }
            field22: "boolean"
            field23: [{
                field24: "string"
                field25: "string"
            }
            ]
        }

        iotonStr = IOTON.stringify(object)
        json = JSON.stringify(object)

        object = IOTON.parse(iotonStr, schema)
        object.should.not.be.null

        jsonStr = IOTON.JSON(iotonStr)
        jsonStr.should.be.equal(json)
        iotonStr2 = IOTON.IOTON(jsonStr)
        for i in [0...iotonStr.length]
            iotonStr2[i].should.be.equal(iotonStr[i])

        done()


