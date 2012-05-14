{exec} = require 'child_process'

execAndPipe = (execString, restart) ->
	piper = exec execString

	piper.stderr.on 'data', (data) ->
		# console.log "** #{execString} error **"
		process.stderr.write data.toString()
	piper.stdout.on 'data', (data) ->
		# console.log "-- #{execString} --"
		process.stdout.write data.toString()
			
task 'watch', 'Compile Speedr in watch mode', ->
	execAndPipe 'coffee -cbw speedr.coffee'

task 'w', 'Shorthand for "watch"', -> invoke 'watch'

task 'minify', 'Minify the compiled javascript', ->
	execAndPipe 'uglifyjs -nm -o speedr-min.js speedr.js'
	
task 'test', 'Run tests', ->
	execAndPipe 'cd tests && coffee tests-node.coffee'
	
task 'bench', 'Run benchmarks', ->
	execAndPipe 'cd tests && coffee bench-node.coffee'