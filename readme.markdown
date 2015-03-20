# mojio-tcu-server-js
Version 3.4.2

A JSON like object notation built in coffeescript called IOTON.




Need a simpler Avro: Compact Avro

Primitive Types

    The set of primitive type names is:

        null: no value
        boolean: a binary value
        int: 32-bit signed integer
        long: 64-bit signed integer
        float: single precision (32-bit) IEEE 754 floating-point number
        double: double precision (64-bit) IEEE 754 floating-point number
        bytes: sequence of 8-bit unsigned bytes
        string: unicode character sequence

        Primitive types have no specified attributes.

        Primitive type names are also defined type names. Thus, for example, the schema "string" is equivalent to:

            {"type": "string"}
            {"type": "long"}

Container Types

    Avro Light supports two kinds of complex types: objects and arrays:

        Arrays
            Arrays use the type name "array" and support a single attribute:

            items: the schema of the array's items.
            For example, an array of strings is declared with:

                {"type": "array", "items": "string"}

            This may not be possible: Arrays can be of variable type by specifying the items in the array as "dynamic"

        Objects (Arvo Records)

            Objects use the type name "object" and support two attributes: name and fields

            name: The name of the object.
            namespace: a namespace that qualifies the name.
            fields: fields consist of an array of schemas for key value pairs consisting of a name and a type.
            The name of the field is the semantic tag of the key value pair represented by a string. Fields
            are the properties of the object.

            For example:

                {"type": "object",
                 "name": "Object1",
                 "namespace": "Mojio",
                 "fields": [
                        {"name": "field1", "type": "string"}
                        {"name": "field2", "type": "long"}
                        {"name": "field3", "type": "double"}
                        {"name": "field4", "type": "boolean"}
                     ]
                }


        Mixed Containers, Objects and Arrays:

            Examples

                An object with an array

                {"type": "object",
                 "name": "Object1",
                 "namespace": "Mojio",
                 "fields": [
                     {"name": "field10", "type": {"type": "array", "items": "string"}}
                  ]
                }

                An object with another object

                {"type": "object",
                 "name": "Object2",
                 "namespace": "Mojio",
                 "fields": [
                    {"name": "field1", "type": "long"},
                    {"name": "field2", "type": "string"},
                    {"name": "field3", "type": "Mojio.Object1"},
                 ]
                }


                An array of arrays

                {"type": "array", "items": {"type": "array", "items": "string"} }


                An array of objects

                {"type": "array", "items": {"type": "Mojio.Object1"} }

Names

    Record, enums and fixed are named types. Each has a fullname that is composed of two parts; a name and a namespace. Equality of names is defined on the fullname.

    The name portion of a fullname, record field names, and enum symbols must:

    start with [A-Za-z_]
    subsequently contain only [A-Za-z0-9_]
    A namespace is a dot-separated sequence of such names. The empty string may also be used as a namespace to indicate the null namespace. Equality of names (including field names and enum symbols) as well as fullnames is case-sensitive.

    In record, enum and fixed definitions, the fullname is determined in one of the following ways:

    A name and namespace are both specified. For example, one might use "name": "X", "namespace": "org.foo" to indicate the fullname org.foo.X.
    A fullname is specified. If the name specified contains a dot, then it is assumed to be a fullname, and any namespace also specified is ignored. For example, use "name": "org.foo.X" to indicate the fullname org.foo.X.
    A name only is specified, i.e., a name that contains no dots. In this case the namespace is taken from the most tightly enclosing schema or protocol. For example, if "name": "X" is specified, and this occurs within a field of the record definition of org.foo.Y, then the fullname is org.foo.X. If there is no enclosing namespace then the null namespace is used.
    References to previously defined names are as in the latter two cases above: if they contain a dot they are a fullname, if they do not contain a dot, the namespace is the namespace of the enclosing definition.

    Primitive type names have no namespace and their names may not be defined in any namespace.

    A schema or protocol may not contain multiple definitions of a fullname. Further, a name must be defined before it is used ("before" in the depth-first, left-to-right traversal of the JSON parse tree, where the types attribute of a protocol is always deemed to come "before" the messages attribute.)


Data Serialization

    Avro Lite data is never serialized with its schema.

    Avro-based remotes must guarantee that remote recipients of data have a copy of the schema used to write that data.

    Because the schema used to write data is assumed to always available when the data is read, Avro data itself is not tagged with type information. The schema is required to parse data.

    In general, both serialization and deserialization proceed as a depth-first, left-to-right traversal of the schema, serializing primitive types as they are encountered.

Encodings

    Avro specifies two serialization encodings: binary and JSON. Most applications will use the binary encoding, as it is smaller and faster. But, for debugging and web-based applications, the JSON encoding may sometimes be appropriate.

Binary Encoding

    Primitive Types
        Primitive types are encoded in binary as follows:

        null is written as zero bytes.
        a boolean is written as a single byte whose value is either 0 (false) or 1 (true).
        int and long values are written using variable-length zig-zag coding. Some examples:
            value	hex
            0	00
            -1	01
            1	02
            -2	03
            2	04
            ...
            -64	7f
            64	 80 01
            ...
        a float is written as 4 bytes. The float is converted into a 32-bit integer using a method equivalent to Java's floatToIntBits and then encoded in little-endian format.
        a double is written as 8 bytes. The double is converted into a 64-bit integer using a method equivalent to Java's doubleToLongBits and then encoded in little-endian format.
        bytes are encoded as a long followed by that many bytes of data.
        a string is encoded as a long followed by that many bytes of UTF-8 encoded character data.
        For example, the three-character string "foo" would be encoded as the long value 3 (encoded as hex 06) followed by the UTF-8 encoding of 'f', 'o', and 'o' (the hex bytes 66 6f 6f):
        06 66 6f 6f

    Container Types
        Complex types are encoded in binary as follows:

        Objects
            An object is encoded by encoding the values of its fields in the order that they are declared. In other words, an object is encoded as just the concatenation of the encodings of its fields. Field values are encoded per their schema.

            For example, the record schema

                      {
                      "type": "record",
                      "name": "test",
                      "fields" : [
                      {"name": "a", "type": "long"},
                      {"name": "b", "type": "string"}
                      ]
                      }

            An instance of this object whose a field has value 27 (encoded as hex 36) and whose b field has value "foo" (encoded as hex bytes 06 66 6f 6f), would be encoded simply as the concatenation of these, namely the hex byte sequence:

            36 06 66 6f 6f

        Arrays
            Arrays are encoded as a series of blocks. Each block consists of a long count value, followed by that many array items. A block with count zero indicates the end of the array. Each item is encoded per the array's item schema.

            If a block's count is negative, its absolute value is used, and the count is followed immediately by a long block size indicating the number of bytes in the block. This block size permits fast skipping through data, e.g., when projecting a record to a subset of its fields.

            For example, the array schema

            {"type": "array", "items": "long"}
            an array containing the items 3 and 27 could be encoded as the long value 2 (encoded as hex 04) followed by long values 3 and 27 (encoded as hex 06 36) terminated by zero:

            04 06 36 00
            The blocked representation permits one to read and write arrays larger than can be buffered in memory, since one can start writing items without knowing the full length of the array.

JSON Encoding

    The JSON encoding is:

        avro type	    json type	example
        null	        null	    null
        boolean	        boolean	    true
        int,long	    number	    1
        float,double	number	    1.1
        bytes	        string	    "\u00FF"
        string	        string	    "foo"
        record	        object	    {"a": 1}
        array	        array	    [1]

