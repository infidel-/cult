// node class


//extern class JQuery extends Dummy {}

class Node
{
  var ui: UI;
  var game: Game;

  public var id: Int;
  public var name: String;
  public var power: Array<Dynamic>; // intimidation, persuasion, bribe
  public var powerGenerated: Array<Dynamic>;
  public var marker: Dynamic;
  public var x: Int;
  public var y: Int;
  public var centerX: Int;
  public var centerY: Int;
  var visibility: Array<Bool>;
  public var isGenerator: Bool;
  public var isProtected: Bool;
  public var level: Int;
  public var owner: Player;

  public var lines: List<Line>;
  public var links: List<Node>;

  public function new(gvar, uivar, newx, newy, index: Int)
    {
      game = gvar;
      ui = uivar;
      id = index;
      lines = new List<Line>();
      links = new List<Node>();
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
      if (Game.debugNear)
        {
          s += "Node " + id + "<br>";
          for (n in links)
            s += n.id + "<br>";
        }

      if (Game.debugVis)
        {
          s += "Node " + id + "<br>";
          for (i in 0...Game.numPlayers)
            s += visibility[i] + "<br>";
        }

      if (owner != null)
        s += "<span style='color:" + Game.playerColors[owner.id] + "'>" +
          owner.name + "</span><br>";
      if (owner != null && owner.startNode == this)
        s += "<span style='color:" + Game.playerColors[owner.id] +
          "'>The Origin</span><br>";
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
      isProtected = false;
	  if (isGenerator)
		{
		  marker.style.border = '3px solid #777';
          if (owner != null)
            {
              var cnt = 0;
              for (n in links)
                if (n.owner == owner)
                  cnt++;

              if (cnt >= 3)
                {
                  isProtected = true;
                  marker.style.border = '3px solid #ffffff';
                }
            }

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
      // +1 to hardness on first gain
      if (owner == null)
        for (i in 0...Game.numPowers)
          if (power[i] > 0)
            power[i]++;

      // update caches
      if (owner != null)
        owner.nodes.remove(this);
      owner = p;
      owner.nodes.add(this);
      update();
    }

// set visible flag
  public function setVisible(player: Player, v: Bool)
    {
      visibility[player.id] = v;
      if (!player.isAI)
        {
          if (Game.mapVisible)
            v = true;
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

      // +1 hardness
      for (i in 0...Game.numPowers)
        if (power[i] > 0)
          power[i]++;

      level++;
      update();
    }


// update link visibility for given player
  public function updateLinkVisibility(player)
    {
      // update nodes visibility for previous owner in a radius
      for (n in links)
        if (n.isVisible(player) && n.owner != player)
          {
            var vis = false;
            // try to find any adjacent node of this player
            for (n2 in n.links)
              if (n2.owner == player)
                {
                  vis = true;
                  break;
                }

            n.setVisible(player, vis);
            n.update();
          }
    }


// paint links from adjacent nodes owned by node owner to this one
  public function paintLines()
    {
	  // create lines between this node and adjacent ones
      var hasLine = false;
      for (n in links)
        if (n.owner == this.owner)
          {
            var l = Line.paint(ui.map, this.owner, n, this);
            game.lines.add(l);
            n.lines.add(l);
            this.lines.add(l);
            if (!owner.isAI ||
                (n.isVisible(game.player) && this.isVisible(game.player)))
              l.setVisible(true);
            hasLine = true;
          }

      if (hasLine)
        return;

      // no lines were drawn - draw to closest player node
      var dist: Float = 10000;
      var nc = null;
      for (n in owner.nodes)
        if (this != n && this.distance(n) < dist)
          {
            dist = this.distance(n);
            nc = n;
          }

      var l = Line.paint(ui.map, this.owner, nc, this);
      game.lines.add(l);
      nc.lines.add(l);
      this.lines.add(l);
      if (!owner.isAI ||
          (nc.isVisible(game.player) && this.isVisible(game.player)))
        l.setVisible(true);
    }


// show nodes around to the current owner
  public function showLinks()
    {
      for (n in links)
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
