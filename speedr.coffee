speedr = {}
	
isArray = Array.isArray or (obj) ->
	return toString.call(obj) == '[object Array]'
	
isFunction = (obj) ->
	return toString.call(obj) == '[object Function]'

isObjectLit = (obj) ->
	if isArray(obj) or isFunction(obj) then return false
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
		
	each: (f, start=0, end=@length, step=1) ->
		for i in [start...end] by step
			k = @iterKey(i)
			v = @iterVal(i)
			f(k,v)
		return null
			
	eachKey: (f, start=0, end=@length, step=1) ->
		for i in [start...end] by step
			f(@iterKey(i))
		return null
			
	eachVal: (f, start=0, end=@length, step=1) ->
		for i in [start...end] by step
			f(@iterVal(i))
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
		if not items[0]? then return @length
		# passed object
		if isObjectLit(items[0]) then items = toArrayPairs(items[0])
		for item in items
			if not isArray(item)
				throw 'Attempted set of invalid item.'
			key = item[0]
			val = item[1]
			if not @items[key]?
				@revKeys[key] = @keys.length
				@keys[@keys.length] = key
			@items[key] = val
		return @updateLength()
	
	updateRevKeysAfterDeleting: (position) ->
		for i in @revKeys
			if @revKeys[i] > position
				@revKeys[i]--;

	remove: (key) ->
		if not key? then return @length
		if @items[key]?
			delete @items[key]
			position = @revKeys[key]
			@keys.splice(position, 1)
			delete @revKeys[key]
			@updateRevKeysAfterDeleting(position)
		return @updateLength()
		
	iter: (counter) ->
		return [@keys[counter], @items[@keys[counter]]]
	iterKey: (counter) -> @keys[counter]
	iterVal: (counter) -> @items[@keys[counter]]
	
	hasKey: (key) ->
		return @items[key]?
		
	clear: ->
		@items = {}
		@revKeys = {}
		@keys = []
		@updateLength()
		return null
		
	
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
		if not items[0]? then return @length
		# passed object
		if isObjectLit(items[0]) then items = toArrayPairs(items[0])
		for item in items
			if not isArray(item)
				throw 'Attempted set of invalid item.'
			key = item[0]
			val = item[1]
			i = speedr.binarySearch(@keys, key)
			
			# if the key already exists in the map
			if @keys[i] == key
				# replace the key's associated value
				@vals[i] = val
			else
				# insert a new item
				@keys.splice(i, 0, key)
				@vals.splice(i, 0, val)
				
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
	iterKey: (counter) -> return @keys[@length - 1 - counter]
	iterVal: (counter) -> return @vals[@length - 1 - counter]
	
	hasKey: (key) ->
		if speedr.binarySearch(@keys, key, true) == -1
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
		@insert(items...)
		@updateLength()
		
	get: -> return null # in order to get something, we'd have to return a range
	set: -> return null
	
	insert: (items...) ->
		if not items[0]? then return @length
		# passed object
		if isObjectLit(items[0]) then items = toArrayPairs(items[0])
		for item in items
			if not isArray(item)
				throw 'Attempted insert of invalid item.'
			key = item[0]
			val = item[1]
			i = speedr.binarySearch(@keys, key)
			@keys.splice(i, 0, key)
			@vals.splice(i, 0, val)
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