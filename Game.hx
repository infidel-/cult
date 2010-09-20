// game class for Cult


class Game
{
  var ui: UI;

  // cults list and link to player
  public var cults: Array<Cult>;
  public var player: Cult;

  public var turns: Int; // turns passed
  public var isFinished: Bool; // game finished?
  public var difficultyLevel: Int; // game difficulty (0: easy, 1: normal, 2: hard)
  public var difficulty: Dynamic; // link to difficulty info

  // index of the last node/cult (for id generation)
  var lastNodeIndex: Int;
  var lastCultID: Int;

  // nodes and lines arrays
  public var nodes: Array<Node>;
  public var lines: List<Line>;


  public static var powerNames: Array<String> =
    [ "Intimidation", "Persuasion", "Bribery", "Virgins" ];
  public static var powerShortNames: Array<String> =
    [ "I", "P", "B", "V" ];
  public static var followerNames: Array<String> =
    [ "Neophyte", "Adept", "Priest" ];
  public static var powerConversionCost: Array<Int> = [2, 2, 2, 1];
  public static var willPowerCost: Int = 2;
  public static var cultColors: Array<String> =
    [ "#00B400", "#2F43FD", "#B400AE", "#B4AE00" ];

  public static var version = "v4pre0"; // game version
  public static var followerLevels = 3; // number of follower levels
  public static var numPowers = 3; // number of basic powers
  public static var numCults = 4; // number of cults in game
  public static var numSummonVirgins = 9; // number of virgins needed for summoning
  static var nodesCount = 100; // amount of nodes on map
  public static var upgradeCost = 3; // cost to upgrade follower
  public static var isDebug = true; // debug mode (debug button + extended info window)


// constructor
  function new()
    {
      isFinished = true;
	  this.turns = 0;
	  ui = new UI(this);
	  ui.init();
      ui.mainMenu.show(); // needs to be moved into ui
    }


// restart a game
  public function restart(newDifficulty: Int)
    {
      // show starting message
      if (ui.config.get('hasPlayed') == null)
        ui.alert("Welcome.<br><br>If this is your first time playing, please take the time to " +
          "read the <a target=_blank href='http://code.google.com/p/cult/wiki/Manual_" + version +
          "'>Manual</a> " +
          "before playing. We are not responsible for horrific deaths caused by not reading the " +
          "Manual. You have been warned.");
      ui.config.set('hasPlayed', '1');

      ui.track("startGame diff:" + newDifficulty);
      startTimer("restart");

      difficultyLevel = newDifficulty;
      difficulty = Static.difficulty[difficultyLevel];
      this.isFinished = false;
	  this.turns = 0;
      ui.clearMap();
      ui.clearLog();
      ui.log("Game started.", false);

      this.lines = new List<Line>();
      this.nodes = new Array<Node>();
      this.cults = new Array<Cult>();
      this.lastCultID = 0;

      // clear cults
      var cultInfo = new Array<Int>();
      for (i in 0...numCults)
        {
          var p = null;
          var id = this.lastCultID++;
          var infoID = 0;
          if (i > 0)
            while (true)
              {
                infoID = 1 + Std.int(Math.random() * (Static.cults.length - 1));
                var ok = true;
                for (ii in cultInfo)
                  if (infoID == ii)
                    {
                      ok = false;
                      break;
                    }

                if (ok) break;
              }

          if (i == 0)
            p = new Cult(this, ui, id, infoID);
          else p = new AI(this, ui, id, infoID);
          cults.push(p);
          cultInfo.push(infoID);
        }
      player = cults[0];
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

      updateLinks(); // update adjacent node links

      // choose and setup starting nodes
      for (p in cults)
	    p.setOrigin();

      ui.updateStatus();
      endTimer("restart"); 
    }


// update adjacent node links
  function updateLinks()
    {
      // fill adjacent node lists
      for (n in nodes)
        for (n2 in nodes)
          if (n != n2 && n.distance(n2) < UI.nodeVisibility)
            {
              n.links.remove(n2);
              n.links.add(n2);
            }
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
	  var index: Int = Math.round((numPowers - 1) * Math.random());
	  node.power[index] = 1;

      if (mapVisible)
        node.setVisible(player, true);

      node.update();
      nodes.push(node);
    }


// load game (flo)
  public function load(save: Dynamic)
    {
      // clear everything
      this.isFinished = false;
	  this.turns = 0;
      ui.clearMap();
      ui.clearLog();

      this.lines = new List<Line>();
      this.nodes = new Array<Node>();
      this.cults = new Array<Cult>();

      // load cults
      var savecults:Array<Dynamic> = save.cults;
      for (c in savecults)
        {
          var cult = null;
          if (c.ia == 0)
            {
              cult = new Cult(this, ui, c.id, c.iid);
              player = cult;
            }
          else cult = new AI(this, ui, c.id, c.iid);
          cult.load(c);
          cults.push(cult);
        }

      //trace(obj);

      // load nodes
      var savenodes:Array<Dynamic> = save.nodes;
//	  this.lastNodeIndex = 0;
      for (n in savenodes)
        {
          var node = new Node(this, ui, n.x, n.y, n.id);
          node.load(n);
          nodes.push(node);
        }
      updateLinks(); // update adjacent node links

      for (c in savecults) // misc cult info
        for (cc in cults)
          if (c.id == cc.id)
            {
              var n = getNode(c.or); // cult origin
              if (n != null)
                cc.origin = n;
            }

      for (n in nodes)
        n.update();

      // load lines
      var savelines:Array<Dynamic> = save.lines;
      for (l in savelines)
        {
          var startNode = getNode(l[0]);
          var endNode = getNode(l[1]);
          var cult = cults[l[2]];
          var line = Line.paint(ui.map, cult, startNode, endNode);
          if (l[3] == 1)
            line.setVisible(true);
          lines.add(line);
        }

      difficultyLevel = save.dif;
      difficulty = Static.difficulty[difficultyLevel];
      turns = save.turns;

      ui.updateStatus();
    }


// save game (fsa)
  public function save(): Dynamic
    {
      // TODO: save log? - possibly last 10 records
      var save: Dynamic = {};
      save.nodes = new Array<Dynamic>();
      for (n in nodes)
        save.nodes.push(n.save());
      save.cults = new Array<Dynamic>();
      for (c in cults)
        save.cults.push(c.save());
      save.lines = new Array<Dynamic>();
      for (l in lines) // pack lines into int arrays
        save.lines.push([ l.startNode.id, l.endNode.id, l.owner.id,
          (l.isVisible ? 1 : 0) ]);

      save.turns = turns;
      save.dif = difficultyLevel;
      return save;
    }


// get node by id
  function getNode(id: Int): Node
    {
      for (n in nodes)
        if (n.id == id)
          return n;
      return null;
    }


// on clicking end turn button
  public function endTurn()
    {
      // clear node highlight
      for (n in nodes)
        if (n.isHighlighted)
          n.setHighlighted(false);

      // ensure player goes last
      for (c in cults)
        if (c.isAI && !c.isDead)
          {
            c.turn();

            // game could be finished on summoning success
            if (isFinished)
              return;

            startTimer("ai " + c.name);
            untyped c.aiTurn();
            endTimer("ai " + c.name);
          }
      player.turn();

	  turns++;
	  ui.updateStatus();
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


// =========================================

  // these are changed from debug menu
  public static var debugTime = false; // show execution time of various parts
  public static var debugVis = false; // show node visibility for all cults
  public static var debugNear = false; // show "nearness" of all nodes
  public static var debugAI = false; // show AI debug messages
  public static var mapVisible = false; // all map is visible at start
}
