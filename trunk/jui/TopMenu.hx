// top menu

import js.Lib;

class TopMenu
{
  var ui: UI;
  var game: Game;

  var panel: Dynamic;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;

      // panel element
      panel = Lib.document.createElement("div");
      panel.id = 'topPanel';
      panel.style.position = 'absolute';
      panel.style.width = UI.mapWidth + 8;
      panel.style.height = 26;
      panel.style.left = 240;
      panel.style.top = 5;
      panel.style.background = '#090909';
      Lib.document.body.appendChild(panel);

      Tools.button({
        id: 'cults',
        text: "CULTS",
        w: 70,
        h: buttonHeight,
        x: 20,
        y: 2,
        fontSize: 16,
        container: panel,
        title: "Click to view cults information (or press <span style=\"color:white\">C</span>).",
        func: onCults
        });

      Tools.button({
        id: 'sects',
        text: "SECTS",
        w: 70,
        h: buttonHeight,
        x: 110,
        y: 2,
        fontSize: 16,
        container: panel,
        title: "Click to view sects controlled by your cult (or press <span style=\"color:white\">S</span>).",
        func: onSects
        });

      Tools.button({
        id: 'log',
        text: "LOG",
        w: 70,
        h: buttonHeight,
        x: 200,
        y: 2,
        fontSize: 16,
        container: panel,
        title: "Click to view message log (or press <span style=\"color:white\">L</span>).",
        func: onLog
        });

      if (Game.isDebug)
        Tools.button({
          id: 'debug',
          text: "DEBUG",
          w: 70,
          h: buttonHeight,
          x: 290,
          y: 2,
          fontSize: 16,
          container: panel,
          title: "Click to open debug menu (or press <span style=\"color:white\">D</span>).",
          func: onDebug
          });
  
      Tools.button({
        id: 'about',
        text: "ABOUT",
        w: 70,
        h: buttonHeight,
        x: 700,
        y: 2,
        fontSize: 16,
        container: panel,
        title: "Click to go to About page.",
        func: onAbout
        });

      Tools.button({
        id: 'advanced',
        text: "A",
        w: 12,
        h: 12,
        x: 774,
        y: 30,
        fontSize: 10,
        container: panel,
        title: "Click to set/unset advanced map mode (or press <span style=\"color:white\">A</span>).",
        func: onAdvanced
        });

//      s += "<div class=button style='position: absolute; z-index: 20; top: 30; left: 240;' title='" + tipMainMenu +
//        "' id='status.mainMenu'>A</div>";
    }


  public function onCults(event: Dynamic)
    {
      ui.info.show();
    }


  public function onSects(e: Dynamic)
    {
      ui.sects.show();
    }


  public function onLog(event: Dynamic)
    {
      ui.logWindow.show();
    }


  public function onDebug(event)
    {
      if (game.isFinished || !Game.isDebug)
        return;

      ui.debug.show();
    }


  public function onAdvanced(event)
    {
      ui.map.isAdvanced = !ui.map.isAdvanced;
      ui.map.paint();
    }

// about game button
  function onAbout(event: Dynamic)
    {
      Lib.window.open("http://code.google.com/p/cult/wiki/About"); 
    }


  static var buttonHeight = 20;
}
