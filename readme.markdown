# IOTON
Version 0.0.2

A JSON like object notation for the internet of things.

# The Problem

There is this thing called JSON. It’s become the defect standard format for passing objects.  The goto for representation of data. But, its more expensive than custom solutions in the context of mobile networks because it has a lot of unnecessary characters used to communicate semantic context. Most of the time, both ends of a point to point connection know the context, meaning the semantic information only needs to be passed once, when the two sides first connect.

In the device world, engineers are constantly inventing their own object notations, requiring that anyone wishing to communicate with the device do a bunch of "bit twaddling" to decifer the notation and write a parser for it. 

What if one notation could be made where the parse only had to be created once and everyone used it? Isn't that JASN? So how can these two things be unified.

# An aside: 

There are lots of protocols that mix object notation with communication protocols and transport. This complicates a problem that should be simple.  Object notation should be a separate concern from protocol and transport definitions. To put it another way, how packets get wrapped and delivered should not be dependent on the contents of those packets. Envelopes and delivery men don't care what's in the package, only that it's wrapped correctly.

# IOTON

The idea is to make packet size smaller by passing semantic information as a JSON schema in a separate message from the content. Follow on communication only includes an delimited list of fields, preferably binary, but possibly not.

The schema is sent once when communication is established, allowing both ends of the communication to be able to put the semantic information back together with the content when it is delivered.

# Schema 

The schema needs to communicate three pieces of information in order for both parties to 

# AON & BON

Two object notations 
Built with love in coffeescript.

TODO: 
more tests
