mongoose = require 'mongoose'
moment = require 'moment'
_s = require 'underscore.string'

Message = new mongoose.Schema
    id:
        type: mongoose.Schema.Types.ObjectId
    _run:
        type: mongoose.Schema.Types.ObjectId
        required: true
        ref: 'Run'
    type:
        type: String
    step:
        type: Number
    stepname:
        type: String
    properties: 
        type: mongoose.Schema.Types.Mixed
    time:
        type: Number

    _modified: 
        type: Date

.pre 'save', (next) ->
    this._modified = new Date()
    next()

Message.virtual('modified').get () -> 
    return moment this._modified

Message.virtual('created').get () -> 
    return moment this._id.generationTime

module.exports = Message