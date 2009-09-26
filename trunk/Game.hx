// game class for Cult
// TODO: ai wont finish by conquering all

import js.Lib;



class Game
{
  var ui: UI;

  // players list and link to player
  public var players: Array<Player>;
  public var player: Player;

  // turns passed
  public var turns: Int;

  // index of the last node/player (for id generation)
  var lastNodeIndex: Int;
  var lastPlayerID: Int;

  // nodes and lines arrays
  public var nodes: Array<Node>;
  public var lines: List<Line>;


  public static var powerNames: Array<String> =
    [ "Intimidation", "Persuasion", "Bribery", "Virgins" ];
  public static var powerShortNames: Array<String> =
    [ "I", "P", "B", "V" ];
  public static var powerColors: Array<String> =
    [ "#ff0000", "#00ffff", "#00ff00", "#ffff00" ];
  public static var followerNames: Array<String> =
    [ "Neophyte", "Adept", "Priest" ];
  public static var powerConversionCost: Array<Int> = [2, 2, 2, 1];
  public static var lineColors: Array<String> =
    [ "#55dd55", "#2727D7", "#E052CA", "#D8E151" ];
  public static var nodeColors: Array<String> =
    [ "#005500", "#010955", "#560053", "#565300" ];
  public static var playerColors: Array<String> =
    [ "#00B400", "#2F43FD", "#B400AE", "#B4AE00" ];
 
  public static var followerLevels = 3;
  public static var numPowers = 3;
  public static var numPlayers = 4;
  public static var numSummonVirgins = 9;
  static var nodesCount = 100;
  public static var upgradeCost = 3;
  public static var isDebug = true;
  public static var debugTime = false;
  public static var debugVis = false;
  public static var debugNear = false;
  public static var debugAI = true;


// constructor
  function new()
    {
	  ui = new UI(this);
	  ui.init();
      restart();
      ui.updateStatus();
    }


// restart a game
  public function restart()
    {
      startTimer("restart");
      ui.clearMap();

      this.lines = new List<Line>();
      this.nodes = new Array<Node>();

      this.players = new Array<Player>();
      this.lastPlayerID = 0;

      // clear players
      for (i in 0...numPlayers)
        {
          var p = null;
          if (i == 0)
            p = new Player(this, ui, this.lastPlayerID++);
          else p = new AI(this, ui, this.lastPlayerID++);
          players.push(p);
        }
      player = players[0];
	  this.turns = 0;
	  this.lastNodeIndex = 0;

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

      // fill near lists
      for (n in nodes)
        for (n2 in nodes)
          if (n != n2 && n.distance(n2) < UI.nodeVisibility)
            {
              n.links.remove(n2);
              n.links.add(n2);
            }

      // choose and setup starting nodes
      for (p in players)
	    p.setStartNode();

      ui.updateStatus();
      endTimer("restart"); 
    }


// on clicking end turn button
  public function endTurn()
    {
      // ensure player goes last
      for (p in players)
        if (p.isAI && !p.isDead)
          {
            p.turn();
            startTimer("ai");
            untyped p.aiTurn();
            endTimer("ai");
          }
      player.turn();

	  turns++;
	  ui.updateStatus();
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

		  // node
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


// start counting time
  var timerTime: Float;
  public inline function startTimer(name)
    {
      if (debugTime)
        timerTime = Date.now().getTime();
    }


// end counting time and display it
  public inline function endTimer(name)
    {
      if (debugTime)
        trace(name + ": " + (Date.now().getTime() - timerTime) + "ms");
    }


// main function
  static var instance: Game;
  static function main()
    {
      instance = new Game();
    }
}
