fs = require 'fs'
path = require 'path'
cs = require 'coffee-script'
uuid = require 'node-uuid'

export.timedEvent = (event,args,delay,app) ->
	w = app.get 'logger'

	_emitEvent = (event) ->
		app.emit(event,args)
	setInterval _emitEvent, delay

	return
