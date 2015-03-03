all: clean cult.js

cult.js: ; ./compile

#    export HAXE_LIBRARY_PATH=/home/infidel/haxe-2.0-linux/std && \
#    ~/haxe-2.0-linux/haxe -cp . cult.hxml
#	haxe cult.hxml

cult.n:
	haxe cultnme.hxml

clean:
	rm -f cult.n cult.js
