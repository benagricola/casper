index = require '../routes/index'

module.exports = (app) -> 
    app.get '/', index.index
    #app.get '/js/template.js', index.template

    app.get '*', index.index

    return
