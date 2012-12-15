fs = require 'fs'
path = require 'path'
cs = require 'coffee-script'
uuid = require 'node-uuid'
jsp = require 'uglify-js'

code = {}

module.exports = (app) ->
    w = app.get 'logger'
    io = app.get 'io'

    compileFiles = (directory) ->
        for filename in fs.readdirSync directory
            do (filename) ->
                return if filename.split('.').pop() != 'coffee'
                abspath = path.join directory,filename
                w.info "Compiling #{abspath}..."
                compilePath abspath
                return
        return

    watchFiles = (directory) ->
        fs.watch directory, (event,filename) ->
            return if event == 'rename'
            return if filename.split('.').pop() != 'coffee'
            abspath = path.join directory,filename
            w.info "File change detected on #{abspath}, recompiling..."
            ## Listen to test files and update clients if required
            compilePath abspath
            return
        return

    compilePath = (path) ->
        fs.stat path, (err,stat) ->
            return w.error err if err
            modifiedTime = stat.mtime.getTime()
            if modifiedTime > (code[path]?.mtime || 0)
                code[path] = {} if not code[path]?
                code[path].mtime = modifiedTime # Set this NOW so 2 events in quick succession wont dupe
                fs.readFile path, (err,data) ->
                    code[path].data = jsp.minify(cs.compile(data.toString(),bare: false),fromString: true).code
                    app.emit "clientdata:updated", outputCode()


    outputCode = () ->
        sourceCode = for file, src of code
            "#{src.data}"
        return sourceCode.join('')


    clientCodeDir = app.get('client-code-dir')
    compileFiles clientCodeDir
    watchFiles clientCodeDir

    # When we receive a bootstrap event, return the callback with our output code
    app.on "clientdata:bootstrap", (cb) ->
        return cb? outputCode() ? ''

    return
