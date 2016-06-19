try
    environment = process.env.PARAM1
    environment ?= 'Local'


    debug = process.env.DEBUG == 'true' || false

    Context = {
        env: environment
        debug: debug
    }

    if (environment == 'Local')
        Context.logger = console
        Context.loadTest = false
        Context.debug = true
    else
        Loggly = require('loggly')
        Context.logger = Loggly.createClient({
            token: "a9ab4898-5e03-4144-bd51-fab7a9bc42ec",
            subdomain: "mojio",
            tags: ["NodeJS", "IOTONNodeServer", environment],
            json:true
        })

    Context.logger.log("IOTON Node Server starting up... #{Context.env}")
    Context.logger.log("Debug?: " + Context.debug)
    Context.logger.log("Logger?: " + if Context.env == 'Local' then "Console" else "Loggly")

    module.exports = Context

catch error
    Context.logger.log("Error in Context: "+error)

