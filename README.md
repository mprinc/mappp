Speedr.js
====
Improved javascript objects.

* [Motivation](#a)
* [Features](#b)
* [Usage](#c)
	* [Construction](#c1)
	* [Setting and Inserting](#c2)
* [Installation](#d)
	* [Node.js](#d1)
	* [Browser](#d2)
* [Tests and Benchmarks](#e)

<a name='a' />
Motivation
----
Javascript is built on objects.  You can use them to make functions or nifty class-like constructs, but mostly we know them from when we {use: 'them', like: {hash: 'maps'}}.

Javascript objects work well as maps in many cases, but there are big gaps in their implementation when used as such.  For example:

* What if I need sorting?
* Do I really need to loop through and count manually in order to get the number of elements I've defined in an object?
* What If I need *fast* iteration on Node.js or Chrome?  For small objects, speed might not be an issue, but as an object grows in size, iteration speeds can become troublesome.

Speedr addresses these issues and then some by introducing a new Map class.  

<a name='b' />
Features
----
* Blazing fast iteration on V8 platforms like Chrome and Node.js.  Huge speedups over the normal for..in object iteration are common.
* No-overhead .length attribute.  Just like with Array.length, Speedr maps keep track of their lengths internally.  Iteration should only be necessary when you're actually doing something useful with the data.
* Fast sorting using binary search.
* Duplicate or unique keys for sorted maps.
* No external dependencies.

<a name='c' />
Usage
----
Speedr currently introduces three new 'Map' classes:

* Map
	* An unsorted hash map that can only store one value per key (i.e. keys are *unique*).
* SortedMap
	* A hash map that sorts its keys upon insertion.  
* SortedMultiMap
	* Sorted map that allows multiple entries to be inserted under the same key.
	
<a name='c1' />
### Construction
Maps can be constructed in two ways

```javascript
// From a native javascript object
var map = new Map({a: 1, b:2});

// Or by passing a series of arrays as [key, value] pairs
var map = new Map(['a', 1], ['b', 2]);
```

The reason for this is that object literal keys are always strings.  i.e. the key in {1: 'a'} is *not* the number 1, but the string '1'.  Thus, if you want to preserve your numbered keys, you must use the `new Map([1, 'a'], [2, 'b'])` style of construction rather than passing in an object.

<a name='c2' />
### Setting and Inserting
Coming real soon...

<a name='d' />
Installation
----
<a name='d1' />
### Node.js
* [Install npm.](http://nodejs.org/#download) (it comes with Node.js)
* Install speedr:
	* In your project directory: `npm install speedr`
	* Or as an npm dependency in your package.json file: `"dependencies":{ "speedr":"*" }` followed by `npm install`
* Require it: `var speedr = require('speedr');`

<a name='d2' />
### Browser
* Download [speedr.min.js.](https://raw.github.com/genericdave/speedr.js/master/speedr-min.js)
* Include it: `<script src='lib/speedr.min.js'></script>`

<a name='e' />
Tests and Benchmarks
----
* Go try out the [jsPerf benchmarks!](http://jsperf.com/speedr-js-vs-normal-object-iteration/2)
* To run the tests on Node.js:
	* Get Coffeescript: `sudo npm -g coffee-script`
	* cd into your tests directory: `cd speedr/tests`
	* Install test dependencies: `npm install`
	* Run `coffee tests-node.coffee` or `coffee bench-node.coffee`