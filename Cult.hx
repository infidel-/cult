// cult (game player)

import Static;
import sects.Sect;

class Cult
{
  var game: Game;
  var ui: UI;
  public var id: Int;
  public var infoID: Int;
  public var name: String;
  public var fullName(get, null): String;
  public var info: CultInfo;
  public var difficulty: DifficultyInfo; // difficulty info link

  public var isInfoKnown: Array<Bool>; // info known to players?
  public var isDiscovered: Array<Bool>; // is met by players?
  public var isAI: Bool; // player or AI?
  public var isDead: Bool; // cult is dead
  public var isParalyzed: Bool; // cult is paralyzed
  var paralyzedTurns: Int; // paralyzed state count
  public var isDebugInvisible: Bool; // debug: cult nodes are invisible

  // ritual stuff
  public var isRitual: Bool; // cult is performing ritual?
  public var ritual: RitualInfo; // which ritual is in progress
  public var ritualPoints: Int; // amount of ritual points left

  public var awarenessMod: Int; // awareness static mod from expansions
  public var awarenessBase: Int; // base awareness
  public var awareness(get, null): Int; // public awareness (combined)

  // power reserves
  public var power: Array<Int>; // intimidation, persuasion, bribe, virgins
  public var virgins(get, set): Int;

  public var wars: Array<Bool>; // wars
  public var powerMod: Array<Int>; // power that will be generated next turn (cache)
  public var origin: Node; // origin

  // followers number cache
  public var neophytes(get, null): Int;
  public var adepts(get, null): Int;
  public var priests(get, null): Int;

  public var nodes: List<Node>; // cache of owned nodes
  public var adeptsUsed: Int; // how many adepts were used this turn
  public var sects: List<Sect>; // list of controlled sects
  public var options: Options; // player options

  public var hasInvestigator: Bool; // does this cult has investigator on its back?
  public var investigator: Investigator; // investigator
  public var investigatorTimeout: Int; // timeout before next investigator may appear

  public var logMessages: String; // log string
  public var logMessagesTurn: String; // log string for this turn
  public var logPanelMessages: List<LogPanelMessage>; // log panel messages list
  public var highlightedNodes: List<Node>; // highlighted nodes list

  // expansion stuff
  public var artifacts: artifacts.CultArtifacts;


