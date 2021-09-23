// line drawing class

import js.Browser;
import js.html.CanvasRenderingContext2D;


typedef Pixel =
{
  var x: Int;
  var y: Int;
};

class Line
{
  var ui: UI;
  var map: MapUI;

  public var startNode: Node;
  public var endNode: Node;
  public var pixels: Array<Pixel>;
  public var owner: Cult;
  public var visibility: Array<Bool>; // line visibility to cults


  function new(ui: UI)
    {
      this.ui = ui;
      this.map = ui.map;
      this.pixels = new Array<Pixel>();
    }


// make a new line on screen
  public static function create(ui: UI, player: Cult,
      startNode: Node, endNode: Node): Line
    {
      var line = new Line(ui);
      line.owner = player;
      line.startNode = startNode;
      line.endNode = endNode;
      line.visibility = [ false, false, false, false ];

      if (UI.classicMode)
        {
          var cnt = 10;
          var dist = startNode.distance(endNode);
          if (dist < 50)
            cnt = Std.int(dist / 6) + 1;

          var x: Float = startNode.centerX;
          var y: Float = startNode.centerY;
          var modx = (endNode.centerX - startNode.centerX) / cnt,
            mody = (endNode.centerY - startNode.centerY) / cnt;

          for (i in 1...cnt)
            {
              x += modx;
              y += mody;

              line.pixels.push({
                x: Math.round(x),
                y: Math.round(y)
              });
            }
        }

      return line;
    }


// paint a line
  public function paint(ctx: CanvasRenderingContext2D, cultID: Int)
    {
      if (!visibility[cultID])
        return;

      // both nodes significantly out of view rect, can skip
      var out = 0;
      if (!startNode.uiNode.inViewRect(200))
        out++;
      if (!endNode.uiNode.inViewRect(200))
        out++;
      if (out == 2)
        return;

      if (UI.classicMode)
        {
          var pixelSize = Std.int(ui.map.zoom * 2);
          if (pixelSize < 1)
            pixelSize = 1;
          for (p in pixels)
            ctx.drawImage(map.nodeImage,
              owner.id * 2, 120, 2, 2,
              ui.map.zoom * (p.x - map.viewRect.x),
              ui.map.zoom * (p.y - map.viewRect.y),
              pixelSize, pixelSize);
        }
      else
        {
          ctx.strokeStyle = UI.vars.cultColors[owner.id];
          ctx.lineWidth = 3 * ui.map.zoom;
          ctx.beginPath();
          ctx.moveTo(ui.map.zoom * (startNode.centerX - map.viewRect.x),
            ui.map.zoom * (startNode.centerY - map.viewRect.y));
          ctx.lineTo(ui.map.zoom * (endNode.centerX - map.viewRect.x),
            ui.map.zoom * (endNode.centerY - map.viewRect.y));
          ctx.stroke();
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

