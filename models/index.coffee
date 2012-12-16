mongoose = require 'mongoose'
_s = require 'underscore.string'

addEvents = require '../lib/mongoose-add-events'

# Schemas go here
schemas = 
    test: require './test'
    run: require './run'
    message: require './message'

# We want to add events to all of our models, this allows them
# to send and receive events on the app object, which can be picked
# up and used or fired off in different places (e.g. websockets)
module.exports = (app) ->
    for schemaName, schema of schemas
        mongoose.model _s.capitalize(schemaName),schema
        schema.plugin(addEvents, { ee: app.get('io').of('/view'), name: _s.capitalize(schemaName) })
