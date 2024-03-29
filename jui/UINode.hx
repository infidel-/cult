// node ui
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;

class UINode
{
  var game: Game;
  var ui: UI;
  var node: Node;
  var imageName: String; // image name

  var tempx: Int; // temp buffer for painting - calculated screen x,y,h, border width
  var tempy: Int;
  var temph: Int;
  var tempd: Int;


  public function new(gvar, uivar, nvar)
    {
      game = gvar;
      ui = uivar;
      node = nvar;
    }


// paint node on map
  public function paint(ctx: CanvasRenderingContext2D)
    {
      // node not visible to player
      if (!node.isVisible(game.player))
        return;

      // node out of view rectangle
      if (!inViewRect(UI.vars.markerWidth))
        return;
//      game.startTimer('node paint');

      var key = '';
      var xx = node.x, yy = node.y,
//        hlx: Float = node.x - 10, hly: Float = node.y - 10,
        hlx: Float = node.x, hly: Float = node.y,
        tx = node.x + 4, ty = node.y + 14;
      var text = '';
      var textColor = 'white';

      // get power char
      var isI = false, is1 = false;
      var cnt = 0;
      for (i in 0...Game.numFullPowers)
        if (node.power[i] > 0)
          {
            cnt++;
            text = Game.powerShortNames[i];
            textColor = UI.getVar('--power-color-' + i);
            isI = false;
            if (Game.powerShortNames[i] == "I")
              isI = true;
          }
      if (cnt > 1)
        {
          text = Game.powerShortNames[4];
          textColor = UI.getVar('--power-color-4');
        }
      if (node.type == 'artifact')
        {
          isI = false;
          text = 'A';
          textColor = UI.getVar('--artifact-color');
        }

      // get bg and node char
      if (node.owner != null)
        {
//          key = "cult" + node.owner.id;
          key = 'c';
          text = '' + (node.level + 1);
          textColor = 'white';
          if (node.sect != null)
            text = 'S';
          if (!node.isKnown[game.player.id])
            text = '?';
        }
      else key = "neutral";

      // different borders
      var dd = 0;
      tempd = 0;
      temph = 17;
      if (node.isGenerator)
        {
          key += "g";
          dd = 2;
        }

      for (p in game.cults)
        if (p.origin == node && !p.isDead &&
            node.isKnown[game.player.id])
          {
            key = 'o';
            dd = 4;
            break;
          }
      if (node.isProtected)
        key += "p";
      xx -= dd;
      yy -= dd;
      temph += dd * 2;
      tempd = dd;

      if (isI) // "I" symbol needs to be centered
        tx += 2;

      xx -= ui.map.viewRect.x;
      yy -= ui.map.viewRect.y;
      tx -= ui.map.viewRect.x;
      ty -= ui.map.viewRect.y;
      hlx -= ui.map.viewRect.x;
      hly -= ui.map.viewRect.y;

      // paint node highlight
      for (n in game.player.highlightedNodes)
        if (n == node)
          {
            if (UI.classicMode)
              ctx.drawImage(ui.map.nodeImage,
                0, 167, 37, 37,
                (hlx - 10) * ui.map.zoom,
                (hly - 10) * ui.map.zoom,
                37 * ui.map.zoom,
                37 * ui.map.zoom);
            else
              {
                // rectangle animation
                var img = getImage();
                hlx -= 0.5 * ui.map.highlightZoom * ui.map.nodeHL.width;
                hlx += 0.5 * img.width;
                hly -= 0.5 * ui.map.highlightZoom * ui.map.nodeHL.height;
                hly += 0.5 * img.height;

                ctx.drawImage(ui.map.nodeHL,
                  hlx * ui.map.zoom,
                  hly * ui.map.zoom,
                  ui.map.nodeHL.width * ui.map.zoom * ui.map.highlightZoom,
                  ui.map.nodeHL.height * ui.map.zoom * ui.map.highlightZoom);
              }
            break;
          }

      // paint node images
      if (UI.classicMode)
        {
          var a: Array<Int> = Reflect.field(imageKeys, key);
          var y0 = a[0];
          var w = a[1];
          var x0 = (node.owner != null ? node.owner.id * w : 0);
          ctx.drawImage(ui.map.nodeImage,
            x0, y0, w, w,
            xx * ui.map.zoom,
            yy * ui.map.zoom,
            w * ui.map.zoom,
            w * ui.map.zoom);
//          ctx.fillStyle = 'red';
//          ctx.fillRect(xx, yy, 20, 20);

          // paint node symbol
          ctx.fillStyle = textColor;
          ctx.fillText(text, tx * ui.map.zoom, ty * ui.map.zoom);
          if (node.type == 'artifact')
            {
              var art: artifacts.ArtifactNode = cast node;
              ctx.fillText('' + art.turns, tx + 15, ty + 8);
            }
        }
      else
        {
          if (node.owner == null)
            text = '-';
//          ctx.fillStyle = 'red';
//          ctx.fillRect(xx, yy, 52, 52);

          // background
          var img = getImage();
          ctx.drawImage(img, xx * ui.map.zoom, yy * ui.map.zoom,
            img.width * ui.map.zoom,
            img.height * ui.map.zoom);

          // node icon
          paintIcon(ctx, xx, yy, key);

          // resource to acquire
          if (node.owner != game.player &&
              !game.options.getBool('mapAdvancedMode') &&
              (node.isKnown[game.player.id] || node.owner == null))
            {
              var idx = -1;
              for (i in 0...Game.numFullPowers)
                if (node.power[i] > 0)
                  {
                    if (idx == -1)
                      idx = i;
                    else idx = Game.numFullPowers;
                  }
              var img = ui.map.powerImages[idx];
              ctx.drawImage(img,
                (xx + 1) * ui.map.zoom, yy * ui.map.zoom,
                img.width * ui.map.zoom,
                img.height * ui.map.zoom);
            }

          // level text
          paintLevel(ctx, xx, yy, text);
        }

      tempx = xx;
      tempy = yy;
//      game.endTimer('node paint');
    }

// paint node icon (can be overriden)
  public function paintIcon(ctx: CanvasRenderingContext2D,
      xx: Int, yy: Int, key: String)
    {
      var imageID = node.imageID;
      if (key == 'o' || key == 'op') // origin
        imageID = 14;
      var img = ui.map.jobImages[imageID];
      ctx.drawImage(img,
        (xx + jobInfo[imageID].x) * ui.map.zoom,
        (yy + jobInfo[imageID].y + 6) * ui.map.zoom,
        img.width * ui.map.zoom,
        img.height * ui.map.zoom);
    }

// paint node level (can be overriden)
  public function paintLevel(ctx: CanvasRenderingContext2D,
      xx: Int, yy: Int, text: String)
    {
      var img = ui.map.textImages[MapUI.textToIndex[text]];
      ctx.drawImage(img,
        (xx + 39) * ui.map.zoom,
        (yy + 1) * ui.map.zoom,
        img.width * ui.map.zoom,
        img.height * ui.map.zoom);
    }

// paint advanced node info
  public function paintAdvanced(ctx: CanvasRenderingContext2D)
    {
      // node not visible to player
      if (!node.isVisible(game.player))
        return;

      // node out of view rectangle
      if (!inViewRect(UI.vars.markerWidth))
        return;

      ctx.textAlign = 'left';

      // draw production indicators
      var productionIndicatorWidth = 6;
      var productionIndicatorHeight = 2;
      if (node.isGenerator && !node.isTempGenerator)
        if (node.owner != game.player ||
            node.isKnown[game.player.id])
          {
            var j = 0;
            for (i in 0...Game.numFullPowers)
              if (node.powerGenerated[i] > 0)
                {
                  if (node.powerGenerated[i] == 0)
                    continue;
                  ctx.fillStyle = ui.map.powerColors[i];
                  if (UI.classicMode)
                    ctx.fillRect(
                      (tempx + (tempd - 1) +
                      i * (productionIndicatorWidth + 1)) * ui.map.zoom,
                      (tempy - productionIndicatorHeight) * ui.map.zoom,
                      productionIndicatorWidth * ui.map.zoom,
                      productionIndicatorHeight * ui.map.zoom);
                  else 
                    {
                      ctx.shadowColor = 'black';
                      ctx.fillText(roman[node.powerGenerated[i]],
                        ui.map.zoom * (tempx + 62),
                        ui.map.zoom * (tempy + 26 + j * 16));
                      ctx.shadowColor = 'transparent';
                    }
                  j++;
                }
          }

      if (node.owner != game.player)
        {
          // chance to gain node
          var ch = game.player.getGainChance(node);
          if (UI.classicMode)
            {
              ctx.fillStyle = "#aaa";
              ctx.fillText(ch + '%',
                ui.map.zoom * (tempx - 4),
                ui.map.zoom * (tempy - 4));
            }
          else
            {
              ctx.fillStyle = "#402b2b";
              ctx.shadowOffsetX = 1;
              ctx.shadowOffsetY = 1;
              ctx.shadowBlur = 1;
              ctx.shadowColor = "#84aa9d";
              ctx.fillText(ch + '%',
                ui.map.zoom * (tempx + 13),
                ui.map.zoom * (tempy - 4));
              ctx.shadowColor = 'transparent';
            }

          // resources to conquer
          if (node.owner == null || node.isKnown[game.player.id])
            {
              var j = 0;
              var isOrigin =
                (node.owner != null && node.owner.origin == node);
              for (i in 0...node.power.length)
                {
                  if (node.power[i] == 0)
                    continue;
                  if (UI.classicMode)
                    {
                      ctx.fillStyle = ui.map.powerColors[i];
                      var d = 0;
                      if (node.isGenerator)
                        d += 4;
                      if (isOrigin)
                        d += 4;
                      ctx.fillText(node.power[i] + '',
                        ui.map.zoom * (tempx - 4),
                        ui.map.zoom * (tempy + 27 + d + j * 16));
                    }
                  else
                    {
                      ctx.shadowColor = 'black';
  /*
                      ctx.beginPath();
                      ctx.arc(tempd + tempx - 13,
                        tempy + temph - 5 + j * 13, 5, 0, 2 * Math.PI);
                      ctx.fillStyle = ui.map.powerColors[i];
                      ctx.fill();
  */
                      ctx.fillStyle = ui.map.powerColors[i];
                      var s = roman[node.power[i]];
                      var w = ctx.measureText(s).width;
                      ctx.fillText(s,
                        ui.map.zoom * (tempx - 4) - w,
                        ui.map.zoom * (tempy + 26 + j * 16));
                      ctx.shadowColor = 'transparent';
                    }
                  j++;
                }
            }
        }
    }


// get node icon for modern mode
  function getImage(): CanvasElement
    {
      var idx = 8;
      if (node.owner != null)
        idx = node.owner.id;
      var img = (node.isGenerator ?
        ui.map.nodeImagesGenerator[idx] :
        ui.map.nodeImages[idx]);
      return img;
    }


// check if this node is in view
  public function inViewRect(border: Int): Bool
    {
      if (node.x * ui.map.zoom <
            (ui.map.viewRect.x - border) * ui.map.zoom ||
          node.y * ui.map.zoom <
            (ui.map.viewRect.y - border) * ui.map.zoom ||
          node.x * ui.map.zoom >
            (ui.map.viewRect.x * ui.map.zoom + ui.map.viewRect.w +
             UI.vars.markerWidth * ui.map.zoom) ||
          node.y * ui.map.zoom >
            (ui.map.viewRect.y * ui.map.zoom + ui.map.viewRect.h +
             UI.vars.markerHeight * ui.map.zoom))
        return false;
      return true;
    }


// update node display
  public function update()
    {
    }


// update tooltip text
  public function getTooltip(): String
    {
      if (!node.isVisible(game.player))
        return '';

      var s = "";
      if (Game.isDebug)
        s += 'Node ' + node.id + ' (' + node.x + ',' + node.y + ')<br>';
      if (Game.debugNear)
        {
          s += 'Links: ';
          for (n in node.links)
            s += n.id + " ";
          if (node.isProtected)
            s += "<br>Protected<br>";
          else s += "<br>Unprotected<br>";
        }

      if (Game.debugVis)
        {
          s += "Node " + node.id + "<br>";
          for (i in 0...game.difficulty.numCults)
            s += node.visibility[i] + "<br>";
        }
/*
      s += 'isKnown: <br>';
      for (i in 0...game.difficulty.numCults)
        s += node.isKnown[i] + "<br>";
*/
      if (node.owner != null &&
          !node.owner.isInfoKnown[game.player.id] &&
          !node.isKnown[game.player.id] &&
          node.owner != game.player)
        {
          s += "<span class=shadow style='color:var(--node-error-color)'>Use sects to gather cult<br>or node information.</span><br>";
          if (node.owner == null || node.owner != game.player)
            {

              s += "<br>Chance of success: <span class=shadow style='color:white'>" +
                game.player.getGainChance(node) + "%</span><br>";
              if (node.owner != null &&
                  !node.owner.isInfoKnown[game.player.id])
                s += "<span class=shadow style='color:var(--node-error-color)'>(-20%, no cult information)</span><br>";
              if (!node.isKnown[game.player.id])
                s += "<span class=shadow style='color:var(--node-error-color)'>(-10%, no node information)</span><br>";
            }
          return s;
        }

      if (node.owner != null) // cult info
        {
          s += UI.cultName(node.owner.id, node.owner.info) + '<br>';
          if (node.owner.origin == node &&
              node.isKnown[game.player.id])
            s += "<span class=shadow style='color:" +
              UI.vars.cultColors[node.owner.id] +
              "'>The Origin</span><br>";
          s += "<br>";
        }

      // name and job
      s += "<span class=shadow style='color:white'>" + node.name + "</span><br>";
      s += node.job + "<br>";

      if (node.owner != null) // follower level
        s += "<b>" + (node.isKnown[game.player.id] ? Game.followerNames[node.level] : 'Unknown') +
          "</b> <span class=shadow style='color:white'>L" +
          (node.isKnown[game.player.id] ? '' + (node.level + 1) : '?') + "</span><br>";
      s += "<br>";

      if (node.sect != null) // sect name
        s += 'Leader of<br>' + node.sect.name + "<br><br>";

      if (node.owner != game.player)
        {
          var br = false;

          // check for power
          if (node.isKnown[game.player.id] || node.owner == null)
            for (i in 0...Game.numFullPowers)
              if (game.player.power[i] < node.power[i])
                {
                  s += "<span class=shadow style='color:var(--node-error-color)'>Not enough " + Game.powerNames[i] + "</span><br>";
                  br = true;
                }

          // check for links
          if (node.isGenerator && node.owner != null)
            {
              // count links with same owner
              var cnt = 0;
              for (n in node.links)
                if (n.owner == node.owner)
                  cnt++;

              if (cnt >= 3)
                s += "<span class=shadow style='color:var(--node-error-color)'>Generator has " + cnt + " links</span><br>";
            }

          if (br)
            s += '<br>';
        }

      // amount of power to conquer
      if (node.owner == null || node.isKnown[game.player.id])
        for (i in 0...node.power.length)
          if (node.power[i] > 0)
            s += '<b>' + UI.powerName(i) + '</b> ' + node.power[i] + '<br>';
      if (node.owner == null || node.owner.isAI)
        {
          s += "Chance of success: <span class=shadow style='color:white'>" +
            game.player.getGainChance(node) + "%</span><br>";
          if (node.owner != null && !node.isKnown[game.player.id])
            s += "<span class=shadow style='color:var(--node-error-color)'>(-10%, no node information)</span><br>";
        }

      if (node.isGenerator && (node.owner == null || node.isKnown[game.player.id]))
        {
          s += "<br>Generates:<br>";
          for (i in 0...Game.numFullPowers)
             if (node.powerGenerated[i] > 0)
               s += '<b>' + UI.powerName(i) + '</b> ' + node.powerGenerated[i] + '<br>';
          if (node.isTempGenerator)
            s += "Temporary<br>";
        }

      // debug info
      if (Game.isDebug)
        {
          // find closest node distance
          var d = 1000000.0;
          for (n in game.nodes)
            if (n != this.node)
              {
                var dx = n.distance(this.node);
                if (dx < d)
                  d = dx;
              }
          s += 'DBG dist nearest: ' + Std.int(d) + '<br>';
        }

      return s;
    }


// update node visibility
  public function setVisible(c: Cult, v: Bool)
    {
      if (c.isAI)
        return;
      if (Game.mapVisible)
        v = true;
    }

