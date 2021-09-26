// map block

import js.Browser;
import js.html.DivElement;
import js.html.Image;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.WheelEvent;
import js.html.MouseEvent;

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
  var map: CanvasElement;
  var mapBorder: DivElement;
  public var mapWidth: Float;
  public var mapHeight: Float;
  public var minimap: CanvasElement;

  // modern mode
  var firstTime: Bool;
  public var nodeImages: Array<CanvasElement>; // node images
  public var nodeHL: Image; // node highlight image
  public var nodeImagesGenerator: Array<CanvasElement>;
  public var textImages: Array<CanvasElement>; // text images: S, 1, 2, 3
  public var jobImages: Array<Image>; // loaded job images
  public var powerImages: Array<Image>; // loaded power images
  public var powerColors: Array<String>; // css vars cached

  // map zoom vars
  public var zoom: Float; // current value (on top of base map scale factor)
  var targetZoom: Float; // target value
  var targetZoomX: Int;
  var targetZoomY: Int;
  var lastZoomFrame: Float;
  static var minZoom = 0.25; // min value for zoom
  static var maxZoom = 1.0; // min value for zoom
  static var zoomSpeed = 15.0;

  // highlight zoom vars
  public var highlightZoom: Float;
  var targetHighlightZoom: Float;
  var lastHighlightZoomFrame: Float;
  static var maxHighlightZoom = 1.1;
  static var highlightZoomTime = 0.05; // seconds 
  static var highlightZoomSpeed = 0.007;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      viewRect = {
        x: 0,
        y: 0,
        w: 200,
        h: 200,
      };
      bgImage = null;
      firstTime = true;
      isDrag = false;
      zoom = 1.0;
      targetZoom = 1.0;
      targetHighlightZoom = maxHighlightZoom;
      highlightZoom = 1.0;

      // get power colors for canvas
      powerColors = [];
      for (i in 0...(Game.numPowers + 1))
        powerColors[i] = UI.getVar('--power-color-' + i);
      if (UI.classicMode)
        maxZoom = 3.0;

      // map display
      mapBorder = cast UI.e("mapBorder");
      map = cast UI.e("map");
      mapWidth = 200;
      mapHeight = 200;
//      map.getContext2d().scale(Browser.window.devicePixelRatio,
//        Browser.window.devicePixelRatio);

      map.onclick = onClick;
      map.onmousemove = onMouseMove;
      map.onmousedown = onMouseDown;
      map.onmouseup = onMouseUp;
      map.onmouseout = onMouseOut;
      Browser.document.onmouseout = function(event: MouseEvent)
        {
          if (event.relatedTarget == null)
            isDrag = false;
        }
      map.onwheel = onWheel;

      // tooltip element
      tooltip = Tools.window({
        id: "mapTooltip",
        fontSize: 16,
        w: null,
        h: null,
        z: 3000,
        border: false,
      });
      tooltip.style.display = 'none';

      loadImages();
      update(0); // first call
    }


// reinit minimap on new game
  public function initMinimap()
    {
      // can be called from load()
      if (minimap == null)
        {
          minimap = cast Browser.document.createElement('canvas');
          minimap.id = 'minimap';
        }
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
        loadImagesModern();
    }


