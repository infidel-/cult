// map block

import js.Lib;

typedef Rect =
{ 
  var x: Int;
  var y: Int;
  var w: Int;
  var h: Int;
};


class Map
{
  var ui: UI;
  var game: Game;

  public var images: Hash<Dynamic>; // images array
  public var tooltip: Dynamic;
//  public var screen: Dynamic; // map element
  public var viewRect: Rect; // viewport x,y
  var isDrag: Bool; // is viewport being dragged?

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      viewRect = { x:0, y:0, w:UI.mapWidth, h:UI.mapHeight };

      // map display
      var screen:Dynamic = UI.e("map");
      screen.style.border = 'double white 4px';
      screen.style.width = UI.mapWidth;
      screen.style.height = UI.mapHeight;
      screen.style.position = 'absolute';
      screen.style.left = 240;
      screen.style.top = 5 + UI.topHeight;
      screen.style.overflow = 'hidden';
      if (!(untyped screen).getContext)
        Lib.window.alert("No canvas available. Please use a canvas-compatible browser like Mozilla Firefox 3.5+ or Google Chrome.");

      screen.onclick = onClick;
      screen.onmousemove = onMove;
      screen.onmousedown = onMouseDown; 
      screen.onmouseup = onMouseUp;
      screen.onmouseout = onMouseUp;
      
      // main menu window
      tooltip = Tools.window(
        {
          id: "mapTooltipWindow",
          center: true,
          winW: UI.winWidth,
          winH: UI.winHeight,
          fontSize: 16,
          w: 200,
          h: 280,
          z: 3000
        });
      tooltip.style.padding = 5;
      tooltip.style.border = '1px solid';
      tooltip.style.opacity = 0.9;

      loadImages();
    }


// load all game-related images
  function loadImages()
    {
      images = new Hash<Dynamic>();

      var imgnames = [ 'cult0', 'cult0gp', 'cult0g', 'cult1g', 'cult1gp', 'cult1', 
        'cult2g', 'cult2gp', 'cult2', 'cult3g', 'cult3gp', 
        'cult3', 'hl', 'neutralg', 'neutral', 'origin0', 'origin0p', 
        'origin1', 'origin1p', 'origin2', 'origin2p', 'origin3', 
        'origin3p', 'pixel0', 'pixel1', 'pixel2', 'pixel3'
      ];

      for (nm in imgnames)
        {
          var img = untyped __js__("new Image()");
          img.onload = onLoadImage;
          img.src = 'data/nodes/' + nm + '.png';

          images.set(nm, img);
        }
    }


  function onLoadImage()
    {
      paint();
    }


// paint all map
  public function paint()
    {
      if (game.isFinished)
        return;

      var el = untyped UI.e("map");
      var ctx = el.getContext("2d");
      ctx.fillStyle = "black";
      ctx.fillRect(0, 0, UI.mapWidth, UI.mapHeight);
      ctx.font = "14px Verdana";

      // paint visible lines
      for (l in game.lines)
        l.paint(ctx, this);

      // paint visible nodes
      for (n in game.nodes)
        n.uiNode.paint(ctx);

      paintMinimap(ctx); // paint minimap
    }


// paint minimap
  function paintMinimap(ctx: Dynamic)
    {
      var mw = 100, mh = 100,
        mx = UI.mapWidth - mw, my = UI.mapHeight - mh;

      var xscale:Float = 1.0 * Game.mapWidth / mw;
      var yscale:Float = 1.0 * Game.mapHeight / mh;

      // draw bg
      ctx.fillStyle = 'rgba(20,20,20,0.5)';
      ctx.fillRect(mx, my, mw, mh);

      var imageData = ctx.getImageData(mx, my, mw, mh);
      var pix: Array<Int> = imageData.data;

      for (n in game.nodes)
        if (n.isVisible(game.player))
          {
            var x = Std.int(n.x / xscale);
            var y = Std.int(n.y / yscale);

            var index = (x + y * mw) * 4;
            var color = UI.nodeNeutralPixelColors;
            if (n.owner != null)
              color = UI.nodePixelColors[n.owner.id];
            pix[index] = color[0];
            pix[index + 1] = color[1];
            pix[index + 2] = color[2];

            if (n.owner != null)
              {
              }
          }

      ctx.putImageData(imageData, mx, my);

      // draw view frame
      ctx.strokeStyle = 'rgb(100,100,100)';
      ctx.lineWidth = 1.0;
      ctx.strokeRect(mx + viewRect.x / xscale, my + viewRect.y / yscale,
        UI.mapWidth / xscale, UI.mapHeight / yscale);
    }


