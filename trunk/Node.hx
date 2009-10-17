// node class

class Node
{
  var ui: UI;
  var game: Game;
  var uiNode: UINode;

  public var id: Int;
  public var name: String;
  public var power: Array<Dynamic>; // intimidation, persuasion, bribe
  public var powerGenerated: Array<Dynamic>;
  public var x: Int;
  public var y: Int;
  public var centerX: Int;
  public var centerY: Int;
  public var visibility: Array<Bool>;
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
      level = 0;
      owner = null;

      name = names[Std.int(Math.random() * (names.length - 1))];
      
	  x = newx;
      y = newy;
      centerX = x + Math.round(UI.markerWidth / 2);
      centerY = y + Math.round(UI.markerHeight / 2);

      uiNode = new UINode(game, ui, this);
    }


// update node display
  public function update()
    {
      // update protected flag
      isProtected = false;
	  if (isGenerator && owner != null)
		{
          var cnt = 0;
          for (n in links)
            if (n.owner == owner)
              cnt++;

          if (cnt >= 3)
            isProtected = true;
        }

      uiNode.update();
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
      uiNode.setVisible(player, v);
      if (!player.isAI)
        {
          if (Game.mapVisible)
            v = true;
          for (l in lines)
            l.setVisible(v);
        }
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
