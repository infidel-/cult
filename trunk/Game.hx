// game class for Cult

import js.Lib;



class Game
{
  var ui: UI;

  // turns passed
  public var turns: Int;

  // virgins
  public var virgins: Int;

  // index of the last node (for id generation)
  var lastNodeIndex: Int;

  // player power reserve
  public var power: Array<Int>; // intimidation, persuasion, bribe, worship
  
  // power that will be generated next turn (cache variable)
  public var powerMod: Array<Int>;

  // starting node
  var startNode: Node;

  // nodes and lines arrays
  public var nodes: Array<Node>;
  public var lines: Array<Line>;


  public static var powerNames: Array<String> =
    [ "Intimidation", "Persuasion", "Bribery", "Worship" ];
  public static var powerShortNames: Array<String> =
    [ "I", "P", "B", "W" ];
  public static var powerColors: Array<String> =
    [ "#ff0000", "#00ffff", "#00ff00", "#ffff00" ];
  public static var followerNames: Array<String> =
    [ "Neophyte", "Adept", "Priest" ];

  public static var numPowers = 3;
  public static var numSummonVirgins = 9;
  static var nodesCount = 70;
  static var conversionCost = 3;
  public static var upgradeCost = 3;
  public static var isDebug = true;


// constructor
  function new()
    {
	  ui = new UI(this);
	  ui.init();
      restart();
    }


// upgrade nodes
  public function upgrade(level)
    {
      // summon
      if (level == 2)
        {
          summon();
          return;
        }

      if (virgins < level + 1)
        {
          ui.msg("Not enough virgins");
          return;
        }

      virgins -= level + 1;

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
      if (virgins < numSummonVirgins)
        {
          ui.msg("Not enough virgins");
          return;
        }

      virgins -= numSummonVirgins;

      // 25% chance of failure
      if (Math.random() < 0.25)
        {
          // 1 priest goes totally insane and has to be replaced with neophyte
          for (n in nodes)
            if (n.isOwned && n.level == 2)
              {
                n.level = 0;
                n.update();
                break;
              }

          ui.alert("The stars were not right. The high priest goes insane.");
          return;
        }

      ui.finish(1);
    }


// convert resources
  public function convert(from, to)
    {
	  if (power[from] < conversionCost)
	    {
	      ui.msg("Not enough " + powerNames[from]);
		  return;
		}
	
	  power[from] -= conversionCost;
	  power[to] += 1;
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
	  startNode.setGenerator(true);

	  startNode.marker.style.visibility = 'visible';
      updateVisibility(startNode);
	}


// on clicking end turn button
  public function endTurn()
    {
	  // give player power and recalculate power mod cache
	  powerMod = [0, 0, 0];
      var cntNeophytes = 0;
	  for (node in nodes)
	    if (node.isOwned)
          {
            if (node.level == 0)
              cntNeophytes++;

            if (node.isGenerator)
		      for (i in 0...numPowers)
		        {
		          power[i] += Math.round(node.powerGenerated[i]);
			      powerMod[i] += Math.round(node.powerGenerated[i]);
			    }
          }

      // neophytes bring in some virgins
      var value = Std.int(Math.random() * cntNeophytes / 3);
//      trace(value + " by " + cntNeophytes);
      virgins += value;

	  turns++;
	  ui.updateStatus();
	}


// update visibility area around node
  function updateVisibility(node: Dynamic)
    {
      for (n in nodes)
        if (node.distance(n) < UI.nodeVisibility)
	  n.marker.style.visibility = 'visible';
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

	  if (node.isGenerator)
	    for (i in 0...numPowers)
		  powerMod[i] += Math.round(node.powerGenerated[i]);
      node.setOwned(true);
      updateVisibility(node);
	  ui.updateStatus();
//      ui.updateMap();
//      new JQuery('#map *').tooltip({ delay: 0 });

	  // create lines between this node and adjacent ones
      for (n in nodes)
        if (n.isOwned && node != n && node.distance(n) < UI.nodeVisibility + 10)
          lines.push(Line.paint(ui.map, n, node));

      // check for game end
//      checkFinish();
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
      var node = new Node(ui, x, y, lastNodeIndex++);
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
      this.power = [0, 0, 0];
      this.powerMod = [0, 0, 0];
	  this.turns = 0;
      this.virgins = 0;
	  this.lastNodeIndex = 0;
      nodes = new Array<Node>();

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

      ui.updateMap();
      ui.updateStatus();
    }


// check for game end
/*
  function checkFinish()
    {
      // count player nodes
      var cnt = 0;
      for (n in nodes)
        if (n.isOwned)
          cnt++;

      if (cnt < nodes.length)
        return;

      // player won
      ui.finish(1);
    }
*/

// main function
  static var inst: Game;
  static function main()
    {
      inst = new Game();
    }
}
