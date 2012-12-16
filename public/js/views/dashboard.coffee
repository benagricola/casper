define ['backbone','views/suite'], (Backbone,SuiteView) ->
	return Backbone.View.extend
		el: 'body'

		suiteViews: {}

		initialize: () ->
			@app = @options.app
			return

		activate: () ->
			@app.collections.suites.off().on 'reset', () =>
				@clearViews()
				@render()
			.on 'add', () =>
				@renderSuites()
			@app.collections.suites.fetch()
			return
		
		clearViews: () ->
			_.each @suiteViews, (viewID,view) ->
				view.$el.remove()
				view.clear
					silent: true
			@suiteViews = {}

		render: () ->
			@$el.html @app.templates['dashboard']()
			@renderSuites()
			@$el.removeClass().addClass 'dashboard'
 
			return

		renderSuites: () ->
			console.log "Render all suites" + @app.collections.suites.length
			@app.collections.suites.each @renderSuite, @

		renderSuite: (suite) ->
			console.log "Rendering #{suite.get('name')} suite"
			console.log(@)
			suiteView = new SuiteView
				app: @app
				id: "suite-row-#{suite.id}"
				model: suite
				template: @app.templates['suite-detail']
			suiteView.render()
			@$('.suite-detail').append(suiteView.el)
			return

