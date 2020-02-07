// node class

import sects.Sect;

class Node
{
  var ui: UI;
  var game: Game;
  public var uiNode: UINode;

  public var id: Int;
  public var name: String; // node name
  public var job: String; // RL job
  public var power: Array<Int>; // power to conquer: intimidation, persuasion, bribe
  public var powerGenerated: Array<Int>; // power generated each turn
  public var x: Int;
  public var y: Int;
  public var centerX: Int;
  public var centerY: Int;
  public var visibility: Array<Bool>; // node visibility to cults
  public var isKnown: Array<Bool>; // node info known to players?
  public var isGenerator: Bool; // node is generating resources?
  public var isTempGenerator: Bool; // temporary generator?
  public var isProtected: Bool; // node protected by neighbours?
  public var level: Int; // node level
  public var owner: Cult; // node owner
  public var sect: Sect; // sect link

  public var lines: List<Line>; // lines drawn to this node
  public var links: List<Node>; // adjacent nodes buffer


  public function new(gvar, uivar, newx, newy, index: Int)
    {
      game = gvar;
      ui = uivar;
      id = index;
      lines = new List<Line>();
      links = new List<Node>();
      visibility = [];
      for (i in 0...game.difficulty.numCults)
        visibility.push(false);
      isKnown = [];
      for (i in 0...game.difficulty.numCults)
        isKnown.push(false);

      owner = null;

      x = newx;
      y = newy;
      centerX = x + Math.round(UI.vars.markerWidth / 2);
      centerY = y + Math.round(UI.vars.markerHeight / 2);
      generateAttributes();

      uiNode = new UINode(game, ui, this);
    }


// generate new attributes
  public function generateAttributes()
    {
      name = GenName.generate();
      job = jobs[Std.int(Math.random() * (jobs.length - 1))];

      isGenerator = false;
      isTempGenerator = false;
      isKnown = [];
      for (i in 0...game.difficulty.numCults)
        isKnown.push(false);
      power = [0, 0, 0];
      powerGenerated = [0, 0, 0];
      level = 0;
      var index: Int = Math.round((Game.numPowers - 1) * Math.random());
      power[index] = 1;
    }


// make this node a generator
  public function makeGenerator()
    {
      // make node harder to conquer
      var powerIndex = 0;
      for (ii in 0...Game.numPowers)
        if (power[ii] > 0)
          {
            power[ii]++;
            powerIndex = ii;
          }

      // another resource must be generated
      var ii = -1;
      while (true)
        {
          ii = Math.round((Game.numPowers - 1) * Math.random());
          if (ii != powerIndex)
            break;
        }
      powerGenerated[ii] = 1;

      setGenerator(true);
    }


// load node info from json-object
  public function load(n:Dynamic)
    {
      power = n.p;
      if (n.l != null)
        level = n.l;
      if (n.vis != null) // visibility
        {
          var vis:Array<Int> = n.vis;
          visibility = [];
          var i = 0;
          for (v in vis)
            {
              visibility.push(v == 1 ? true : false);
              if (v == 1)
                uiNode.setVisible(game.cults[i], true);
              i++;
            }
        }

      if (n.o != null)
        {
          owner = game.cults[n.o];
          owner.nodes.add(this);
        }

      if (n.pg != null)
        {
          isGenerator = true;
          powerGenerated = n.pg;

          // update power mod cache
          if (owner != null)
            for (i in 0...Game.numPowers)
              owner.powerMod[i] += Math.round(powerGenerated[i]);
        }
    }


// dump node info for saving (skip everything that's default)
  public function save(): Dynamic
    {
      var obj:Dynamic = {
        id: id,
//        nm: name,
//        j: job,
        p: power,
        x: x,
        y: y,
        };
      if (owner != null)
        obj.o = owner.id;
      if (level > 0)
        obj.l = level;
      var vis = [];
      var savevis = false;
      for (v in visibility)
        {
          vis.push(v ? 1 : 0);
          if (v)
            savevis = true;
        }
      if (savevis)
        obj.vis = vis;
      if (isGenerator)
        obj.pg = powerGenerated;

      return obj;
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

//      uiNode.update();
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
      isKnown[owner.id] = true;
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

      if (isVisible(game.player) && !owner.isDiscovered[game.player.id]) // discover cult
        game.player.discover(owner);
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
          if (Game.mapVisible) // debug: everything is visible
            v = true;
          for (l in lines) // show lines leading to this node
            l.setVisible(cult, v);
//          if (v && cult != game.player)
//            cult.highlightNode(this);
          if (owner != null && !owner.isDiscovered[cult.id]) // discover cult
            cult.discover(owner);
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
//      update();
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
//            n.update();
          }

      // update visibility of this node for that cult
      var hasLinks = false;
      for (n2 in links)
        if (n2.owner == cult)
          {
            setVisible(cult, true);
            hasLinks = true;
            break;
          }

      if (!hasLinks)
        setVisible(cult, false);
    }


// paint links from adjacent nodes owned by node owner to this one
  public function paintLines()
    {
      // create lines between this node and adjacent ones
      var hasLine = false;
      for (n in links)
        if (n.owner == this.owner)
          {
            var l = Line.create(ui, this.owner, n, this);
            game.lines.add(l);
            n.lines.add(l);
            this.lines.add(l);

            // make line visible to all cults who see that node
            for (c in game.cults)
              if (n.isVisible(c) || this.isVisible(c))
                l.setVisible(c, true);

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

      var l = Line.create(ui, this.owner, nc, this);
      game.lines.add(l);
      nc.lines.add(l);
      this.lines.add(l);

      // make line visible to all cults who see that node
      for (c in game.cults)
        if (nc.isVisible(c) || this.isVisible(c))
          l.setVisible(c, true);
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


  static var jobs: Array<String> =
    [
      "Government official",
      "Corporate worker",
      "University professor",
      "Army officer",
      "Scientist",
      "Politician",
      "Media person"
    ];
}
