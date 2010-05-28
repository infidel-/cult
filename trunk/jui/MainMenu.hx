// main menu class

class MainMenu
{
  var ui: UI;
  var game: Game;

  var window: Dynamic; // window element
  var bg: Dynamic; // background element
  var close: Dynamic; // close button element


  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;

      // main menu window
      window = Tools.window(
        {
          id: "mainMenuWindow",
          center: true,
          winW: UI.winWidth,
          winH: UI.winHeight,
          w: 420,
          h: 200,
          z: 20
        });

      // main menu contents
      Tools.button({
        id: 'newGameEasy',
        text: "START NEW GAME - EASY",
        w: 350,
        h: 30,
        x: 35,
        y: 30,
        container: window,
        func: onNewGame
        });
      Tools.button({
        id: 'newGameNormal',
        text: "START NEW GAME - NORMAL",
        w: 350,
        h: 30,
        x: 35,
        y: 70,
        container: window,
        func: onNewGame
        });
      Tools.button({
        id: 'newGameHard',
        text: "START NEW GAME - HARD",
        w: 350,
        h: 30,
        x: 35,
        y: 110,
        container: window,
        func: onNewGame
        });

      bg = Tools.bg({ w: UI.winWidth + 20, h: UI.winHeight});
      close = Tools.closeButton(window, 160, 160, 'mainMenuClose');
	  close.onclick = onClose;
    }


// show main menu
  public function show()
    {
      window.style.visibility = 'visible';
      bg.style.visibility = 'visible';
      close.style.visibility = 
        (game.isFinished ? 'hidden' : 'visible');
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
      UI.e("haxe:trace").innerHTML = "";
      game.restart(dif);
      onClose(null);
    }


// hide main menu
  function onClose(event: Dynamic)
    {
      if (game.isFinished)
        return;
      window.style.visibility = 'hidden';
      bg.style.visibility = 'hidden';
      close.style.visibility = 'hidden';
    }
}
