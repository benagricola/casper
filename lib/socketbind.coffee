_ = require 'underscore'
fs = require 'fs'

setPrivs = (uid,gid) -> 
    try 
    
        gid? process.setgid gid 
        uid? process.setuid uid
    catch e
        console.log "Unable to setuid(%s) / setgid(%s)!",uid,gid
        process.exit 1 

module.exports = (application) ->

    port = process.env.PORT || 8080
    host = process.env.HOST;

    uid = process.env.RUN_AS_USER || null
    gid = process.env.RUN_AS_GROUP || null

    oldUmask;

    if !_.isNumber port
        oldUmask = process.umask 0o0002
        setPrivs uid,gid
    
    server = application.listen port,host, () ->

        listen = if server.address()?.address then server.address().address + ':' + server.address().port else 'socket ' + server.address()
        console.log "Express server listening on %s in %s mode",listen,application.settings.env
        
        if _.isNumber(port)
            setPrivs uid,gid
        else 
            process.umask oldUmask
        return

    return server