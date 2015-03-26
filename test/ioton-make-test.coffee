assert = require('assert')
should = require('should')
ioton = require('../src/ioton')

Type = require('../src/binary/Type')

describe 'IOTON', ->

    IOTON = new ioton()
    it 'It can make an object from a schema', () ->

        schema = {
            field1: "string"
            field2: 'uint'
            field3: 'boolean'
            field4: 'boolean'
            field5: 'string'
            field6: ["string"]
            field26: {field15: "string", field16: 'uint'}
        }
        object = IOTON.make(schema)
        console.log(JSON.stringify(object))
        JSON.stringify(object).should.be.equal('{"field1":"0","field2":0,"field3":true,"field4":true,"field5":"0","field6":["0","0","0"],"field26":{"field15":"0","field16":0}}')

        schema = {
            field1: [{field2: ["string"]}]
        }
        object = IOTON.make(schema)
        console.log(JSON.stringify(object)+'\n')
        JSON.stringify(object).should.be.equal('{"field1":[{"field2":["0","0","0"]},{"field2":["0","0","0"]},{"field2":["0","0","0"]}]}')