  public function new(gvar: Game, uivar: UI, id: Int, infoID: Int)
    {
      game = gvar;
      ui = uivar;
      this.id = id;
      this.infoID = infoID;
      this.info = Static.cults[infoID];
      this.name = this.info.name;
      this.isAI = false;
      this.highlightedNodes = new List<Node>();
      this.options = new Options(game, ui, this);
      this.artifacts = new artifacts.CultArtifacts(game, ui, this);

      this.isDiscovered = [];
      this.isInfoKnown = [];
      this.paralyzedTurns = 0;
      for (i in 0...game.difficulty.numCults)
        this.isInfoKnown[i] = game.difficulty.isInfoKnown;
      for (i in 0...game.difficulty.numCults)
        this.isDiscovered[i] = game.difficulty.isDiscovered;
      // self discovered and info known
      this.isDiscovered[id] = true;
      this.isInfoKnown[id] = true;

      this.power = [0, 0, 0, 0];
      this.powerMod = [0, 0, 0, 0];
      wars = [];
      for (i in 0...game.difficulty.numCults)
        wars.push(false);
      this.adeptsUsed = 0;
      this.awarenessBase = 0;
      this.awarenessMod = 0;
      this.awareness = 0;
      this.nodes = new List<Node>();
      this.sects = new List<Sect>();
      this.investigatorTimeout = 0;
      this.difficulty = game.difficulty;
      this.logMessages = '';
      this.logMessagesTurn = '';
      this.logPanelMessages = new List();
    }


// load node info from json-object
  public function load(c:Dynamic)
    {
      difficulty = Static.difficulty[c.dif];
      isDead = (c.ide ? true : false);
      isParalyzed = (c.ip ? true : false);
      trace('TODO load isDiscovered isInfoKnown');
//      isDiscovered = (c.idi ? true : false);
//      isInfoKnown = (c.iin ? true : false);
      power = c.p;
      adeptsUsed = c.au;
      investigatorTimeout = c.it;
      if (c.inv != null)
        {
          hasInvestigator = true;
          investigator = new Investigator(this, ui, game);
          investigator.load(c.inv);
        }
      if (c.r != null)
        {
          isRitual = true;
          ritualPoints = c.rp;
          for (r in Static.rituals)
            if (r.id == c.r)
              ritual = r;
        }
      awareness = c.aw;
      if (c.w != null)
        {
          var wlist:Array<Int> = c.w;
          wars = [];
          for (w in wlist)
            wars.push(w == 1 ? true : false);
        }
    }


// dump cult info for saving
  public function save(): Dynamic
    {
      trace('TODO save isDiscovered isInfoKnown');
      var obj:Dynamic = {
        id: id,
        iid: infoID,
        dif: difficulty.level,
        ia: (isAI ? 1 : 0),
        ide: (isDead ? 1 : 0),
        ip: (isParalyzed ? 1 : 0),
//        idi: (isDiscovered ? 1 : 0),
//        iin: (isInfoKnown ? 1 : 0),
        p: power,
        or: (origin != null ? origin.id : 0),
        au: adeptsUsed,
        it: investigatorTimeout
        };
      if (hasInvestigator)
        obj.inv = investigator.save();
      if (isRitual)
        {
          obj.r = ritual.id;
          obj.rp = ritualPoints;
        }
      obj.aw = awareness;
      var ww = [];
      var savewars = false;
      for (w in wars)
        {
          ww.push(w ? 1 : 0);
          if (w)
            savewars = true;
        }
      if (savewars)
        obj.w = wars;

      return obj;
    }


// max number of sects
  public inline function getMaxSects(): Int
    {
      return Std.int(nodes.length / 4);
    }

// get generated ritual points
  public function getRitualPoints(): Int
    {
      if (game.flags.artifacts)
        return artifacts.getRitualPoints();
      return priests;
    }

// get max ritual points
  public function getMaxRitualPoints(): Int
    {
      var pts = ritual.points;
      if (game.flags.longRituals)
        return Std.int(Const.longRitualsRitualPoints * pts);
      return pts;
    }

// create a new sect
  public function createSect(node: Node)
    {
      if (sects.length >= getMaxSects())
        return;

      var sect = new Sect(game, ui, node, this);
      sects.add(sect);
      node.sect = sect;
      node.update();
      if (game.flags.devoted) // DEVOTED: pick a resource to buff with
        sect.powerID = Std.random(Game.numPowers);

      if (!isAI)
        ui.log2(this, node.name +
          " becomes the puppeteer of a sect called " + sect.name + ".",
          { type: 'sect', symbol: 's' });

      // tutorial
      if (!isAI)
        game.tutorial.play('gainSect');
    }

// remove a sect
  public function removeSect(node: Node, src: String)
    {
      var text = node.sect.name;
      if (src == 'investigator')
        text += ' has dispersed without proper inspiration.';
      else if (src == 'sacrifice')
        text += ' was sacrificed to discourage the investigator.';
      else if (src == 'attack')
        text += ' was disbanded when its puppeteer has left the cult.';
      else if (src == 'harvest')
        text += ' was harvested for resources.';
      if (src != null)
        ui.log2(this, text, { type: 'sect', symbol: 's' });
      sects.remove(node.sect);
      node.sect.leader = null;
      node.sect = null;
      node.update();
    }

// get sect by id
  public function getSect(id: Int): Sect
    {
      for (s in sects)
        if (s.id == id)
          return s;
      return null;
    }

// setup random starting node
  public function setOrigin()
    {
      // change method on the difficulty setting
      if (game.difficulty.numCults <= 4)
        setupOriginFair();
      else setupOriginRandom();

      origin.owner = this;
      if (!isAI || game.difficulty.isOriginKnown)
        origin.isKnown[this.id] = true;

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
      origin.setGenerator(true);

      origin.setVisible(this, true);
      origin.showLinks();
      highlightedNodes.clear(); // hack: clear highlighted

      // give initial power from starting node
      for (i in 0...Game.numPowers)
        {
          power[i] += Math.round(origin.powerGenerated[i]);

          // 50% chance of raising the conquer difficulty
          if (Math.random() < 0.5)
            origin.power[i]++;
        }
      origin.update();

      // remove close generators on hard for player
      if (!isAI && game.difficultyLevel == 2)
        removeCloseGenerators();
    }


// pick an origin fairly
  function setupOriginFair()
    {
      // pick unused quadrant and set origin there
      // pick unused quadrant
      var quad = game.freeQuadrants[Std.random(game.freeQuadrants.length)];
      game.freeQuadrants.remove(quad);

      // get all nodes in this quadrant
      var tmp = [];
      var outer: Node = null;
      var outerd = 10000.0;
      for (n in game.nodes)
        if (quad.x1 <= n.x && quad.y1 <= n.y &&
            n.x <= quad.x2 && n.y <= quad.y2)
          {
            tmp.push(n);

            // also pick outermost node for tutorial
            if (outer != null && !isAI && game.isTutorial)
              {
                var d = 0.0;
                if (quad.id == 0)
                  d = n.distanceXY(quad.x1, quad.y1);
                else if (quad.id == 1)
                  d = n.distanceXY(quad.x2, quad.y1);
                else if (quad.id == 2)
                  d = n.distanceXY(quad.x1, quad.y2);
                else if (quad.id == 3)
                  d = n.distanceXY(quad.x2, quad.y2);
                if (d < outerd)
                  {
                    outer = n;
                    outerd = d;
                  }
              }
            else outer = n;
          }
      var node = tmp[Std.random(tmp.length)];
      if (game.isTutorial && !isAI)
        node = outer;
      origin = node;
    }


// pick a random node as an origin
  function setupOriginRandom()
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
                node.distance(p.origin) < difficulty.nodeActivationRadius + 50)
              {
                ok = 0;
                break;
              }
          if (ok == 0)
            continue;

          origin = game.nodes[index];
          return;
        }
    }


