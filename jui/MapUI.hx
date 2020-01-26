// map block

import js.Browser;
import js.html.DivElement;

typedef Rect =
{
  var x: Int;
  var y: Int;
  var w: Int;
  var h: Int;
};


class MapUI
{
  var ui: UI;
  var game: Game;

//  public var images: Hash<Dynamic>; // images array
  public var fontImage: Dynamic; // bitmapped font image
  public var nodeImage: Dynamic; // nodes imageset
  public var tooltip: DivElement;
//  public var screen: Dynamic; // map element
  public var viewRect: Rect; // viewport x,y
  var isDrag: Bool; // is viewport being dragged?
  public var isAdvanced: Bool; // is advanced mode

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      viewRect = { x:0, y:0, w:UI.mapWidth, h:UI.mapHeight };
      isAdvanced = false;

      // map display
      var screen = UI.e("map");
      screen.style.border = 'double #777 4px';
      screen.style.width = UI.mapWidth + 'px';
      screen.style.height = UI.mapHeight + 'px';
      screen.style.position = 'absolute';
      screen.style.left = '240px';
      screen.style.top = (5 + UI.topHeight) + 'px';
      screen.style.overflow = 'hidden';
      if (!(untyped screen).getContext)
        Browser.window.alert("No canvas available. Please use a canvas-compatible browser like Mozilla Firefox 3.5+ or Google Chrome.");

      screen.onclick = onClick;
      screen.onmousemove = onMove;
      screen.onmousedown = onMouseDown;
      screen.onmouseup = onMouseUp;
      screen.onmouseout = onMouseOut;

      // tooltip element
      tooltip = Tools.window({
        id: "mapTooltipWindow",
        winW: UI.winWidth,
        winH: UI.winHeight,
        fontSize: 16,
        w: 200,
        h: 280,
        z: 3000
      });
      tooltip.style.padding = '5px';
      tooltip.style.border = '1px solid';
      tooltip.style.opacity = '0.9';

      loadImages();
    }


// load all game-related images
  function loadImages()
    {
/*
      images = new Hash<Dynamic>();

      var imgnames = [ 'cult0', 'cult0gp', 'cult0g', 'cult1g', 'cult1gp', 'cult1',
        'cult2g', 'cult2gp', 'cult2', 'cult3g', 'cult3gp',
        'cult3', 'hl', 'neutralg', 'neutral', 'origin0', 'origin0p',
        'origin1', 'origin1p', 'origin2', 'origin2p', 'origin3',
        'origin3p', 'pixel0', 'pixel1', 'pixel2', 'pixel3', 'data/4x6'
      ];

      for (nm in imgnames)
        {
          var img = untyped __js__("new Image()");
          img.onload = onLoadImage;
          img.src = (nm.indexOf('/') > 0 ? '' : 'data/nodes/') + nm + '.png';

          images.set(nm, img);
        }
*/
      nodeImage = untyped __js__("new Image()");
      nodeImage.onload = onLoadImage;
      nodeImage.src = 'data/nodes.png';

      fontImage = untyped __js__("new Image()");
      fontImage.onload = onLoadImage;
      fontImage.src = 'data/5x8.png';
    }


  function onLoadImage()
    {
      paint();
    }


// paint all map
  public function paint()
    {
//      trace('paint');
      if (game.isFinished && game.turns == 0)
        return;

      game.startTimer('map paint');

      var el = untyped UI.e("map");
      var ctx = el.getContext("2d");
      ctx.fillStyle = "black";
      ctx.fillRect(0, 0, UI.mapWidth, UI.mapHeight);
      ctx.font = "14px Verdana";

      // paint visible lines
      for (l in game.lines)
        l.paint(ctx, this, game.player.id);

      // paint visible nodes
      for (n in game.nodes)
        n.uiNode.paint(ctx);

      if (isAdvanced) // paint advanced node info
        {
          ctx.font = "11px Verdana";
          for (n in game.nodes)
            n.uiNode.paintAdvanced(ctx);
        }

      if (game.difficulty.mapWidth > UI.mapWidth ||
          game.difficulty.mapHeight > UI.mapHeight)
        paintMinimap(ctx); // paint minimap

      game.endTimer('map paint');
    }


// paint minimap
  function paintMinimap(ctx: Dynamic)
    {
      var mw = 100, mh = 100,
        mx = UI.mapWidth - mw, my = UI.mapHeight - mh;

      var xscale:Float = 1.0 * game.difficulty.mapWidth / mw;
      var yscale:Float = 1.0 * game.difficulty.mapHeight / mh;

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
/*
            if (n.owner != null)
              {
              }
*/
          }

      ctx.putImageData(imageData, mx, my);

      // draw view frame
      ctx.strokeStyle = 'rgb(100,100,100)';
      ctx.lineWidth = 1.0;
      ctx.strokeRect(mx + viewRect.x / xscale, my + viewRect.y / yscale,
        UI.mapWidth / xscale, UI.mapHeight / yscale);
    }


// paint bitmapped text
  public function paintText(ctx: Dynamic, syms: Array<Int>, row: Int, x: Int, y: Int)
    {
      var i = 0;
      for (ch in syms)
        {
          ctx.drawImage(fontImage,
            ch * 5, row * 8, 5, 8,
            x + i * 6, y, 5, 8);
          i++;
        }
    }


  public inline function hideTooltip()
    {
      tooltip.style.display = 'none';
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
          hideTooltip();
          return;
        }

      if (isAdvanced) // no tooltips in advanced mode
        return;

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
      var x = event.clientX - el.offsetLeft - 4 + js.Browser.document.body.scrollLeft;
      var y = event.clientY - el.offsetTop - 6 + js.Browser.document.body.scrollTop;

      if (x + 250 > js.Browser.window.innerWidth)
        x = js.Browser.window.innerWidth - 250;
      if (y + cnt * 20 + 50 > js.Browser.window.innerHeight)
        y = js.Browser.window.innerHeight - cnt * 20 - 50;

      tooltip.style.left = x + 'px';
      tooltip.style.top = y + 'px';

      tooltip.innerHTML = text;
      tooltip.style.height = (cnt * 20) + 'px';
      tooltip.style.display = 'inline';
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


  public function onMouseOut(event: Dynamic)
    {
      isDrag = false;
      hideTooltip();
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
      if (viewRect.x + viewRect.w > game.difficulty.mapWidth)
        viewRect.x = game.difficulty.mapWidth - viewRect.w;
      if (viewRect.y + viewRect.h > game.difficulty.mapHeight)
        viewRect.y = game.difficulty.mapHeight - viewRect.h;
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
      // No game started yet
      if (game.nodes == null)
        return null;

      var el = untyped UI.e("map");
      var x = event.clientX - el.offsetLeft - 4 + viewRect.x + js.Browser.document.body.scrollLeft;
      var y = event.clientY - el.offsetTop - 6 + viewRect.y + js.Browser.document.body.scrollTop;

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
