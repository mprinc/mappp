speedr = {}

if document?
	`speedr.ie = (function(){

	    var v = 3,
	        div = document.createElement('div'),
	        all = div.getElementsByTagName('i');

	    while (
	        div.innerHTML = '<!--[if gt IE ' + (++v) + ']><i></i><![endif]-->',
	        all[0]
	    );

	    return v > 4 ? v : false;

	}());`
else
	speedr.ie = false
	
	
isArray = Array.isArray or (obj) ->
	return toString.call(obj) == '[object Array]'

isObject = (obj) ->
	return obj == Object(obj)


speedr.getArrays = (obj) ->
	if not isObject(obj)
		throw new Error 'No keys for non-object'
	keys = []
	vals = []
	for k,v of obj
		if hasOwnProperty.call(obj, k)
			keys[keys.length] = k
			vals[vals.length] = v
	return [keys, vals]

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
		

# unsorted map with unique keys
class speedr.Map
	constructor: (@items = {}) ->
		if not isObject(@items)
			throw 'Map requires an object for construction.'
			
		[@keys, junk] = speedr.getArrays(@items)
		@updateLength()
		
	updateLength: ->
		@length = @keys.length
		return @length
		
	get: (key) ->
		return @items[key]
		
	set: (obj, others...) ->
		pushPair = (key, val) =>
			if not @items[key]?
				@keys.push(key)
			@items[key] = val
		# passed an object
		if others.length == 0
			for key,val of obj
				pushPair(key, val)
		# passed key, element pairs as normal args
		else
			pushPair(obj, others[0])
			for i in [1...others.length] by 2
				pushPair(others[i], others[i + 1])
		return @updateLength()
		
	remove: (key) ->
		if @items[key]?
			delete @items[key]
			Array.remove(@keys, key)
		return @updateLength()
		
	each: (f) ->
		if not speedr.ie
			for i in [0...@length]
				k = @iterK(i)
				v = @iterV(i)
				f(k,v)
		else
			for k,v of @items
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
		@keys = []
		@updateLength()
		return null
		

# unsorted map that allows for duplicate keys	
class speedr.MultiMap extends speedr.Map
	constructor: (items...) ->
		
	
# a map that is sorted upon insertion.
# keys must be unique
class speedr.SortedMap
	constructor: (items...) ->
		@keys = []
		@vals = []
		@insert(items...)
		@updateLength()
		
	updateLength: ->
		@length = @keys.length
		return @length
		
	get: (key) ->
		if not key? then return null
		i = speedr.binarySearch(@keys, key, true)
		if i == -1 then return null
		return @vals[i]
		
	keyPosition: (key) ->
		i = speedr.binarySearch(@keys, key, true)
		if i == -1 then return null
		else return @length - 1 - i
		
	valPosition: (val) ->
		i = speedr.binarySearch(@vals, val, true)
		if i == -1 then return null
		else return @length - 1 - i
		
	insert: (items...) ->
		if not items? then return @length
		for item in items
			if not isArray(item)
				throw 'Attempted insert of invalid item.'
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
		@insert(items...)
		@updateLength()
		
	keyPosition: ->
	valPosition: ->
		# shouldn't exist?  maybe it could return ranges?
		
	insert: (items...) ->
		if not items? then return @length
		for item in items
			if not isArray(item)
				throw 'Attempted insert of invalid item.'
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