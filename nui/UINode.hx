// node ui

import nme.display.MovieClip;
import nme.display.Bitmap;
import nme.display.Bitmap;
import nme.text.TextField;
import nme.events.MouseEvent;

class UINode
{
  var game: Game;
  var ui: UI;
  var node: Node;

  public var clip: MovieClip; // node container
  var hl: Bitmap; // node highlight
  var text: TextField; // node text
  var bitmap: Bitmap; // link to image
  var clipImage: String; // image name
  var tooltip: Tooltip;

  public static var textFormat;


  public function new(gvar, uivar, nvar)
    {
      game = gvar;
      ui = uivar;
      node = nvar;

      // hl background
      var bmp: Bitmap = ui.map.images.get('hl');
      hl = new Bitmap(bmp.bitmapData.clone());
      hl.visible = false;
      ui.map.screen.addChild(hl);

      // node clip
      clip = new MovieClip();
      clip.x = node.x;
      clip.y = node.y;
      clip.width = 17;
      clip.height = 17;
      clip.visible = false;
      ui.map.screen.addChild(clip);
      clip.addEventListener(MouseEvent.CLICK, onClick);
      clip.mouseChildren = false;
      clipImage = "";
      bitmap = null;

      // node text
      text = new TextField();
      text.x = textX;
      text.y = textY;
      text.width = 14;
      text.height = 16;
      text.textColor = 0xffffff;
      text.selectable = false;
      text.defaultTextFormat = textFormat;
      clip.addChild(text);
    
      tooltip = new Tooltip(clip, "");
    }


// clicking this node
  public function onClick(e: MouseEvent)
    {
      ui.map.onClick(node);
    }


// update node image
  public function updateImage()
    {
      var key = "";

      // get power char
      var isI = false, is1 = false;
      for (i in 0...Game.numPowers)
        if (node.power[i] > 0)
          {
            text.text = Game.powerShortNames[i];
            text.textColor = UI.powerColors[i];
            isI = false;
            if (Game.powerShortNames[i] == "I")
              isI = true;
          }

      // get bg and node char
      if (node.owner != null)
        {
          key = "cult" + node.owner.id;
          text.text = "" + (node.level + 1);
          if (node.level == 0)
            is1 = true;
          text.textColor = 0xffffff;
        }
      else
        {
          key = "neutral";
        }

      // different borders
      var dd = 0;
      text.x = textX;
      text.y = textY;
      hl.x = clip.x - 10;
      hl.y = clip.y - 10;
	  if (node.isGenerator)
		{
          key += "g";
          dd = 2;

          for (p in game.cults)
            if (p.origin == node && !p.isDead)
              {
                key = "origin" + p.id;
                dd = 4;
                break;
              }
          if (node.isProtected)
            key += "p";
          clip.x = node.x - dd;
          clip.y = node.y - dd;
          text.x = textX + dd;
          text.y = textY + dd;
          hl.x = clip.x - 10 + dd;
          hl.y = clip.y - 10 + dd;
        }
      if (isI) // "I" symbol needs to be centered
        text.x = text.x + 2;
//      if (is1) // "1" symbol
//       text.x = text.x - 1;

      var bmp: Bitmap = ui.map.images.get(key);
      if (key != clipImage) // image changed
        {
          if (bitmap != null)
            clip.removeChild(bitmap);
          var b = new Bitmap(bmp.bitmapData.clone());
          clip.addChild(b);
          clip.removeChild(text);
          clip.addChild(text);
          clipImage = key;
          bitmap = b;
          clip.width = b.width;
          clip.height = b.height;
        }
    }


// set node highlight
  public function setHighlighted()
    {
      hl.visible = node.isHighlighted;
      update();
    }


// update node display
  public function update()
    {
      updateImage();
      updateTooltip();
    }


// update node tooltip
  function updateTooltip()
    {
      var s = "";
      if (Game.debugNear)
        {
          s += "Node " + node.id + "<br>\n";
          for (n in node.links)
            s += n.id + "<br>\n";
        }

      if (Game.debugVis)
        {
          s += "Node " + node.id + "<br>\n";
          for (i in 0...Game.numCults)
            s += node.visibility[i] + "<br>\n";
        }

      if (node.owner != null)
        s += "<font color='" + Game.cultColors[node.owner.id] + "'>" +
          node.owner.name + "</font><br>\n";
      if (node.owner != null && node.owner.origin == node)
        s += "<font color='" + Game.cultColors[node.owner.id] +
          "'>The Origin</font><br>\n";
      s += node.name + "\n<br>\n";

      if (node.owner != null)
        s += "<b>" + Game.followerNames[node.level] + 
          "</b> <font color=white>L" +
          (node.level + 1) + "</font><br>\n";

      s += "<br>\n";
      // amount of generated power
      for (i in 0...Game.numPowers)
        if (node.power[i] > 0)
          {
            s += "<b><font color=" + UI.powerColorsString[i] + ">" +
              Game.powerNames[i] + "</font></b> " + node.power[i] + "\n<br>\n";
          }
      if (node.owner == null || node.owner.isAI)
        s += "Chance of success: <font color=white>" +
          game.player.getGainChance(node) + "%</font><br>\n";

	  if (node.isGenerator)
		{
		  s += "<br>\nGenerates:<br>\n";
	      for (i in 0...Game.numPowers)
     	    if (node.powerGenerated[i] > 0)
          	  s += "<b><font color='" + UI.powerColors[i] + "'>" +
                Game.powerNames[i] + "</font></b> " +
			    node.powerGenerated[i] + "<br>\n";
		}

/*
      // temporary de-htmling
      s = StringTools.replace(s, "<br>", "\n");
      var sb = new StringBuf();
      var arr = s.split('<');
      var start = 0;
      for (t in arr)
        sb.add(t.substr(t.indexOf('>') + 1));

      s = sb.toString();
*/
      tooltip.setText(s);
    }



// update node visibility
  public function setVisible(c: Cult, v: Bool)
    {
      if (c.isAI)
        return;
      if (Game.mapVisible)
        v = true;
      clip.visible = v;
    }


  static var textX:Int = 3;
  static var textY:Int = 0;
}