// render node images for modern mode
  public function loadImagesModern()
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
          c.width = UI.vars.markerWidth;
          c.height = UI.vars.markerHeight;
          var cx = Std.int(c.width / 2);
          var cy = Std.int(c.height / 2);

          var r = cx;
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
          var clx = 44, cly = 8, rs = 8;
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

      // render generator node images
      nodeImagesGenerator = [];
      for (i in 0...9)
        {
          var c: CanvasElement =
            cast Browser.document.createElement('canvas');
          c.width = UI.vars.markerWidth;
          c.height = UI.vars.markerHeight;
          var cx = Std.int(c.width / 2);
          var cy = Std.int(c.height / 2);

          var r = cx;
          var n = c.getContext2d();

          // outer circle
          n.beginPath();
          n.arc(cx, cy, r, 0, 2 * Math.PI);
          n.fillStyle = UI.vars.cultColors[i];
          n.fill();

          // middle circle
          n.beginPath();
          n.arc(cx - 1, cy + 2, r - 5, 0, 2 * Math.PI);
          n.fillStyle = '#ffffff40';
          if (UI.modernGeneratorColors[i] != null)
            n.fillStyle = '#ffffff' + UI.modernGeneratorColors[i][1];
          n.fill();

          // inner circle
          n.beginPath();
          n.arc(cx - 3, cy + 6, r - 12, 0, 2 * Math.PI);
          n.fillStyle = '#ffffff70';
          if (UI.modernGeneratorColors[i] != null)
            n.fillStyle = '#ffffff' + UI.modernGeneratorColors[i][2];
          n.fill();

          // outer circle (level)
          var clx = 44, cly = 8, rs = 8;
          n.beginPath();
          n.arc(clx, cly, rs, 0, 2 * Math.PI);
          n.fillStyle = UI.vars.cultColors[i];
          n.fill();

          // inner circle (level)
          n.beginPath();
          n.arc(clx, cly, rs - 1, 0, 2 * Math.PI);
          n.fillStyle = '#f5efe1';
          n.fill();

          nodeImagesGenerator[i] = c;
        }

      // job images
      jobImages = [];
      for (info in UINode.jobInfo)
        {
          var img = new Image();
          img.src = 'data/' + info.img;
          img.width = info.w;
          img.height = info.h;
          jobImages.push(img);
        }

      // power icons
      powerImages = [];
      for (name in UI.modernPowerImages)
        {
          var img = new Image();
          img.src = 'data/' + name + '-map.png';
          img.width = 15;
          img.height = 15;
          powerImages.push(img);
        }

      // node highlight image
      nodeHL = new Image();
      nodeHL.src = 'data/highlight.png';
      nodeHL.width = 80;
      nodeHL.height = 80;
      jobImages.push(nodeHL);
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


/*
// scale loaded job images
  function scaleJobImages()
    {
      jobImages = [];
      for (img in jobImagesTemp)
        {
          var c: CanvasElement =
            cast Browser.document.createElement('canvas');
          c.width = 52;
          c.height = 52;
          var n = c.getContext2d();
          n.drawImage(img, 0, 0, c.width, c.height);
          jobImages.push(c);
        }
    }
*/


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


// re-enable animations
  public function enableAnimations()
    {
      Browser.window.requestAnimationFrame(update);
    }


// animation update and repaint
  function update(t: Float)
    {
      if (ui.config.getBool('animation'))
        Browser.window.requestAnimationFrame(update);

      // animate highlight zoom
      if (Sys.time() - lastHighlightZoomFrame > highlightZoomTime)
        {
          if (targetHighlightZoom > highlightZoom)
            {
              highlightZoom += highlightZoomSpeed;
              if (highlightZoom >= targetHighlightZoom)
                targetHighlightZoom = 1.0;
            }
          else
            {
              highlightZoom -= highlightZoomSpeed;
              if (highlightZoom <= targetHighlightZoom)
                targetHighlightZoom = maxHighlightZoom;
            }
          lastHighlightZoomFrame = Sys.time();
        }

      // animate map zoom
      var d = (Sys.time() - lastZoomFrame);
      zoom += (targetZoom - zoom) * zoomSpeed * d;
      if (Math.abs(targetZoom - zoom) < 0.001)
        zoom = targetZoom;
      lastZoomFrame = Sys.time();
//      trace('target: ' + targetZoom + ', cur: ' + zoom);
      if (zoom != targetZoom)
        center(targetZoomX, targetZoomY);
      paint();
    }


