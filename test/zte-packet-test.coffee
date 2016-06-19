assert = require('assert')
should = require('should')
Ioton = require('../src/Ioton')
Bioton = require('../src/Bioton')
_ = require('underscore')

Type = require('../src/binary/Type')

describe 'ZTE Packets', ->

    IOTON = new Ioton()

    schemaPieces = () ->
        identification = {
            id: "string"
            sequence: 'uint'
            opcode: "string"
            eventTime: 'datetime'
        }
        accident = {
            state: 'boolean',
            profile: [{x: 'double', y: 'double', z: 'double'}]
        }
        harsh = {
            profile: [{x: 'double', y: 'double', z: 'double'}]
        }
        location = {lat: 'double', lon: 'double'}
        accelerometer = {x: 'double', y: 'double', z: 'double'}
        movement = {idle: 'timespan', moving: 'timespan'}
        fuel = {level: 'string', efficiency: 'string'}
        DTC = ['string']
        tow = { state: 'boolean', from: location }
        attitude = {

        }
        vehicle = {
            location: location
            heading: 'string'
            altitude: 'uint'
            accelerometer: accelerometer
            distance: 'string'
            battery: 'string'
            ignition: 'boolean'
            speed: 'string'
            acceleration: 'string'
            RPM: 'string'
            movement: movement
            odometer: 'string'
            fuel: fuel
            DTC: DTC
            tow: tow
            accident: accident
            harsh: harsh
        }
        # enumerated type:
        bus = "{ 1: J1850 VPW, 2: J1850 PWM, 3: ISO9141_2, 4: KWP2000 Fast Init, \
                5: ISO15765 CAN 11BIT 500KBaud, 6: ISO15765 CAN 29BIT 500KBaud, \
                7: ISO15765 CAN 11BIT 250KBaud, 8: ISO15765 CAN 29BIT 250KBaud, \
                9: KWP2000 5-Baud Init }"
        GPS = {
            strength: 'string',
            accuracy: 'string',
            status: "{ 1: 'off', 2: 'searching', 3: 'connected }"
            satellites: "string"
        }
        SIM = {
            IMSI: 'string'
            connected: 'boolean'
            strength: 'string'
        }
        firmware = {
            version: 'string'
        }
        configuration = {
            version: 'string'
        }
        operation = {
            battery: 'string'
            GPS: GPS
        }

        device = {
            bus:  bus
            battery: 'string'
            VIN: 'string'
            GPS: GPS
            firmware: firmware
            configuration: configuration
            sim: SIM
            state: "{ 1: 'sleep', 2: 'waking', 3: 'standby', 4: 'operational' }"
        }

        return {
            identification: identification, vehicle: vehicle,
            device: device, operation: operation
            bus:  bus, GPS: GPS, SIM: SIM,
            firmware: firmware, configuration: configuration,
            location: location, accident: accident, tow: tow, DTC: DTC,
            fuel: fuel, movement: movement, accelerometer: accelerometer
        }
    describe 'Status Messages', ->
        it 'Full Status Packet', () ->
            parts = schemaPieces()
            packet = _({}).extend(parts.identification, parts.vehicle)
            packet = _({}).extend(packet, parts.device)
            console.log(""); console.log("# ") 
            console.log("# --------------------------------------");
            console.log("# "+@test.parent.title)
            console.log("# --------------------------------------");
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))

        it 'Device Complete Status Packet', () ->
            parts = schemaPieces()
            devicePacket = packet = _({}).extend(parts.identification, parts.device)
            console.log(""); console.log("# ") 
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))

        it 'Device Operational Status Packet', () ->
            parts = schemaPieces()
            packet = parts.operation
            console.log(""); console.log("# ") 
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))

        it 'Vehicle Complete Status Packet', () ->
            parts = schemaPieces()
            packet = _({}).extend(parts.identification, parts.vehicle)
            packet = _({}).extend(packet, parts.operations)
            console.log(""); console.log("# ") 
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))

    describe 'Change Messages', ->
        it 'Vehicle Ignition Change Packet', () ->
            parts = schemaPieces()
            packet = _({}).extend(parts.identification, parts.vehicle)
            packet = _({}).extend(packet, parts.operations)
            console.log(""); console.log("# ") 
            console.log("# --------------------------------------");
            console.log("# "+@test.parent.title)
            console.log("# --------------------------------------");
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))
            return

        it 'Vehicle DTC Change Packet', () ->
            parts = schemaPieces()
            packet = _({}).extend(parts.identification, parts.vehicle)
            packet = _({}).extend(packet, parts.operations)
            console.log(""); console.log("# ") 
            console.log("# --------------------------------------");
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))
            return

        it 'Device Connection Change Packet', () ->
            parts = schemaPieces()
            packet = _({}).extend(parts.identification, parts.device)
            console.log(""); console.log("# ") 
            console.log("# --------------------------------------");
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))
            return

        it 'Device Power Change Packet', () ->
            parts = schemaPieces()
            packet = _({}).extend(parts.identification, parts.device)
            console.log(""); console.log("# ") 
            console.log("# --------------------------------------");
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))
            return

    describe 'Alarm Messages', ->
        it 'Vehicle Tow Alarm Packet', () ->
            parts = schemaPieces()
            packet = _({}).extend(parts.identification, parts.vehicle)
            console.log(""); console.log("# ") 
            console.log("# --------------------------------------");
            console.log("# "+@test.parent.title)
            console.log("# --------------------------------------");
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))
            return
        it 'Vehicle Accident Alarm Packet', () ->
            parts = schemaPieces()
            packet = _({}).extend(parts.identification, parts.vehicle)
            console.log(""); console.log("# ") 
            console.log("# --------------------------------------");
            console.log("# "+@test.parent.title)
            console.log("# --------------------------------------");
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))
            return
        it 'Vehicle Battery Alarm Packet', () ->
            parts = schemaPieces()
            packet = _({}).extend(parts.identification, parts.vehicle)
            console.log(""); console.log("# ") 
            console.log("# --------------------------------------");
            console.log("# "+@test.parent.title)
            console.log("# --------------------------------------");
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))
            return
        it 'Vehicle Harsh Alarm Packet', () ->
            parts = schemaPieces()
            packet = _({}).extend(parts.identification, parts.vehicle)
            console.log(""); console.log("# ") 
            console.log("# --------------------------------------");
            console.log("# "+@test.parent.title)
            console.log("# --------------------------------------");
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))
            return
        it 'Device Battery Alarm Packet', () ->
            parts = schemaPieces()
            packet = _({}).extend(parts.identification, parts.device)
            console.log(""); console.log("# ") 
            console.log("# --------------------------------------");
            console.log("# "+@test.parent.title)
            console.log("# --------------------------------------");
            console.log("# "+@.test.title+": "); console.log(JSON.stringify(packet, null, 2))
            return
