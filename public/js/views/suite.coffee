define ['backbone'], (Backbone) ->
	return Backbone.View.extend
		tagName: 'div'
		className: 'suite-row'

		initialize: () ->
			@model.on 'change',@render,@
			return

		render: () ->
			@$el.html @options.template
				suite: @model
			@$el.removeClass().addClass('success span6')


			

