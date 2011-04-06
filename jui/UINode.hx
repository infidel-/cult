// node ui

class UINode
{
  var game: Game;
  var ui: UI;
  var node: Node;
  public var marker: Dynamic;
  var markerHL: Dynamic;

  public function new(gvar, uivar, nvar)
    {
      game = gvar;
      ui = uivar;
      node = nvar;
      
      marker = js.Lib.document.createElement("div");
      marker.id = "map.node" + node.id;
	  marker.node = node;
	  marker.style.background = '#222';
	  marker.style.border = '1px solid #777';
	  marker.style.width = UI.markerWidth;
	  marker.style.height = UI.markerHeight;
	  marker.style.position = 'absolute';
	  marker.style.left = node.x;
	  marker.style.top = node.y;
	  marker.style.visibility = 'hidden';
	  marker.style.textAlign = 'center';
	  marker.style.fontWeight = 'bold';
      marker.style.fontSize = '12px';
	  marker.style.zIndex = 10;
	  marker.style.cursor = 'pointer';
	  marker.onclick = ui.map.onNodeClick;
	  ui.map.screen.appendChild(marker);

      markerHL = js.Lib.document.createElement("div");
      markerHL.style.visibility = 'hidden';
	  markerHL.style.background = '#111';
	  markerHL.style.border = '1px solid #333';
	  markerHL.style.width = UI.markerWidth + 20;
	  markerHL.style.height = UI.markerHeight + 20;
	  markerHL.style.position = 'absolute';
      markerHL.style.opacity = 0.5;
      markerHL.style.left = node.centerX - (UI.markerWidth + 21) / 2;
      markerHL.style.top = node.centerY - (UI.markerHeight + 21) / 2;
	  markerHL.style.zIndex = 8;
	  ui.map.screen.appendChild(markerHL);
    }


// set node highlight
  public function setHighlighted()
    {
      update();
    }


// update node display
  public function update()
    {
      updateTooltip();
      var sym = '';
      var col = '';
      var bg = 'rgb(17, 17, 17)';
      var brd = '1px solid rgb(119, 119, 119)';

      // change marker style
      if (node.owner == null || node.isKnown)
        for (i in 0...Game.numPowers)
          if (node.power[i] > 0)
            {
              sym = Game.powerShortNames[i];
              col = UI.powerColors[i];
            }
      if (node.owner != null)
        {
          sym = "" + (node.level + 1);
          if (node.sect != null)
            sym = 'S';
          if (node.owner != null && !node.isKnown)
            sym = '?';
          col = 'rgb(255, 255, 255)';
          bg = UI.nodeColors[node.owner.id];
        }
  
      var borderWidth = 1;
	  if (node.isGenerator && (node.owner == null || node.isKnown))
		{
          borderWidth = 3;
          var bcol = 'rgb(119, 119, 119)';
          var type = 'solid';

          if (node.isProtected)
            bcol = 'rgb(255, 255, 255)';
          for (p in game.cults)
            if (p.origin == node && !p.isDead && node.isKnown)
              {
                borderWidth = 5;
                type = 'double';
                break;
              }

		  brd = borderWidth + 'px ' + type + ' ' + bcol;
		}

      // update elements only when actual parameters change
      if (sym != marker.innerHTML)
        marker.innerHTML = sym;
      if (col != marker.style.color)
        marker.style.color = col;
      if (bg != marker.style.backgroundColor)
        marker.style.backgroundColor = bg;
      if (brd != marker.style.border)
        marker.style.border = brd;

      // node highlight
      markerHL.style.visibility = (node.isHighlighted ? "visible" : "hidden");
      if (node.isHighlighted)
        {
  	      markerHL.style.width = UI.markerWidth + borderWidth + 19;
	      markerHL.style.height = UI.markerHeight + borderWidth + 19;
          markerHL.style.left = node.centerX - (UI.markerWidth - borderWidth + 22) / 2;
          markerHL.style.top = node.centerY - (UI.markerHeight - borderWidth + 22) / 2;
        }
    }


// update tooltip text
  public function updateTooltip()
    {
      if (!node.isVisible(game.player))
        return;

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
          for (i in 0...Game.numCults)
            s += node.visibility[i] + "<br>";
        }

      if (node.owner != null && !node.owner.isInfoKnown && !node.isKnown)
        {
          s += 'Use sect to gather cult or node information.<br>';
          if (node.owner == null || node.owner.isAI)
            s += "<br>Chance of success: <span style='color:white'>" +
              game.player.getGainChance(node) + "%</span><br>";
          marker.title = s;
          new JQuery("#map\\.node" + node.id).tooltip({ delay: 0 });
          return;
        }

      if (node.owner != null) // cult info
        {
          s += "<span style='color:" + Game.cultColors[node.owner.id] + "'>" +
            node.owner.name + "</span><br>";
          if (node.owner.origin == node && node.isKnown)
            s += "<span style='color:" + Game.cultColors[node.owner.id] +
              "'>The Origin</span><br>";
          s += "<br>";
        }

      // name and job
      s += "<span style='color:white'>" + node.name + "</span><br>";
      s += node.job + "<br>";

      if (node.owner != null) // follower level
        s += "<b>" + (node.isKnown ? Game.followerNames[node.level] : 'Unknown') + 
          "</b> <span style='color:white'>L" +
          (node.isKnown ? '' + (node.level + 1) : '?') + "</span><br>";
      s += "<br>";

      if (node.sect != null) // sect name
        s += 'Leader of ' + node.sect.name + "<br><br>";

      // amount of power to conquer
      if (node.owner == null || node.isKnown)
        for (i in 0...Game.numPowers)
          if (node.power[i] > 0)
            {
              s += "<b style='color:" + UI.powerColors[i] + "'>" +
                Game.powerNames[i] + "</b> " + node.power[i] + "<br>";
            }
      if (node.owner == null || node.owner.isAI)
        s += "Chance of success: <span style='color:white'>" +
          game.player.getGainChance(node) + "%</span><br>";

	  if (node.isGenerator && (node.owner == null || node.isKnown))
		{
		  s += "<br>Generates:<br>";
	      for (i in 0...Game.numPowers)
     	    if (node.powerGenerated[i] > 0)
          	  s += "<b style='color:" + UI.powerColors[i] + "'>" +
                Game.powerNames[i] + "</b> " +
			    node.powerGenerated[i] + "<br>";
        }

      marker.title = s;
      new JQuery("#map\\.node" + node.id).tooltip({ delay: 0 });
    }


// update node visibility
  public function setVisible(c: Cult, v: Bool)
    {
      if (c.isAI)
        return;
      if (Game.mapVisible)
        v = true;
      // if node is made visible, update tooltip
      if (v && marker.style.visibility == 'hidden')
        updateTooltip();
      marker.style.visibility = 
        (v ? 'visible' : 'hidden');
    }
}
