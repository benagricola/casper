Casper = require('casper').Casper
utils = require 'utils'

@_ = @_ || {}

class @_.CasperTest extends Casper
    stepNames: []
    currentStepResults: []

    constructor: (options) ->
        @sock = options.sock
        @uid = options.uid
        options.sock = undefined
        super options

        # We need to override the onTimeout callbacks so they do NOT call @die
        @options.onStepTimeout = (timeout,stepNum) ->
            @log "Step timeout of #{timeout}ms reached on step #{stepNum}", "error"

        @options.onWaitTimeout = (timeout) ->
            @log "Wait timeout of #{timeout}ms reached", "error"

        @options.onTimeout = (timeout) ->
            @log "Script timeout of #{timeout}ms reached", "error"

        @sock.on 'run.abort', () =>
            @log "Aborting (exiting) on run.abort","error"
            phantom.exit(1) # Rely on something to restart the test clients

        @on 'run.start', (args) ->
            @sock.emit 'run.start', uid: @uid

        @on 'run.complete', (args) ->
            @clear()
            @sock.emit 'run.complete', uid: @uid, time: @result.time

        @on 'step.start', (args) ->
            @currentStepResults = []
            @sock.emit 'step.start',
                uid: @uid, id: @currentStep(), name: @currentStepName(), time: @currentTime()

        @on 'step.complete', (args) ->  
            @sock.emit 'step.complete', 
                uid: @uid, id: @currentStep(), name: @currentStepName(), time: @currentTime(), results: @currentStepResults

        @on 'step.timeout', (args) ->
            console.log 'Step timeout occurred'

        @test.on 'success', (result) =>
            @currentStepResults.push result
            @sock.emit 'test.success', uid: @uid, result: result

        @test.on 'fail', (result) =>
            @currentStepResults.push result
            @sock.emit 'test.fail', uid: @uid, result: result

    currentTime: () ->
        return new Date().getTime() - this.startTime

    currentStep: () ->
        return @step-1

    currentStepName: () ->
        return @stepNames[@step-1]

    loadSteps: (steps) ->
        if steps[0]?.command? != 'start'
            @log 'First step MUST be start', 'error'
            throw "First step MUST be start"
            return
        @createStep step.command, step.opts for step in steps
        return

    addStep: (command,opts...) =>
        
        @log "Creating step #{command}", 'info'

        switch command

            when 'start' 
                @start opts..., () ->
                    @test.assertTrue 0 == @getCurrentUrl().indexOf opts[0], "Can browse to #{opts[0]}"
                    @log "Starting with URL: #{@getCurrentUrl()}",'info'

            when 'url-open'
                @thenOpen opts..., () ->
                    @log "Now opening URL: #{@getCurrentUrl()}",'info'

            when 'element-exists'
                @then () ->
                    @test.assertExists opts...

            when 'element-has-text'
                @then () ->
                    @test.assertSelectorHasText opts...

            when 'element-visible'
                @then () ->
                    @test.assertVisible opts...

            when 'wait-for-protocol'
                @waitFor () ->
                    return @getCurrentUrl().split(':')[0] == opts[0]
                ,opts[1..]...

            when 'is-protocol'
                @then () ->
                    @test.assertTrue @getCurrentUrl().split(':')[0] == opts[0], opts[1..]

            when 'is-status'
                @then () ->
                    @test.assertHttpStatus opts...

            when 'wait-for-element-visible'
                @waitUntilVisible opts...   

            when 'wait-for-text'
                @waitForText opts...

            when 'capture'
                @then () ->
                    @sock.emit 'capture.saved', @captureBase64 'jpeg'

            when 'click'
                @then () ->
                    @click opts...

            when 'fill-form'
                @then () ->
                    @fill opts...

            else
                return @log "Unknown command #{command}!",'error'

        @stepNames.push command
        return



