###
Without any more extending, this class can simply be used as a generic
collection by instantiating it with a url. It creates its' own generic
model which contains the same url (required to allow creating the model
outside of a collection - not that this should occur, really).
###
define ['backbone','models/base-model'], (Backbone,BaseModel) ->
	return Backbone.Collection.extend

		url: () ->
			throw new Error 'You need to override url() in your extended collection!'

		initialize: (models,options) ->
			@url = options.url or @url
			@model = options.model || BaseModel.extend
				urlRoot: @url
			@ioBind 'create', @_create, @
			

		_create: (data) ->
			console.log 'Remote create with data',data
			if @.get(data._id) then @.get(data._id).set(data) else @add(data)
			return


		