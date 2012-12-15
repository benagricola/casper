module.exports = (app) ->
	w = app.get 'logger'
	io = app.get 'io'

	io.of('/log').authorization (data,cb) ->
		connectPassword = data?.query?.pass
		if connectPassword == app.get 'casper-password'
			cb '',true
		else
				cb 'Password given does not match',false
		return

	io.of('/log').on 'connection', (socket) ->
		w.info "Websocket logging client connected with ID: #{socket.id}"
		socket.on 'log', (args) ->
			w.log args.level, "[#{socket.id}] #{args.msg}"
			return
		return