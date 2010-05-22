// main menu class

class MainMenu
{
  var ui: UI;
  var game: Game;

  var window: Dynamic; // window element
  var bg: Dynamic; // background element


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

      bg = js.Lib.document.createElement("div");
      bg.style.visibility = 'hidden';
      bg.style.position = 'absolute';
      bg.style.zIndex = 15;
      bg.style.width = UI.winWidth + 20;
      bg.style.height = UI.winHeight;
      bg.style.left = 0; 
      bg.style.top = 0;
      bg.style.opacity = 0.8;
      bg.style.background = '#000';
      js.Lib.document.body.appendChild(bg);

      var close = Tools.closeButton(window, 160, 160, 'mainMenuClose');
	  close.onclick = onClose;
    }


// show main menu
  public function show()
    {
      window.style.visibility = 'visible';
      bg.style.visibility = 'visible';
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
      window.style.visibility = 'hidden';
      bg.style.visibility = 'hidden';
      UI.e("haxe:trace").innerHTML = "";
      game.restart(dif);
    }


// hide main menu
  function onClose(event: Dynamic)
    {
      if (game.isFinished)
        return;
      window.style.visibility = 'hidden';
      bg.style.visibility = 'hidden';
    }
}
