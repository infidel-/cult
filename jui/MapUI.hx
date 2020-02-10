// map block

import js.Browser;
import js.html.DivElement;
import js.html.Image;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

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

  public var fontImage: Image; // bitmapped font image
  public var nodeImage: Image; // nodes imageset (classic)
  public var bgImage: Image; // map bg
  public var tooltip: DivElement;
  public var viewRect: Rect; // viewport x,y
  var isDrag: Bool; // is viewport being dragged?
  public var isAdvanced: Bool; // is advanced mode
  var map: CanvasElement;
  var mapWidth: Float;
  var mapHeight: Float;
  var minimap: CanvasElement;

  // modern mode
  var firstTime: Bool;
  public var nodeImages: Array<CanvasElement>; // node images
  public var textImages: Array<CanvasElement>; // text images: S, 1, 2, 3

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      viewRect = { x: 0, y: 0, w: UI.mapWidth, h: UI.mapHeight };
      isAdvanced = false;
      bgImage = null;
      firstTime = true;

      // map display
      map = cast UI.e("map");
      map.style.border = 'double #777 4px';
      map.style.width = UI.mapWidth + 'px';
      map.style.height = UI.mapHeight + 'px';
      map.style.position = 'absolute';
      map.style.left = '240px';
      map.style.top = (5 + UI.topHeight) + 'px';
      map.style.overflow = 'hidden';
      mapWidth = UI.mapWidth;
      mapHeight = UI.mapHeight;
      map.getContext2d().scale(Browser.window.devicePixelRatio,
        Browser.window.devicePixelRatio);

      map.onclick = onClick;
      map.onmousemove = onMove;
      map.onmousedown = onMouseDown;
      map.onmouseup = onMouseUp;
      map.onmouseout = onMouseOut;

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


// reinit minimap on new game
  public function initMinimap()
    {
      minimap = cast Browser.document.createElement('canvas');
      minimap.id = 'minimap';
      minimap.width = Std.int(game.difficulty.mapWidth * 100.0 /
        game.difficulty.mapHeight);
      minimap.height = 100;
    }


// load all game-related images
  function loadImages()
    {
      nodeImage = new Image();
      nodeImage.onload = onLoadImage;
      nodeImage.src = 'data/nodes.png';

      fontImage = new Image();
      fontImage.onload = onLoadImage;
      fontImage.src = 'data/5x8.png';

      if (UI.modernMode)
        {
          bgImage = new Image();
          bgImage.onload = onLoadImage;
          bgImage.src = 'data/bg.png';

          // render node images
          nodeImages = [];
          for (i in 0...9)
            {
              var c: CanvasElement =
                cast Browser.document.createElement('canvas');
              c.width = 52;
              c.height = 52;
              var cx = Std.int(c.width / 2);
              var cy = Std.int(c.height / 2);

              var r = 26;
              var n = c.getContext2d();

              // outer circle
              n.beginPath();
              n.arc(cx, cy, r, 0, 2 * Math.PI);
              n.fillStyle = UI.vars.cultColors[i];
              n.fill();

              // inner circle
              n.beginPath();
              n.arc(cx - 1, cy + 2, r - 5, 0, 2 * Math.PI);
              n.fillStyle = '#f5efe1';
              n.fill();

              // outer circle (level)
              var clx = 40, cly = 8, rs = 8;
              n.beginPath();
              n.arc(clx, cly, rs, 0, 2 * Math.PI);
              n.fillStyle = UI.vars.cultColors[i];
              n.fill();

              // inner circle (level)
              n.beginPath();
              n.arc(clx, cly, rs - 1, 0, 2 * Math.PI);
              n.fillStyle = '#f5efe1';
              n.fill();

              nodeImages[i] = c;
            }
        }
    }


// generate text images
  function loadTextImages()
    {
      // render text images
      textImages = [];
      var text = [ '?', 'S', '1', '2', '3', '-' ];
      for (i in 0...text.length)
        {
          var c: CanvasElement =
            cast Browser.document.createElement('canvas');
          c.width = 11;
          c.height = 13;
          var r = c.getContext2d();
          r.textBaseline = 'top';
          r.textAlign = 'left';
          r.font = 'bold 14px Mitr';
//          r.fillStyle = 'red';
//          r.fillRect(0, 0, c.width, c.height);
          r.fillStyle = 'black';
          r.fillText(text[i], (text[i] == '1' ? 2 : 1), 1);

          textImages[i] = c;
        }
    }

  public static var textToIndex = [
    '?' => 0,
    'S' => 1,
    '1' => 2,
    '2' => 3,
    '3' => 4,
    '-' => 5,
  ];


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

      // hack: generate text images on first real paint
      // this is needed because font might not be loaded earlier
      if (UI.modernMode && firstTime)
        {
          loadTextImages();
          firstTime = false;
        }

//      game.startTimer('map paint 1');

      var ctx = map.getContext2d();
      if (UI.modernMode)
        {
//          trace(mapWidth + ',' + mapHeight + ' : ' +
//            bgImage.width + ',' + bgImage.height);
          var w = 0.0, h = 0.0;
          if (mapWidth < mapHeight)
            {
              w = mapWidth;
              h = bgImage.height / (bgImage.width / mapWidth);
              if (h < mapHeight)
                {
                  w = bgImage.width / (bgImage.height / mapHeight);
                  h = mapHeight + 1;
                }
            }
          else
            {
              w = bgImage.width / (bgImage.height / mapHeight);
              h = mapHeight + 1;
              if (w < mapWidth)
                {
                  w = mapWidth;
                  h = bgImage.height / (bgImage.width / mapWidth);
                }
            }
          ctx.drawImage(bgImage, 0, 0, w, h);
        }
      else
        {
          ctx.fillStyle = "black";
          ctx.fillRect(0, 0, mapWidth, mapHeight);
          ctx.font = "14px Verdana";
        }
