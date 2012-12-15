@_ = @_ || {}

@sock.on 'run.request', (options,cb) => 
	test = new @_.CasperTest
		uid: options.uid
		sock: @sock
		verbose: true
		exitOnError: false
		logLevel: 'debug'
		viewportSize:
			width: 1440
			height: 900

	for step in options.steps
		@log "Adding step: #{step[0]}", "info"
		test.addStep step...

	test.run () ->
		@log "Test run completed", "info"
		@test.done()
		phantom.clearCookies()

	cb(true) # When server receives this, it should lock the test until we're done (or timeout)

		