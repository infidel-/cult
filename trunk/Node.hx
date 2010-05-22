// node class

class Node
{
  var ui: UI;
  var game: Game;
  var uiNode: UINode;

  public var id: Int;
  public var name: String;
  public var power: Array<Dynamic>; // power to conquer: intimidation, persuasion, bribe
  public var powerGenerated: Array<Dynamic>; // power generated each turn
  public var x: Int;
  public var y: Int;
  public var centerX: Int;
  public var centerY: Int;
  public var visibility: Array<Bool>;
  public var isGenerator: Bool;
  public var isProtected: Bool;
  public var isHighlighted: Bool;
  public var level: Int;
  public var owner: Cult;

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
      for (i in 0...Game.numCults)
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
  public function setOwner(c: Cult)
    {
      var prevOwner = owner;

      // update power mod cache
	  if (isGenerator)
	    for (i in 0...Game.numPowers)
		  c.powerMod[i] += Math.round(powerGenerated[i]);

      // clear lines leading to this node
      clearLines();

      // +1 to hardness on first gain
      if (owner == null)
        for (i in 0...Game.numPowers)
          if (power[i] > 0)
            power[i]++;

      // update caches
      if (owner != null)
        owner.nodes.remove(this);
      owner = c;
      owner.nodes.add(this);
      update();

      // show nearby nodes to new owner
      showLinks();

      // update previous owner's visibility of the links for this node
      if (prevOwner != null)
        updateLinkVisibility(prevOwner);

      // raise public awareness for new owner
      if (isGenerator)
        owner.awareness += 2;
      else owner.awareness++;

      if (!owner.isAI)
        ui.updateStatus();

      // paint lines to this node from adjacent nodes owned by new node owner
      paintLines();

      // update display
      for (n in links)
        n.update();

      // do all cult stuff with losing a node
      if (prevOwner != null)
        prevOwner.loseNode(this, owner);
    }


// clear this node of ownership, updating all stuff
  public function removeOwner()
    {
      if (owner == null)
        return;

      var prevOwner = owner;
      clearLines();
      owner.nodes.remove(this);
      owner = null;
      level = 0;
      update();

      // update previous owner's visibility of the links for this node
      updateLinkVisibility(prevOwner);

      // update display
      for (n in links)
        n.update();  

      // lower all power to 2 max
      for (i in 0...Game.numPowers)
        if (power[i] > 2)
          power[i] = 2;

      // do all cult stuff with losing a node
      if (prevOwner != null)
        prevOwner.loseNode(this);
    }


// set visible flag
  public function setVisible(cult: Cult, v: Bool)
    {
      visibility[cult.id] = v;
      uiNode.setVisible(cult, v);
      if (!cult.isAI)
        {
          if (Game.mapVisible)
            v = true;
          for (l in lines)
            l.setVisible(v);
          if (isHighlighted)
            setHighlighted(v);
        }
    }


// is visible?
  public inline function isVisible(c: Cult)
    {
      return visibility[c.id];
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


// update link visibility for given cult
  public function updateLinkVisibility(cult: Cult)
    {
      // update nodes visibility for previous owner in a radius
      for (n in links)
        if (n.isVisible(cult) && n.owner != cult)
          {
            var vis = false;
            // try to find any adjacent node of this cult
            for (n2 in n.links)
              if (n2.owner == cult)
                {
                  vis = true;
                  break;
                }

            n.setVisible(cult, vis);
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


// show nodes around this one to the current owner
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


// set node highlight
  public function setHighlighted(isHL: Bool)
    {
      isHighlighted = isHL;
      uiNode.setHighlighted();
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
