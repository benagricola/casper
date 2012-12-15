uuid = require 'node-uuid'

module.exports = (app) ->
	socketRR = []

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
			return runTest(test)
		else
			testObject = test.toObject()
			# Otherwise emit test event to client
			testObject.uid = uuid.v4()

			w.debug "Emitting run request: UID #{testObject.uid}"
			targetSock.emit 'run.request',testObject, () ->
				w.debug "Confirmed run request started"

				# This callback occurs when the test run start is acknowledged
				test.set(locked: true).save()

				# setTimeout and fire a run.abort if it runs too long
				
				# When test is finally completed, re-add the sock to the rr list
				targetSock.on 'run.complete', (status) ->
					test.set(locked: false).save()
					socketRR.push targetSockId
		return

	# Listen for the test:run event
	app.on 'test:run', (test) ->
		return runTest args

		
	io.of('/test').authorization (data,cb) ->
		connectPassword = data?.query?.pass
		if connectPassword == app.get 'casperPassword'
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
	return