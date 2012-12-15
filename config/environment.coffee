express = require 'express'
w = require 'winston'

logger = new w.Logger
    transports: [
        new w.transports.Console
            timestamp: true
            colorize: true
    ]

module.exports = (app) ->
    app.configure () -> 
        app.set 'port', process.env.PORT || 3000
        app.set 'views', 'views'
        app.set 'view engine', 'jade'
        app.use express.favicon()
        app.use logger
        app.use express.static 'public'
        app.use express.bodyParser()
        app.use express.methodOverride()
        app.use express.cookieParser 'KJHKJdhkjHSKJhKJSHDKJSD'
        app.use express.session()
        app.use express.responseTime()
        return

    app.set 'logger', logger
    app.set 'casper-password', 'acjB9FYSJa8MTeOwQqlgFrrMXUMklo9u8V0n6wh0'
    app.set 'test-timeout', 120000
    app.set 'client-code-dir', './client-code'
    
    app.configure 'development', () ->
        app.use express.errorHandler
            'dumpExceptions': true
            'showStack': true
        return
    

    app.configure 'production', () ->
        app.use express.errorHandler()
        return

    return
