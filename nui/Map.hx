// map block

import nme.display.MovieClip;
import nme.display.Loader;
import nme.display.Bitmap;
import nme.net.URLRequest;


class Map
{
  var ui: UI;
  var game: Game;

  public var screen: MovieClip; // map clip
  public var images: Hash<Bitmap>; // images hash

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;

      images = new Hash<Bitmap>();

      var tf = new nme.text.TextFormat();
      tf.font = 'FreeSans';
      tf.size = 11;
      tf.bold = true;

//tf.align = "center";
      UINode.textFormat = tf;
    }


// init everything
  public function init()
    {
      screen = new MovieClip();
      screen.x = x;
      screen.y = y;
      screen.width = UI.mapWidth;
      screen.height = UI.mapHeight;
      ui.screen.addChild(screen);

      loadImage("neutral", "nodes/neutral.png");
      loadImage("neutralg", "nodes/neutralg.png");
      loadImage("cult0", "nodes/cult0.png");
      loadImage("cult1", "nodes/cult1.png");
      loadImage("cult2", "nodes/cult2.png");
      loadImage("cult3", "nodes/cult3.png");
      loadImage("cult0g", "nodes/cult0g.png");
      loadImage("cult1g", "nodes/cult1g.png");
      loadImage("cult2g", "nodes/cult2g.png");
      loadImage("cult3g", "nodes/cult3g.png");
      loadImage("cult0gp", "nodes/cult0gp.png");
      loadImage("cult1gp", "nodes/cult1gp.png");
      loadImage("cult2gp", "nodes/cult2gp.png");
      loadImage("cult3gp", "nodes/cult3gp.png");
      loadImage("origin0", "nodes/origin0.png");
      loadImage("origin1", "nodes/origin1.png");
      loadImage("origin2", "nodes/origin2.png");
      loadImage("origin3", "nodes/origin3.png");
      loadImage("origin0p", "nodes/origin0p.png");
      loadImage("origin1p", "nodes/origin1p.png");
      loadImage("origin2p", "nodes/origin2p.png");
      loadImage("origin3p", "nodes/origin3p.png");
      loadImage("pixel0", "nodes/pixel0.png");
      loadImage("pixel1", "nodes/pixel1.png");
      loadImage("pixel2", "nodes/pixel2.png");
      loadImage("pixel3", "nodes/pixel3.png");
      loadImage("hl", "nodes/hl.png");
    }


// load image into hash
  function loadImage(key: String, file: String)
    {
      var l = new Loader();
      l.load(new URLRequest("data/" + file));
      images.set(key, cast l.content);
    }


// on clicking node
  public function onClick(node: Node)
    {
      if (game.isFinished || node == null)
        return;

      game.player.activate(node);
    }


// clear map
  public function clear()
    {
      while (screen.numChildren > 0)
        screen.removeChildAt(0);
    }


  public static var x = 220;
  public static var y = 5;
}
