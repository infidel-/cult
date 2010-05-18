// line drawing class

import js.Lib;

class Line
{
  var screen: Dynamic;

  public var startNode: Dynamic;
  public var endNode: Dynamic;
  public var pixels: Array<Dynamic>;
  public var owner: Cult;
  public var isVisible: Bool;


  function new(screen)
	{
      this.screen = screen;
	  this.pixels = new Array<Dynamic>();
	}


// make a new line on screen
  public static function paint(map: Map, player,
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

	  var x: Float = startNode.centerX, y: Float = startNode.centerY;
      var modx = (endNode.centerX - startNode.centerX) / cnt,
        mody = (endNode.centerY - startNode.centerY) / cnt;

      for (i in 1...cnt)
        {
		  x += modx;
		  y += mody;

          var pixel = js.Lib.document.createElement("pixel");
		  pixel.style.position = 'absolute';
		  pixel.style.left = Math.round(x) + 'px';
		  pixel.style.top = Math.round(y) + 'px';
		  pixel.style.width = '2';
		  pixel.style.height = '2';
		  pixel.style.background = Game.lineColors[player.id];
          pixel.style.zIndex = 10;
          pixel.style.visibility = 'hidden';
		  screen.appendChild(pixel);

		  line.pixels.push(pixel);
        }

      return line;
	}


// set line visibility
  public function setVisible(vis)
    {
      for (p in pixels)
        p.style.visibility = (vis ? 'visible' : 'hidden');
      isVisible = vis;
    }


// clear a line
  public function clear()
    {
      for (p in pixels)
        screen.removeChild(p);
      pixels = null;
    }
}