// on moving over map
  public function onMove(event: Dynamic)
    {
      if (isDrag)
        {
          viewRect.x -= Std.int(event.clientX - dragEventX);
          viewRect.y -= Std.int(event.clientY - dragEventY);

          dragEventX = event.clientX;
          dragEventY = event.clientY;

          rectBounds(); // put rect into map bounds

          paint();
          return;
        }

      var node = getEventNode(event);
      if (node == null)
        {
          tooltip.style.visibility = 'hidden';
          return;
        }

      // render tooltip for this node
      var text = node.uiNode.getTooltip();

      var cnt = 0;
      var ii = 0;
      while (true)
        {
          var i = text.indexOf('<br>', ii);
          if (i == -1)
            break;
          ii = i + 1;
          cnt++;
        }

      var el = untyped UI.e("map");
      var x = event.clientX - el.offsetLeft - 4;
      var y = event.clientY - el.offsetTop - 6;

      if (x + 250 > js.Lib.window.innerWidth)
        x = js.Lib.window.innerWidth - 250;
      if (y + cnt * 20 + 50 > js.Lib.window.innerHeight)
        y = js.Lib.window.innerHeight - cnt * 20 - 50;

      tooltip.style.left = x;
      tooltip.style.top = y;

      tooltip.innerHTML = text;
      tooltip.style.height = cnt * 20;
      tooltip.style.visibility = 'visible';
    }


  var dragEventX: Int;
  var dragEventY: Int;
  public function onMouseDown(event: Dynamic)
    {
      isDrag = true;
      dragEventX = event.clientX;
      dragEventY = event.clientY;
    }


  public function onMouseUp(event: Dynamic)
    {
      isDrag = false;
    }


// on clicking map
  public function onClick(event: Dynamic)
    {
      if (game.isFinished)
        return;

      var node = getEventNode(event);
      if (node == null)
        return;

      game.player.activate(node);
      paint();
    }


// put view rectangle into map bounds
  function rectBounds()
    {
      if (viewRect.x < 0)
        viewRect.x = 0;
      if (viewRect.y < 0)
        viewRect.y = 0;
      if (viewRect.x + viewRect.w > Game.mapWidth)
        viewRect.x = Game.mapWidth - viewRect.w;
      if (viewRect.y + viewRect.h > Game.mapHeight)
        viewRect.y = Game.mapHeight - viewRect.h;
    }


// center on x,y
  public function center(x: Int, y: Int)
    {
      viewRect.x = Std.int(x - viewRect.w / 2);
      viewRect.y = Std.int(y - viewRect.h / 2);

      rectBounds();
      paint();
    }


// get node from mouse event
  function getEventNode(event: Dynamic): Node
    {
      var el = untyped UI.e("map");
      var x = event.clientX - el.offsetLeft - 4 + viewRect.x;
      var y = event.clientY - el.offsetTop - 6 + viewRect.y;

      // find which node the click was on
      var node = null;
      for (n in game.nodes)
        {
          if (!n.isVisible(game.player))
            continue;

          if (x > n.x - 10 && x <= n.x + 20 &&
              y > n.y - 10 && y <= n.y + 20)
            {
              node = n;
              break;
            }
        }

      return node;
    }


// clear map
  public function clear()
    {
    }
}
