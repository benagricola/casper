mongoose = require 'mongoose'
moment = require 'moment'
_s = require 'underscore.string'

Run = new mongoose.Schema
    id:
        type: mongoose.Schema.Types.ObjectId
    _test:
        type: mongoose.Schema.Types.ObjectId
        required: true
        ref: 'Test'
    count:
        type: Number
        required: true
        default: 0
    startTime:
        type: Date
        required: true
        default: Date.now
    endTime:
        type: Date
        required: false
    _modified: 
        type: Date

.pre 'save', (next) ->
    this._modified = new Date()
    next()

Run.virtual('modified').get () -> 
    return moment this._modified

Run.virtual('created').get () -> 
    return moment this._id.generationTime

module.exports = Run