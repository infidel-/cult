// main menu class

import nme.display.DisplayObject;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;

class MainMenu
{
  var ui: UI;
  var game: Game;

  var window: Window; // menu window
  var bg: Background; // background
  public var isVisible(getIsVisible, null): Bool;


  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
    }


// init stuff
  public function init()
    {
      bg = new Background(ui.screen);
      window = new Window(ui.screen,
        {
          center: true,
          image: "mainbg",
          w: 428,
          h: 208
        });

      var newEasy = new Button(window, 
        { x: 35, y: 30, image: "new_easy",
          name: "newGameEasy",
          onClick: onNewGame });
      var newNormal = new Button(window, 
        { x: 35, y: 70, image: "new_normal",
          name: "newGameNormal",
          onClick: onNewGame });
      var newHard = new Button(window, 
        { x: 35, y: 110, image: "new_hard",
          name: "newGameHard",
          onClick: onNewGame });

      var close = new Button(window, 
        { x: 160, y: 160, image: "close", onClick: onClose });
    }


// show main menu
  public function show()
    {
      window.visible = true;
      bg.visible = true;
    }


// start new game
  function onNewGame(target: DisplayObject)
    {
      var dif = 0;
      if (target.name == "newGameEasy")
        dif = 0;
      else if (target.name == "newGameNormal")
        dif = 1;
      else dif = 2;

      onNewGameReal(dif);
    }


  function onNewGameReal(dif: Int)
    {
      game.restart(dif);
      onClose(null);
    }


// hide main menu
  function onClose(event: Dynamic)
    {
      if (game.isFinished)
        return;

      window.visible = false;
      bg.visible = false;
    }


// key press
  public function onKey(e: KeyboardEvent)
    {
      // new game - easy
      if (e.keyCode == Keyboard.NUMBER_1) 
        onNewGameReal(0);

      // new game - normal
      else if (e.keyCode == Keyboard.NUMBER_2)
        onNewGameReal(1);

      // new game - hard
      else if (e.keyCode == Keyboard.NUMBER_3)
        onNewGameReal(2);

      // exit menu
      else if (e.keyCode == Keyboard.ESCAPE)
        onClose(null);
    }


// getter for isVisible
  function getIsVisible(): Bool
    {
      return window.visible;
    }
}