// remove close node generators
  function removeCloseGenerators()
    {
      for (n in origin.links)
        {
/*
          for (n2 in n.links)
            if (n2.owner == null && n2.isGenerator)
              n2.setGenerator(false);
*/
          if (n.owner == null && n.isGenerator)
            n.setGenerator(false);
        }
    }


// get resource chance
  public function getResourceChance()
    {
      var ch = 99 - Std.int(difficulty.awarenessResource * awareness);
      if (ch < 1)
        ch = 1;
      return ch;
    }


// get upgrade chance
  public function getUpgradeChance(level)
    {
      var ch = 0;
      if (level == 0)
        ch = Std.int(99 * difficulty.upgradeChance -
          awareness * difficulty.awarenessUpgrade);
      else if (level == 1)
        ch = Std.int(80 * difficulty.upgradeChance -
          awareness * 1.5 * difficulty.awarenessUpgrade);
      else if (level == 2)
        ch = Std.int(75 * difficulty.upgradeChance -
          awareness * 2 * difficulty.awarenessUpgrade);
      if (ch < 1)
        ch = 1;
      if (ch > 99)
        ch = 99;
      return ch;
    }


// get gain chance (pl)
  public function getGainChance(node: Node)
    {
      var ch = 0;

      if (!node.isGenerator) // generators are harder to gain
        ch = 99 - Std.int(awareness * difficulty.awarenessGain);
      else ch = 99 - Std.int(awareness * 2 * difficulty.awarenessGain);

      // player penalty if cult info is not known
      if (!isAI && node.owner != null && !node.owner.isInfoKnown[game.player.id])
        ch -= 20;

      // player penalty if node info is not known
      if (!isAI && node.owner != null && !node.isKnown[game.player.id])
        ch -= 10;

      if (ch < 1)
        ch = 1;
      return ch;
    }


// lower awareness
  public function lowerAwareness(pwr)
    {
      if (awarenessBase == 0 || adeptsUsed >= adepts || pwr == 3 ||
          power[pwr] < 1)
        return;

      awarenessBase -= 2;
      if (awarenessBase < 0)
        awarenessBase = 0;
      power[pwr]--;
      adeptsUsed++;

      if (!isAI)
        {
          ui.updateStatus();
          ui.map.paint();
        }
    }


// lower investigator willpower chance
  public function getLowerWillChance(): Int
    {
      var failChance = 30 * difficulty.investigatorWillpower;
      if (investigator.name == "Randolph Carter") // wink-wink
        failChance += 10;
      return Std.int(100 - failChance);
    }


