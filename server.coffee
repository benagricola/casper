uuid = require 'node-uuid'
mongoose = require 'mongoose'

app = require('express')()

require('./config/version')(app)
require('./config/environment')(app)
require('./config/routing')(app)
require('./config/database')(app)

server = require('./lib/socketbind')(app)

# Initialise websockets
require('./config/sockets')(server,app)

# Load socket functionality
require('./lib/log-sockets')(app) 
require('./lib/test-sockets')(app) 

# Load test client data management
require('./config/clientdata')(app)
	
require('./models')(app) 

# Get all stored tests and set up run intervals for them
Test = mongoose.model 'Test'

Test.find (err,tests) ->
	return console.log err if err
	# For each test, add a new interval to run the tests
	for test in tests
		do (test) ->
			setInterval (args...) ->
				app.emit 'test:run',args...
			,test.interval,test
			return



###Test = mongoose.model 'Test'
newModel = new Test
	name: 'HFM Week Login Test 2'
	description: 'Login test'
	steps: [
		[ "start", "http://www.hfmweek.com" ]
		[ "element-exists", "li.login > span", "Checking for existence of login area" ]
		[ "click", "li.login > span" ]
		[ "wait-for-element-visible",".login .area"  ]
		[ "element-visible", "#log_in_out_button","Checking for login button visibility" ]
		[ "element-exists", "#log_in_out_button", "Checking for existence of login button" ]
		[ "fill-form",".login .area form", 
			SQ_LOGIN_USERNAME: 'selenium_user' 
			SQ_LOGIN_PASSWORD: '2=:U8:!zD;4{"*+' 
		, false ]
		#[ "capture" ]
		[ "click", "#log_in_out_button" ]
		[ "wait-for-text", "You are currently logged in as" ]
		[ "element-has-text", "li.login > span", "Log out", "Checking that login button is now log out" ]
	]

newModel.save (err,dbEntry) ->
	console.log(err,dbEntry)
console.log()###