  public static var imageKeys: Dynamic =
    {
      c: [ 0, 17 ],
      cg: [ 19, 21 ],
      cgp: [ 42, 21 ],
      o: [ 65, 25 ],
      op: [ 92, 25 ],
      neutral: [ 125, 17 ],
      neutralg: [ 144, 21 ],
    }

  public static var jobInfo = [
    {
      img: "char-official-male.png",
      x: 3,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-official-female.png",
      x: 2,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-corporate-male.png",
      x: 8,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-corporate-female.png",
      x: -5,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-professor-male.png",
      x: 1,
      y: 3,
      w: 52,
      h: 52,
    },
    {
      img: "char-professor-female.png",
      x: 8,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-army-male.png",
      x: -1,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-army-female.png",
      x: -4,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-scientist-male.png",
      x: -4,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-scientist-female.png",
      x: -2,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-politician-male.png",
      x: -2,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-politician-female.png",
      x: 5,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-media-male.png",
      x: 8,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-media-female.png",
      x: -5,
      y: 0,
      w: 52,
      h: 52,
    },
    {
      img: "char-origin.png",
      x: -4,
      y: -10,
      w: 68,
      h: 61,
    },
  ];

  static var roman = [
    '', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X',
    'XI', 'XII', 'XIII', 'XIV', 'XV'
  ];
}
