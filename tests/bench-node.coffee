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
for i in [0..100]
	obj[i.toString()] = i
	map.set(i.toString(), i)

copy = {}
bench 'Normal object for loop (keys only)', ->
	for k of obj
		copy[k] = obj[k]