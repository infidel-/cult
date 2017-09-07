all: clean cult.js

cult.js:
	haxe cult.hxml

cult.n:
	haxe cultnme.hxml

clean:
	rm -f cult.n cult.js
