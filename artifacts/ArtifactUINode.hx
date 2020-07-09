// node ui
package artifacts;

import js.html.CanvasRenderingContext2D;

class ArtifactUINode extends UINode
{
  public function new(gvar, uivar, nvar)
    {
      super(gvar, uivar, nvar);
    }

// paint node icon
  public override function paintIcon(ctx: CanvasRenderingContext2D,
      xx: Int, yy: Int, key: String)
    {
      var art: ArtifactNode = cast node;
      // image
      var img = ui.artifacts.mapIconImages[
        art.isUnique ? art.artifactID : art.artifactType];
      var modx = (art.isUnique ? art.artifactInfo.x :
        StaticArtifacts.artifacts[art.artifactTypeID].x);
      var mody = (art.isUnique ? art.artifactInfo.y :
        StaticArtifacts.artifacts[art.artifactTypeID].y);
      ctx.drawImage(img,
        (xx + modx) * ui.map.zoom,
        (yy + mody) * ui.map.zoom,
        img.width * ui.map.zoom,
        img.height * ui.map.zoom);

      // timer text (use node highlight zoom as transparency animation base)
      var mod = 240;
      if (ui.config.getBool('animation'))
        {
          mod = 50 + Std.int((ui.map.highlightZoom - 1.0) * 2450);
          if (mod > 255)
            mod = 255;
        }
      ctx.textAlign = 'center';
      ctx.fillStyle = UI.getVar('--artifact-timer-color') +
        StringTools.hex(mod);
      ctx.shadowOffsetX = 1;
      ctx.shadowOffsetY = 1;
      ctx.shadowBlur = 1;
      ctx.shadowColor = UI.getVar('--artifact-timer-shadow');
      ctx.font = 'bold ' + (35 * ui.map.zoom) + 'px Mitr';
      ctx.fillText('' + art.turns,
        (xx + 28) * ui.map.zoom,
        (yy + 43) * ui.map.zoom);
      ctx.shadowColor = 'rgba(0,0,0,0)'; // clear
    }

// paint node level
  public override function paintLevel(ctx: CanvasRenderingContext2D,
      xx: Int, yy: Int, text: String)
    {
      var img = ui.map.textImages[
        MapUI.textToIndex['' + (node.level + 1)]];
      ctx.drawImage(img,
        (xx + 39) * ui.map.zoom,
        (yy + 1) * ui.map.zoom,
        img.width * ui.map.zoom,
        img.height * ui.map.zoom);
    }

// return tooltip text
  public override function getTooltip(): String
    {
      if (!node.isVisible(game.player))
        return '';

      var art: ArtifactNode = cast node;
      var s = new StringBuf();
      if (Game.isDebug)
        s.add('Node ' + node.id + ' (' + node.x + ',' + node.y + ')<br>');
      s.add("<span class=shadow style='color:var(--artifact-color)'>" + node.name + "</span><br>");
      s.add("Artifact <span class=shadow style='color:white'>L" +
        (node.level + 1) + "</span><br>");
      if (art.isUnique)
        s.add("<i style='color:var(--artifact-fluff-color)'>" + art.artifactInfo.fluff + '</i><br>');
      s.add('<br>');

      var br = false;
      for (i in 0...Game.numFullPowers)
        if (game.player.power[i] < node.power[i])
          {
            s.add("<span class=shadow style='color:var(--node-error-color)'>Not enough " + Game.powerNames[i] + "</span><br>");
            br = true;
          }
      if (br)
        s.add('<br>');

      for (i in 0...node.power.length)
        if (node.power[i] > 0)
          s.add('<b>' + UI.powerName(i) + '</b> ' + node.power[i] + '<br>');

      return s.toString();
    }
}
