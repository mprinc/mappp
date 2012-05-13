speedr = {}
	
isArray = Array.isArray or (obj) ->
	return toString.call(obj) == '[object Array]'

isObject = (obj) ->
	if isArray(obj) then return false
	return obj == Object(obj)
	
toArrayPairs = (obj) ->
	tempItems = []
	for k,v of obj
		tempItems[tempItems.length] = [k,v]
	return tempItems


speedr.binarySearch = (arr, val, exactMatch = false) ->
	h = arr.length
	l = -1
	while h - l > 1
		if arr[m = (h + l) >> 1] > val then l = m
		else h = m
	if exactMatch
		if arr[h] == val then return h
		else return -1
	else return h
	
	
class BaseMap
	updateLength: ->
		@length = @keys.length
		return @length
		
	each: (f) ->
		for i in [0...@length]
			k = @iterK(i)
			v = @iterV(i)
			f(k,v)
		return null
			
	eachKey: (f) ->
		for i in [0...@length]
			f(@iterK(i))
		return null
			
	eachVal: (f) ->
		for i in [0...@length]
			f(@iterV(i))
		return null
		

# unsorted map with unique keys
class speedr.Map extends BaseMap
	constructor: (items...) ->
		@keys = []
		# reverse keys = key -> index of key in @keys
		# (for fast removal since we can avoid indexOf())
		@revKeys = {}
		@items = {}
		@set(items...)
		@updateLength()
		
	get: (key) ->
		if not key? then return null
		return @items[key]
		
	set: (items...) ->
		if not items? then return @length
		# passed object
		if isObject(items[0]) then items = toArrayPairs(items[0])
		for item in items
			if not isArray(item)
				throw 'Attempted set of invalid item.'
			# key = item[0]
			# val = item[1]
			if not @items[item[0]]?
				@revKeys[item[0]] = @keys.length
				@keys[@keys.length] = item[0]
			@items[item[0]] = item[1]
		return @updateLength()
		
	remove: (key) ->
		if not key? then return @length
		if @items[key]?
			delete @items[key]
			@keys.splice(@revKeys[key], 1)
			delete @revKeys[key]
		return @updateLength()
		
	iter: (counter) ->
		return [@keys[counter], @items[@keys[counter]]]
	iterK: (counter) -> @keys[counter]
	iterV: (counter) -> @items[@keys[counter]]
	
	hasKey: (key) ->
		return @items[key]?
		
	hasVal: (val) ->
		result = false
		for i in [0...@length]
			if val == @iterV(i)
				result = true
				break
		return result
		
	clear: ->
		@items = {}
		@revKeys = {}
		@keys = []
		@updateLength()
		return null
		

# unsorted map that allows for duplicate keys	
class speedr.MultiMap extends speedr.Map
	constructor: (items...) ->
		
	
# a map that is sorted upon insertion.
# keys must be unique
class speedr.SortedMap extends BaseMap
	constructor: (items...) ->
		@keys = []
		@vals = []
		@set(items...)
		@updateLength()
		
	get: (key) ->
		if not key? then return null
		i = speedr.binarySearch(@keys, key, true)
		if i == -1 then return null
		return @vals[i]
		
	set: (items...) ->
		if not items? then return @length
		# passed object
		if isObject(items[0]) then items = toArrayPairs(items[0])
		for item in items
			if not isArray(item)
				throw 'Attempted set of invalid item.'
			# key = item[0]
			# val = item[1]
			i = speedr.binarySearch(@keys, item[0])
			@keys.splice(i, 0, item[0])
			@vals.splice(i, 0, item[1])
		return @updateLength()
				
	remove: (key) ->
		if not key? then return @length
		i = speedr.binarySearch(@keys, key)
		@keys.splice(i, 1)
		@vals.splice(i, 1)
		return @updateLength()
		
	pop: ->
		@keys.pop()
		@vals.pop()
		return @updateLength()
		
	# note that these iterate from the top down
	# (from smaller to larger)
	iter: (counter) ->
		return [@keys[@length - 1 - counter], @vals[@length - 1 - counter]]
	iterK: (counter) -> return @keys[@length - 1 - counter]
	iterV: (counter) -> return @vals[@length - 1 - counter]
	
	hasKey: (key) ->
		if speedr.binarySearch(@keys, key, true) == -1
			return false
		else
			return true
		
	hasVal: (val) ->
		if speedr.binarySearch(@vals, val, true) == -1
			return false
		else
			return true
		
	clear: ->
		@keys = []
		@vals = []
		@updateLength()
		return null
			
		
# a map that is sorted upon insertion.  multiple values can be
# stored under a single key.  thus, item removal requires both
# the key *and* the value for if the value is something like a 
# class instance.
class speedr.SortedMultiMap extends speedr.SortedMap
	constructor: (items...) ->
		# can't do super(items...) as it would call super many times
		# so, just repeat the constructor
		@keys = []
		@vals = []
		@set(items...)
		@updateLength()
		
	set: (items...) ->
		if not items? then return @length
		# passed object
		if isObject(items[0]) then items = toArrayPairs(items[0])
		for item in items
			if not isArray(item)
				throw 'Attempted set of invalid item.'
			# key = item[0]
			# val = item[1]
			i = speedr.binarySearch(@keys, item[0])
			@keys.splice(i, 0, item[0])
			@vals.splice(i, 0, item[1])
		return @updateLength()
		
	remove: (key, val) ->
		# if we have multiple items with the same key,
		# we also need to match the value to remove an item.
		# note that not passing a value when you have copied keys
		# will result in a random matching entry getting removed
		if not key? then return @length
		i = speedr.binarySearch(@keys, key)
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
		return @updateLength()
		
	
# export functions
if module? and exports?
	module.exports = speedr
else
	window.speedr = speedr