// lower investigator willpower
  public function lowerWillpower(pwr)
    {
      if (!hasInvestigator || adeptsUsed >= adepts || pwr == 3 ||
          power[pwr] < Game.willPowerCost || investigator.isHidden)
        return;

      power[pwr] -= Game.willPowerCost;
      adeptsUsed++;

      // chance of failure
      if (Std.random(100) > getLowerWillChance())
        {
          if (!isAI)
            {
              ui.msg("You have failed to shatter the will of the investigator.");
              ui.updateStatus();
            }
          return;
        }

      investigator.lowerWillpower(1);
      if (!isAI)
        ui.updateStatus();
    }


// remove investigator for this cult
  public function killInvestigator()
    {
      investigator = null;
      hasInvestigator = false;
      investigatorTimeout = 3;

      game.failSectTasks(); // fail all tasks for that investigator

      if (!isAI)
        game.tutorial.play('investigatorDead');
    }


// convert resources
  public function convert(from: Int, to: Int)
    {
      if (power[from] < Game.powerConversionCost[from])
        {
//          if (!isAI)
//            ui.msg("Not enough " + Game.powerNames[from]);
          return;
        }

      power[from] -= Game.powerConversionCost[from];
      power[to] += 1;
      if (!isAI)
        ui.updateStatus();
    }


// cult can upgrade?
  public function canUpgrade(level: Int): Bool
    {
      if (game.isFinished)
        return false;
      if (level < 2)
        {
          // base
          var ok = (getNumFollowers(level) >= Game.upgradeCost &&
            virgins >= level + 1);
          if (!ok)
            return false;

          // flags
          if (game.flags.artifacts)
            return artifacts.canUpgrade(level);

          return true;
        }
      // final ritual
      else return
        (priests >= Static.rituals['summoning'].priests &&
         virgins >= game.difficulty.numSummonVirgins &&
         !isRitual);
    }


// cult can start this ritual?
  public function canStartRitual(id: String): Bool
    {
      if (game.isFinished)
        return false;
      var info = Static.rituals[id];
      if (isRitual || priests < info.priests || virgins < info.virgins)
        return false;

      // all origins are known
      if (id == 'unveiling')
        {
          for (c in game.cults)
            if (c.origin != null && !c.origin.isKnown[this.id])
              return true;
          return false;
        }

      return true;
    }


// start ritual by id
  public function startRitual(id: String)
    {
      if (!canStartRitual(id))
        return;

      // player is already in ritual
      if (isRitual)
        {
          ui.alert("You must first finish the current ritual before starting another.");
          return;
        }

      var info = Static.rituals[id];
      virgins -= info.virgins;
      ritual = info;
      ritualPoints = getMaxRitualPoints();
      isRitual = true;
      ui.log2(this, fullName + " has started the " + ritual.name + ".",
        { symbol: 'R' });
      if (!isAI)
        ui.updateStatus();
    }


// upgrade nodes (fupgr)
  public function upgrade(level)
    {
      // cannot upgrade
      if (!canUpgrade(level))
        return;

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
              ui.msg('You have failed the ritual to gain ' +
                (level == 0 ? 'an adept.' : 'a priest.'));
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

      // find a node with maximum amount of links
      if (!ok)
        {
          upNode = findMostLinkedNode(level);
          if (upNode != null)
            {
              upNode.upgrade();
              ok = true;
            }
        }
      if (!ok)
        {
          trace('BUG: Cannot upgrade. No nodes found.');
          return;
        }

      // expansions
      if (game.flags.artifacts && level == 1)
        artifacts.onUpgrade(upNode);

      if (!isAI)
        ui.updateStatus();

      // notify player
      if (this != game.player && priests >= 2)
        ui.log2(this, fullName + " has " + priests + " priests. Be careful.");

      // cult un-paralyzed with priests
      if (isParalyzed && priests >= 1)
        {
          unParalyze();
          ui.log2(this, fullName + " has gained a priest and is no longer paralyzed.");
        }

      ui.map.paint();

      // tutorial hooks
      if (!isAI)
        {
          if (adepts >= 1)
            game.tutorial.play('gainAdept');
          if (adepts >= 3)
            game.tutorial.play('gain3Adepts');
          if (priests >= 1)
            game.tutorial.play('gainPriest');
        }
    }


