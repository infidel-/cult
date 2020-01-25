// main menu class

import js.html.DivElement;

class MainMenu
{
  var ui: UI;
  var game: Game;

  var window: DivElement; // window element
  var bg: DivElement; // background element
  var close: DivElement; // close button element
  var saveButton: Dynamic; // save button element
  public var isVisible: Bool;


  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      isVisible = false;

      // main menu window
      window = Tools.window(
        {
          id: "mainMenuWindow",
          center: true,
          winW: UI.winWidth,
          winH: UI.winHeight,
          w: 420,
          h: 280,
          z: 20
        });

      Tools.label({
        id: 'titleLabel',
        text: 'Evil Cult ' + Game.version,
        w: 260,
        h: 30,
        x: 130,
        y: 10,
        container: window
        });

      // main menu contents
      Tools.button({
        id: 'newGameEasy',
        text: "START NEW GAME - EASY",
        w: 350,
        h: 30,
        x: 35,
        y: 40,
        container: window,
        func: onNewGame
        });
      Tools.button({
        id: 'newGameNormal',
        text: "START NEW GAME - NORMAL",
        w: 350,
        h: 30,
        x: 35,
        y: 80,
        container: window,
        func: onNewGame
        });
      Tools.button({
        id: 'newGameHard',
        text: "START NEW GAME - HARD",
        w: 350,
        h: 30,
        x: 35,
        y: 120,
        container: window,
        func: onNewGame
        });

      Tools.button({
        id: 'customGame',
        text: "CUSTOM GAME",
        w: 350,
        h: 30,
        x: 35,
        y: 160,
        container: window,
        func: onCustomGame
        });

      Tools.button({
        id: 'customGame',
        text: "MULTIPLAYER GAME",
        w: 350,
        h: 30,
        x: 35,
        y: 200,
        container: window,
        func: onMultiplayerGame
        });
/*
      Tools.button({
        id: 'createMult',
        text: "CREATE MULT",
        w: 150,
        h: 30,
        x: 35,
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

      saveButton = { style: {} };
/*
      Tools.button({
        id: 'loadGame',
        text: "LOAD GAME",
        w: 350,
        h: 30,
        x: 35,
        y: 160,
        container: window,
        func: onLoadGame
        });
      saveButton = Tools.button({
        id: 'saveGame',
        text: "SAVE GAME",
        w: 350,
        h: 30,
        x: 35,
        y: 200,
        container: window,
        func: onSaveGame
        });
*/
      bg = Tools.bg({ w: UI.winWidth + 20, h: UI.winHeight});
      close = Tools.closeButton(window, 160, 240, 'mainMenuClose');
      close.onclick = onClose;
    }


// show main menu
  public function show()
    {
      window.style.display = 'inline';
      bg.style.display = 'inline';
//      close.style.visibility =
//        (game.isFinished ? 'hidden' : 'visible');
      saveButton.style.display =
        (game.isFinished ? 'none' : 'inline');
      isVisible = true;
    }


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
  public function onKey(e: Dynamic)
    {
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
/*
      // load game
      else if (e.keyCode == 52) // 4
        onLoadGame(null);

      // save game
      else if (e.keyCode == 53) // 5
        onSaveGame(null);
*/
      // exit menu
      else if (e.keyCode == 27
      ) // ESC
        onClose(null);
    }


// hide main menu
  function onClose(event: Dynamic)
    {
      if (game.isNeverStarted)
        return;

      window.style.display = 'none';
      bg.style.display = 'none';
//      close.style.display = 'none';
      saveButton.style.display = 'none';
      isVisible = false;
    }
}
