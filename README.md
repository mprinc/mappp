speedr.js
=
Improved javascript objects.

Features
-
* Blazing fast iteration on V8 platforms like Chrome and Node.js.  Huge speedups over the normal for..in object iteration are common.
* No-overhead .length attribute.  
* Sorting.
* Duplicate or unique keys.

Tests and Benchmarks
-
* Go try out the [jsPerf benchmarks!](http://jsperf.com/speedr-js-vs-normal-object-iteration)
* To run the tests on Node.js, first make sure you have [NPM installed](http://nodejs.org/#download) (it comes with Node.js).  The tests are written in coffeescript, so you'll have to get that with ```sudo npm -g coffee-script```.  Then cd into your tests directory: ```cd speedr/tests``` and run ```coffee tests-node.coffee``` or ```coffee bench-node.coffee```.

Todo
-
* Add tests for browser
* Minified version
* Docs