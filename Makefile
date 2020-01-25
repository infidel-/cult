#all: clean cult.js
all: clean app.js

app.js:
	~/haxe-4.0.2/run.sh cult-electron.hxml && cp app.* main.* package.json /mnt/d/1/electron-v7.1.10-win32-x64/resources/app/ 

cult.js:
	haxe cult.hxml

cult.n:
	haxe cultnme.hxml

clean:
	rm -f cult.n cult.js app.js main.js
