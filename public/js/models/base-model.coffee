define ['backbone'], (Backbone) ->
	return Backbone.Model.extend

		idAttribute: '_id'

		initialize: () ->
			@ioBind 'update', @update, @
			@ioBind 'delete', @delete, @

		update: (data) ->
			console.log 'Remote update with data',data
			@set data
			return
			
		delete: (data) ->
			console.log 'Remote delete with data',data
			if @collection then @collection.remove(@) else @trigger 'remove', @ 
			@ioUnbindAll()
			return