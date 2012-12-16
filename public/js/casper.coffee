define ['socket.io','backbone','models/base-collection','template','views/dashboard','views/addsuite'], (io,Backbone,BaseCollection,templates,DashboardView,AddSuiteView) ->
	return Backbone.Router.extend
		views: {}
		collections: {}

		routes:
			'':			'dashboard'
			dashboard: 	'dashboard'
			'add-suite': 'addsuite'
			log:		'log'

		initialize: () ->
			@_initSocket()

			@templates = templates
			
			@views.addsuite = new AddSuiteView
				app: @

			@views.dashboard = new DashboardView
				app: @

			@collections.suites = new BaseCollection null, 
				url: 'suite'

			@collections.groups = new BaseCollection null,
				url: 'group'
				data: {}

			@collections.messages = new BaseCollection null,
				url: 'message'
				data: {}

			@collections.runs = new BaseCollection null,
				url: 'run'
				data: {}
			
			console.log 'Fetching...'
			#_.invoke @collections, 'fetch'

			return @

		_initSocket: () ->

			@socket = Backbone.socket = window.socket = io.connect()

			@socket.of('/view').on 'connect', () ->
				console.log 'Socket.IO Connected'

			@socket.of('/view').on 'message', (data) ->
				console.log data

		dashboard: () ->
			console.log 'Render dashboard'
			@views.dashboard.activate()

		addsuite: () ->
			console.log 'Render addsuite'
			#@views.addsuite.render()

		log: () ->
			console.log 'Render log'