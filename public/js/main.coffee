require.config
	shim:
		'$':
			exports: '$'
		'Moment':
			exports: 'moment'
		'underscore':
			exports: '_'
		'underscore.string': ['underscore']
		'socket.io':
			exports: 'window.io'
		'backbone':
			deps: ['underscore','$']
			exports: 'Backbone'
		'template':
			exports: 'templates'
		'Bootstrap': ['$']
		'bb.iosync': ['underscore','backbone']
		'bb.iobind': ['underscore','backbone']
		'CasperFrontend':
			deps: ['socket.io','backbone','Moment','Jade','Bootstrap']
	paths:
		'socket.io': '/socket.io/socket.io'
		'$': 'lib/jquery.min'
		'underscore': 'lib/underscore.min'
		'underscore.string': 'lib/underscore.string.min'
		'backbone': 'lib/backbone'
		'bb.iosync': 'lib/backbone.iosync.min'
		'bb.iobind': 'lib/backbone.iobind.min'
		'Moment': 'lib/moment.min'
		'Jade': 'lib/runtime.min'
		'Bootstrap': 'lib/bootstrap.min'
		'CasperFrontend': 'casper'

require [ 
	'$'
	'underscore'
	'backbone'
	'Moment'
	'CasperFrontend'
	'Bootstrap'
	'underscore.string'
	'bb.iosync'
	'bb.iobind'
], ($,_,Backbone,moment,CasperFrontend) ->
	_.mixin _.string.exports()

	window.Casper = new CasperFrontend()

	Backbone.history.start
		pushState: true

