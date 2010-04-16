// cult (game player)

class Cult
{
  var game: Game;
  var ui: UI;
  public var id: Int;
  public var name: String;
  public var fullName(getFullName, null): String;
  public var info: Dynamic;

  public var isAI: Bool; // player or AI?
  public var isDead: Bool; // cult is dead
  public var isParalyzed: Bool; // cult is paralyzed

  // ritual stuff
  public var isRitual: Bool; // cult is performing ritual?
  public var ritual: Dynamic; // which ritual is in progress
  public var ritualPoints: Int; // amount of ritual points needed

  public var awareness(default, setAwareness): Int; // public awareness

  // power reserves
  public var power: Array<Int>; // intimidation, persuasion, bribe, virgins
  public var virgins(getVirgins, setVirgins): Int;
 
  public var wars: Array<Bool>; // wars
  public var powerMod: Array<Int>; // power that will be generated next turn (cache)
  public var origin: Node; // origin 

  // followers number cache
  public var neophytes(getNeophytes, null): Int;
  public var adepts(getAdepts, null): Int;
  public var priests(getPriests, null): Int;

  public var nodes: List<Node>; // cache of owned nodes
  public var adeptsUsed: Int; // how many adepts were used this turn

  public var hasInvestigator: Bool; // does this cult has investigator on its back?
  public var investigator: Investigator; // investigator


  public function new(gvar, uivar, id, infoID)
    {
      game = gvar;
      ui = uivar;
      this.id = id;
      this.info = Static.cults[infoID];
      this.name = this.info.name;
      this.isAI = false;
      this.power = [0, 0, 0, 0];
      this.powerMod = [0, 0, 0, 0];
      this.wars = [false, false, false, false];
      this.adeptsUsed = 0;
      this.awareness = 0;
      this.nodes = new List<Node>();
    }


// setup random starting node
  public function setOrigin()
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
          for (p in game.cults)
            if (p.origin != null &&
                node.distance(p.origin) < UI.nodeVisibility + 50)
              {
                ok = 0;
                break;
              }
          if (ok == 0)
            continue;

          break;
        }
	  origin = game.nodes[index];
      origin.owner = this;
      nodes.add(origin);
      origin.update();
//      origin.setOwner(this);

      // make starting node generator
	  for (i in 0...Game.numPowers)
	    if (origin.power[i] > 0)
		  {
		    origin.powerGenerated[i] = 1;
			powerMod[i] += 1;
		  }
      neophytes++;
	  origin.setGenerator(true);

      origin.setVisible(this, true);
      origin.showLinks();

      // give initial power from starting node
	  for (i in 0...Game.numPowers)
        {
	      power[i] += Math.round(origin.powerGenerated[i]);

          // 50% chance of raising the conquer difficulty
          if (Math.random() < 0.5)
            origin.power[i]++;
        }
      origin.update();
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
      if (awareness == 0 || adeptsUsed >= adepts || pwr == 3)
        return;

      awareness -= 2;
      if (awareness < 0)
        awareness = 0;
      power[pwr]--;
      adeptsUsed++;

      if (!isAI)
        ui.updateStatus();
    }


// lower investigator willpower
  public function lowerWillpower(pwr)
    {
      if (!hasInvestigator || adeptsUsed >= adepts || pwr == 3 ||
          power[pwr] < Game.willPowerCost || investigator.will >= 9)
        return;

      power[pwr] -= Game.willPowerCost;

      // chance of failure
      if (100 * Math.random() < 30)
        {
          if (!isAI)
            ui.alert("You have failed to shatter the will of the investigator.");
          return;
        }

      investigator.will -= 1;
      if (investigator.will <= 0)
        {
          investigator = null;
          hasInvestigator = false;
          ui.log("The investigator of the " + fullName +
            " has disappeared.");
        }
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


// upgrade nodes (fupgr)
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
          summonStart();
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
      var upNode = null;
      if (origin != null && origin.level == level)
        {
          origin.upgrade();
          upNode = origin;
          ok = true;
        }

      // generators upgrade 2nd
      if (!ok)
        for (n in nodes)
          if (n.level == level && n.isGenerator)
            {
              n.upgrade();
              upNode = n;
              ok = true;
              break;
            }
 

      // usual nodes upgrade last
      if (!ok)
        for (n in nodes)
          if (n.level == level)
            {
              n.upgrade();
              upNode = n;
              ok = true;
              break;
            }

      if (!isAI)
        ui.updateStatus();
      
      // notify player
      if (this != game.player && priests >= 2)
        ui.log(fullName + " has " + priests + " priests. Be careful.");

      // cult un-paralyzed 
      if (isParalyzed && priests >= 1)
        {
          isParalyzed = false;
          origin = upNode;
          origin.update();
          ui.log(fullName + " gains a priest and is no longer paralyzed.");
        }
    }


// chance of gaining investigator
  public function getInvestigatorChance(): Int
    {
      if (priests == 1)
        return 50;
      else if (priests == 2)
        return 65;
      else return 80;
    }


