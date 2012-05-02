speedr = require './speedr'
_      = require 'underscore'

test = (name, result, expected) ->
	if not _.isEqual(result, expected)
		console.log "#{name} FAILED"
		console.log "Got:      #{result}"
		console.log "Expected: #{expected}"
		
		
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
