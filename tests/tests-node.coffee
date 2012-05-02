speedr = require '../speedr'
_      = require 'underscore'

testCount = 0
test = (name, result, expected) ->
	if not _.isEqual(result, expected)
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
		
# flexiSlice
fn = speedr.flexiSlice
test 'slice 1 ', fn('abcdefg', 2,4), 'cd'
test 'slice 2 ', fn('abcdefg', 2), 'cdefg'
test 'slice 3 ', fn('abcdefg', 2,30), 'cdefg'
test 'slice 4 ', fn('abcdefg', 6,2), 'gfed'
test 'slice 5 ', fn('abcdefg', 2,2), ''
test 'slice 6 ', fn('abcdefg', -2,-2), ''
test 'slice 7 ', fn('abcdefg', -2,2), 'fgab'
test 'slice 8 ', fn('abcdefg', -2,-20), 'fedcba'
test 'slice 9 ', fn(['a','b','c'], 1,2), ['b']
test 'slice 10', fn(['a','b','c'], -2,-2), []
test 'slice 11', fn(['a','b','c'], 1,-2), ['b','a','c']
test 'slice 12', fn(['a','b','c'], -10,0), ['a','b','c']

# Table
blah = new speedr.Table a: 8, b: 9, c: 10
test 'Table 1', blah.get('b'), 9
test 'Table 2', blah.set(b: 'yoje'), { a: 8, b: 'yoje', c: 10 }
boom = 'BOOM'
blah.set(boom, 'shakalaka', '3', 12)
test 'Table 3', blah.set(boom, 'shakalaka', '3', 12), 
	a: 8, b: 'yoje', c: 10, 'BOOM': 'shakalaka', 3: 12
ass = {}
for i in [0...blah.length]
	[k,v] = blah.iter(i)
	ass[k] = v
test 'Table 4', blah.items, ass
test 'Table 5', blah.length, 5
test 'Table 6', blah.hasVal('yoje'), true
test 'Table 7', blah.hasVal('yaaaje'), false

# # binarySearch
# sorty = new speedr.SortedTable()
# len = 1000
# for i in [0...len]
# 	t = rambo(10000000) / rambo(1000)
# 	sorty.insert(t, 0)
# 	if chance(5) then sorty.remove(t)
# 	if chance(5) then sorty.insert(t, 0)
# results = []
# for i in [0...sorty.length]
# 	results.splice(0, 0, sorty.iterK(i))
# for i in [0...results.length]
# 	if (results[i - 1]? and not (results[i] <= results[i - 1])) or
# 		(results[i + 1]? and not (results[i] >= results[i + 1]))
# 			echo "ERROR: #{results[i - 1]} > #{results[i]} > #{results[i + 1]}"


console.log "** #{testCount} tests completed **"