// find most linked node for this cult
  function findMostLinkedNode(?level: Int, ?noSects: Bool): Node
    {
      var node = null;
      var nlinks = -1;
      if (level != null)
        {
          for (n in nodes)
            {
              // no sects
              if (noSects && n.sect != null)
                continue;

              // count links owned by that cult
              var cnt = 0;
              for (l in n.links)
                if (l.owner == this)
                  cnt++;

              if (n.level == level && cnt > nlinks)
                {
                  node = n;
                  nlinks = cnt;
                }
            }
        }
      else
        for (n in nodes)
          {
            // no sects
            if (noSects && n.sect != null)
              continue;

            // count links owned by that cult
            var cnt = 0;
            for (l in n.links)
              if (l.owner == this)
                cnt++;

            if (cnt > nlinks)
              {
                node = n;
                nlinks = cnt;
              }
          }
      return node;
    }


// unparalyze cult
  function unParalyze()
    {
      // get most protected with links node
      var node = findMostLinkedNode();

      // make it a temp generator
      node.makeGenerator();
      node.isTempGenerator = true;

      // unparalyze cult
      isParalyzed = false;
      paralyzedTurns = 0;
      origin = node;
    }


// chance of gaining investigator
  public function getInvestigatorChance(): Int
    {
      // chance depends on size
      var x = (20 * priests + 5 * adepts + 0.5 * neophytes) *
        difficulty.investigatorChance * // difficulty mod
        (100.0 + awareness) / 100.0; // awareness mod
      // on very low awareness we halve it
      if (awareness <= 5)
        x /= 2.0;
      return Std.int(x);
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

      virgins -= game.difficulty.numSummonVirgins;
      isRitual = true;
      for (c in game.cults)
        isInfoKnown[c.id] = true;
      ritual = Static.rituals['summoning'];
      ritualPoints = getMaxRitualPoints();

      // every cult starts war with this one
      for (p in game.cults)
        if (p != this && !p.isDead)
          {
            p.wars[id] = true;
            wars[p.id] = true;
          }

      ui.alert(fullName + " has started the " + ritual.name + ".<br><br>" +
        info.summonStart, {
          w: 700,
          h: 400,
        });
      ui.log2(this, fullName + " has started the " + ritual.name + ".",
        { symbol: 'R' });
      if (!isAI)
        ui.updateStatus();
      if (isAI)
        game.tutorial.play('enemyFinalRitual');
    }


// finish a ritual
  function ritualFinish()
    {
      if (ritual.id == "summoning")
        summonFinish();
      else if (ritual.id == "unveiling")
        {
          ui.log2(this, fullName + ' has finished the ' + ritual.name + '.',
            { symbol: 'R' });
          unveilingFinish();
        }

      isRitual = false;
    }


// finish unveiling
  function unveilingFinish()
    {
      if (!isAI)
        ui.alert(fullName + ' has finished the ' + ritual.name +
          '. All cult origins are revealed.',
          { h: 130 });

      for (c in game.cults)
        if (c.origin != null)
          {
            c.origin.setVisible(this, true);
            c.origin.isKnown[this.id] = true;
          }
      ui.map.paint();
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

          ui.alert(fullName +
            " has failed to perform the " + Static.rituals['summoning'].name + ".<br><br>" +
            info.summonFail, { h: 380 });
          if (!isAI)
            {
              var msg =
                "<div style='text-size: 20px'><b>FINAL RITUAL FAILED</b></div><br>" +
                "The stars were not properly aligned. The high priest goes insane.";
              ui.alert(msg);
              ui.log2(this, fullName + " has failed to perform the " +
                Static.rituals['summoning'].name + ".",
              { symbol: 'R' });
              ui.updateStatus();
            }
          else
            {
              ui.log2(this, fullName + " has failed to perform the " +
                Static.rituals['summoning'].name + ".",
                { symbol: 'R' });
            }
          return;
        }

      ui.finish(this, "summon");
      ui.log2(this, fullName + " has completed the " +
        Static.rituals['summoning'].name + ". Game over.");
    }


