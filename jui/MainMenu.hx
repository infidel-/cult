// main menu class

import js.Browser;
import js.html.DivElement;
#if electron
import electron.renderer.Remote;
import haxe.Json;
import js.node.Fs;
#end


class MainMenu extends Window
{
  var saveButton: DivElement;
  var customGameButton: DivElement;
  var mpGameButton: DivElement;
  var loadGameButton: DivElement;

  public function new(uivar: UI, gvar: Game)
    {
#if electron
      var h = 354;
#else
      var h = 200;
#end
      super(uivar, gvar, 'mainMenu', 350, h, 20);

      Tools.label({
        id: 'mainMenuTitle',
        text: 'EVIL&nbsp;&nbsp;CULT <span id=titleVersion>' + Game.version + '</span>',
        w: 260,
        h: 30,
        x: null,
        y: null,
        fontSize: null,
        container: window
      });

      // main menu contents
      var contents: DivElement = cast Browser.document.createElement("div");
      contents.id = 'mainMenuContents';
      window.appendChild(contents);

      Tools.button({
        id: 'newGame',
        text: "NEW GAME",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: null,
        y: null,
        flow: true,
        container: contents,
        func: function(event) {
          ui.newGameMenu.show();
        }
      });

      customGameButton = Tools.button({
        id: 'customGame',
        text: "CUSTOM GAME",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: null,
        y: null,
        flow: true,
        container: contents,
        func: onCustomGame
      });

      mpGameButton = Tools.button({
        id: 'multiGame',
        text: "MULTIPLAYER GAME",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: null,
        y: null,
        flow: true,
        container: contents,
        func: onMultiplayerGame
      });

      loadGameButton = Tools.button({
        id: 'loadGame',
        text: "LOAD GAME",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: null,
        y: null,
        flow: true,
        container: contents,
        func: onLoadGame
      });

      saveButton = Tools.button({
        id: 'saveGame',
        text: "SAVE GAME",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: null,
        y: null,
        flow: true,
        container: contents,
        func: onSaveGame
      });

      Tools.button({
        id: 'optionsMenu',
        text: "OPTIONS",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: null,
        y: null,
        flow: true,
        container: contents,
        func: function(event) {
          ui.options.show();
        }
      });


#if electron
      Tools.button({
        id: 'exitGame',
        text: "EXIT",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: null,
        y: null,
        flow: true,
        container: contents,
        func: onExit
      });
#end
/*
      Tools.button({
        id: 'createMult',
        text: "CREATE MULT",
        w: 150,
        h: 30,
        x: x,
        y: 200,
        container: window,
        func: onCreateMult
        });

      Tools.button({
        id: 'joinMult',
        text: "JOIN MULT",
        w: 120,
        h: 30,
        x: 220,
        y: 200,
        container: window,
        func: onJoinMult
        });
*/
    }


  override function onShow()
    {
      close.style.visibility =
        (game.isNeverStarted ? 'hidden' : 'visible');
      if (game.isNeverStarted || game.isFinished)
        saveButton.className = 'uiButtonDisabled statusButton mainMenuButton';
      else saveButton.className = 'uiButton statusButton mainMenuButton';
#if demo
      for (btn in [ saveButton, customGameButton, mpGameButton, loadGameButton ])
        btn.className = 'uiButtonDisabled statusButton mainMenuButton';
#end
    }


// exit game
#if electron
  function onExit(event: Dynamic)
    {
      Remote.getCurrentWindow().close();
    }
#end


// custom game menu
  function onCustomGame(event: Dynamic)
    {
#if !demo
      ui.customMenu.show();
      onClose(null);
#end
    }


// multiplayer game menu
  function onMultiplayerGame(event: Dynamic)
    {
#if !demo
      ui.mpMenu.show();
      onClose(null);
#end
    }


// load game menu
  function onLoadGame(event: Dynamic)
    {
#if !demo
      ui.loadMenu.show();
      onClose(null);
#end
    }


// save game menu
  function onSaveGame(event: Dynamic)
    {
      if (game.isNeverStarted || game.isFinished)
        return;

#if !demo
      ui.saveMenu.show();
      onClose(null);
#end
    }

/*
  function onCreateOpened()
    {
//      sendMessage('/mp.opened');
      trace('onCreateOpened');
    }


  function onJoinOpened()
    {
      sendMessage('/mp.joined');
      trace('onJoinOpened');
    }


  function onMessage(m)
    {
      trace('onMessage ' + m.data);
//      newState = JSON.parse(m.data);
    }


// send message through channel
  function sendMessage(path: String, ?opt_param: Dynamic)
    {
      path += '?k=' + game_key;
      if (opt_param != null)
        path += '&' + opt_param;

      var xhr = new js.html.XMLHttpRequest();
      xhr.open('GET', path, true);
      xhr.send(null);
    }


// create multiplayer game
  var game_key: String;
  function onCreateMult(event: Dynamic)
    {
      var dif = Static.difficulty[3];
      game.restart(-1, dif);

      // get channel id and game key
      var req = new js.html.XMLHttpRequest();
      req.open("GET", "/mp.create" //"?owner=" +
//        ui.config.get("owner") + "&id=" + save.id
        , false);
      req.send(null);
      var text = req.responseText;
      var arr = text.split(',');
      game_key = arr[0];
      var token = arr[1];

      var channel = untyped __js__("new goog.appengine.Channel(token)");
      var handler = {
        onopen: onCreateOpened,
        onmessage: onMessage,
        onerror: function() {},
        onclose: function() {}
      };
      var socket = channel.open(handler);
      socket.onopen = onCreateOpened;
      socket.onmessage = onMessage;

      onClose(null);
    }


// join multiplayer game
  function onJoinMult(event: Dynamic)
    {
      game_key = '123';

      // get channel id
      var req = new js.html.XMLHttpRequest();
      req.open("GET", "/mp.join?k=" + game_key, false);
      req.send(null);
      var text = req.responseText;
      var token = text;

      // open channel
      var channel = untyped __js__("new goog.appengine.Channel(token)");
      var handler = {
        onopen: onJoinOpened,
        onmessage: onMessage,
        onerror: function() {},
        onclose: function() {}
      };
      var socket = channel.open(handler);
      socket.onopen = onJoinOpened;
      socket.onmessage = onMessage;

      onClose(null);
    }
*/

// key press
  public override function onKey(e: Dynamic)
    {
//      trace(e.keyCode);
      // new game menu
      if (e.keyCode == 49) // 1
        ui.newGameMenu.show();

      // custom game
      else if (e.keyCode == 50) // 2
        onCustomGame(null);

      // multiplayer game
      else if (e.keyCode == 51) // 3
        onMultiplayerGame(null);

#if electron
      // quit game
      else if (e.keyCode == 81) // q
        onExit(null);
#end

      // debug game start
      else if (e.keyCode == 88 && Game.isDebug) // x
        {
          onClose(null);
          game.isTutorial = false;
          game.difficultyLevel = 2; // 1 - normal
          game.flags.noBlitz = true;
          game.flags.devoted = true;
          game.flags.longRituals = true;
          game.flags.artifacts = true;
          game.restart();
        }

      // load game
      else if (e.keyCode == 52) // 4
        onLoadGame(null);

      // save game
      else if (e.keyCode == 53 && !game.isNeverStarted) // 5
        onSaveGame(null);

      // exit menu
      else if (e.keyCode == 27 && !game.isNeverStarted) // ESC
        onClose(null);
    }
}
