mongoose = require 'mongoose'
moment = require 'moment'
_s = require 'underscore.string'

Test = new mongoose.Schema
	id:
		type: mongoose.Schema.Types.ObjectId
	name:
		type: String
		required: true
		unique: true
		trim: true
	description:
		type: String
		required: false
		default: ''
	steps: 
		type: mongoose.Schema.Types.Mixed
	runCount:
		type: Number
		default: 0
	interval:
		type: Number
		default: 300000 # 5 Minutes
	_lastRun:
		type: Date
		required: false
	locked:
		type: Boolean
		default: false
	_modified: 
		type: Date

.pre 'save', (next) ->
	this.name = _s.capitalize this.name
	this._modified = new Date()
	next()

Test.virtual('modified').get () -> 
	return moment this._modified

Test.virtual('created').get () -> 
	return moment this._id.generationTime

Test.virtual('lastRun').get () -> 
	return moment this._lastRun

module.exports = Test