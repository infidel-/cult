// game class for Cult

import js.Lib;



class Game
{
  var ui: UI;

  // turns passed
  public var turns: Int;

  // public awareness
  public var awareness(default, setAwareness): Int;

  // index of the last node (for id generation)
  var lastNodeIndex: Int;

  // player power reserve
  public var power: Array<Int>; // intimidation, persuasion, bribe, worship
  
  // power that will be generated next turn (cache variable)
  public var powerMod: Array<Int>;

  // starting node
  public var startNode: Node;

  // nodes and lines arrays
  public var nodes: Array<Node>;
  public var lines: Array<Line>;

  // followers number cache
  public var numFollowers: Array<Int>;

  // how many adepts were used this turn
  public var adeptsUsed: Int;

  public static var powerNames: Array<String> =
    [ "Intimidation", "Persuasion", "Bribery", "Virgins" ];
  public static var powerShortNames: Array<String> =
    [ "I", "P", "B", "V" ];
  public static var powerColors: Array<String> =
    [ "#ff0000", "#00ffff", "#00ff00", "#ffff00" ];
  public static var followerNames: Array<String> =
    [ "Neophyte", "Adept", "Priest" ];
  public static var powerConversionCost: Array<Int> = [2, 2, 2, 1];

  public static var numPowers = 3;
  public static var numSummonVirgins = 9;
  static var nodesCount = 100;
  public static var upgradeCost = 3;
  public static var isDebug = true;


// constructor
  function new()
    {
	  ui = new UI(this);
	  ui.init();
      restart();
      ui.updateStatus();
    }


// upgrade nodes
  public function upgrade(level)
    {
      if ((level == 2 && power[3] < numSummonVirgins) ||
          (level < 2 && power[3] < level + 1))
        {
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
          ui.alert("Ritual failed.");
          ui.updateStatus();
          return;
        }

      awareness += level;
      numFollowers[level]--;
      numFollowers[level + 1]++;

      // find first node of this level and upgrade
      for (n in nodes)
        if (n.isOwned && n.level == level)
          {
            n.upgrade();
            break;
          }
  
      ui.updateStatus();
    }


// summon elder god
  public function summon()
    {
      power[3] -= numSummonVirgins;

      // chance of failure
      if (100 * Math.random() > getUpgradeChance(2))
        {
          // 1 priest goes totally insane and has to be replaced with neophyte
          for (n in nodes)
            if (n.isOwned && n.level == 2)
              {
                n.level = 0;
                n.update();
                numFollowers[2]--;
                break;
              }

          ui.alert("The stars were not right. The high priest goes insane.");
          ui.updateStatus();
          return;
        }

      ui.finish("summon");
    }


// convert resources
  public function convert(from: Int, to: Int)
    {
	  if (power[from] < powerConversionCost[from])
	    {
	      ui.msg("Not enough " + powerNames[from]);
		  return;
		}
	
	  power[from] -= powerConversionCost[from];
	  power[to] += 1;
	  ui.updateStatus();
	}


// setter for awareness
  function setAwareness(v)
    {
      awareness = v;
      for (n in nodes)
        if (n.isVisible && !n.isOwned)
          n.update();
      return v;
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
      ui.updateStatus();
    }


// setup starting node
  function setStartingNode(node)
    {
      startNode = node;
      startNode.setOwned(true);
	  for (i in 0...numPowers)
	    if (startNode.power[i] > 0)
		  {
		    startNode.powerGenerated[i] = 1;
			powerMod[i] += 1;
		  }
      numFollowers[0]++;
	  startNode.setGenerator(true);
      startNode.isVisible = true;
      updateVisibility(startNode);
	}


// on clicking end turn button
  public function endTurn()
    {
	  // give player power and recalculate power mod cache
	  powerMod = [0, 0, 0, 0];
	  for (node in nodes)
	    if (node.isOwned)
          if (node.isGenerator)
		    for (i in 0...numPowers)
		      {
                // failure chance
                if (100 * Math.random() < getResourceChance())
		          power[i] += Math.round(node.powerGenerated[i]);
			    powerMod[i] += Math.round(node.powerGenerated[i]);
			  }

      // neophytes bring in some virgins
      var value = Std.int(Math.random() * (numFollowers[0] / 4 - 0.5));
//      trace(value + " by " + cntNeophytes);
      power[3] += value;

	  turns++;
      adeptsUsed = 0;
	  ui.updateStatus();
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
  public function getGainChance(isGenerator)
    {
      var ch = 0;
      if (!isGenerator)
        ch = 99 - awareness;
      else ch = 99 - awareness * 2;
      if (ch < 1)
        ch = 1;
      return ch;
    }


// update visibility area around node
  function updateVisibility(node: Dynamic)
    {
      for (n in nodes)
        if (node.distance(n) < UI.nodeVisibility)
          n.isVisible = true;
    }


// activate node
  public function activate(node: Dynamic)
    {
	  if (node.isOwned)
		return;

	  // check for power
	  for (i in 0...numPowers)
		if (power[i] < node.power[i])
		  {
			ui.msg("Not enough " + powerNames[i]);
			return;
		  }

	  // subtract power
	  for (i in 0...numPowers)
		power[i] = Math.round(power[i] - node.power[i]);

      // failure chance
      if (100 * Math.random() > getGainChance(node.isGenerator))
        {
          ui.alert("Could not gain a follower.");
          ui.updateStatus();
          return;
        }

	  if (node.isGenerator)
	    for (i in 0...numPowers)
		  powerMod[i] += Math.round(node.powerGenerated[i]);
      node.setOwned(true);
      numFollowers[0]++;
      updateVisibility(node);

      // raise public awareness
      if (node.isGenerator)
        awareness += 2;
      else awareness++;

      ui.updateStatus();

	  // create lines between this node and adjacent ones
      var hasLine = false;
      for (n in nodes)
        if (n.isOwned && node != n &&
            node.distance(n) < UI.nodeVisibility - 10)
          {
            lines.push(Line.paint(ui.map, n, node));
            hasLine = true;
          }

      // no lines were drawn - draw to closest player node 
      if (!hasLine)
        {
          var dist = 10000;
          var nc = null;
          for (n in nodes)
            if (n.isOwned && node != n &&
                node.distance(n) < dist)
              {
                dist = node.distance(n);
                nc = n;
              }

          lines.push(Line.paint(ui.map, nc, node));
        }

      // check for finish
      var cntOwned = 0;
      var cntVisible = 0;
      for (n in nodes)
        {
          if (n.isOwned)
            cntOwned++;
          if (n.isVisible)
            cntVisible++;
        }

      // all visible nodes are owned, player won
      if (cntOwned == cntVisible)
        ui.finish("conquer");
    }


// spawn new node (fsp)
  public function spawnNode()
    {
      // find node position
      var x = 0, y = 0;
      var cnt = 0;
      while (true)
        {
		  x = Math.round(20 + Math.random() * 
		    (UI.mapWidth - UI.markerWidth - 40));
		  y = Math.round(20 + Math.random() * 
		    (UI.mapHeight - UI.markerHeight - 40));

		  cnt++;
		  if (cnt > 100)
		    return;

		  // nodes overlap
		  var ok = 1;
		  for (n in nodes)
	    	if ((x - 30 < n.x && x + UI.markerWidth + 30 > n.x) &&
	        	(y - 30 < n.y && y + UI.markerHeight + 30 > n.y))
		      ok = 0;

		  if (ok == 1)
	    	break;
		}

      // node attributes
      var node = new Node(this, ui, x, y, lastNodeIndex++);
	  node.marker.onclick = ui.onNodeClick;
	  var index: Int = Math.round((numPowers - 1) * Math.random());
	  node.power[index] = 1;

      node.update();
      nodes.push(node);
    }


// restart a game
  public function restart()
    {
      ui.clearMap();

      this.lines = new Array<Line>();
      this.power = [0, 0, 0, 0];
      this.powerMod = [0, 0, 0, 0];
      this.numFollowers = [0, 0, 0];
	  this.turns = 0;
      this.adeptsUsed = 0;
	  this.lastNodeIndex = 0;
      nodes = new Array<Node>();
      this.awareness = 0;

      // spawn nodes
      for (i in 1...(nodesCount + 1))
        spawnNode();

      // make 15% of nodes generators
      var cnt: Int = Std.int(0.15 * nodesCount);
      for (i in 0...cnt)
        {
          var nodeIndex = Math.round((nodesCount - 1) * Math.random());
          var node = nodes[nodeIndex];

          var powerIndex = 0;
          for (ii in 0...numPowers)
            if (node.power[ii] > 0)
              {
                node.power[ii]++;
                powerIndex = ii;
              }

		  // another resource must be generated
		  var ii = -1;
		  while (true)
			{
			  ii = Math.round((numPowers - 1) * Math.random());
			  if (ii != powerIndex)
			    break;
			}
		  node.powerGenerated[ii] = 1;
		  node.setGenerator(true);
        }

      // choose and setup starting node
      var index = Math.round((nodes.length - 1) * Math.random());
	  setStartingNode(nodes[index]);

	  // give initial power from starting node
	  for (i in 0...numPowers)
	    power[i] += Math.round(startNode.powerGenerated[i]);

      ui.updateStatus();
    }


// main function
  static var instance: Game;
  static function main()
    {
      instance = new Game();
    }
}
