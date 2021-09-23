#all: clean cult.js
all: clean app.js-debug
.PHONY: app.js app.js-debug cult.js

app.js:
	~/haxe-4.0.2/run.sh cult-electron.hxml && \
#	haxe cult-electron.hxml --connect 6001 && \
	cp app-classic.* app.* main.* package.json \
	/mnt/e/Projects/electron-v7.1.10-win32-ia32/resources/app/ 

app.js-debug:
	~/haxe-4.0.2/run.sh -D mydebug cult-electron.hxml && \
#	haxe -D mydebug cult-electron.hxml --connect 6001 && \
	cp app-classic.* app.* main.* package.json \
	/mnt/e/Projects/electron-v7.1.10-win32-ia32/resources/app/ 

demo.js:
	~/haxe-4.0.2/run.sh -D demo cult-electron.hxml && \
#	haxe -D demo cult-electron.hxml --connect 6001 && \
	cp app-classic.* app.* main.* package.json \
	/mnt/e/Projects/electron-v7.1.10-win32-ia32/resources/app/ 

demo.js-debug:
	~/haxe-4.0.2/run.sh -D mydebug -D demo cult-electron.hxml && \
#	haxe -D mydebug -D demo cult-electron.hxml --connect 6001 && \
	cp app-classic.* app.* main.* package.json \
	/mnt/e/Projects/electron-v7.1.10-win32-ia32/resources/app/ 

cult.js:
	~/haxe-4.0.2/run.sh -D mydebug cult.hxml
#	haxe cult --connect 6001

clean:
	rm -f cult.js app.js main.js