// paint all map
  public function paint()
    {
      if (game.isFinished && game.turns == 0)
        return;

      game.startTimer('map paint');

      // hack: generate text images on first real paint
      // this is needed because font might not be loaded earlier
      if (UI.modernMode && firstTime)
        {
          loadTextImages();
//          scaleJobImages();
          firstTime = false;
        }

      var ctx = map.getContext2d();
      if (UI.modernMode)
        {
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
          ctx.font =
            (UI.getVarInt('--map-font-size') * zoom) + 'px ' +
            UI.getVar('--map-font');
        }

      // paint visible lines
      for (l in game.lines)
        l.paint(ctx, game.player.id);

      // paint visible nodes
      for (n in game.nodes)
        n.uiNode.paint(ctx);

      // paint advanced node info
      if (game.options.getBool('mapAdvancedMode'))
        {
          var fontSize = zoom *
            UI.getVarInt('--advanced-mode-font-size');
          ctx.font = fontSize + 'px ' + UI.getVar('--advanced-mode-font');
          for (n in game.nodes)
            n.uiNode.paintAdvanced(ctx);
        }
      if (game.difficulty.mapWidth > mapWidth ||
          game.difficulty.mapHeight > mapHeight)
        {
          updateMinimap();
          ctx.drawImage(minimap,
            mapWidth - minimap.width,
            mapHeight - minimap.height);
        }

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

            color = UI.vars.nodeNeutralPixelColors[n.type];
            if (n.owner != null)
              color = UI.vars.nodePixelColors[n.owner.id];

            // larger dots for origins and artifacts
            var sz = 2;
            if (n.owner != null && n.owner.origin == n)
              sz = 3;
            if (n.type == 'artifact')
              sz = 3;
            for (dy in 0...sz)
              for (dx in 0...sz)
                paintPixel(pix,
                  (x + dx + (y + dy) * minimap.width) * 4, color);
          }

      ctx.putImageData(imageData, 0, 0);

      // draw view frame
      ctx.strokeStyle =
        (UI.classicMode ? 'rgb(100,100,100)' : 'rgb(200,200,200)');
      ctx.lineWidth = 1.0;
      ctx.strokeRect(
        viewRect.x / xscale + 1,
        viewRect.y / yscale + 1,
        mapWidth / xscale / zoom - 1,
        mapHeight / yscale / zoom - 1);
    }

// helper: paint a pixel with color
  inline function paintPixel(pix: js.lib.Uint8ClampedArray,
      index: Int, color: Array<Int>)
    {
      pix[index] = color[0];
      pix[index + 1] = color[1];
      pix[index + 2] = color[2];
    }

  public inline function hideTooltip()
    {
      tooltip.style.display = 'none';
    }

// scrolling wheel - map zoom
  public function onWheel(event: WheelEvent)
    {
      if (game.difficulty.mapWidth < game.difficulty.mapHeight)
        minZoom = 1.0 * viewRect.w / game.difficulty.mapWidth;
      else minZoom = 1.0 * viewRect.h / game.difficulty.mapHeight;
      if (minZoom > 1.0)
        minZoom = 1.0;
      var cx = Std.int(viewRect.w / 2 / zoom + viewRect.x);
      var cy = Std.int(viewRect.h / 2 / zoom + viewRect.y);
      targetZoomX = cx;
      targetZoomY = cy;

      var d = 0;
      if (event != null)
        d = (event.deltaY < 0 ? 1 : -1);
      var oldzoom = targetZoom;
      targetZoom += (UI.classicMode ? 0.15 : 0.05) * d;
      if (targetZoom < minZoom)
        targetZoom = minZoom;
      if (targetZoom > maxZoom) 
        targetZoom = maxZoom;
      if (targetZoom == oldzoom)
        return;
      if (!ui.config.getBool('animation'))
        zoom = targetZoom;

      center(cx, cy);
    }

// on moving over map
  public function onMouseMove(event: MouseEvent)
    {
      // toggle console
      ui.logConsole.check(event);

      // clear drag and selection
      if (event.buttons == 0)
        isDrag = false;
      if (event.buttons > 0)
        Browser.window.getSelection().empty();
      if (isDrag)
        {
          map.style.cursor = 'grabbing';
          viewRect.x -= Std.int((event.clientX - dragEventX) / zoom);
          viewRect.y -= Std.int((event.clientY - dragEventY) / zoom);

          dragEventX = event.clientX;
          dragEventY = event.clientY;

          rectBounds(); // put rect into map bounds
          paint();
          return;
        }

      var node = getEventNode(event);
      if (node == null)
        {
          map.style.cursor = 'grab';
          hideTooltip();
          return;
        }
      map.style.cursor =
        (game.player.canActivate(node) ? 'pointer' : 'not-allowed');

      // no tooltips in advanced mode
      if (game.options.getBool('mapAdvancedMode'))
        return;

      // render tooltip for this node
      showTooltip(node);

      // calculate tooltip position
      var mapRect = map.getBoundingClientRect();
      var tooltipRect = tooltip.getBoundingClientRect();
      var x = event.clientX - 20.0 - tooltipRect.width;
      var y = event.clientY + 5.0;
      if (x < 0)
        x = event.clientX + 20.0;
      if (x + tooltipRect.width > Browser.window.innerWidth)
        x = Browser.window.innerWidth - tooltipRect.width;
      if (y + tooltipRect.height > Browser.window.innerHeight)
        y = Browser.window.innerHeight - tooltipRect.height;

      tooltip.style.left = x + 'px';
      tooltip.style.top = y + 'px';
      tooltip.style.width = null;
      tooltip.style.height = null;
    }

