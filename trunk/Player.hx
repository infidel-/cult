// game player

class Player
{
  var game: Game;
  var ui: UI;
  public var id: Int;

  // or AI?
  public var isAI: Bool;

  // public awareness
  public var awareness(default, setAwareness): Int;

  // power reserve
  public var power: Array<Int>; // intimidation, persuasion, bribe, worship
  
  // power that will be generated next turn (cache variable)
  public var powerMod: Array<Int>;

  // starting node
  public var startNode: Node;

  // followers number cache
  public var numFollowers: Array<Int>;

  // how many adepts were used this turn
  public var adeptsUsed: Int;


  public function new(gvar, uivar, id)
    {
      game = gvar;
      ui = uivar;
      this.id = id;
      this.isAI = true;
      this.power = [0, 0, 0, 0];
      this.powerMod = [0, 0, 0, 0];
      this.numFollowers = [0, 0, 0];
      this.adeptsUsed = 0;
      this.awareness = 0;
    }


// setup random starting node
  public function setStartingNode()
    {
      var index = Math.round((game.nodes.length - 1) * Math.random());
	  startNode = game.nodes[index];
      startNode.setOwner(this);

	  for (i in 0...Game.numPowers)
	    if (startNode.power[i] > 0)
		  {
		    startNode.powerGenerated[i] = 1;
			powerMod[i] += 1;
		  }
      numFollowers[0]++;
	  startNode.setGenerator(true);

      startNode.setVisible(this, true);
      startNode.updateVisibility();

      // give initial power from starting node
	  for (i in 0...Game.numPowers)
	    power[i] += Math.round(startNode.powerGenerated[i]);

	}


// setter for awareness
  function setAwareness(v)
    {
      awareness = v;
      for (n in game.nodes)
        if (n.isVisible(this) && n.owner != this)
          n.update();
      return v;
    }


// get resource chance
  public function getResourceChance()
    {
      var ch = Std.int(99 - 1.5 * awareness);
      if (ch < 1)
        ch = 1;
      return ch;
    }


// get upgrade chance
  public function getUpgradeChance(level)
    {
      var ch = 0;
      if (level == 0)
        ch = 99 - awareness;
      else if (level == 1)
        ch = 80 - awareness * 2;
      else if (level == 2)
        ch = 75 - awareness * 3;
      if (ch < 1)
        ch = 1;
      return ch;
    }


// get gain chance
  public function getGainChance(node)
    {
      var ch = 0;
      if (!node.isGenerator)
        ch = 99 - awareness;
      else ch = 99 - awareness * 2;
      if (ch < 1)
        ch = 1;
      return ch;
    }


// lower awareness
  public function lowerAwareness(pwr)
    {
      if (awareness == 0)
        return;

      awareness -= 2;
      if (awareness < 0)
        awareness = 0;
      power[pwr]--;
      adeptsUsed++;

      if (!isAI)
        ui.updateStatus();
    }


// convert resources
  public function convert(from: Int, to: Int)
    {
	  if (power[from] < Game.powerConversionCost[from])
	    {
          if (!isAI)
	        ui.msg("Not enough " + Game.powerNames[from]);
		  return;
		}
	
	  power[from] -= Game.powerConversionCost[from];
	  power[to] += 1;
      if (!isAI)
	    ui.updateStatus();
	}


// upgrade nodes
  public function upgrade(level)
    {
      if ((level == 2 && power[3] < Game.numSummonVirgins) ||
          (level < 2 && power[3] < level + 1))
        {
          if (!isAI)
            ui.msg("Not enough virgins");
          return;
        }

      // summon
      if (level == 2)
        {
          summon();
          return;
        }

      power[3] -= level + 1;

      // check for failure
      if (100 * Math.random() > getUpgradeChance(level))
        {
          if (!isAI)
            {
              ui.alert("Ritual failed.");
              ui.updateStatus();
            }
          return;
        }

      awareness += level;
      numFollowers[level]--;
      numFollowers[level + 1]++;

      // find first node of this level and upgrade
      for (n in game.nodes)
        if (n.owner == this && n.level == level)
          {
            n.upgrade();
            break;
          }
  
      ui.updateStatus();
    }


// summon elder god
  public function summon()
    {
      power[3] -= Game.numSummonVirgins;

      // chance of failure
      if (100 * Math.random() > getUpgradeChance(2))
        {
          // 1 priest goes totally insane and has to be replaced with neophyte
          for (n in game.nodes)
            if (n.owner == this && n.level == 2)
              {
                n.level = 0;
                n.update();
                numFollowers[2]--;
                break;
              }

          if (!isAI)
            {
              ui.alert("The stars were not right. The high priest goes insane.");
              ui.updateStatus();
            }
          return;
        }

      ui.finish(this, "summon");
    }


// make turn - gain resources and do ai stuff if it's ai
  public function turn()
    {
	  // give power and recalculate power mod cache
	  powerMod = [0, 0, 0, 0];
	  for (node in game.nodes)
	    if (node.owner == this && node.isGenerator)
		    for (i in 0...Game.numPowers)
		      {
                // failure chance
                if (100 * Math.random() < getResourceChance())
		          power[i] += Math.round(node.powerGenerated[i]);
			    powerMod[i] += Math.round(node.powerGenerated[i]);
			  }

      // neophytes bring in some virgins
      var value = Std.int(Math.random() * (numFollowers[0] / 4 - 0.5));
      power[3] += value;
      adeptsUsed = 0;

      if (!isAI) return;

      // TODO: do ai stuff

      for (node in game.nodes)
        {
          if (node.owner == this || !node.isVisible(this))
            continue;

          var ret = activate(node);
          if (!ret)
            continue;
          break;
        }
    }


// activate node (returns result for AI stuf)
  public function activate(node: Dynamic): Bool
    {
	  if (node.owner == this)
		return false;

	  // check for power
	  for (i in 0...Game.numPowers)
		if (power[i] < node.power[i])
		  {
            if (!isAI)
		 	  ui.msg("Not enough " + Game.powerNames[i]);
			return false;
		  }

	  // subtract power
	  for (i in 0...Game.numPowers)
		power[i] = Math.round(power[i] - node.power[i]);

      // failure chance
      if (100 * Math.random() > getGainChance(node))
        {
          if (!isAI)
            {
              ui.alert("Could not gain a follower.");
              ui.updateStatus();
            }
          return false;
        }

	  if (node.isGenerator)
	    for (i in 0...Game.numPowers)
		  powerMod[i] += Math.round(node.powerGenerated[i]);
      node.setOwner(this);
      numFollowers[0]++;
      node.updateVisibility();

      // raise public awareness
      if (node.isGenerator)
        awareness += 2;
      else awareness++;

      if (!isAI)
        ui.updateStatus();

	  // create lines between this node and adjacent ones
      var hasLine = false;
      for (n in game.nodes)
        if (n.owner == this && node != n &&
            node.distance(n) < UI.nodeVisibility - 10)
          {
            game.lines.push(Line.paint(ui.map, n, node));
            hasLine = true;
          }

      // no lines were drawn - draw to closest node 
      if (!hasLine)
        {
          var dist = 10000;
          var nc = null;
          for (n in game.nodes)
            if (n.owner == this && node != n &&
                node.distance(n) < dist)
              {
                dist = node.distance(n);
                nc = n;
              }

          game.lines.push(Line.paint(ui.map, nc, node));
        }

      // check for finish
      var cntOwned = 0;
      var cntVisible = 0;
      for (n in game.nodes)
        {
          if (n.owner == this)
            cntOwned++;
          if (n.isVisible(this))
            cntVisible++;
        }

      // all visible nodes are owned, won
      if (cntOwned == cntVisible)
        ui.finish(this, "conquer");

      return true;
    }
}
