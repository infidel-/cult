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
      // TODO: image
      var img = ui.map.powerImages[0];
      ctx.drawImage(img,
        (xx + 10) * ui.map.zoom,
        (yy + 10) * ui.map.zoom,
        img.width * ui.map.zoom,
        img.height * ui.map.zoom);

      // timer text
      ctx.textAlign = 'center';
      ctx.fillStyle = "#402b2b";
      ctx.shadowOffsetX = 1;
      ctx.shadowOffsetY = 1;
      ctx.shadowBlur = 1;
      ctx.shadowColor = "#84aa9d";
      ctx.font = 'bold ' + (35 * ui.map.zoom) + 'px Mitr';
      ctx.fillText('' + cast(node, ArtifactNode).turns,
        (xx + 28) * ui.map.zoom,
        (yy + 43) * ui.map.zoom);
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

      var s = new StringBuf();
      if (Game.isDebug)
        s.add('Node ' + node.id + ' (' + node.x + ',' + node.y + ')<br>');
      s.add("<span class=shadow style='color:white'>" + node.name + "</span><br>");
      s.add("Artifact <span class=shadow style='color:white'>L" +
        (node.level + 1) + "</span><br>");
      s.add('<br>');
      for (i in 0...node.power.length)
        if (node.power[i] > 0)
          s.add('<b>' + UI.powerName(i) + '</b> ' + node.power[i] + '<br>');

      return s.toString();
    }
}
