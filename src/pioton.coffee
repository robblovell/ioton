Ioton = require('./Ioton')

module.exports = class IotonP

    constructor: (encoding = "ascii", objectEncoding = null) ->
        @encoding = encoding
        if (objectEncoding)
            @objectEncoding = objectEncoding
        else
            @objectEncoding = new Ioton()

        @endMessageCharacter = '\x17'
        @beginPacketCharacter = '\x14'
        @ackCharacter = '\x06'
        @nackCharacter = '\x15'
        @sequenceCharacter = '\x16'
        @cancelCharacter = '\x18'
        @resetCharacter = '\x10'
        @inquiryCharacter = '\x05'
        @answerCharacter = '\x12'
        @stringBeginCharacter = '\x0F'

        @endMessageHextet = 0x17
        @beginPacketHextet = 0x14
        @ackHextet= 0x06
        @nackHextet = 0x15
        @sequenceHextet = 0x16
        @cancelHextet = 0x18
        @resetHextet = 0x10
        @inquiryHextet = 0x05
        @answerHextet = 0x12
        @stringBeginHextet = 0x0F
        # IOTON marker


    schema: (schema) ->
        @objectEncoding.schema(schema)

    parse: (packet) ->
        switch packet[0]
            when @beginPacketHextet
                message = @parsePacket(packet)
            when @inquiryHextet
                message = @parseInquiry(packet)
            when @answerHextet
                message = @parseAnswer(packet)
            when @ackHextet
                message = @parseAck(packet)
            when @nackHextet
                message = @parseNack(packet)
            when @cancelHextet
                message = @parseCancel(packet)
            when @resetHextet
                message = @parseReset(packet)
        return message

    parsePacket: (packet) ->
        tokens = packet.toString().split(@stringBeginCharacter)
        message = tokens[1].substring(0,tokens[1].length-1)
        tokens = tokens[0].split(@sequenceCharacter)
        if (tokens.length > 1) # have a sequence number
            sequence = tokens[1]
        else
            sequence = ''
        tag = tokens[0].substring(1,tokens[0].length)
        return { id: tag, sequence: sequence, message: message }

    packet: (packet, id=null, sequenceNumber=null) ->
        throw "Error: Can't pack null or undefined packet!" unless packet?
        if (id? and sequenceNumber?)
            message = @beginPacketCharacter + id + @sequenceCharacter + sequenceNumber
        else if (id?)
            message = @beginPacketCharacter + id
        else if (sequenceNumber?)
            message = @beginPacketCharacter + @sequenceCharacter + sequenceNumber
        else
            message = @beginPacketCharacter

        if (@objectEncoding instanceof Ioton)
            message += @objectEncoding.stringify(packet) + @endMessageCharacter
        else if (@objectEncoding instanceof Bioton)
            message += @objectEncoding.encode(packet) + @endMessageCharacter

        message = new Buffer(message, @encoding)

        return message

    parseInquiry: (packet) ->
        if packet.length == 2 and packet[0] = @inquiryHextet and packet[1] = @endMessageHextet
            return { inquiry: '"schema"' }
        request = packet.toString()
        return { inquiry: request.substring(1,request.length-1) }

    inquiry: (messageJSON = null) ->
        if (!messageJSON? || messageJSON == '"schema"')
            message = new Buffer("  ", @encoding)
            message[0] = @inquiryHextet
            message[1] = @endMessageHextet
            return message
        else
            message = @inquiryCharacter + messageJSON
        message = new Buffer(message+" ", @encoding)
        message[message.length-1] = @endMessageHextet
        return message

    parseAnswer: (packet) ->
        answer = packet.toString()
        return { answer: answer.substring(1,answer.length-1) }

    answer: (messageJSON = null) ->
        if (!messageJSON?)
            throw "No answer message given."

        message = @answerCharacter + messageJSON
        message = new Buffer(message+" ", @encoding)
        message[message.length-1] = @endMessageHextet
        return message

    parseAck: (packet) ->
        ack = packet.toString()

        if (packet.length == 1)
            return {ack: "ack"}
        else if (packet[1] == @sequenceHextet)
            return {ack: {id: ack.substring(2,ack.length-1)}}

        loc = ack.indexOf(@sequenceCharacter)
        if (loc == -1)
            return {ack: {sequence: ack.substring(1,ack.length-1)}} # just a sequence number.
        else # both sequence and id.
            return {ack: {id: ack.substring(loc+1,ack.length-1), sequence: ack.substring(1,loc)}}


    ack: (id = null, sequenceNumber = null) ->
        if (id? and sequenceNumber?)
            message = @ackCharacter + sequenceNumber + @sequenceCharacter + id + @endMessageCharacter
        else if (sequenceNumber?)
            message = @ackCharacter + sequenceNumber + @endMessageCharacter
        else if (id?)
            message = @ackCharacter + @sequenceCharacter + id + @endMessageCharacter
        else
            message = @ackCharacter
        message = new Buffer(message, @encoding)
        return message

    parseNack: (packet) ->
        return {nack: "nack"}

    nack: () ->
        return new Buffer(@nackCharacter, @encoding)

    parseCancel: (packet) ->
        return {cancel: "cancel"}

    cancel: () ->
        return new Buffer(@cancelCharacter, @encoding)

    parseReset: (packet) ->
        return {reset: "reset"}

    reset: () ->
        return new Buffer(@resetCharacter, @encoding)
