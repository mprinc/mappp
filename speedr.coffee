speedr = {}

speedr.getKeys = Object.keys or (obj) ->
	if obj != Object(obj)
		throw new Error 'No keys for non-object'
	keys = []
	for k of obj
		if hasOwnProperty.call(obj, k)
			keys[keys.length] = k
	return keys

speedr.binarySearch = (arr, val, exactOnly = false) ->
	h = arr.length
	l = -1
	while h - l > 1
		if arr[m = (h + l) >> 1] > val then l = m
		else h = m
	if exactOnly
		if arr[h] == val then return h
		else return -1
	else return h

speedr.equals = (a, b) ->
	if typeOf(a) != typeOf(b) then return false
	if typeOf(a) == 'array'
		if a.length != b.length then return false
		for v,i in a
			if not equals(a[i], b[i]) then return false
	else if typeOf(a) == 'object'
		if Object.getLength(a) != Object.getLength(b) then return false
		for i,v of a
			if not equals(a[i], b[i]) then return false
	else return a == b
	return true
		
speedr.flexiSlice = (obj, start, end) ->
	if typeOf(obj) == 'array' then temp = [] else temp = ''
	if not end?
		if start >= 0 then end = obj.length
		else end = -obj.length - 1
	if end > obj.length then end = obj.length
	if end < -obj.length then end = -obj.length - 1
	if start > obj.length then start = obj.length - 1
	if start < -obj.length then start = -obj.length
	for i in [start...end]
		if typeOf(obj) == 'array'
			if i >= 0 then temp.push(obj[i])
			else temp.push(obj[obj.length + i])
		else
			if i >= 0 then temp += obj[i]
			else temp += obj[obj.length + i]
	return temp

# an improved table that keeps track of its length efficiently
# and provides easy, fast iteration
class speedr.Table
	constructor: (@items = {}) ->
		if not @ instanceof arguments.callee
			throw new Error '''Constructor called as a function.  
							   Use 'new' for instantiating classes.'''
							   	
		if typeOf(@items) != 'object'
			throw 'Table requires an object for construction.'
			
		@keys = Object.keys(@items)
		@length = @keys.length
		
	get_length: -> @keys.length
	set_length: ->
		
	get: (key) ->
		return @items[key]
		
	set: (obj, others...) ->
		pushPair = (key, val) =>
			if not @items[key]?
				@keys.push(key)
			@items[key] = val
		# passed a table
		if others.length == 0
			for key,val of obj
				pushPair(key, val)
		# passed key, element pairs as normal args
		else
			pushPair(obj, others[0])
			for i in [1...others.length] by 2
				pushPair(others[i], others[i + 1])
		@items
		
	remove: (key) ->
		if @items[key]?
			delete @items[key]
			Array.remove(@keys, key)
		@items
		
	iter: (counter) ->
		return [@keys[counter], @items[@keys[counter]]]
	iterK: (counter) -> @keys[counter]
	iterV: (counter) -> @items[@keys[counter]]
	
	hasKey: (key) ->
		@items[key]?
		
	hasVal: (val) ->
		result = false
		for i in [0...@length]
			if val == @iterV(i)
				result = true
				break
		return result
		
	clear: ->
		@items = {}
		@keys = []
		
# a table that is sorted upon insertion.  multiple values can be
# stored under a single key.  thus, item removal requires both
# the key *and* the value for if the value is something like a 
# class instance.
class speedr.SortedTable
	constructor: () ->
		@keys = []
		@vals = []
		@length = 0
		
	insert: (key, val) ->
		i = binarySearch(@keys, key)
		@keys.splice(i, 0, key)
		@vals.splice(i, 0, val)
		
	remove: (key, val) ->
		if not key? then return
		i = binarySearch(@keys, key)
		if val?
			j = i - 1
			while true
				if val == @vals[i] then break
				if val == @vals[j]
					i = j
					break
				i++
				j--
		@keys.splice(i, 1)
		@vals.splice(i, 1)
		
	pop: ->
		@keys.pop()
		@vals.pop()
		
	# note that these iterate from the top down
	# (from smaller to larger)
	iter: (counter) ->
		return [@keys[@length - 1 - counter], @vals[@length - 1 - counter]]
	iterK: (counter) -> @keys[@length - 1 - counter]
	iterV: (counter) -> @vals[@length - 1 - counter]