// map block

import js.Lib;

class Map
{
  var ui: UI;
  var game: Game;

  public var screen: Dynamic; // map element

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;

      // map display
      screen = UI.e("map");
      screen.style.border = 'double white 4px';
      screen.style.width = UI.mapWidth;
      screen.style.height = UI.mapHeight;
      screen.style.position = 'absolute';
      screen.style.left = 240;
      screen.style.top = 5 + UI.topHeight;
      screen.style.overflow = 'hidden';
    }


// on clicking node
  public function onNodeClick(event: Dynamic)
    {
      if (game.isFinished)
        return;
  
      game.player.activate(Tools.getTarget(event).node);
    }


// clear map
  public function clear()
    {
      while (screen.hasChildNodes())
        screen.removeChild(screen.firstChild);
    }
}
