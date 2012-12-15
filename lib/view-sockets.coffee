module.exports = (app) ->
    w = app.get 'logger'
    io = app.get 'io'

    io.of('/view').on 'connection', (socket) ->
        w.info "Websocket view client connected with ID: #{socket.id}"

    io.of('/view').on ''

    return