// node class


//extern class JQuery extends Dummy {}

class Node
{
  var ui: UI;
  var game: Game;

  public var id: Int;
  public var name: String;
  public var power: Array<Dynamic>; // intimidation, persuasion, bribe, worship
  public var powerGenerated: Array<Dynamic>;
  public var marker: Dynamic;
  public var x: Int;
  public var y: Int;
  public var centerX: Int;
  public var centerY: Int;
//  public var isVisible(default, setVisible): Bool;
  var visibility: Array<Bool>;
  public var isGenerator: Bool;
  public var level: Int;
  public var owner: Player;
  public var lines: List<Line>;

  public function new(gvar, uivar, newx, newy, index: Int)
    {
      game = gvar;
      ui = uivar;
      id = index;
      lines = new List<Line>();
      visibility = new Array<Bool>();
      for (i in 0...Game.numPlayers)
        visibility.push(false);

	  isGenerator = false;
      power = [0, 0, 0];
	  powerGenerated = [0, 0, 0];
      marker = null;
      level = 0;
      owner = null;

      name = names[Std.int(Math.random() * (names.length - 1))];
      
	  x = newx;
      y = newy;
      centerX = x + Math.round(UI.markerWidth / 2);
      centerY = y + Math.round(UI.markerHeight / 2);

      marker = js.Lib.document.createElement("map.node" + id);
      marker.id = "map.node" + id;
	  marker.node = this;
	  marker.style.innerHTML = ' ';
	  marker.style.background = '#222';
	  marker.style.border = '1px solid #777';
	  marker.style.width = UI.markerWidth;
	  marker.style.height = UI.markerHeight;
	  marker.style.position = 'absolute';
	  marker.style.left = x;
	  marker.style.top = y;
	  marker.style.visibility = 'hidden';
	  marker.style.textAlign = 'center';
	  marker.style.fontWeight = 'bold';
      marker.style.fontSize = '12px';
	  marker.style.zIndex = 20;
	  marker.style.cursor = 'pointer';
	  ui.map.appendChild(marker);
    }


// update node display
  public function update()
    {
      var s = "";
      if (Game.debugVis)
        {
          s += "Node " + id + "<br>";
          for (i in 0...Game.numPlayers)
            s += visibility[i] + "<br>";
        }

      if (owner != null)
        s += "<span style='color:" + Game.playerColors[owner.id] + "'>" +
          owner.name + "</span><br>";
      s += name + "<br>";

      if (owner != null)
        s += "<b>" + Game.followerNames[level] + 
          "</b> <span style='color:white'>L" +
          (level + 1) + "</span><br>";
      if (owner == null || owner.isAI)
        {
          s += "<br>";
          // amount of generated power
          for (i in 0...Game.numPowers)
            if (power[i] > 0)
		      {
                s += "<b style='color:" + Game.powerColors[i] + "'>" +
                  Game.powerNames[i] + "</b> " + power[i] + "<br>";
			    marker.innerHTML = Game.powerShortNames[i];
                marker.style.color = Game.powerColors[i];
		      }
          s += "Chance of success: <span style='color:white'>" +
            game.player.getGainChance(this) + "%</span><br>";
        }

	  marker.style.background = '#111';
      if (owner != null)
        {
          marker.innerHTML = "" + (level + 1);
          marker.style.color = '#ffffff';
          marker.style.background = Game.nodeColors[owner.id];
        }
	  if (isGenerator)
		{
		  marker.style.border = '3px solid #aaa';
		  s += "<br>Generates:<br>";
	      for (i in 0...Game.numPowers)
     	    if (powerGenerated[i] > 0)
          	  s += "<b style='color:" + Game.powerColors[i] + "'>" +
                Game.powerNames[i] + "</b> " +
			    powerGenerated[i] + "<br>";
		}

      marker.title = s;
      new JQuery("#map\\.node" + id).tooltip({ delay: 0 });
    }


// calculate distance between this node and the other one
  public function distance(node: Node): Float
    {
      return Math.sqrt((node.x - x) * (node.x - x) +
        (node.y - y) * (node.y - y));
    }


// set/unset generator flag
  public function setGenerator(isgen: Bool)
    {
	  isGenerator = isgen;
	  update();
	}


// set owned flag
  public function setOwner(p: Player)
    {
      owner = p;
      update();
    }

// set visible flag
  public function setVisible(player: Player, v: Bool)
    {
      visibility[player.id] = v;
      if (!player.isAI)
        {
          marker.style.visibility = 
            (v ? 'visible' : 'hidden');
          for (l in lines)
            l.setVisible(v);
        }
      return v;
    }


// is visible?
  public inline function isVisible(player: Player)
    {
      return visibility[player.id];
    }


// upgrade node
  public function upgrade()
    {
      if (level >= Game.followerNames.length - 1)
        return;

      level++;
      update();
    }


// update visibility area around
  public function updateVisibility()
    {
      for (n in game.nodes)
        if (n.distance(this) < UI.nodeVisibility)
          n.setVisible(this.owner, true);
    }


// clear lines leading to this node
  public function clearLines()
    {
      if (owner == null)
        return;
   
      for (l in lines)
        {
          l.clear();
          game.lines.remove(l);
          l.startNode.lines.remove(l);
          l.endNode.lines.remove(l);
        }
    }

  static var names: Array<String> = 
    [
      "Government official",
      "Corporate worker",
      "University professor",
      "Army officer",
      "Scientist"
    ];
}