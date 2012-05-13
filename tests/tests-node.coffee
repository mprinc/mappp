speedr = require '../speedr'
_      = require 'underscore'

STATUS = 'ok'

testCount = 0
test = (name, result, expected) ->
	if not _.isEqual(result, expected)
		STATUS = 'WITH ERRORS'
		console.log "#{name} FAILED"
		console.log "Got:      #{result}"
		if result == Object(result)
			console.log ("#{i}: #{v}" for i,v of result)
		console.log "Expected: #{expected}"
		if expected == Object(expected)
			console.log ("#{i}: #{v}" for i,v of expected)
	testCount++

rambo = (min, max) ->
	if not max? then [max, min] = [min, 0]
	return Math.floor(Math.random() * (max - min) + min)
	
chance = (prob) ->
	if rambo(100) <= 100 - prob - 1 then return false
	else return true
		
# Map
blah = new speedr.Map a: 8, b: 9, c: 10
test 'Map 1', blah.get('b'), 9

blah.set(b: 'yoje')
test 'Map 2', blah.items, { a: 8, b: 'yoje', c: 10 }

boom = 'BOOM'
blah.set([boom, 'shakalaka'], ['3', 12])
blah.set([boom, 'shakalaka'], ['3', 12])
test 'Map 3', blah.items, 
	a: 8, b: 'yoje', c: 10, 'BOOM': 'shakalaka', 3: 12
	
blah.remove('b')
test 'Map 4', blah.items, 
	a: 8, c: 10, 'BOOM': 'shakalaka', 3: 12
	
blah.each (k,v) ->
	# console.log "#{k}, #{v}"
	test 'Map each', k? and v?, true
	
ass = {}
for i in [0...blah.length]
	[k,v] = blah.iter(i)
	ass[k] = v
test 'Map 5', ass, blah.items
test 'Map 6', blah.length, 4


# SortedMap
msorty = new speedr.SortedMap([420, 'a'], [69, 'b'], [500, 'c'], [123, 'd'])
resultLength = 4

test 'SortedMap 1 ', msorty.get(420), 'a'
test 'SortedMap 2 ', msorty.get(69), 'b'
test 'SortedMap 3 ', msorty.hasKey(420), true
test 'SortedMap 4 ', msorty.hasKey(100), false

len = 1000
for i in [0...len]
	t = rambo(10000000) / rambo(1000)
	# only increment resultLength if the key is new
	# (since Map keys are unique)
	if not msorty.hasKey(t) then resultLength++
	msorty.set([t, 0])
	if chance(5)
		msorty.remove(t)
		resultLength--
	if chance(5)
		if not msorty.hasKey(t) then resultLength++
		msorty.set([t, 0])
	
test 'SortedMap length', msorty.length, resultLength

results = []
for i in [0...msorty.length]
	results.splice(0, 0, msorty.iterK(i))
for i in [0...results.length]
	test 'SortedMap loop',  (results[i - 1]? and not (results[i] <= results[i - 1])) or
							(results[i + 1]? and not (results[i] >= results[i + 1])), false
	# in order to give the specific place where it went wrong:
	if  (results[i - 1]? and not (results[i] <= results[i - 1])) or
		(results[i + 1]? and not (results[i] >= results[i + 1]))
			console.log "ERROR: #{results[i - 1]} > #{results[i]} > #{results[i + 1]}"

msorty.clear()
test 'SortedMap clear', msorty.keys, []
test 'SortedMap clear', msorty.vals, []

msorty = null


# SortedMultiMap
msorty = new speedr.SortedMultiMap([420, 'a'], [69, 'b'], [500, 'c'], [123, 'd'])
resultLength = 4

test 'SortedMultiMap 1 ', msorty.get(420), 'a'
test 'SortedMultiMap 2 ', msorty.get(69), 'b'
test 'SortedMultiMap 3 ', msorty.hasKey(420), true
test 'SortedMultiMap 4 ', msorty.hasKey(100), false

len = 1000
for i in [0...len]
	t = rambo(10000000) / rambo(1000)
	msorty.set([t, 0])
	resultLength++
	if chance(5)
		msorty.remove(t)
		resultLength--
	if chance(5)
		msorty.set([t, 0])
		resultLength++
	
msorty.each (k,v) ->
	test 'Map each', k? and v?, true
	
test 'SortedMultiMap length', msorty.length, resultLength

results = []
for i in [0...msorty.length]
	results.splice(0, 0, msorty.iterK(i))
for i in [0...results.length]
	test 'SortedMultiMap loop',  (results[i - 1]? and not (results[i] <= results[i - 1])) or
							(results[i + 1]? and not (results[i] >= results[i + 1])), false
	# in order to give the specific place where it went wrong:
	if  (results[i - 1]? and not (results[i] <= results[i - 1])) or
		(results[i + 1]? and not (results[i] >= results[i + 1]))
			console.log "ERROR: #{results[i - 1]} > #{results[i]} > #{results[i + 1]}"

msorty.clear()
test 'SortedMultiMap clear', msorty.keys, []
test 'SortedMultiMap clear', msorty.vals, []


console.log "** #{testCount} tests completed #{STATUS} **"