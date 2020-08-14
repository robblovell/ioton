# IOTON
Version 0.0.2

A JSON like object notation for the internet of things.

# The Problem

There is this thing called JSON. It’s become the defect standard format for passing objects.  The goto for representation of data. But, its more expensive than custom solutions in the context of mobile networks because it has a lot of unnecessary characters used to communicate semantic context. Most of the time, both ends of a point to point connection know the context, meaning the semantic information only needs to be passed once, when the two sides first connect.

In the device world, engineers are constantly inventing their own object notations, requiring that anyone wishing to communicate with the device do a bunch of "bit twaddling" to decipher the notation and write a parser for it. 

What if one notation could be made where the parse only had to be created once and everyone used it? Isn't that JASN? So how can these two things be unified.

# An aside: 

There are lots of protocols that mix object notation with communication protocols and transport. This complicates a problem that should be simple.  Object notation should be a separate concern from protocol and transport definitions. To put it another way, how packets get wrapped and delivered should not be dependent on the contents of those packets. Envelopes and delivery men don't care what's in the package, only that it's wrapped correctly.

# IOTON

The idea is to make packet size smaller by passing semantic information as a JSON schema in a separate message from the content. Follow on communication only includes an delimited list of fields, preferably binary, but possibly not.

The schema is sent once when communication is established, allowing both ends of the communication to be able to put the semantic information back together with the content when it is delivered.

# Schema 

The schema needs to communicate five or six pieces of information in order for both parties to understand the object sent in a packet. First, the structure of the object needs to be established. Second, the semantic tags for each field. Third, the type of each field.  Fourth, the parser used to match up fields to tags. The fifth piece of information is any configuration necessary to make the parser work. For instance, if the parser is a simple comma separated list of strings, then it might be necessary to establish the separator character. In the case of some parsers, the length of each field may need to be communicated.

JSON schemas could be used to communicate this information, but a simplified version is more compact. What can communicate the semantics is a JSON object where the values are replaced with the type of the field. This communicates the structure, the tags, and the types, leaving the parser name or id and the configuration of the parser.

{
    "metadata": /* some JSON object with useful information like company, device, versioning, etc. */
    "parser": /* the parser id */,
    "options": /* some JSON object the parser understands */,
    "schema": /* some JSON object with type instead of values */
}

The metadata and options fields are optional, but parser and schema are required. At some point parser may become optional if a standard is established. 

# Protocol Envelope 

By itself, an object definition does not describe how packets are delivered. The packet definition is outside of the scope of this repository. However, it is important to note that some communication channels may send several different objects and the protocol must define how different object types are identified so that the correct parser is selected.

The protocol is concerned with defining the beginning and end of a packet as well as identifying the parser and schema used to extract the contents. This is normally established with a header block.

See PIOTON or Protocol for the Internet of Things Object Notation. This protocol is currently being formed within this repo, but the plan is to remove it to its own repository for clarity.

# AON & BON

Two object notation are implemented within this repostiory, AON and BON, for ASCII Object Notation and Binary Object Notation. While one would think that a pure binary implementation would be the most compact, there are some interesting properties that are adventageous to an ASCII approach in some contexts.

Both are presented and tested side by side and a comparison of compactness made in the unit tests.

AON's approach is to use little used control characters within the ASCII table as delimiters of fields. The implication is that these characters cannot be used within strings or must be escaped/quoted if they are used. Characters of the JSON specification like curly and square braces, or quotes and commas are replaced with control characters. Curly braces: ^1 & !4, Square braces: ^2 & ^3, Quotes: ^15, Commas: ^31, Colon: ^14, Null Value: ^25. 

At first brush, this approach seems silly, but it does have the advantage of allowing variable length fields.  It also allows for protocol level manipulation of the packets where objects can be encoded based on differences from the last packet. The later is a technique similar to run length encoding which skips n characters that are the same, only here, skipping n fields that haven't changed since the last packet sent.

BON's approach is include length within the schema specification so that binary values of fixed length can be sent and extracted from the message packet representing the object. This is a straight forward approach that will win in the packet size competition where values change consistently and often.

# AON

# BON

Built with love in coffeescript.

TODO: 
More tests
Separate out PIOTON
Implement schema definition better, realign with JSON Schema.
Documentation website with github
