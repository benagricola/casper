uuid = require 'node-uuid'
mongoose = require 'mongoose'

socketRR = []

module.exports = (app) ->
    Run = mongoose.model 'Run'
    Message = mongoose.model 'Message'

    w = app.get 'logger'
    io = app.get 'io'

    app.on 'clientdata:updated', (args) ->
        io.of('/test').emit 'bootstrap', args
        return

    runTest = (test) ->
        # Check we have registered socket test clients
        if socketRR.length < 1 
            return w.error "No test client to run test on"

        w.debug "Test client pool is: #{socketRR.length}"

        # Make sure test is not currently locked (running)
        if test.locked
            return w.error "Test is currently locked"

        # Pick the next test client
        targetSockId = socketRR.shift()
        targetSock = io.of('/test').socket targetSockId

        # If disconnected, pick next client
        if targetSock.disconnected
            return runTest test
        
        newRunId = new mongoose.Types.ObjectId()

        targetSock.emit 'run.request',
            _id: newRunId
            steps: test.steps
        , (result) ->
            # This callback occurs when the test run start is acknowledged
            w.debug "Confirmed run request started"

            # Lock the test and increment its' run count
            test.set(locked: true,runCount: test.runCount + 1).save()
                
            # TODO setTimeout and fire a run.abort if it runs too long
            abortTimer = setTimeout () ->
                targetSock.emit 'run.abort'
                test.set(locked: false).save()
                socketRR.push targetSockId
                return
            ,app.get 'test-timeout'

            # Catch run.start and use it to create a new run record
            targetSock.once 'run.start', (args) ->
                newRun = new Run
                    _id: args.run
                    _test: test._id
                    count: test.runCount + 1
                    startTime: new Date()
                newRun.save()
                return

            # When test is finally completed, re-add the sock to the rr list
            targetSock.once 'run.complete', (args) ->
                clearTimeout abortTimer

                test.set(locked: false).save()

                Run.findOne
                    _id: args.run
                ,(err,run) ->
                    return w.error "Could not find run by UID #{args._id}" if err
                    run.endTime = new Date()
                    run.save()

                socketRR.push targetSockId
                return
            return

        return

    # Listen for the test:run event
    app.on 'test:run', (test) ->
        return runTest test

    io.of('/test').authorization (data,cb) ->
        connectPassword = data?.query?.pass
        if connectPassword == app.get 'casper-password'
            cb '',true
        else
            cb 'Password given does not match',false
        return

    io.of('/test').on 'connection', (socket) ->
        w.info "Websocket test client connected with ID: #{socket.id}"

        socket.on 'disconnect', () ->
            console.log "Websocket test client disconnected with ID: #{socket.id}"
            rrIndex = socketRR.indexOf socket.id
            return socketRR.splice rrIndex, 1 if rrIndex isnt -1
                
        # On bootstrap, emit app event to get compiled client code
        socket.on 'bootstrap', () ->
            w.info "Requested bootstrap"
            # Emit an app event and wait for callback with code
            app.emit 'clientdata:bootstrap', (data) ->
                # Emit data to client
                socket.emit 'bootstrap', data

                # If client has not already been bootstrapped, add it to
                # the RR list of socket and save its' bootstrapped status
                socketRR.push socket.id
                socket.get 'bootstrapped', (err,bootstrapped) ->
                    if not bootstrapped or err
                        socket.set 'bootstrapped', true, () ->
                            w.debug "Test client pool is: #{socketRR.length}"
                    return
                return
            return

        # Catch all run messages and use them to create new run message records.
        socket.on 'run.msg', (args) ->
            newMessage = Message
                _run: args.run
                type: args.type
                time: args.time
                step: args.step
                stepname: args.name

            ###args.run = undefined
            args.type = undefined
            args.time = undefined
            args.name = undefined
            args.step = undefined
            
            newMessage.set
                properties: args
            ###
            newMessage.save()
            return
        return
    return