// summon elder god
  public function summonStart()
    {
      // player is already in ritual
      if (isRitual)
        {
          ui.alert("You must first finish the current ritual before starting another.");
          return;
        }

      virgins -= Game.numSummonVirgins;
      isRitual = true;
      ritual = Static.rituals[0];
      ritualPoints = ritual.points;

      // every cult starts war with this one
      for (p in game.cults)
        if (p != this)
          {
            p.wars[id] = true;
            wars[p.id] = true;
          }

      ui.alert(fullName + " has started the " + ritual.name + ".<br><br>" +
        Static.cults[id].summonStart);
      ui.log(fullName + " has started the " + ritual.name + ".");
      if (!isAI)
        ui.updateStatus();
    }


// finish a ritual
  function ritualFinish()
    {
      if (ritual.id == "summoning")
        summonFinish();

      isRitual = false;
    }


// finish summoning
  public function summonFinish()
    {
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
              ui.alert("The stars were not proerly aligned. The high priest goes insane.");
              ui.log(fullName + " has failed to perform the " + 
                Static.rituals[0].name + ".");
              ui.updateStatus();
            }
          else
            {
              ui.alert(fullName +
                " has failed to perform the " + Static.rituals[0].name + ".<br><br>" +
                info.summonFail);
              ui.log(fullName + " has failed the " +
                Static.rituals[0].name + ".");
            }
          return;
        }

      game.isFinished = true;
      ui.finish(this, "summon");
      ui.log("Game over.");
    }


// end of turn for this cult (fturn) - gain resources, finish rituals
  public function turn()
    {
      // if a cult has any priests, each turn it has a 
      // big chance of an investigator finding out about it
      if (priests > 0 && !hasInvestigator && 100 * Math.random() < getInvestigatorChance())
        {
          hasInvestigator = true;
          ui.log("An investigator has found out about " + fullName + ".");
          investigator = new Investigator(this, ui);

          if (!isAI)
            ui.updateStatus();
        }

      // finish a ritual if there is one
      if (isRitual)
        {
          ritualPoints -= priests;
          if (ritualPoints <= 0)
            ritualFinish();

          // summon finished
          if (game.isFinished)
            return;
        }

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

      // investigator acts
      if (hasInvestigator)
        investigator.turn();
    }


// can this player activate this node?
  public function canActivate(node: Node): Bool
    {
	  for (i in 0...Game.numPowers)
        if (power[i] < node.power[i])
          return false;

      return true;
    }


// activate node (fact) (returns result for AI stuff)
  public function activate(node: Node): String
    {
      if (isParalyzed)
        {
          if (!isAI)
            ui.alert("Cult is paralyzed without the Origin.");
          return "";
        }

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
      node.setOwner(this);

      // check for victory
      checkVictory();

      return "ok";
    }


// declare war to this cult
  public function declareWar(cult: Cult)
    {
      if (cult.wars[id])
        return;

      cult.wars[id] = true;
      wars[cult.id] = true;

      ui.log(fullName + " has declared war against " +
        UI.cultName(cult.id, cult.info) + ".");
    }


// lose node to new owner (who is null in the case of losing)
  public function loseNode(node: Node, ?cult: Cult)
    {
      // check for death
      checkDeath();
      if (isDead) return;

      // raise public awareness
      awareness++;
      if (!isAI)
        ui.updateStatus();

      // declare war
      if (cult != null)
        cult.declareWar(this);

      // converting the origin
      if (origin == node)
        loseOrigin();

      node.update();
    }


// lose origin
  public function loseOrigin()
    {
      ui.log(fullName + " has lost its Origin.");

      // stop a ritual
      if (isRitual)
        {
          isRitual = false;
          ui.log("The execution of " + ritual.name + " has been stopped.");
        }

      // find a new origin, starting with priests
      var ok = false;
      origin = null;
      for (n in nodes)
        {
          if (n.level == 2)
            {
              origin = n;
              ok = true;
              break;
            }
        }

      // if not found, cult is in big trouble
      if (!ok)
        {
          ui.log("With no priests left " + fullName +
            " is completely paralyzed.");
          isParalyzed = true;
        }
      else
        {
          ui.log("Another priest becomes the Origin of " +
            fullName + ".");
          origin.update();
        }
    }


// check for victory for this cult
  function checkVictory()
    {
      // check for finish
      var ok = true;
      for (p in game.cults)
        if (p != this && !p.isDead)
          ok = false;

      // there are active cults left
      if (!ok)
        return;

      ui.finish(this, "conquer");
    }


// check if cult still has any nodes
  public function checkDeath()
    {
      if (this.nodes.length > 0)
        return;

      // owner dead
      ui.log(fullName + " has been destroyed, forgotten by time.");

      isDead = true;

      // player cult is dead
      if (!isAI)
        {
          game.isFinished = true;
          ui.finish(this, "wiped");
        }
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

  function getFullName()
    {
      return UI.cultName(id, info);
    }
}