// also called on changing node owner
  public function showTooltip(node: Node)
    {
      var text = node.uiNode.getTooltip();
      tooltip.innerHTML = text;
      tooltip.style.display = 'inline';
    }

// press and hold
  var dragEventX: Int;
  var dragEventY: Int;
  public function onMouseDown(event: MouseEvent)
    {
      // map same size as map or smaller
      if (viewRect.w >= game.difficulty.mapWidth &&
          viewRect.h >= game.difficulty.mapHeight)
        return;

      // do not allow drag start when on node
      if (getEventNode(event) != null)
        return;

      isDrag = true;
      dragEventX = event.clientX;
      dragEventY = event.clientY;
      map.style.cursor = 'grabbing';
    }


  public function onMouseUp(event: MouseEvent)
    {
      isDrag = false;
      map.style.cursor = 'grab';
    }


  public function onMouseOut(event: MouseEvent)
    {
      hideTooltip();
    }


// on clicking map
  public function onClick(event: MouseEvent)
    {
      var node = getEventNode(event);
      if (node == null)
        return;
      if (!game.player.canActivate(node))
        {
          map.style.cursor = 'not-allowed';
          return;
        }

      // activate node and run tutorial hooks
      var ret = game.player.activate(node);
      if (ret == 'ok')
        {
          game.tutorial.play('gainNode');
          if (game.player.origin.isProtected)
            game.tutorial.play('originProtected');
          if (game.player.awareness >= 10)
            game.tutorial.play('awareness');
        }
      paint();
    }


// put view rectangle into map bounds
  function rectBounds()
    {
      if ((viewRect.x * zoom + viewRect.w) >
          game.difficulty.mapWidth * zoom)
        viewRect.x = Std.int((game.difficulty.mapWidth * zoom -
          viewRect.w) / zoom);
      if (viewRect.y * zoom + viewRect.h >
          game.difficulty.mapHeight * zoom)
        viewRect.y = Std.int((game.difficulty.mapHeight * zoom -
          viewRect.h) / zoom);
      if (viewRect.x < 0)
        viewRect.x = 0;
      if (viewRect.y < 0)
        viewRect.y = 0;
    }


// center on x,y
  public function center(x: Int, y: Int)
    {
      viewRect.x = Std.int((x * zoom - viewRect.w / 2) / zoom);
      viewRect.y = Std.int((y * zoom - viewRect.h / 2) / zoom);

      rectBounds();
      paint();
    }


// get node from mouse event
  function getEventNode(event: MouseEvent): Node
    {
      // game not started yet
      if (game.nodes == null)
        return null;

      var mapRect = map.getBoundingClientRect();
      var x = (event.clientX - mapRect.x) / zoom + viewRect.x;
      var y = (event.clientY - mapRect.y) / zoom + viewRect.y;
//      trace('event ' + Std.int(x),Std.int(y));

      // find which node the click was on
      var node = null;
      var r = (UI.classicMode ? 10 : 32);
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
      var bw = Std.parseInt(map.style.borderWidth);
      var panelRect = mapBorder.getBoundingClientRect();
      var marginx = UI.getVarInt('--map-margin-x');
      var marginy = UI.getVarInt('--map-margin-y');
      mapWidth = panelRect.width - marginx;
      mapHeight = panelRect.height - marginy;
      map.width = Std.int(mapWidth);
      map.height = Std.int(mapHeight);
      map.style.width = mapWidth + 'px';
      map.style.height = mapHeight + 'px';
      viewRect.w = map.width;
      viewRect.h = map.height;

      if (game.isNeverStarted)
        return;

      // reset view x,y when map is smaller than viewport
      if (game.difficulty.mapWidth <= mapWidth && 
          game.difficulty.mapHeight <= mapHeight)
        {
          viewRect.x = 0;
          viewRect.y = 0;
        }

      onWheel(null);
      paint();
    }
}
