fs = require 'fs'
cs = require 'coffee-script'
uuid = require 'node-uuid'
jsp = require 'uglify-js'

# Configure initial sockets and logger
module.exports = (server,app) ->
    w = app.get 'logger'
    io = require('socket.io').listen server

    io.configure () ->
        io.set 'logger', w
        io.set 'log level', 3
        #io.set 'heartbeat interval', 5
        #io.set 'heartbeat timeout', 10
        io.enable 'browser client minification'
        io.enable 'browser client etag'
        io.enable 'browser client gzip'
        return

    app.set 'io',io

