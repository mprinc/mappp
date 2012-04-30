{exec} = require 'child_process'

execAndPipe = (execString, restart = true) ->
	piper = exec execString

	piper.stderr.on 'data', (data) ->
		# console.log "** #{execString} error **"
		process.stderr.write data.toString()
	piper.stdout.on 'data', (data) ->
		# console.log "-- #{execString} --"
		process.stdout.write data.toString()

	piper.on 'exit', (code) ->
		console.log "** #{execString} exited with code #{code} **"
		if restart
			console.log 'restarting...'
			execAndPipe execString
			
task 'watch', 'Compile speedr in watch mode', ->
	execAndPipe 'coffee -cbw speedr.coffee', false

task 'w', 'Shorthand for "watch"', -> invoke 'watch'
