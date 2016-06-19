
# 
# --------------------------------------
# Status Messages
# --------------------------------------
# Full Status Packet: 
{
"id": "string",
"sequence": "uint",
"opcode": "string",
"eventTime": "datetime",
"location": {
    "lat": "double",
    "lon": "double"
},
"heading": "string",
"altitude": "uint",
"accelerometer": {
    "x": "double",
    "y": "double",
    "z": "double"
},
"distance": "string",
"battery": "string",
"ignition": "boolean",
"speed": "string",
"acceleration": "string",
"RPM": "string",
"movement": {
    "idle": "timespan",
    "moving": "timespan"
},
"odometer": "string",
"fuel": {
    "level": "string",
    "efficiency": "string"
},
"DTC": [
    "string"
],
"tow": {
    "state": "boolean",
    "from": {
        "lat": "double",
        "lon": "double"
    }
},
"accident": {
    "state": "boolean",
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
},
"harsh": {
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
},
"bus": "{ 1: J1850 VPW, 2: J1850 PWM, 3: ISO9141_2, 4: KWP2000 Fast Init, 5: ISO15765 CAN 11BIT 500KBaud, 6: ISO15765 CAN 29BIT 500KBaud, 7: ISO15765 CAN 11BIT 250KBaud, 8: ISO15765 CAN 29BIT 250KBaud, 9: KWP2000 5-Baud Init }",
"VIN": "string",
"GPS": {
    "strength": "string",
    "accuracy": "string",
    "status": "{ 1: 'off', 2: 'searching', 3: 'connected }",
    "satellites": "string"
},
"firmware": {
    "version": "string"
},
"configuration": {
    "version": "string"
},
"sim": {
    "IMSI": "string",
    "connected": "boolean",
    "strength": "string"
},
"state": "{ 1: 'sleep', 2: 'waking', 3: 'standby', 4: 'operational' }"
}
# 
# Device Complete Status Packet: 
{
"id": "string",
"sequence": "uint",
"opcode": "string",
"eventTime": "datetime",
"bus": "{ 1: J1850 VPW, 2: J1850 PWM, 3: ISO9141_2, 4: KWP2000 Fast Init, 5: ISO15765 CAN 11BIT 500KBaud, 6: ISO15765 CAN 29BIT 500KBaud, 7: ISO15765 CAN 11BIT 250KBaud, 8: ISO15765 CAN 29BIT 250KBaud, 9: KWP2000 5-Baud Init }",
"battery": "string",
"VIN": "string",
"GPS": {
    "strength": "string",
    "accuracy": "string",
    "status": "{ 1: 'off', 2: 'searching', 3: 'connected }",
    "satellites": "string"
},
"firmware": {
    "version": "string"
},
"configuration": {
    "version": "string"
},
"sim": {
    "IMSI": "string",
    "connected": "boolean",
    "strength": "string"
},
"state": "{ 1: 'sleep', 2: 'waking', 3: 'standby', 4: 'operational' }"
}
# 
# Device Operational Status Packet: 
{
"battery": "string",
"GPS": {
    "strength": "string",
    "accuracy": "string",
    "status": "{ 1: 'off', 2: 'searching', 3: 'connected }",
    "satellites": "string"
}
}
# 
# Vehicle Complete Status Packet: 
{
"id": "string",
"sequence": "uint",
"opcode": "string",
"eventTime": "datetime",
"location": {
    "lat": "double",
    "lon": "double"
},
"heading": "string",
"altitude": "uint",
"accelerometer": {
    "x": "double",
    "y": "double",
    "z": "double"
},
"distance": "string",
"battery": "string",
"ignition": "boolean",
"speed": "string",
"acceleration": "string",
"RPM": "string",
"movement": {
    "idle": "timespan",
    "moving": "timespan"
},
"odometer": "string",
"fuel": {
    "level": "string",
    "efficiency": "string"
},
"DTC": [
    "string"
],
"tow": {
    "state": "boolean",
    "from": {
        "lat": "double",
        "lon": "double"
    }
},
"accident": {
    "state": "boolean",
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
},
"harsh": {
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
}
}
# 
# --------------------------------------
# Change Messages
# --------------------------------------
# Vehicle Ignition Change Packet: 
{
"id": "string",
"sequence": "uint",
"opcode": "string",
"eventTime": "datetime",
"location": {
    "lat": "double",
    "lon": "double"
},
"heading": "string",
"altitude": "uint",
"accelerometer": {
    "x": "double",
    "y": "double",
    "z": "double"
},
"distance": "string",
"battery": "string",
"ignition": "boolean",
"speed": "string",
"acceleration": "string",
"RPM": "string",
"movement": {
    "idle": "timespan",
    "moving": "timespan"
},
"odometer": "string",
"fuel": {
    "level": "string",
    "efficiency": "string"
},
"DTC": [
    "string"
],
"tow": {
    "state": "boolean",
    "from": {
        "lat": "double",
        "lon": "double"
    }
},
"accident": {
    "state": "boolean",
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
},
"harsh": {
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
}
}
# 
# --------------------------------------
# Vehicle DTC Change Packet: 
{
"id": "string",
"sequence": "uint",
"opcode": "string",
"eventTime": "datetime",
"location": {
    "lat": "double",
    "lon": "double"
},
"heading": "string",
"altitude": "uint",
"accelerometer": {
    "x": "double",
    "y": "double",
    "z": "double"
},
"distance": "string",
"battery": "string",
"ignition": "boolean",
"speed": "string",
"acceleration": "string",
"RPM": "string",
"movement": {
    "idle": "timespan",
    "moving": "timespan"
},
"odometer": "string",
"fuel": {
    "level": "string",
    "efficiency": "string"
},
"DTC": [
    "string"
],
"tow": {
    "state": "boolean",
    "from": {
        "lat": "double",
        "lon": "double"
    }
},
"accident": {
    "state": "boolean",
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
},
"harsh": {
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
}
}
# 
# --------------------------------------
# Device Connection Change Packet: 
{
"id": "string",
"sequence": "uint",
"opcode": "string",
"eventTime": "datetime",
"bus": "{ 1: J1850 VPW, 2: J1850 PWM, 3: ISO9141_2, 4: KWP2000 Fast Init, 5: ISO15765 CAN 11BIT 500KBaud, 6: ISO15765 CAN 29BIT 500KBaud, 7: ISO15765 CAN 11BIT 250KBaud, 8: ISO15765 CAN 29BIT 250KBaud, 9: KWP2000 5-Baud Init }",
"battery": "string",
"VIN": "string",
"GPS": {
    "strength": "string",
    "accuracy": "string",
    "status": "{ 1: 'off', 2: 'searching', 3: 'connected }",
    "satellites": "string"
},
"firmware": {
    "version": "string"
},
"configuration": {
    "version": "string"
},
"sim": {
    "IMSI": "string",
    "connected": "boolean",
    "strength": "string"
},
"state": "{ 1: 'sleep', 2: 'waking', 3: 'standby', 4: 'operational' }"
}
# 
# --------------------------------------
# Device Power Change Packet: 
{
"id": "string",
"sequence": "uint",
"opcode": "string",
"eventTime": "datetime",
"bus": "{ 1: J1850 VPW, 2: J1850 PWM, 3: ISO9141_2, 4: KWP2000 Fast Init, 5: ISO15765 CAN 11BIT 500KBaud, 6: ISO15765 CAN 29BIT 500KBaud, 7: ISO15765 CAN 11BIT 250KBaud, 8: ISO15765 CAN 29BIT 250KBaud, 9: KWP2000 5-Baud Init }",
"battery": "string",
"VIN": "string",
"GPS": {
    "strength": "string",
    "accuracy": "string",
    "status": "{ 1: 'off', 2: 'searching', 3: 'connected }",
    "satellites": "string"
},
"firmware": {
    "version": "string"
},
"configuration": {
    "version": "string"
},
"sim": {
    "IMSI": "string",
    "connected": "boolean",
    "strength": "string"
},
"state": "{ 1: 'sleep', 2: 'waking', 3: 'standby', 4: 'operational' }"
}
# 
# --------------------------------------
# Alarm Messages
# --------------------------------------
# Vehicle Tow Alarm Packet: 
{
"id": "string",
"sequence": "uint",
"opcode": "string",
"eventTime": "datetime",
"location": {
    "lat": "double",
    "lon": "double"
},
"heading": "string",
"altitude": "uint",
"accelerometer": {
    "x": "double",
    "y": "double",
    "z": "double"
},
"distance": "string",
"battery": "string",
"ignition": "boolean",
"speed": "string",
"acceleration": "string",
"RPM": "string",
"movement": {
    "idle": "timespan",
    "moving": "timespan"
},
"odometer": "string",
"fuel": {
    "level": "string",
    "efficiency": "string"
},
"DTC": [
    "string"
],
"tow": {
    "state": "boolean",
    "from": {
        "lat": "double",
        "lon": "double"
    }
},
"accident": {
    "state": "boolean",
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
},
"harsh": {
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
}
}
# 
# --------------------------------------
# Alarm Messages
# --------------------------------------
# Vehicle Accident Alarm Packet: 
{
"id": "string",
"sequence": "uint",
"opcode": "string",
"eventTime": "datetime",
"location": {
    "lat": "double",
    "lon": "double"
},
"heading": "string",
"altitude": "uint",
"accelerometer": {
    "x": "double",
    "y": "double",
    "z": "double"
},
"distance": "string",
"battery": "string",
"ignition": "boolean",
"speed": "string",
"acceleration": "string",
"RPM": "string",
"movement": {
    "idle": "timespan",
    "moving": "timespan"
},
"odometer": "string",
"fuel": {
    "level": "string",
    "efficiency": "string"
},
"DTC": [
    "string"
],
"tow": {
    "state": "boolean",
    "from": {
        "lat": "double",
        "lon": "double"
    }
},
"accident": {
    "state": "boolean",
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
},
"harsh": {
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
}
}
# 
# --------------------------------------
# Alarm Messages
# --------------------------------------
# Vehicle Battery Alarm Packet: 
{
"id": "string",
"sequence": "uint",
"opcode": "string",
"eventTime": "datetime",
"location": {
    "lat": "double",
    "lon": "double"
},
"heading": "string",
"altitude": "uint",
"accelerometer": {
    "x": "double",
    "y": "double",
    "z": "double"
},
"distance": "string",
"battery": "string",
"ignition": "boolean",
"speed": "string",
"acceleration": "string",
"RPM": "string",
"movement": {
    "idle": "timespan",
    "moving": "timespan"
},
"odometer": "string",
"fuel": {
    "level": "string",
    "efficiency": "string"
},
"DTC": [
    "string"
],
"tow": {
    "state": "boolean",
    "from": {
        "lat": "double",
        "lon": "double"
    }
},
"accident": {
    "state": "boolean",
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
},
"harsh": {
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
}
}
# 
# --------------------------------------
# Alarm Messages
# --------------------------------------
# Vehicle Harsh Alarm Packet: 
{
"id": "string",
"sequence": "uint",
"opcode": "string",
"eventTime": "datetime",
"location": {
    "lat": "double",
    "lon": "double"
},
"heading": "string",
"altitude": "uint",
"accelerometer": {
    "x": "double",
    "y": "double",
    "z": "double"
},
"distance": "string",
"battery": "string",
"ignition": "boolean",
"speed": "string",
"acceleration": "string",
"RPM": "string",
"movement": {
    "idle": "timespan",
    "moving": "timespan"
},
"odometer": "string",
"fuel": {
    "level": "string",
    "efficiency": "string"
},
"DTC": [
    "string"
],
"tow": {
    "state": "boolean",
    "from": {
        "lat": "double",
        "lon": "double"
    }
},
"accident": {
    "state": "boolean",
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
},
"harsh": {
    "profile": [
        {
            "x": "double",
            "y": "double",
            "z": "double"
        }
    ]
}
}
# 
# --------------------------------------
# Alarm Messages
# --------------------------------------
# Device Battery Alarm Packet: 
{
"id": "string",
"sequence": "uint",
"opcode": "string",
"eventTime": "datetime",
"bus": "{ 1: J1850 VPW, 2: J1850 PWM, 3: ISO9141_2, 4: KWP2000 Fast Init, 5: ISO15765 CAN 11BIT 500KBaud, 6: ISO15765 CAN 29BIT 500KBaud, 7: ISO15765 CAN 11BIT 250KBaud, 8: ISO15765 CAN 29BIT 250KBaud, 9: KWP2000 5-Baud Init }",
"battery": "string",
"VIN": "string",
"GPS": {
    "strength": "string",
    "accuracy": "string",
    "status": "{ 1: 'off', 2: 'searching', 3: 'connected }",
    "satellites": "string"
},
"firmware": {
    "version": "string"
},
"configuration": {
    "version": "string"
},
"sim": {
    "IMSI": "string",
    "connected": "boolean",
    "strength": "string"
},
"state": "{ 1: 'sleep', 2: 'waking', 3: 'standby', 4: 'operational' }"
}