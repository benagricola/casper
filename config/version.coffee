module.exports = (app) -> 
    app.set 'name','CasperGrid'
    app.set 'version','0.1d'

    app.locals.appName = app.set 'name'
    app.locals.appVersion = app.set 'version'

    return