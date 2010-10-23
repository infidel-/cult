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
        id: 'sects',
        text: "SECTS",
        w: 70,
        h: buttonHeight,
        x: 20,
        y: 2,
        fontSize: 16,
        container: panel,
        func: onSects
        });
    }


  public function onSects(e: Dynamic)
    {
      ui.sects.show();
    }


  static var buttonHeight = 20;
}
