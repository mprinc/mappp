speedr = require '../speedr'
_      = require 'underscore'

bench = (name, f) ->
	before = new Date()
	f()
	after  = new Date()
	console.log "#{name}: #{after.getTime() - before.getTime()} ms"
	
# make test objects
obj = {}
map = new speedr.Map()
for i in [0..1000000]
	iS = i.toString()
	obj[iS] = iS
	map.set([iS, iS])

counter = 0
bench 'Normal object for loop (keys only)', ->
	for k of obj
		counter++
		
counter = 0
bench 'Normal object for loop (keys and values)', ->
	for k, v of obj
		counter++
		
counter = 0
bench 'speedr.js map eachKey function', ->
	map.eachKey (k) ->
		counter++
		
counter = 0
bench 'speedr.js map eachVal function', ->
	map.eachVal (v) ->
		counter++
		
counter = 0
bench 'speedr.js map each function', ->
	map.each (k,v) ->
		counter++
		
counter = 0
bench 'speedr.js map iterKey function', ->
	for i in [0...map.length]
		k = map.iterKey(i)
		counter++
		
counter = 0
bench 'speedr.js map iterVal function', ->
	for i in [0...map.length]
		v = map.iterVal(i)
		counter++

counter = 0
bench 'speedr.js map iter function', ->
	for i in [0...map.length]
		[k,v] = map.iter(i)
		counter++