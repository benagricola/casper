define ['backbone'], (Backbone) ->
	return Backbone.View.extend

		initialize: (options) ->
			@app = options.app
			return

		render: () ->
			#$(@el).html @app.templates['suite-add']()
			#return

