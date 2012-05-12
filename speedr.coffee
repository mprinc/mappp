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

speedr.getArrays = (obj) ->
	if obj != Object(obj)
		throw new Error 'No keys for non-object'
	keys = []
	vals = []
	for k,v of obj
		if hasOwnProperty.call(obj, k)
			keys[keys.length] = k
			vals[vals.length] = v
	return [keys, vals]

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
		
speedr.flexiSlice = (obj, start, end) ->
	if toString.call(obj) == '[object Array]'
		temp = []
	else temp = ''
	if not end?
		if start >= 0 then end = obj.length
		else end = -obj.length - 1
	if end > obj.length then end = obj.length
	if end < -obj.length then end = -obj.length - 1
	if start > obj.length then start = obj.length - 1
	if start < -obj.length then start = -obj.length
	for i in [start...end]
		if toString.call(obj) == '[object Array]'
			if i >= 0 then temp.push(obj[i])
			else temp.push(obj[obj.length + i])
		else
			if i >= 0 then temp += obj[i]
			else temp += obj[obj.length + i]
	return temp
		

# unique keys
class speedr.Map
	constructor: (@items = {}) ->
		if @items != Object(@items)
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
		
		
class speedr.SortedMap
	constructor: (items = {}) ->
		if items != Object(items)
			throw 'SortedMap requires an object for construction.'
			
		@keys = []
		@vals = []
		@insert(items)
		@updateLength()
		
	updateLength: ->
		@length = @keys.length
		return @length
		
	insert: (key, val) ->
		if not key? then return @length
		# passed a key, value pair
		if val?
			i = speedr.binarySearch(@keys, key)
			@keys.splice(i, 0, key)
			@vals.splice(i, 0, val)
			return @updateLength()
		# passed an object
		else if key == Object(key)
			for k,v of key
				@insert(k, v)
			return @updateLength()
		else
			throw 'Attempted insert of invalid items.'
				
	remove: (key) ->
		if not key? then return @length
		i = speedr.binarySearch(@keys, key)
		@keys.splice(i, 1)
		@vals.splice(i, 1)
		@updateLength()
		
	pop: ->
		@keys.pop()
		@vals.pop()
		@updateLength()
		
	# note that these iterate from the top down
	# (from smaller to larger)
	iter: (counter) ->
		return [@keys[@length - 1 - counter], @vals[@length - 1 - counter]]
	iterK: (counter) -> @keys[@length - 1 - counter]
	iterV: (counter) -> @vals[@length - 1 - counter]
		
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
		# return @items[key]?
		for k in @keys
			if key == k then return true
		return false
		
	hasVal: (val) ->
		for v in @vals
			if vals == v then return true
		return false
		
	clear: ->
		@keys = []
		@vals = []
		@updateLength()
		return null
			
		
# a table that is sorted upon insertion.  multiple values can be
# stored under a single key.  thus, item removal requires both
# the key *and* the value for if the value is something like a 
# class instance.
class speedr.SortedTable
	constructor: () ->
		@keys = []
		@vals = []
		@updateLength()
		
	updateLength: ->
		@length = @keys.length
		return @length
		
	insert: (key, val) ->
		i = speedr.binarySearch(@keys, key)
		@keys.splice(i, 0, key)
		@vals.splice(i, 0, val)
		return @updateLength()
		
	remove: (key, val) ->
		if not key? then return
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
		@updateLength()
		
	pop: ->
		@keys.pop()
		@vals.pop()
		@updateLength()
		
	# note that these iterate from the top down
	# (from smaller to larger)
	iter: (counter) ->
		return [@keys[@length - 1 - counter], @vals[@length - 1 - counter]]
	iterK: (counter) -> @keys[@length - 1 - counter]
	iterV: (counter) -> @vals[@length - 1 - counter]
	
	
# export functions
if module? and exports?
	module.exports = speedr
else
	window.speedr = speedr