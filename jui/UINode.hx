// node ui

import js.html.CanvasRenderingContext2D;

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
      if (node.x < ui.map.viewRect.x - UI.vars.markerWidth ||
          node.y < ui.map.viewRect.y - UI.vars.markerHeight ||
          node.x >
            ui.map.viewRect.x + ui.map.viewRect.w + UI.vars.markerWidth ||
          node.y >
            ui.map.viewRect.y + ui.map.viewRect.h + UI.vars.markerHeight)
        return;
//      game.startTimer('node paint');

      var key = '';
      var xx = node.x, yy = node.y,
        hlx = node.x - 10, hly = node.y - 10,
        tx = node.x + 4, ty = node.y + 14;
      var text = '';
      var textColor = 'white';

      // get power char
      var isI = false, is1 = false;
      for (i in 0...Game.numPowers)
        if (node.power[i] > 0)
          {
            text = Game.powerShortNames[i];
            textColor = 'var(--power-color-' + i + ')';
            isI = false;
            if (Game.powerShortNames[i] == "I")
              isI = true;
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
        }
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
            ctx.drawImage(ui.map.nodeImage,
              0, 167, 37, 37,
              hlx, hly, 37, 37);
            break;
          }

      // paint node image
      var a: Array<Int> = Reflect.field(imageKeys, key);
      var y0 = a[0];
      var w = a[1];
      var x0 = (node.owner != null ? node.owner.id * w : 0);
      
      if (UI.classicMode)
        {
          ctx.drawImage(ui.map.nodeImage,
            x0, y0, w, w,
            xx, yy, w, w);
//          ctx.fillStyle = 'red';
//          ctx.fillRect(xx, yy, 20, 20);

          // paint node symbol
          ctx.fillStyle = textColor;
          ctx.fillText(text, tx, ty);
        }
      else
        {
          var idx = 8;
          if (node.owner != null)
            idx = node.owner.id;
          else text = '-';
//          ctx.fillStyle = 'red';
//          ctx.fillRect(xx, yy, 52, 52);

          // background
          ctx.drawImage(
            ui.map.nodeImages[idx], xx, yy);

          // job icon
          ctx.drawImage(ui.map.jobImages[node.imageID],
            xx + jobInfo[node.imageID].x,
            yy + jobInfo[node.imageID].y + 6);

          // resource to acquire
          if (node.owner != game.player &&
              (node.isKnown[game.player.id] || node.owner == null))
            for (i in 0...Game.numPowers)
              if (node.power[i] > 0)
                {
                  ctx.drawImage(ui.map.powerImages[i],
                    xx + 1, yy);
                  break;
                }

          // level text
          ctx.drawImage(
            ui.map.textImages[MapUI.textToIndex[text]], xx + 39, yy + 1);
        }

      tempx = xx;
      tempy = yy;
//      game.endTimer('node paint');
    }


// paint advanced node info
  public function paintAdvanced(ctx: Dynamic)
    {
      // node not visible to player
      if (!node.isVisible(game.player))
        return;

      // node out of view rectangle
      if (node.x < ui.map.viewRect.x - 20 ||
          node.y < ui.map.viewRect.y - 20 ||
          node.x > ui.map.viewRect.x + ui.map.viewRect.w ||
          node.y > ui.map.viewRect.y + ui.map.viewRect.h)
        return;

      // draw production indicators
      var productionIndicatorWidth = 6;
      var productionIndicatorHeight = 2;
      if (node.isGenerator && !node.isTempGenerator)
        if (node.owner == null || node.isKnown[game.player.id])
          {
            for (i in 0...Game.numPowers)
              if (node.powerGenerated[i] > 0)
                {
                  ctx.fillStyle = 'var(--power-color-' + i + ')';
                  ctx.fillRect(
                    tempx + (tempd - 1) + i*(productionIndicatorWidth+1),
                    tempy - productionIndicatorHeight,
                    productionIndicatorWidth,
                    productionIndicatorHeight);
                }
          }

      // chance to gain node
      if (node.owner != game.player)
        {
          var ch = game.player.getGainChance(node);
          ui.map.paintText(ctx, [ Std.int(ch / 10), ch % 10, 10 ], 0,
             tempx + tempd + 1, tempy - 11);
/*
          ctx.fillStyle = 'white';
          ctx.fillText(game.player.getGainChance(node) + '%', tempx - 3, tempy - 4);
*/

          if (node.owner == null || node.isKnown[game.player.id])
            {
              for (i in 0...Game.numPowers)
                if (node.power[i] > 0)
                  ui.map.paintText(ctx, [ node.power[i] ], i + 1,
                    tempd + tempx + i * 6, tempy + temph + 3);
                else
                  ui.map.paintText(ctx, [ 10 ], i + 1,
                    tempd + tempx + i * 6, tempy + temph + 3);
/*
              for (i in 0...Game.numPowers)
                if (node.power[i] > 0)
                  {
                    ctx.fillStyle = UI.vars.powerColors[i];
                    ctx.fillText(node.power[i], tempd + tempx - 3 + i * 7, tempy + temph + 11);
                  }
                else
                  {
                    ctx.fillStyle = '#333';
                    ctx.fillText('-', tempd + tempx - 3 + i * 7, tempy + temph + 11);
                  }
*/
            }
        }
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
      if (Game.debugNear)
        {
          s += "Node " + node.id + "<br>";
          for (n in node.links)
            s += n.id + "<br>";
          if (node.isProtected)
            s += "Protected<br>";
          else s += "Unprotected<br>";
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
            s += "<br>Chance of success: <span style='color:white'>" +
              game.player.getGainChance(node) + "%</span><br>";
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
            for (i in 0...Game.numPowers)
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
        for (i in 0...Game.numPowers)
          if (node.power[i] > 0)
            s += '<b>' + UI.powerName(i) + '</b> ' + node.power[i] + '<br>';
      if (node.owner == null || node.owner.isAI)
        s += "Chance of success: <span class=shadow style='color:white'>" +
          game.player.getGainChance(node) + "%</span><br>";

      if (node.isGenerator && (node.owner == null || node.isKnown[game.player.id]))
        {
          s += "<br>Generates:<br>";
          for (i in 0...Game.numPowers)
             if (node.powerGenerated[i] > 0)
               s += '<b>' + UI.powerName(i) + '</b> ' + node.powerGenerated[i] + '<br>';
          if (node.isTempGenerator)
            s += "Temporary<br>";
        }

      // find closest node distance
      if (Game.isDebug)
        {
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
    },
    {
      img: "char-official-female.png",
      x: 2,
      y: 0,
    },
    {
      img: "char-corporate-male.png",
      x: 8,
      y: 0,
    },
    {
      img: "char-corporate-female.png",
      x: -5,
      y: 0,
    },
    {
      img: "char-professor-male.png",
      x: 1,
      y: 3,
    },
    {
      img: "char-professor-female.png",
      x: 8,
      y: 0,
    },
    {
      img: "char-army-male.png",
      x: -1,
      y: 0,
    },
    {
      img: "char-army-female.png",
      x: -4,
      y: 0,
    },
    {
      img: "char-scientist-male.png",
      x: -4,
      y: 0,
    },
    {
      img: "char-scientist-female.png",
      x: -2,
      y: 0,
    },
    {
      img: "char-politician-male.png",
      x: -2,
      y: 0,
    },
    {
      img: "char-politician-female.png",
      x: 5,
      y: 0,
    },
    {
      img: "char-media-male.png",
      x: 8,
      y: 0,
    },
    {
      img: "char-media-female.png",
      x: -5,
      y: 0,
    },
  ];
}
