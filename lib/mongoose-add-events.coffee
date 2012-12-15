mongoose = require 'mongoose'

module.exports = exports = crudEventsPlugin = (schema,options) ->
    if not options.ee?
        throw "Must provide an ee (EventEmitter) on which events can be emitted / listened for"
    if not options.name?
        throw "Must provide a name for schema events"

    Model = mongoose.model options.name

    # Calculate whether this is a new or old 
    schema.pre 'save', (next) ->
        @_wasNew = @isNew
        console.log "Saving #{options.name}..."
        next()
        return

    schema.post 'save',(data) ->
        if @_wasNew
            console.log "Saved new item #{options.name} (#{@_id})..."
            options.ee.emit "#{options.name}:created",@
        else
            console.log "Saved updated item #{options.name} (#{@_id})..."
            options.ee.emit "#{options.name}/#{@_id}:updated",@
        return  

    schema.post 'remove',(next) ->
        console.log "Deleted item #{options.name} (#{@_id})..."
        options.ee.emit "#{options.name}/#{@_id}:deleted",@
        next()
        return

    # Creating a model will automatically create it in the relevant collection
    options.ee.on "#{options.name}:create", (data,fn) ->
        newModel = new Model data
        newModel.save (err,dbEntry) ->
            return fn err if err
            return fn null, dbEntry

    options.ee.on "#{options.name}:read", (data,fn) ->
        Model.find(data).exec (err,dbEntries) ->
            return fn err if err
            return fn null, dbEntries

    # Updating is model only, but this should also trigger a collection update
    options.ee.on "#{options.name}:update", (data,fn) ->
        Model.findById data._id, (err,dbEntry) ->
            return fn err if err

            dbEntry.set(data)
            
            dbEntry.save (err,dbEntry) ->
                return fn err if err
                return fn null, dbEntry

    # Delete only concerns the collection since this is where it's deleted from.
    options.ee.on "#{options.name}:delete", (data,fn) ->
        Model.findByIdAndRemove data._id, (err,dbEntry) ->
            return fn err if err
            return fn null, dbEntry
    return Model