// start new turn for this cult (fturn) - gain resources, finish rituals, etc
  public function turn()
    {
      // un-paralyzed after 3 turns even if no priests available
      if (isParalyzed && paralyzedTurns > 3)
        {
          unParalyze();
          var text = fullName + " has gained an origin and is no longer paralyzed.";
          ui.log2(this, text);
          if (!isAI)
            ui.alert(text,
              { h: UI.getVarInt('--alert-window-height-2lines') });
        }

      // if a cult has any adepts, each turn it has a
      // chance of an investigator finding out about it
      if ((priests > 0 || adepts > 0) &&
          !hasInvestigator &&
          100 * Math.random() < getInvestigatorChance() &&
          investigatorTimeout == 0)
        {
          hasInvestigator = true;
          ui.log2(this, "An investigator has found out about " + fullName + ".",
            {
              important: !this.isAI,
              symbol: 'I'
            });
          investigator = new Investigator(this, ui, game);

          if (!isAI)
            ui.updateStatus();

          // tutorial
          if (!isAI)
            game.tutorial.play('investigator');
        }

      if (investigatorTimeout > 0)
        investigatorTimeout--;

      // finish a ritual if there is one
      if (isRitual)
        {
          ritualPoints -= getRitualPoints();
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
          for (i in 0...Game.numFullPowers)
            {
              // failure chance
              if (100 * Math.random() < getResourceChance())
                power[i] += node.powerGenerated[i];
              powerMod[i] += node.powerGenerated[i];
            }

      // neophytes bring in some virgins
      var value = Std.random(maxVirgins() + 1);
      virgins += value;
      adeptsUsed = 0;

      // investigator acts
      if (hasInvestigator)
        investigator.turn();

      for (s in sects) // sect tasks
        s.turn();

      if (isParalyzed) // count paralyzed state time
        paralyzedTurns++;

      createSects(); // create new sects

      // run sect advisor
      if (options.getBool('sectAdvisor'))
        game.sectAdvisor.run(this);

      // expansions
      if (game.flags.artifacts && !isAI)
        artifacts.turn();

      // recalculate base awareness
      calcBaseAwareness();
    }

// recalculate base awareness
  function calcBaseAwareness()
    {
      // DEVOTED: bonus to mod
      awarenessMod = 0;
      for (s in sects)
        if (s.isDevoted)
          awarenessMod += Const.devotedAwarenessBonus[s.level];
    }

// create new sects
  function createSects()
    {
      if (isAI) return;

      while (sects.length < getMaxSects())
        {
          var node = findMostLinkedNode(null, true);
          createSect(node);
        }
//      ui.map.paint();
    }


  public function maxVirgins(): Int
    {
      var x = Std.int(neophytes / 4 - 0.5);
      if (x < 0)
        return 0;
      return x;
    }


// can this player activate this node?
  public function canActivate(node: Node): Bool
    {
      for (i in 0...Game.numFullPowers)
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

      // check for adjacent nodes of this cult
      var ok = false;
      for (l in node.links)
        if (l.owner == this)
          {
            ok = true;
            break;
          }
      if (!ok)
        {
          if (!isAI)
            ui.alert("Must have an adjacent node to activate.");
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
                ui.alert("Generator has " + cnt + " links.");
              return "hasLinks";
            }
        }

      // check for power
      for (i in 0...Game.numFullPowers)
        if (power[i] < node.power[i])
          {
            if (!isAI)
              ui.alert("Not enough resources of needed type.");

            return "notEnoughPower";
          }

      // subtract power
      for (i in 0...Game.numFullPowers)
        power[i] = power[i] - node.power[i];

      // expansion nodes
      if (node.type != 'person')
        {
          if (isAI)
            {
              trace('BUG: AI activated ' + node.type + ' node.');
              return '';
            }
          if (node.type == 'artifact')
            return game.artifacts.activate(this, cast node);
        }

      // failure chance
      if (100 * Math.random() > getGainChance(node))
        {
          if (!isAI)
            {
              ui.msg("Could not gain a follower.");
              ui.updateStatus();
            }
          return "failure";
        }

      // lose sect
      if (node.sect != null)
        node.owner.removeSect(node, 'attack');

      // on gaining enemy node lite regen it
      if (node.owner != null)
        node.generateLite();
      node.setOwner(this); // set new owner on the node
      if (!isAI)
        ui.map.showTooltip(node);

      // remove temp generator state
      if (node.isTempGenerator)
        {
          node.setGenerator(false);
          node.isTempGenerator = false;
        }

      // check for victory
      checkVictory();

      // set highlight
      for (c in game.cults)
        if (c != this && node.isVisible(c))
          c.highlightNode(node);

      return "ok";
    }


