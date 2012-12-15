module.exports = (app) ->
	w = app.get 'logger'
	io = app.get 'io'

	io.of('/log').on 'connection', (socket) ->
		w.info "Websocket logging client connected with ID: #{socket.id}"
		socket.on 'log', (args) ->
			w.log args.level, "[#{socket.id}] #{args.msg}"
			return
		return