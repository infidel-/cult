// node class

import sects.Sect;
import _SaveGame;

class Node
{
  var ui: UI;
  var game: Game;
  public var uiNode: UINode;

  public var id: Int;
  public var type: String;
  public var name: String; // node name
  public var nation: Int; // nationality
  public var job: String; // job
  public var gender: Bool; // false - male
  public var jobID: Int;
  public var imageID: Int;
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

  // expansions
  public var artifact: artifacts.CultArtifact;


  public function new(gvar, uivar, newx, newy, index: Int)
    {
      game = gvar;
      ui = uivar;
      id = index;
      type = 'person';
      nation = 0;
      artifact = null;
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

// partial regen when conquered from another cult
// leave same job
// disbands sects
  public function generateLite()
    {
      level = 0; // loses all levels
      gender = (Std.random(2) == 0 ? false : true);
      name = GenName.generate(gender, nation);
      imageID = jobID * 2 + (gender ? 1 : 0);

      // lower all power to 2 max
      for (i in 0...Game.numPowers)
        if (power[i] > 2)
          power[i] = 2;
      if (sect != null) // will already be removed in case of attack
        owner.removeSect(this, 'investigator');
      if (game.flags.artifacts)
        owner.artifacts.onLose(this);
      update();
    }

// generate new attributes
  public function generateAttributes()
    {
      gender = (Std.random(2) == 0 ? false : true);
      var nn = (gender ? GenName.namesFemale : GenName.namesMale);
      nation = Std.random(nn.length);
      name = GenName.generate(gender, nation);
      jobID = Std.random(jobs.length);
      imageID = jobID * 2 + (gender ? 1 : 0);
      job = jobs[jobID];

      isGenerator = false;
      isTempGenerator = false;
      isKnown = [];
      for (i in 0...game.difficulty.numCults)
        isKnown.push(false);
      power = [0, 0, 0, 0];
      powerGenerated = [0, 0, 0, 0];
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
      return Static.distance(x, y, node.x, node.y);
    }


// calculate distance between this node and the other one
  public function distanceXY(xx: Int, yy: Int): Float
    {
      return Static.distance(x, y, xx, yy);
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
        owner.awarenessBase += 2;
      else owner.awarenessBase++;

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


// update links from this node to others
  public function updateLinks()
    {
      for (n2 in game.nodes)
        if (this != n2 &&
            this.distance(n2) <= game.difficulty.nodeActivationRadius)
          {
            this.links.remove(n2);
            this.links.add(n2);
          }
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

  public function turn()
    {}

// dump node info for saving (skip everything that's default)
  public function save(): _SaveNode
    {
      var obj: _SaveNode = {
        id: id,
        type: type,
        name: name,
        nation: nation,
        job: job,
        gender: gender,
        jobID: jobID,
        imageID: imageID,
        power: power,
        x: x,
        y: y,
        centerX: centerX,
        centerY: centerY,
        vis: visibility,
        isKnown: isKnown, 
        isTempGenerator: isTempGenerator,
        isProtected: isProtected,
        level: level,
        owner: (owner != null ? owner.id : -1),
        // NOTE: sect link is restored in Sect.hx
        artifact: -1,
      };
      if (isGenerator)
        obj.powerGenerated = powerGenerated;
      if (artifact != null)
        for (idx in 0...owner.artifacts.list().length)
          if (artifact == owner.artifacts.list()[idx])
            {
              obj.artifact = idx;
              break;
            }

      return obj;
    }

// load node info from json-object
  public function load(n: _SaveNode)
    {
      type = n.type;
      name = n.name;
      nation = n.nation;
      job = n.job;
      gender = n.gender;
      jobID = n.jobID;
      imageID = n.imageID;
      power = n.power;
      centerX = n.centerX;
      centerY = n.centerY;
      visibility = n.vis;
      for (i in 0...n.vis.length)
        if (n.vis[i])
          uiNode.setVisible(game.cults[i], true);
      isKnown = n.isKnown;
      isTempGenerator = n.isTempGenerator;
      isProtected = n.isProtected;
      level = n.level;
      if (n.owner >= 0)
        {
          owner = game.cults[n.owner];
          owner.nodes.add(this);
        }
      if (n.powerGenerated != null)
        {
          isGenerator = true;
          powerGenerated = n.powerGenerated;

          // update power mod cache
          if (owner != null)
            for (i in 0...Game.numFullPowers)
              owner.powerMod[i] += Math.round(powerGenerated[i]);
        }
      if (n.artifact >= 0)
        artifact = owner.artifacts.list()[n.artifact];
    }

  public function toString()
    {
      return '(' + x + ',' + y + ')';
    }


  static var jobs = [
    "Government official",
    "Corporate worker",
    "University professor",
    "Army officer",
    "Scientist",
    "Politician",
    "Media person"
  ];
}