// declare war to a cult
  public function declareWar(cult: Cult)
    {
      if (cult.wars[id])
        return;

      cult.wars[id] = true;
      wars[cult.id] = true;

      // log messages
      var text = fullName + " has started a war against " + cult.fullName + ".";
      var m: LogPanelMessage = {
        id: -1,
        old: false,
        type: 'cults',
        text: text,
        obj: { c1: this, c2: cult },
        turn: game.turns + 1,
        params: {}
      };
      for (c in game.cults)
        if (this.isInfoKnown[c.id] || cult.isInfoKnown[c.id] ||
            this.isDiscovered[c.id] || cult.isDiscovered[c.id])
          {
            c.log(text);
            c.logPanel(m);
          }

      if (!cult.isAI)
        ui.alert(text,
          { h: UI.getVarInt('--alert-window-height-2lines') });
    }


// make peace to a cult
  public function makePeace(cult: Cult)
    {
      if (!cult.wars[id])
        return;

      cult.wars[id] = false;
      wars[cult.id] = false;

      // log messages
      var text = fullName + " has made peace with " + cult.fullName + ".";
      var m: LogPanelMessage = {
        id: -1,
        old: false,
        type: 'cults',
        text: text,
        obj: { c1: this, c2: cult },
        turn: game.turns + 1,
        params: {}
      };
      for (c in game.cults)
        if (this.isInfoKnown[c.id] || cult.isInfoKnown[c.id] ||
            this.isDiscovered[c.id] || cult.isDiscovered[c.id])
          {
            c.log(text);
            c.logPanel(m);
          }
    }


// lose node to new owner (who is null in the case of losing)
  public function loseNode(node: Node, ?cult: Cult = null)
    {
      // raise public awareness
      awareness++;
      if (!isAI)
        ui.updateStatus();

      // expansions
      if (game.flags.artifacts)
        artifacts.onLose(node);

      // declare war
      if (cult != null && nodes.length > 0)
        cult.declareWar(this);

      // converting the origin
      if (origin == node)
        loseOrigin(cult);

      node.update();

      // check for death
      checkDeath();
    }


// lose origin
  public function loseOrigin(cult: Cult)
    {
      if (nodes.length > 0)
        ui.log2(this, fullName + " has lost its Origin.");

      // stop a ritual
      if (isRitual)
        {
          isRitual = false;
          ui.log2(this, "The execution of " + ritual.name +
            " has been stopped.", { symbol: 'X' });

          game.failSectTasks(); // fail all appropriate sect tasks
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
          if (nodes.length > 0)
            ui.log2(this, "Destroying the origin of " + fullName +
              " has left it completely paralyzed.", { symbol: 'X' });
          isParalyzed = true;

          if (hasInvestigator) // remove investigator
            {
              killInvestigator();
              if (nodes.length > 0)
                ui.log2(this, "The investigator of the " + fullName +
                  " has disappeared thinking the cult is finished.",
                  { symbol: 'I' });
            }

          if (!isAI)
            game.tutorial.play('cultParalyzed');
        }
      else
        {
          ui.log2(this, "Another priest becomes the Origin of " +
            fullName + ".");
          origin.update();
          ui.map.paint();
        }

      // attacker can gain cult stash
      if (cult != null)
        cult.gainStash(this);
    }


// attacker can gain cult stash on conquering origin
// since AI dont actually stash resources, we generate stash based on cult size
  function gainStash(from: Cult)
    {
      if (Std.random(100) > 30)
        return;

      var text = fullName +
        ' has acquired a stash of resources with the origin of ' +
        from.fullName;
      text += (isAI ? '.' : ': ');
      var sum = 0;
      for (i in 0...3)
        sum += (i + 1) * getNumFollowers(i);
      var val = Std.int(sum / 4);
      if (val == 0)
        return;
      var id = Std.random(3);
      if (Std.random(100) < 25)
        id = 3;
      if (!isAI)
        text += val + ' ' + UI.powerName(id) + '.';
      power[id] += val;
      ui.log2(from, text);
      if (!isAI)
        {
          ui.alert(text,
            { h: UI.getVarInt('--alert-window-height-2lines') });
          ui.status.update();
        }
    }


