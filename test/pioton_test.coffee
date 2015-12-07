assert = require('assert')
should = require('should')
Pioton = require('../src/Pioton')

Type = require('../src/binary/Type')

describe 'PIOTON', ->

    PIOTON = new Pioton()

    it 'It can encode packet', () ->
        packet = PIOTON.packet('hello')
        # control characters below:
        result = "hello
"
        packet.toString().should.be.equal(result)

    it 'It can parse packet', () ->
        packet = PIOTON.packet('hello')
        result = PIOTON.parse(packet)
        result.id.should.be.equal('')
        result.sequence.should.be.equal('')
        result.message.should.be.equal('hello')

        packet = PIOTON.packet('hello', 1)
        result = PIOTON.parse(packet)
        result.id.should.be.equal('1')
        result.sequence.should.be.equal('')
        result.message.should.be.equal('hello')

        packet = PIOTON.packet('hello', 1, 2)
        result = PIOTON.parse(packet)
        result.id.should.be.equal('1')
        result.sequence.should.be.equal('2')
        result.message.should.be.equal('hello')

        packet = PIOTON.packet('hello', null, 2)
        result = PIOTON.parse(packet)
        result.id.should.be.equal('')
        result.sequence.should.be.equal('2')
        result.message.should.be.equal('hello')

#        (PIOTON.packet(null, null, 2)).should.throw()

#        result = PIOTON.parse(packet)
#        result.id.should.be.equal('')
#        result.sequence.should.be.equal('2')
#        result.message.should.be.equal('hello')

    it 'It can encode inquiry', () ->
        packet = PIOTON.inquiry()
        packet[0].should.be.equal(PIOTON.inquiryHextet)
        packet[1].should.be.equal(PIOTON.endMessageHextet)

        packet = PIOTON.inquiry('"schema"')
        packet[0].should.be.equal(PIOTON.inquiryHextet)
        packet[1].should.be.equal(PIOTON.endMessageHextet)

        request = '{"do": "this"}'
        packet = PIOTON.inquiry(request)
        packet[0].should.be.equal(PIOTON.inquiryHextet)
        packet[15].should.be.equal(PIOTON.endMessageHextet)
        packet.toString().substring(1,15).should.be.equal(request)

        request = '[ {"do": "this"}, {"do": "and this"} ]'
        packet = PIOTON.inquiry(request)
        packet[0].should.be.equal(PIOTON.inquiryHextet)
        packet[39].should.be.equal(PIOTON.endMessageHextet)
        packet.toString().substring(1,39).should.be.equal(request)

    it 'It can parse inquiry', () ->
        packet = PIOTON.inquiry()
        result = PIOTON.parse(packet)
        result.inquiry.should.be.equal('"schema"')

        request = '{"do": "this"}'
        packet = PIOTON.inquiry(request)
        packet[0].should.be.equal(PIOTON.inquiryHextet)
        packet[15].should.be.equal(PIOTON.endMessageHextet)
        packet.toString().substring(1,15).should.be.equal(request)
        result = PIOTON.parse(packet)
        result.inquiry.should.be.equal(request)

    it 'It can encode answer', () ->
        request = '{"answer": "this"}'
        packet = PIOTON.answer(request)
        packet[0].should.be.equal(PIOTON.answerHextet)
        packet[19].should.be.equal(PIOTON.endMessageHextet)
        packet.toString().substring(1,19).should.be.equal(request)

        request = '[ {"answer": "this"}, {"answer": "and this"} ]'
        packet = PIOTON.answer(request)
        packet[0].should.be.equal(PIOTON.answerHextet)
        packet[47].should.be.equal(PIOTON.endMessageHextet)
        packet.toString().substring(1,47).should.be.equal(request)

    it 'It can parse answer', () ->
        request = '[ {"answer": "this"}, {"answer": "and this"} ]'
        packet = PIOTON.answer(request)
        packet[0].should.be.equal(PIOTON.answerHextet)
        packet[47].should.be.equal(PIOTON.endMessageHextet)
        packet.toString().substring(1,47).should.be.equal(request)

        result = PIOTON.parse(packet)
        result.answer.should.be.equal(request)

    it 'It can encode ack', () ->
        packet = PIOTON.ack()
        packet[0].should.be.equal(PIOTON.ackHextet)
        packet.length.should.be.equal(1)

        packet = PIOTON.ack(1)
        packet[0].should.be.equal(PIOTON.ackHextet)
        packet[1].should.be.equal(PIOTON.sequenceHextet)
        packet[2].should.be.equal(49)
        packet[3].should.be.equal(PIOTON.endMessageHextet)
        packet.toString().substring(2,3).should.be.equal("1")

        packet = PIOTON.ack(1,999)
        packet[0].should.be.equal(PIOTON.ackHextet)
        packet[1].should.be.equal(57)
        packet[2].should.be.equal(57)
        packet[3].should.be.equal(57)
        packet[4].should.be.equal(PIOTON.sequenceHextet)
        packet[5].should.be.equal(49)
        packet[6].should.be.equal(PIOTON.endMessageHextet)
        packet.toString().substring(5, 6).should.be.equal("1")
        packet.toString().substring(1,4).should.be.equal("999")

    it 'It can parse ack', () ->
        packet = PIOTON.ack()
        result = PIOTON.parse(packet)
        result.ack.should.be.equal("ack")

        should.not.exist(result.ack.id)
        should.not.exist(result.ack.sequence)

        packet = PIOTON.ack(1)
        result = PIOTON.parse(packet)
        result.ack.id.should.be.equal("1")
        should.not.exist(result.ack.sequence)

        packet = PIOTON.ack(1,999)
        result = PIOTON.parse(packet)
        result.ack.id.should.be.equal("1")
        result.ack.sequence.should.be.equal("999")

    it 'It can encode nack', () ->
        packet = PIOTON.nack()
        packet[0].should.be.equal(PIOTON.nackHextet)
        packet.length.should.be.equal(1)

    it 'It can parse nack', () ->
        packet = PIOTON.nack()
        result = PIOTON.parse(packet)
        result.nack.should.be.equal("nack")

    it 'It can encode cancel', () ->
        packet = PIOTON.cancel()
        packet[0].should.be.equal(PIOTON.cancelHextet)
        packet.length.should.be.equal(1)

    it 'It can parse cancel', () ->
        packet = PIOTON.cancel()
        result = PIOTON.parse(packet)
        result.cancel.should.be.equal("cancel")

    it 'It can encode reset', () ->
        packet = PIOTON.reset()
        packet[0].should.be.equal(PIOTON.resetHextet)
        packet.length.should.be.equal(1)

    it 'It can parse reset', () ->
        packet = PIOTON.reset()
        result = PIOTON.parse(packet)
        result.reset.should.be.equal("reset")
