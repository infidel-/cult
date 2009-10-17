// game player

class Player
{
  var game: Game;
  var ui: UI;
  public var id: Int;
  public var name: String;

  // player or AI?
  public var isAI: Bool;

  // player is dead
  public var isDead: Bool;

  // public awareness
  public var awareness(default, setAwareness): Int;

  // power reserve
  public var power: Array<Int>; // intimidation, persuasion, bribe, virgins
  public var virgins(getVirgins, setVirgins): Int;
 
  // wars
  public var wars: Array<Bool>;

  // power that will be generated next turn (cache variable)
  public var powerMod: Array<Int>;

  // starting node
  public var startNode: Node;

  // followers number cache
  public var neophytes(getNeophytes, null): Int;
  public var adepts(getAdepts, null): Int;
  public var priests(getPriests, null): Int;

  // cache of owned nodes
  public var nodes: List<Node>;

  // how many adepts were used this turn
  public var adeptsUsed: Int;


  public function new(gvar, uivar, id)
    {
      game = gvar;
      ui = uivar;
      this.id = id;
      this.name = "Cult " + id;
      this.isAI = false;
      this.power = [0, 0, 0, 0];
      this.powerMod = [0, 0, 0, 0];
      this.wars = [false, false, false, false];
      this.adeptsUsed = 0;
      this.awareness = 0;
      this.nodes = new List<Node>();
    }


// setup random starting node
  public function setStartNode()
    {
      // find appropriate node
      var index = -1;
      while (true)
        {
          index = Math.round((game.nodes.length - 1) * Math.random());
          var node = game.nodes[index];

          if (node.owner != null)
            continue;

          // check for close nodes
          var ok = 1;
          for (p in game.players)
            if (p.startNode != null &&
                node.distance(p.startNode) < UI.nodeVisibility + 50)
              {
                ok = 0;
                break;
              }
          if (ok == 0)
            continue;

          break;
        }
	  startNode = game.nodes[index];
      startNode.setOwner(this);

      // make starting node generator
	  for (i in 0...Game.numPowers)
	    if (startNode.power[i] > 0)
		  {
		    startNode.powerGenerated[i] = 1;
			powerMod[i] += 1;
		  }
      neophytes++;
	  startNode.setGenerator(true);

      startNode.setVisible(this, true);
      startNode.showLinks();

      // give initial power from starting node
	  for (i in 0...Game.numPowers)
        {
	      power[i] += Math.round(startNode.powerGenerated[i]);

          // 50% chance of raising the conquer difficulty
          if (Math.random() < 0.5)
            startNode.power[i]++;
        }
      startNode.update();
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
        ch = 80 - Std.int(awareness * 1.5);
      else if (level == 2)
        ch = 75 - awareness * 2;
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
      if (awareness == 0 || adeptsUsed >= adepts)
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
      if ((level == 2 && virgins < Game.numSummonVirgins) ||
          (level < 2 && virgins < level + 1))
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

      virgins -= (level + 1);

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

      // starting node upgrades first
      var ok = false;
      if (startNode.level == level)
        {
          startNode.upgrade();
          ok = true;
        }

      // generators upgrade 2nd
      if (!ok)
        for (n in nodes)
          if (n.level == level && n.isGenerator)
            {
              n.upgrade();
              ok = true;
              break;
            }
 

      // usual nodes upgrade last
      if (!ok)
        for (n in nodes)
          if (n.level == level)
            {
              n.upgrade();
              ok = true;
              break;
            }

      if (!isAI)
        ui.updateStatus();
      
      // notify player
      if (this != game.player && priests >= 2)
        ui.alert(name + " has " + priests + " priests. Be careful.");
    }


// summon elder god
  public function summon()
    {
      virgins -= Game.numSummonVirgins;

      // chance of failure
      if (100 * Math.random() > getUpgradeChance(2))
        {
          // 1 priest goes totally insane and has to be replaced with neophyte
          for (n in nodes)
            if (n.level == 2)
              {
                n.level = 0;
                n.update();
                break;
              }

          if (!isAI)
            {
              ui.alert("The stars were not right. The high priest goes insane.");
              ui.updateStatus();
            }
          else ui.alert(name + " tried to summon Elder God but failed.");
          return;
        }

      ui.finish(this, "summon");
    }


// make turn - gain resources
  public function turn()
    {
	  // give power and recalculate power mod cache
	  powerMod = [0, 0, 0, 0];
	  for (node in nodes)
	    if (node.isGenerator)
		  for (i in 0...Game.numPowers)
		    {
              // failure chance
              if (100 * Math.random() < getResourceChance())
		        power[i] += Math.round(node.powerGenerated[i]);
			  powerMod[i] += Math.round(node.powerGenerated[i]);
			}

      // neophytes bring in some virgins
      var value = Std.int(Math.random() * (neophytes / 4 - 0.5));
      virgins += value;
      adeptsUsed = 0;
    }


// can this player activate this node?
  public function canActivate(node: Node): Bool
    {
	  for (i in 0...Game.numPowers)
        if (power[i] < node.power[i])
          return false;

      return true;
    }


// activate node (returns result for AI stuff)
  public function activate(node: Node): String
    {
	  if (node.owner == this)
		return "isOwner";

      // cannot gain a generator if it has 3+ active links
      if (node.isGenerator && node.owner != null)
        {
          // count links with same owner
          var cnt = 0;
          for (n in node.links)
            if (n.owner == node.owner)
              cnt++;

          if (cnt >= 3)
            {
              if (!isAI)
                ui.msg("Generator has " + cnt + " links.");
              return "hasLinks";
            }
        }

	  // check for power
	  for (i in 0...Game.numPowers)
		if (power[i] < node.power[i])
		  {
            if (!isAI)
		 	  ui.msg("Not enough " + Game.powerNames[i]);
			return "notEnoughPower";
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
          return "failure";
        }

      // save prev owner
      var prevOwner = node.owner;
      // update power mod cache
	  if (node.isGenerator)
	    for (i in 0...Game.numPowers)
		  powerMod[i] += Math.round(node.powerGenerated[i]);
      node.clearLines();
      node.setOwner(this);
      node.showLinks();

      // update previous owner's visibility of the links for this node
      if (prevOwner != null)
        node.updateLinkVisibility(prevOwner);

      // raise public awareness
      if (node.isGenerator)
        awareness += 2;
      else awareness++;

      if (!isAI)
        ui.updateStatus();

      // paint lines to this node from adjacent nodes owned by node owner
      node.paintLines();

      // update display
      for (n in node.links)
        n.update();

      // check for prev owner's death
      if (prevOwner != null)
        prevOwner.checkDeath();

      // declare war
      if (prevOwner != null && !prevOwner.isDead && !wars[prevOwner.id])
        {
          wars[prevOwner.id] = true;
          prevOwner.wars[id] = true;

          ui.alert(name + " has declared a war against " +
            prevOwner.name + ".");
        }

      // check for victory
      checkVictory();

      return "ok";
    }


// check for player victory
  function checkVictory()
    {
      // check for finish
      var ok = true;
      for (p in game.players)
        if (p != this && !p.isDead)
          ok = false;

      // there are live players left
      if (!ok)
        return;

      ui.finish(this, "conquer");
    }


// check if player still has any nodes
  function checkDeath()
    {
      if (this.nodes.length > 0)
        return;

      // owner dead
      ui.msg(name + " was wiped completely from the world.");

      isDead = true;

      // player dead
      if (!isAI)
        ui.finish(this, "wiped");
    }


// getter for virgins
  function getVirgins()
    {
      return power[3];
    }


// setter for virgins
  function setVirgins(v)
    {
      power[3] = v;
      return v;
    }


// get number of followers of this level
  public function getNumFollowers(level)
    {
      var cnt = 0;
      for (n in nodes)
        if (n.level == level)
          cnt++;
      return cnt;
    }


// getters and setters for different numFollowers
  function getNeophytes()
    {
      return getNumFollowers(0);
    }


  function getAdepts()
    {
      return getNumFollowers(1);
    }


  function getPriests()
    {
      return getNumFollowers(2);
    }
}
