should = require('should')
assert = require('assert')
Ioton = require('../src/Ioton')
Bioton = require('../src/Ioton')


Type = require('../src/binary/Type')

describe 'IOTONB Type', () ->
    myType=null

    it 'should correctly parse a type', () ->
        myType = new Type({
            a: 'int',
            b: ['int'],
            c: [{
                'd?': 'string'
            }]
        })

        assert.deepEqual(myType, {
            __proto__: Type.prototype,
            type: Type.TYPE.OBJECT,
            fields: [{
                name: 'a',
                optional: false,
                array: false,
                type: {
                    type: Type.TYPE.INT
                }
            }, {
                name: 'b',
                optional: false,
                array: true,
                type: {
                    type: Type.TYPE.INT
                }
            }, {
                name: 'c',
                optional: false,
                array: true,
                type: {
                    type: Type.TYPE.OBJECT,
                    fields: [{
                        name: 'd',
                        optional: true,
                        array: false,
                        type: {
                            type: Type.TYPE.STRING
                        }
                    }]
                }
            }]
        })

    it 'should encode-decode a conforming object', () ->
        IOTON = new Ioton()
        myType = new Type({
            a: 'int',
            b: ['int'],
            c: [{
                'd?': 'string'
            }]
        })
        object = {
            a: 22,
            b: [-3, 14, -15, 92, -65, 35],
            c: [{
                d: 'Hello World'
            }, {
                d: '?'
            }]
        }
#        schema = [
#            "a", "number",
#            "b", ["", "number"],
#            "c", ["", ["d", "string"]]
#        ]
        encoded = myType.encode(object)

        testResult = [22,6,125,14,113,128,92,191,191,35,2,1,11,72,101,108,108,111,32,87,111,114,108,100,1,1,63]
        for i in [0...encoded.length]
            encoded[i].should.be.equal(testResult[i])

        IotonResult = IOTON.stringify(object)

        json = JSON.stringify(object)
        console.log("js-binary size-> "+(100*encoded.length/json.length).toPrecision(2)+"% "+
            "ioton size-> "+(100*IotonResult.length/json.length).toPrecision(2)+"% "+
            "json length:"+json.length+" vs "+
            "js-binary length:"+encoded.length+" vs "+
            "ioton length:"+IotonResult.length+"\n")

        myType.decode(encoded).should.be.eql({
            a: 22,
            b: [-3, 14, -15, 92, -65, 35],
            c: [{
                d: 'Hello World'
            }, {
                d: '?'
            }]
        })
#
#    it 'should encode-decode all characters', () ->
#        IOTON = new Ioton()
#        myType = new Type({
#            a: 'string',
#            b: ['double'],
#            c: 'boolean',
#            d: ['int']
#            d: ['uint']
#        })
#        object = {
#            a: ''+ i for i in [' '..'Z']
#            b: [-3, 14, -15, 92, -65, 35],
#            c: [{
#                d: 'Hello World'
#            }, {
#                d: '?'
#            }]
#        }
#        #        schema = [
#        #            "a", "number",
#        #            "b", ["", "number"],
#        #            "c", ["", ["d", "string"]]
#        #        ]
#        encoded = myType.encode(object)
#
#        testResult = [22,6,125,14,113,128,92,191,191,35,2,1,11,72,101,108,108,111,32,87,111,114,108,100,1,1,63]
#        for i in [0...encoded.length]
#            encoded[i].should.be.equal(testResult[i])
#
#        Ioton = IOTON.stringify(object)
#
#        json = JSON.stringify(object)
#        console.log("js-binary size-> "+(100*encoded.length/json.length).toPrecision(2)+"% "+
#                "ioton size-> "+(100*Ioton.length/json.length).toPrecision(2)+"% "+
#                "json length:"+json.length+" vs "+
#                "js-binary length:"+encoded.length+" vs "+
#                "ioton length:"+Ioton.length+"\n")
#
#        myType.decode(encoded).should.be.eql({
#            a: 22,
#            b: [-3, 14, -15, 92, -65, 35],
#            c: [{
#                d: 'Hello World'
#            }, {
#                d: '?'
#            }]
#        })
