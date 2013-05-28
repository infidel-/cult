all: clean cult.js

cult.js:
	haxe cult.hxml && cp cult.js /mnt/1/3/

cult.n:
	haxe cultnme.hxml

clean:
	rm -f cult.n cult.js
