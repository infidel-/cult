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
      var s = "";
      if (Game.debugNear)
        {
          s += "Node " + node.id + "<br>";
          for (n in node.links)
            s += n.id + "<br>";
        }

      if (Game.debugVis)
        {
          s += "Node " + node.id + "<br>";
          for (i in 0...Game.numCults)
            s += node.visibility[i] + "<br>";
        }

      if (node.owner != null)
        {
          s += "<span style='color:" + Game.cultColors[node.owner.id] + "'>" +
            node.owner.name + "</span><br>";
          if (node.owner.origin == node)
            s += "<span style='color:" + Game.cultColors[node.owner.id] +
              "'>The Origin</span><br>";
          s += "<br>";
        }

      s += "<span style='color:white'>" + node.name + "</span><br>";
      s += node.job + "<br>";

      if (node.owner != null) // follower level
        s += "<b>" + Game.followerNames[node.level] + 
          "</b> <span style='color:white'>L" +
          (node.level + 1) + "</span><br>";
      s += "<br>";

      if (node.sect != null) // sect name
        s += node.sect.name + "<br><br>";


      // amount of generated power
      for (i in 0...Game.numPowers)
        if (node.power[i] > 0)
          {
            s += "<b style='color:" + UI.powerColors[i] + "'>" +
              Game.powerNames[i] + "</b> " + node.power[i] + "<br>";
            marker.innerHTML = Game.powerShortNames[i];
            marker.style.color = UI.powerColors[i];
          }
      if (node.owner == null || node.owner.isAI)
        s += "Chance of success: <span style='color:white'>" +
          game.player.getGainChance(node) + "%</span><br>";

      // change marker style
	  marker.style.background = '#111';
      if (node.owner != null)
        {
          marker.innerHTML =
            (node.sect == null ? "" + (node.level + 1) : 'S');
          marker.style.color = '#ffffff';
          marker.style.background = UI.nodeColors[node.owner.id];
        }
  
	  marker.style.border = '1px solid #777';
      var borderWidth = 1;
	  if (node.isGenerator)
		{
          borderWidth = 3;
          var col = '#777';
          var type = 'solid';

          if (node.isProtected)
            col = '#ffffff';
          for (p in game.cults)
            if (p.origin == node && !p.isDead)
              {
                borderWidth = 5;
                type = 'double';
                break;
              }

		  marker.style.border = borderWidth + 'px ' + type + ' ' + col;

		  s += "<br>Generates:<br>";
	      for (i in 0...Game.numPowers)
     	    if (node.powerGenerated[i] > 0)
          	  s += "<b style='color:" + UI.powerColors[i] + "'>" +
                Game.powerNames[i] + "</b> " +
			    node.powerGenerated[i] + "<br>";
		}

      marker.title = s;
      new JQuery("#map\\.node" + node.id).tooltip({ delay: 0 });

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



// update node visibility
  public function setVisible(c: Cult, v: Bool)
    {
      if (c.isAI)
        return;
      if (Game.mapVisible)
        v = true;
      marker.style.visibility = 
        (v ? 'visible' : 'hidden');
    }
}
