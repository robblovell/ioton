#!/usr/bin/env node

#/**
# * Module dependencies.
# */

app = require('../main')
debug = require('debug')('express:server')
http = require('http')
Context = require('../src/Context')
#/**
# * Normalize a port into a number, string, or false.
# */

normalizePort = (val) ->
    port = parseInt(val, 10)

    if (isNaN(port))
#        // named pipe
        return val

    if (port >= 0)
#        // port number
        return port

    return false


#/**
# * Event listener for HTTP server "error" event.
# */

onError = (error) ->
    if (error.syscall != 'listen')
        throw error

    bind = if typeof port == 'string' then 'Pipe ' + port else 'Port ' + port

    #// handle specific listen errors with friendly messages
    switch (error.code)
        when 'EACCES'
            Context.logger.log(bind + ' requires elevated privileges')
            process.exit(1)

        when 'EADDRINUSE'
            Context.logger.log(bind + ' is already in use')
            process.exit(1)
        else
            throw error

#/**
# * Event listener for HTTP server "listening" event.
# */

onListening = () ->
    addr = server.address()
    bind = if typeof addr == 'string' then 'pipe ' + addr else 'port ' + addr.port

    Context.logger.log('Listening on ' + bind)

#/**
# * Get port from environment and store in Express.
# */

port = normalizePort(process.env.PORT || '3000')
app.set('port', port)

#/**
# * Create HTTP server.
# */

server = http.createServer(app)

#/**
# * Listen on provided port, on all network interfaces.
# */

server.listen(port)
server.on('error', onError)
server.on('listening', onListening)
