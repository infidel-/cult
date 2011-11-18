// line drawing class

import js.Lib;


typedef Pixel =
{
  var x: Int;
  var y: Int;
};

class Line
{
  public var startNode: Node;
  public var endNode: Node;
  public var pixels: Array<Pixel>;
  public var owner: Cult;
  public var visibility: Array<Bool>; // line visibility to cults


  function new()
	{
	  this.pixels = new Array<Pixel>();
	}


// make a new line on screen
  public static function create(map: Map, player: Cult,
      startNode: Node, endNode: Node): Line
	{
	  var line = new Line();
      line.owner = player;
	  line.startNode = startNode;
	  line.endNode = endNode;
      line.visibility = [ false, false, false, false ];

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

		  line.pixels.push({ x: Math.round(x), y: Math.round(y) });
        }

      return line;
	}


// paint a line
  public function paint(ctx: Dynamic, map: Map, cultID: Int)
    {
      if (!visibility[cultID])
        return;

//      var img = map.images.get('pixel' + owner.id);
      for (p in pixels)
        {
          // pixel out of view rectangle
          if (p.x < map.viewRect.x - 2 ||
              p.y < map.viewRect.y - 2 ||
              p.x > map.viewRect.x + map.viewRect.w ||
              p.y > map.viewRect.y + map.viewRect.h)
            continue;

//          ctx.drawImage(img, p.x - map.viewRect.x, p.y - map.viewRect.y);
          ctx.drawImage(map.nodeImage,
            owner.id * 2, 120, 2, 2,
            p.x - map.viewRect.x, p.y - map.viewRect.y, 2, 2);
        }
    }


// set line visibility to this cult
  public inline function setVisible(c: Cult, vis: Bool)
    {
      visibility[c.id] = vis;
    }


// clear a line
  public function clear()
    {
      pixels = null;
    }
}

