// node ui

class UINode
{
  var game: Game;
  var ui: UI;
  var node: Node;
  public var marker: Dynamic;

  public function new(gvar, uivar, nvar)
    {
      game = gvar;
      ui = uivar;
      node = nvar;
      
      marker = js.Lib.document.createElement("map.node" + node.id);
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
	  marker.style.zIndex = 20;
	  marker.style.cursor = 'pointer';
	  marker.onclick = ui.onNodeClick;
	  ui.map.appendChild(marker);
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
          for (i in 0...Game.numPlayers)
            s += node.visibility[i] + "<br>";
        }

      if (node.owner != null)
        s += "<span style='color:" + Game.playerColors[node.owner.id] + "'>" +
          node.owner.name + "</span><br>";
      if (node.owner != null && node.owner.origin == node)
        s += "<span style='color:" + Game.playerColors[node.owner.id] +
          "'>The Origin</span><br>";
      s += node.name + "<br>";

      if (node.owner != null)
        s += "<b>" + Game.followerNames[node.level] + 
          "</b> <span style='color:white'>L" +
          (node.level + 1) + "</span><br>";
      if (node.owner == null || node.owner.isAI)
        {
          s += "<br>";
          // amount of generated power
          for (i in 0...Game.numPowers)
            if (node.power[i] > 0)
		      {
                s += "<b style='color:" + Game.powerColors[i] + "'>" +
                  Game.powerNames[i] + "</b> " + node.power[i] + "<br>";
			    marker.innerHTML = Game.powerShortNames[i];
                marker.style.color = Game.powerColors[i];
		      }
          s += "Chance of success: <span style='color:white'>" +
            game.player.getGainChance(node) + "%</span><br>";
        }

	  marker.style.background = '#111';
      if (node.owner != null)
        {
          marker.innerHTML = "" + (node.level + 1);
          marker.style.color = '#ffffff';
          marker.style.background = Game.nodeColors[node.owner.id];
        }

	  if (node.isGenerator)
		{
          var w = '3px';
          var col = '#777';
          var type = 'solid';

          if (node.isProtected)
            col = '#ffffff';
          for (p in game.players)
            if (p.origin == node && !p.isDead)
              {
                w = '5px';
                type = 'double';
                break;
              }

		  marker.style.border = w + ' ' + type + ' ' + col;

		  s += "<br>Generates:<br>";
	      for (i in 0...Game.numPowers)
     	    if (node.powerGenerated[i] > 0)
          	  s += "<b style='color:" + Game.powerColors[i] + "'>" +
                Game.powerNames[i] + "</b> " +
			    node.powerGenerated[i] + "<br>";
		}

      marker.title = s;
      new JQuery("#map\\.node" + node.id).tooltip({ delay: 0 });
    }



// update node visibility
  public function setVisible(player: Player, v: Bool)
    {
      if (player.isAI)
        return;
      if (Game.mapVisible)
        v = true;
      marker.style.visibility = 
        (v ? 'visible' : 'hidden');
    }
}