// check for victory for this cult
  public function checkVictory()
    {
      if (isDead || isParalyzed)
        return;

      // check for finish
      var allDead = true, allParalyzed = true;
      for (p in game.cults)
        {
          if (p == this)
            continue;
          if (!p.isDead)
            allDead = false;
          if (!p.isParalyzed)
            allParalyzed = false;
        }
      // all cults dead, game over
      if (allDead)
        ui.finish(this, "conquer");

      // all cults paralyzed, game over if no flag is set
      else if (allParalyzed && !game.flags.noBlitz)
        ui.finish(this, "conquer");
    }


// check if cult still has any nodes (fdea)
  public function checkDeath()
    {
      if (this.nodes.length > 0 || isDead)
        return;

      ui.log2(this, fullName + " has been destroyed, forgotten by time.",
        { symbol: 'X' });
      ui.map.paint();

      isDead = true;

      // clean wars
      for (c in game.cults)
        c.wars[id] = false;
      for (i in 0...wars.length)
        wars[i] = false;
      hasInvestigator = false;
      investigator = null;

      // clean tasks on that cult
      for (c in game.cults)
        for (s in c.sects)
          if (s.task != null &&
              s.task.type == 'cult' &&
              s.taskTarget == this)
            s.clearTask();

      // player cult is dead
      if (!isAI)
        {
          // check for any alive player cults
          var humansAlive = false;
          for (c in game.cults)
            if (!c.isAI && !c.isDead)
              {
                humansAlive = true;
                break;
              }

          if (!humansAlive)
            ui.finish(this,
              game.difficulty.numPlayers == 1 ? "wiped" : "multiplayerFinish");
        }
      else checkVictory();
    }


// discover another cult
  public function discover(cult: Cult)
    {
      cult.isDiscovered[this.id] = true;
      this.isDiscovered[cult.id] = true;
      ui.log2(this, fullName + " has discovered the existence of " + cult.fullName + ".");
      if (!isAI)
        {
          if (sects.length > 0)
            {
              game.tutorial.play('discoverCult');
              game.tutorial.disable('discoverCultNoSects');
            }
          else
            {
              game.tutorial.play('discoverCultNoSects');
              game.tutorial.disable('discoverCult');
            }
        }
    }


// add message to log and log panel
  public function logAndPanel(s: String, ?params:Dynamic = null)
    {
      log(s);
      logPanelShort(s, params);
    }


// add message to log
  public function log(s: String)
    {
      if (isAI)
        return;

      var s2 = ui.logWindow.getRenderedMessage(s);
      logMessages += s2;
      logMessagesTurn += s2;
      ui.logConsole.update();
    }


// add message to log panel (short)
  public inline function logPanelShort(s: String, ?params:Dynamic = null)
    {
      logPanel({
        id: -1,
        old: false,
        type: 'cult',
        text: s,
        obj: this,
        turn: game.turns + 1,
        params: (params == null ? {} : params)
      });
    }


// add message to log panel
  public function logPanel(m: LogPanelMessage)
    {
      // clear log if too many items
      if (logPanelMessages.length >= 24)
        logPanelMessages.clear();

      logPanelMessages.add(m);
      ui.logPanel.paint();
    }


// highlight a node for this cult
  public function highlightNode(n: Node)
    {
      if (isAI)
        return;
      highlightedNodes.add(n);
    }


// getter for virgins
  function get_virgins()
    {
      return power[3];
    }


// setter for virgins
  function set_virgins(v)
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
  function get_neophytes()
    {
      return getNumFollowers(0);
    }


  function get_adepts()
    {
      return getNumFollowers(1);
    }


  function get_priests()
    {
      return getNumFollowers(2);
    }

  function get_awareness()
    {
      return awarenessBase + awarenessMod;
    }

  function get_fullName(): String
    {
      return UI.cultName(id, info);
    }
}


// log panel message type

typedef LogPanelMessage =
{
  var id: Int; // message id
  var old: Bool; // message old?
  var type: String; // message type (cult, cults, etc)
  var text: String; // message text
  var obj: Dynamic; // message object (origin etc)
  var turn: Int; // turn on which message appeared
  var params: Dynamic; // additional message parameters
};

