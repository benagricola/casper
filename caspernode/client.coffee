phantom.injectJs "socket.io.min.js"
env = require('system').env

class CasperNode
	
	accepted: false

	maxRetryAttempts: 5

	constructor: (host,port,password) ->
		@socketUri = "#{host}:#{port}"
		@password = password
		@connect()

	connect: () ->
		console.log "Attempting to connect to CasperGrid via websocket (#{@socketUri})" , "INFO"
		@logsock = io.connect "#{@socketUri}/log?pass=#{@password}", 
			'connect timeout': 5000
			'try multiple transports': false
			'max reconnection attempts': @maxRetryAttempts
		@sock = io.connect "#{@socketUri}/test?pass=#{@password}", 
			'connect timeout': 5000
			'try multiple transports': false
			'max reconnection attempts': @maxRetryAttempts

		@sock.on 'connect', () =>
			@info('Client registers connection with data socket')
			@bootstrap()
			return

		@sock.on 'error', @_forceExit

		# Force exit after x attempts (socket.io inbuilt retry doesnt emit
		# connect / reconnect_failed )
		@sock.on 'reconnecting', (delay,attempt) =>
			@warn "Reconnection attempt #{attempt}"
			if attempt is @maxRetryAttempts
				@_forceExit()
		@sock.on 'connect_failed', @_forceExit
		
			
		@sock.on 'bootstrap', @_bootstrap

		@sock.on 'disconnect', () =>
			@info('Client disconnected from data socket')
			return

		@logsock.on 'connect', () =>
			@info('Client registers connection with logging socket')
			return

		@logsock.on 'disconnect', () =>
			@info('Client disconnected from logging socket')
			return
		return

	bootstrap: () ->
		@debug 'Running bootstrap'
		@sock.emit 'bootstrap'

	_bootstrap: (code) =>
		try
			code = new Function("#{code}")
			code.apply @
			@info "Bootstrapped code from server"
			return true
		catch error
			@error "Unable to load bootstrap code: #{error}"
			setTimeout @bootstrap, 20000
			return false 

	_forceExit: () =>
		@error 'Forcing exit due to connection'
		phantom.exit()

	log: (level,msg) ->
		console.log "[#{level}] #{msg}"
		@logsock.emit 'log', 
			level: level
			msg: msg

	info: (msg) ->
		@log('info',msg)

	debug: (msg) ->
		@log('debug',msg)

	warn: (msg) ->
		@log('warn',msg)

	error: (msg) ->
		@log('error',msg)

console.log env['HUB_URL']
node = new CasperNode env['HUB_URL'] or 'localhost', env['HUB_PORT'] or 8080, env['HUB_PASS'] or ''
node.info 'Initiated new CasperNode'