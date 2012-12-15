mongoose = require 'mongoose'

module.exports = exports = (app) ->
	app.set 'database',mongoose.connect 'mongodb://127.0.0.1/casper', () ->
		console.log 'Mongoose connected...'
