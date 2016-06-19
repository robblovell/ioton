# IOTON
Version 0.0.2

A JSON like object notation for the internet of things.

The idea is to make packet size smaller by passing semantic information as a JSON schema in a separate message from the content.
The schema is sent once when communication is established, allowing both ends of the communication to be able to put the semantic information back together with the content when it is delivered.

Build with love in coffeescript.

TODO: 
more tests
