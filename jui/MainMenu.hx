// main menu class

import js.Browser;
import js.html.DivElement;
#if electron
import electron.renderer.Remote;
#end

class MainMenu extends Window
{
  public function new(uivar: UI, gvar: Game)
    {
#if electron
      var h = 324;
      var closeY = 280;
#else
      var h = 280;
      var closeY = 240;
#end
      super(uivar, gvar, 'mainMenu', 420, h, 20, closeY);

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

//      var x = (UI.classicMode ? 35 : 48);
      var x = 35;
      var y = 47;

      // main menu contents
      Tools.button({
        id: 'newGameEasy',
        text: "START NEW GAME - EASY",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: x,
        y: y,
        container: window,
        func: onNewGame
      });
      y += 40;
      Tools.button({
        id: 'newGameNormal',
        text: "START NEW GAME - NORMAL",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: x,
        y: y,
        container: window,
        func: onNewGame
      });
      y += 40;
      Tools.button({
        id: 'newGameHard',
        text: "START NEW GAME - HARD",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: x,
        y: y,
        container: window,
        func: onNewGame
      });
      y += 40;

      Tools.button({
        id: 'customGame',
        text: "CUSTOM GAME",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: x,
        y: y,
        container: window,
        func: onCustomGame
      });
      y += 40;

      Tools.button({
        id: 'customGame',
        text: "MULTIPLAYER GAME",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: x,
        y: y,
        container: window,
        func: onMultiplayerGame
      });
      y += 40;

#if electron
      Tools.button({
        id: 'exitGame',
        text: "EXIT",
        className: 'uiButton statusButton mainMenuButton',
        w: null,
        h: null,
        x: x,
        y: y,
        container: window,
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

//      saveButton = { style: {} };
/*
      Tools.button({
        id: 'loadGame',
        text: "LOAD GAME",
        w: 350,
        h: 30,
        x: x,
        y: 160,
        container: window,
        func: onLoadGame
        });
      saveButton = Tools.button({
        id: 'saveGame',
        text: "SAVE GAME",
        w: 350,
        h: 30,
        x: x,
        y: 200,
        container: window,
        func: onSaveGame
        });
*/
    }


  override function onShow()
    {
      close.style.visibility =
        (game.isNeverStarted ? 'hidden' : 'visible');
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
      ui.customMenu.show();
      onClose(null);
    }


// multiplayer game menu
  function onMultiplayerGame(event: Dynamic)
    {
      ui.mpMenu.show();
      onClose(null);
    }


// load game menu
  function onLoadGame(event: Dynamic)
    {
      ui.loadMenu.show();
      onClose(null);
    }


// save game menu
  function onSaveGame(event: Dynamic)
    {
      ui.saveMenu.show();
      onClose(null);
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

// start new game
  function onNewGame(event: Dynamic)
    {
      var id = Tools.getTarget(event).id;
      var dif = 0;
      if (id == "newGameEasy")
        dif = 0;
      else if (id == "newGameNormal")
        dif = 1;
      else dif = 2;
      onNewGameReal(dif);
    }


// start for real
  function onNewGameReal(dif: Int)
    {
      game.restart(dif);
      onClose(null);
    }


// key press
  public override function onKey(e: Dynamic)
    {
//      trace(e.keyCode);
      // new game - easy
      if (e.keyCode == 49) // 1
        onNewGameReal(0);

      // new game - normal
      else if (e.keyCode == 50) // 2
        onNewGameReal(1);

      // new game - hard
      else if (e.keyCode == 51) // 3
        onNewGameReal(2);

      // custom game
      else if (e.keyCode == 52) // 4
        onCustomGame(null);

      // multiplayer game
      else if (e.keyCode == 53) // 5
        onMultiplayerGame(null);

#if electron
      // quit game
      else if (e.keyCode == 81) // q
        onExit(null);
#end
/*
      // load game
      else if (e.keyCode == 52) // 4
        onLoadGame(null);

      // save game
      else if (e.keyCode == 53) // 5
        onSaveGame(null);
*/
      // exit menu
      else if (e.keyCode == 27 && !game.isNeverStarted) // ESC
        onClose(null);
    }
}
