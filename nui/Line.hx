// line drawing class

import nme.display.Bitmap;


class Line
{
  var screen: Dynamic;

  public var startNode: Node;
  public var endNode: Node;
  public var pixels: Array<Bitmap>;
  public var owner: Cult;
  public var isVisible: Bool;


  function new(screen)
	{
      this.screen = screen;
	  this.pixels = new Array<Bitmap>();
	}


// make a new line on screen
  public static function create(map: Map, player: Cult,
      startNode: Node, endNode: Node): Dynamic
	{
      var screen = map.screen;
	  var line = new Line(screen);
      line.owner = player;
	  line.startNode = startNode;
	  line.endNode = endNode;
      line.isVisible = false;

      var cnt = 10;
      var dist = cast startNode.distance(endNode);
      if (dist < 50)
        cnt = Std.int(dist / 6) + 1;

	  var x: Float = startNode.centerX,
        y: Float = startNode.centerY;
      var modx = (endNode.centerX - startNode.centerX) / cnt,
        mody = (endNode.centerY - startNode.centerY) / cnt;

      for (i in 1...cnt)
        {
		  x += modx;
		  y += mody;

          var bmp: Bitmap = cast
            map.images.get("pixel" + player.id);
          var pixel = new Bitmap(bmp.bitmapData.clone());
          pixel.x = x;
          pixel.y = y;
          pixel.visible = false;
          screen.addChild(pixel);

		  line.pixels.push(pixel);
        }
      screen.addChild(startNode.uiNode.clip);
      screen.addChild(endNode.uiNode.clip);

      return line;
	}


// set line visibility
  public function setVisible(vis)
    {
      for (p in pixels)
        p.visible = vis;
      isVisible = vis;
    }


// clear a line
  public function clear()
    {
      for (p in pixels)
        p.parent.removeChild(p);
      pixels = null;
    }
}

