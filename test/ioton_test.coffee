assert = require('assert')
should = require('should')
ioton = require('../src/ioton/ioton')

describe 'IOTON', ->

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


    schema = [
        "field1", "string",
        "field2", "number",
        "field3", "boolean",
        "field4", "boolean",
        "field5", "string",
        "field6", ["", "typed"],
        "field26", [ "field15", "string", "field16", "number" ],
        "field7", [
            "field8", "string",
            "field9", "number",
            "field10", "boolean",
            "field11", "string",
            "field12", ["", "number"],
            "field13", ["", "boolean"],
            "field14", [ "field15", "string", "field16", "number" ]
        ],
        "field17", ["", "boolean"],
        "field18", ["", ["", "number"]],
        "field19", [
            "field20", "string",
            "field21", "number"
        ],
        "field22", "boolean",
        "field23", ["", [
            "field24", "string",
            "field25", "number"
        ]]
    ]

    object2 = {
        field1: [ [4, 5, 6], [1, 4], [[7], [8]] ]
    }
    schema2 = [
        "field1", ["", ["", "number"]]
    ]

    console.log("Schema:"+JSON.stringify(schema)+"\n")

    IOTON = new ioton()

    before ((done) ->
        IOTON.schema = schema
        IOTON.schema.should.equal(schema)
        done()
    )

    it 'It can stringify', (done) ->
        ioton = IOTON.stringify(object)
        test = new Buffer("\u0001\u000Fstring\u001F2\u001FT\u001F\u0019\u001F\u000E\u001F\u0002\u000Felement1\u001F1\u001FT\u001F\u000E\u0003\u001F\u0001\u000Fstring\u001F100\u0004\u001F\u0001\u000Fvalue8\u001F9\u001FF\u001F\u000E\u001F\u00021\u001F2\u001F3\u0003\u001F\u0002T\u001FF\u001FT\u0003\u001F\u0001\u000Fstring\u001F100\u0004\u0004\u001F\u0002T\u001FF\u0003\u001F\u0002\u00024\u001F5\u001F6\u0003\u001F\u00021\u001F4\u0003\u001F\u00027\u001F8\u0003\u0003\u001F\u0001\u000Fstring\u001F9\u0004\u001FT\u001F\u0002\u0001\u000Fstring\u001F\u000Fnumber\u0004\u001F\u0001\u000Fhello\u001F\u000Fthere\u0004\u0003\u0004","ascii")
        for i in [0...test.length] by 1
            ioton[i].should.equal(test[i])
        ioton.toString().should.equal(test.toString())
        console.log(IOTON.JSON(ioton,schema))
        console.log("\n")
        done()

    it 'It can PARSE', (done) ->
        ioton = IOTON.stringify(object)

        object = IOTON.parse(ioton, schema)
        console.log(object.toString())

        console.log("Schema 1:"+JSON.stringify(schema))
        console.log("Schema 2:"+JSON.stringify(schema2))
        ioton = IOTON.stringify(object2)

        object = IOTON.parse(ioton, schema2)
        done()