//      game.endTimer('map paint 1');
//      game.startTimer('map paint 2');

      // paint visible lines
      for (l in game.lines)
        l.paint(ctx, game.player.id);
//      game.endTimer('map paint 2');
//      game.startTimer('map paint 3');

      // paint visible nodes
      for (n in game.nodes)
        n.uiNode.paint(ctx);
//      game.endTimer('map paint 3');
//      game.startTimer('map paint 4');

      if (isAdvanced) // paint advanced node info
        {
          ctx.font = "11px Verdana";
          for (n in game.nodes)
            n.uiNode.paintAdvanced(ctx);
        }
//      game.endTimer('map paint 4');
//      game.startTimer('map paint 5');
      if (game.difficulty.mapWidth > mapWidth ||
          game.difficulty.mapHeight > mapHeight)
        {
          updateMinimap();
          ctx.drawImage(minimap,
            mapWidth - minimap.width,
            mapHeight - minimap.height);
        }
//      game.endTimer('map paint 5');
//      game.startTimer('map paint 6');

/*
      if (UI.modernMode)
        for (i in 0...100)
          {
            var xx = 50 + Std.random(UI.mapWidth),
              yy = 50 + Std.random(UI.mapHeight);
            ctx.drawImage(
              nodeImages[Std.random(4)], xx, yy);
            ctx.drawImage(
              textImages[Std.random(4)], xx + 35, yy + 1);
  /-
            ctx.font = '20px ChangaOne';
            ctx.fillStyle = 'green';
            ctx.fillText("Test 1 2 3 S", xx, yy);
  -/
          }
*/

      game.endTimer('map paint');
    }


// update minimap
// looks like caching is not necessary yet
// (plus view frame has to be drawn every repaint)
  function updateMinimap()
    {
      var ctx = minimap.getContext2d();
      ctx.clearRect(0, 0, minimap.width, minimap.height);

      var xscale = 1.0 * game.difficulty.mapWidth / minimap.width;
      var yscale = 1.0 * game.difficulty.mapHeight / minimap.height;

      // draw bg
      ctx.fillStyle = 'rgba(20,20,20,0.65)';
      ctx.fillRect(0, 0, minimap.width, minimap.height);

      var imageData = ctx.getImageData(0, 0, minimap.width, minimap.height);
      var pix = imageData.data;

      var x = 0, y = 0, index = 0, color = null;
      for (n in game.nodes)
        if (n.isVisible(game.player))
          {
            x = Std.int(n.x / xscale);
            y = Std.int(n.y / yscale);

            color = UI.vars.nodeNeutralPixelColors;
            if (n.owner != null)
              color = UI.vars.nodePixelColors[n.owner.id];

            index = (x + y * minimap.width) * 4;
            pix[index] = color[0];
            pix[index + 1] = color[1];
            pix[index + 2] = color[2];
            pix[index + 4] = color[0];
            pix[index + 5] = color[1];
            pix[index + 6] = color[2];
            index = (x + (y + 1) * minimap.width) * 4;
            pix[index] = color[0];
            pix[index + 1] = color[1];
            pix[index + 2] = color[2];
            pix[index + 4] = color[0];
            pix[index + 5] = color[1];
            pix[index + 6] = color[2];
          }

      ctx.putImageData(imageData, 0, 0);

      // draw view frame
      ctx.strokeStyle =
        (UI.classicMode ? 'rgb(100,100,100)' : 'rgb(200,200,200)');
      ctx.lineWidth = 1.0;
      ctx.strokeRect(
        viewRect.x / xscale + 1,
        viewRect.y / yscale + 1,
        UI.mapWidth / xscale - 1,
        UI.mapHeight / yscale - 1);
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

      var x = event.clientX - map.offsetLeft - 4 + Browser.document.body.scrollLeft;
      var y = event.clientY - map.offsetTop - 6 + Browser.document.body.scrollTop;

      if (x + 250 > Browser.window.innerWidth)
        x = Browser.window.innerWidth - 250;
      if (y + cnt * 20 + 50 > Browser.window.innerHeight)
        y = Browser.window.innerHeight - cnt * 20 - 50;

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
      // map same size as map or smaller
      if (viewRect.w >= game.difficulty.mapWidth &&
          viewRect.h >= game.difficulty.mapHeight)
        return;

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
      // game not started yet
      if (game.nodes == null)
        return null;

      var x = event.clientX - map.offsetLeft - 4 + viewRect.x +
        Browser.document.body.scrollLeft;
      var y = event.clientY - map.offsetTop - 6 + viewRect.y +
        Browser.document.body.scrollTop;

      // find which node the click was on
      var node = null;
      var r = (UI.classicMode ? 10 : 26);
      for (n in game.nodes)
        {
          if (!n.isVisible(game.player))
            continue;

          if (x >= n.x && x <= n.x + 2 * r &&
              y >= n.y && y <= n.y + 2 * r)
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


// resize map
  public function resize()
    {
      var win = Browser.window;
      var bw = Std.parseInt(map.style.borderWidth);
      mapWidth = win.innerWidth - map.offsetLeft - 2 * bw - 8;
      mapHeight = win.innerHeight - map.offsetTop - 2 * bw - 8;
      map.width = Std.int(mapWidth);
      map.height = Std.int(mapHeight);
      map.style.width = mapWidth + 'px';
      map.style.height = mapHeight + 'px';
      viewRect.w = map.width;
      viewRect.h = map.height;

      paint();
    }
}
