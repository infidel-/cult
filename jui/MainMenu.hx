// main menu class

class MainMenu
{
  var ui: UI;
  var game: Game;

  var window: Dynamic; // window element
  var bg: Dynamic; // background element
  var close: Dynamic; // close button element
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
        x: 120,
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
      window.style.visibility = 'visible';
      bg.style.visibility = 'visible';
//      close.style.visibility = 
//        (game.isFinished ? 'hidden' : 'visible');
      saveButton.style.visibility = 
        (game.isFinished ? 'hidden' : 'visible');
      isVisible = true;
    }


// custom game menu
  function onCustomGame(event: Dynamic)
    {
      ui.customMenu.show();
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
      UI.e("haxe:trace").innerHTML = "";
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
/*
      // load game
      else if (e.keyCode == 52) // 4
        onLoadGame(null);

      // save game
      else if (e.keyCode == 53) // 5
        onSaveGame(null);
*/
      // exit menu
      else if (e.keyCode == 27// && !game.isFinished
      ) // ESC
        onClose(null);
    }


// hide main menu
  function onClose(event: Dynamic)
    {
//      if (game.isFinished)
//        return;
      window.style.visibility = 'hidden';
      bg.style.visibility = 'hidden';
//      close.style.visibility = 'hidden';
      saveButton.style.visibility = 'hidden'; 
      isVisible = false;
    }
}
