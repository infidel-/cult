// game class for Cult

import js.Browser;
import Static;

@:expose
class Game
{
  var ui: UI;
  public var director: Director; // AI director
  public var sectAdvisor: sects.Advisor; // sects advisor

  // cults list and link to player
  public var cults: Array<Cult>;
  public var currentPlayerID: Int; // ID of current player's turn
  public var player: Cult;
  public var tutorial: Tutorial;
  public var highScores: HighScores;
  public var sectTasks: Array<sects.Task>; // available sect tasks

  public var startTS: Float; // ts of game start
  public var turns: Int; // turns passed
  public var isNeverStarted: Bool; // game never started?
  public var isFinished: Bool; // game finished?
  public var isTutorial: Bool; // game is in tutorial mode?
  public var difficultyLevel: Int; // game difficulty (0: easy, 1: normal, 2: hard, -1: custom)
  public var difficulty: DifficultyInfo; // link to difficulty info
  public var flags: Flags; // game flags
  public var flagDefaults: Flags; // game flag defaults
  public var freeQuadrants: Array<Quadrant>; // used during origin location selection
  public var mapQuadrants8x8: Array<Quadrant>; // 8x8 quadrants, used for node generation

  // expansions
  public var artifacts: artifacts.ArtifactManager;

  // index of the last node/cult (for id generation)
  public var lastNodeIndex: Int;
  var lastCultID: Int;

  // nodes and lines arrays
  public var nodes: Array<Node>;
  public var lines: List<Line>;

// constructor
  function new()
    {
      flagDefaults = {
        noBlitz: false,
        devoted: false,
        longRituals: false,

        artifacts: false,
      };
      flags = Reflect.copy(flagDefaults);
      ui = new UI(this);
      highScores = new HighScores(this, ui);
      // apply modern mode difficulty fixes
      if (UI.modernMode)
        for (d in Static.difficulty)
          {
            d.mapWidth = Std.int(d.mapWidth * UI.vars.scaleFactor);
            d.mapHeight = Std.int(d.mapHeight * UI.vars.scaleFactor);
            d.nodeActivationRadius =
              Std.int(d.nodeActivationRadius * UI.vars.scaleFactor);
//            trace(d.nodeActivationRadius);
          }
      artifacts = new artifacts.ArtifactManager(this, ui);

#if mydebug
      isDebug = true;
#end
      isNeverStarted = true;
      isFinished = true;
      isTutorial = false;
      this.turns = 0;
    }


// init game
  public function init()
    {
      ui.init();
      director = new Director(this, ui);
      sectAdvisor = new sects.Advisor(this);
      ui.mainMenu.show(); // needs to be moved into ui

      // fill up tasks array
      sectTasks = new Array<sects.Task>();
      for (cl in sects.Sect.taskClasses)
        {
          var t = Type.createInstance(cl, [ this, ui ]);
          sectTasks.push(t);
        }
    }


// restart a game
  public function restart(?newDif: DifficultyInfo)
    {
      startTS = Sys.time();
      isNeverStarted = false;
      tutorial = new Tutorial(this, ui);

      // show starting message
      if (ui.config.get('hasPlayed') == null)
        ui.alert("Welcome.<br><br>If this is your first time playing, do not hesitate to " +
          "consult the Manual if you have any questions. " +
          "We are not responsible for horrific deaths caused by ignoring the " +
          "Manual. You have been warned.");
#if !electron
      ui.alert('Now available on Steam!<br><br><iframe src="https://store.steampowered.com/widget/1237260/" frameborder="0" style="padding-left:3%" width="95%" height="190"></iframe>', {
        h: 320
      });
#end
      if (isTutorial)
        tutorial.play('start');
      ui.config.set('hasPlayed', '1');

      startTimer("restart");

//      difficultyLevel = newDifficulty;
      if (difficultyLevel >= 0)
        difficulty = Static.difficulty[difficultyLevel];
      else difficulty = newDif; // custom difficulty
      this.isFinished = false;
      this.turns = 0;
      ui.map.initMinimap();
      ui.clearMap();
      ui.clearLog();
      ui.logConsole.resize();

      if (isDebug)
        trace('nodeActivationRadius: ' + difficulty.nodeActivationRadius);

      this.lines = new List<Line>();
      this.nodes = new Array<Node>();
      this.cults = new Array<Cult>();
      this.lastCultID = 0;

      // clear cults
      var cultInfo = new Array<Int>();
      var numPlayersLeft = difficulty.numPlayers;
      for (i in 0...difficulty.numCults)
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

          if (numPlayersLeft > 0)
            {
              p = new Cult(this, ui, id, infoID);

              numPlayersLeft--;
            }
          else p = new AI(this, ui, id, infoID);
          cults.push(p);
          cultInfo.push(infoID);
        }
      player = cults[0];
      currentPlayerID = 0;
      this.lastNodeIndex = 0;

      if (flags.artifacts)
        artifacts.onRestart();

      // spawn nodes
      for (i in 1...(difficulty.nodesCount + 1))
        spawnNode();

      // clear nodes that do not have any links
      var toRemove = new List();
      for (node in nodes)
        {
          var ok = false;
          for (n in nodes)
            if (n != node &&
                n.distance(node) < difficulty.nodeActivationRadius)
              {
                ok = true;
                break;
              }
          if (!ok)
            toRemove.add(node);
        }
      if (isDebug && toRemove.length > 0)
        trace(toRemove.length + ' nodes removed');
      for (n in toRemove)
        nodes.remove(n);

      // make 15% of nodes generators
      // split map into small quadrants for each generator
      // and pick random node in that quadrant
      trace('spawning generators...');
      var dx = Std.int(difficulty.mapWidth /
        Math.sqrt(0.15 * difficulty.nodesCount));
      var dy = Std.int(difficulty.mapHeight /
        Math.sqrt(0.15 * difficulty.nodesCount));
      var xx = 0, yy = 0;
      var cnt = 0;
      while (yy < difficulty.mapHeight)
        {
          xx = 0;
          while (xx < difficulty.mapWidth)
            {
              // form a temp list of nodes in that quadrant
              var tmp = [];
              for (n in nodes)
                if (n.x > xx && n.x < xx + dx &&
                    n.y > yy && n.y < yy + dy)
                  tmp.push(n);
              if (tmp.length > 0)
                {
                  var node = tmp[Std.random(tmp.length)];
                  node.makeGenerator();
                  cnt++;
                }
              else trace('no generator for ' +
                xx + ',' + yy + ' -> ' + (xx + dx) + ',' + (yy + dy));
              xx += dx;
            }
          yy += dy;
        }
      trace('done, ' + cnt + ' generators.');

      updateLinks(); // update adjacent node links

      // choose and setup starting nodes
      // init quadrants
      freeQuadrants = Static.getQuadrants(difficulty, 2);
      mapQuadrants8x8 = Static.getQuadrants(difficulty, 8);
      for (c in cults)
        c.setOrigin();

      // update player options from config
      if (difficulty.numPlayers == 1)
        for (info in OptionsMenu.elementInfo)
          {
            var val: Dynamic = null;
            if (info.type == 'bool')
              val = ui.config.getBool(info.name);
            else if (info.type == 'int')
              val = ui.config.getInt(info.name);

            player.options.set(info.name, val);
          }

//      ui.map.paint();
      ui.map.center(player.origin.x, player.origin.y);
      ui.updateStatus();

      for (c in cults)
        c.log("Game started.");
      endTimer("restart");
    }


// update adjacent node links
  function updateLinks()
    {
      // fill adjacent node lists
      for (n in nodes)
        n.updateLinks();
/*
        for (n2 in nodes)
          if (n != n2 && n.distance(n2) <= difficulty.nodeActivationRadius)
            {
              n.links.remove(n2);
              n.links.add(n2);
            }*/
    }


// find free spot for a new node
  public function findFreeSpot(d: Int): { x: Int, y: Int }
    {
      var x = 0, y = 0;
      var cnt = 0;
      var sx = UI.vars.markerWidth * 2;
      var sy = UI.vars.markerHeight * 2;
      var d = UI.vars.markerWidth * 2;
      while (true)
        {
          x = Math.round(20 + Math.random() *
            (difficulty.mapWidth - UI.vars.markerWidth - 40));
          y = Math.round(20 + Math.random() *
            (difficulty.mapHeight - UI.vars.markerHeight - 40));

          cnt++;
          if (cnt > 100)
            {
              trace('could not spawn node');
              return null;
            }

          // check min distance to other nodes
          var ok = 1;
          for (n in nodes)
            if (n.distanceXY(x, y) < d)
              {
                ok = 0;
                break;
              }

          if (ok == 1)
            break;
        }
      
      return { x: x, y: y };
    }


// find free spot for a new node in a given quad
  public function findFreeSpotQuad(quad: Quadrant, d: Int): { x: Int, y: Int }
    {
      var x = 0, y = 0;
      var cnt = 0;
      var sx = UI.vars.markerWidth * 2;
      var sy = UI.vars.markerHeight * 2;
      var d = UI.vars.markerWidth * 2;
      while (true)
        {
          x = Math.round(quad.x1 + 20 + Math.random() *
            (quad.x2 - quad.x1 - UI.vars.markerWidth - 40));
          y = Math.round(quad.y1 + 20 + Math.random() *
            (quad.y2 - quad.y1 - UI.vars.markerHeight - 40));

          cnt++;
          if (cnt > 100)
            {
              trace('could not spawn node');
              return null;
            }

          // check min distance to other nodes
          var ok = 1;
          for (n in nodes)
            if (n.distanceXY(x, y) < d)
              {
                ok = 0;
                break;
              }

          if (ok == 1)
            break;
        }
      
      return { x: x, y: y };
    }


// spawn new node (fsp)
  function spawnNode()
    {
      // find free position
      var pos = findFreeSpot(UI.vars.markerWidth * 2);
      if (pos == null)
        return;

      // node attributes
      var node = new Node(this, ui, pos.x, pos.y, lastNodeIndex++);

      if (mapVisible)
        node.setVisible(player, true);

      node.update();
      nodes.push(node);
    }


// remove node from active game nodes
  public function removeNode(node: Node)
    {
      nodes.remove(node);
      ui.map.paint();
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

      difficultyLevel = save.dif;
      difficulty = Static.difficulty[difficultyLevel];
      turns = save.turns;

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
//      this.lastNodeIndex = 0;
      for (n in savenodes)
        {
          var node = new Node(this, ui, n.x, n.y, n.id);
          node.load(n);
          nodes.push(node);
          if (node.owner == player)
            node.isKnown[player.id] = true;
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

      for (n in nodes) // update node display
        n.update();

      // load lines
      var savelines:Array<Dynamic> = save.lines;
      for (l in savelines)
        {
          var startNode = getNode(l[0]);
          var endNode = getNode(l[1]);
          var cult = cults[l[2]];
          var line = Line.create(ui, cult, startNode, endNode);
          trace('TODO: load lines visibility bug!');
//          if (l[3] == 1)
//            line.setVisible(game.player, true);
          lines.add(line);
          startNode.lines.add(line);
          endNode.lines.add(line);
        }

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
      trace('TODO: save lines fail');
/*
      for (l in lines) // pack lines into int arrays
        save.lines.push([ l.startNode.id, l.endNode.id, l.owner.id,
          (l.isVisible ? 1 : 0) ]);
*/
      save.turns = turns;
      save.dif = difficultyLevel;
      return save;
    }


// get node by id
  public function getNode(id: Int): Node
    {
      for (n in nodes)
        if (n.id == id)
          return n;
      return null;
    }


// on clicking end turn button (ftu)
  public function endTurn()
    {
      // ai turns
      var newPlayerID = -1;
      for (i in (currentPlayerID + 1)...cults.length)
        {
          var c = cults[i];

          // AI turn
          if (c.isAI && !c.isDead)
            {
              var ai: AI = cast cults[i];
              ai.turn();

              // game could be finished on summoning success
              if (isFinished)
                return;

              startTimer("ai " + ai.name);
              ai.aiTurn();
              endTimer("ai " + ai.name);
            }

          if (!c.isAI && !c.isDead)
            {
              newPlayerID = i;
              break;
            }
        }

      // move turn to next player
      if (newPlayerID >= 0)
        {
          player = cults[newPlayerID];
          currentPlayerID = newPlayerID;

          applyPlayerOptions(); // apply options for this player

          player.turn();
          for (c in cults)
            c.checkVictory();

          // center map on new player
          if (difficulty.numPlayers > 1)
            {
              var x = 0, y = 0;
              if (player.origin != null)
                {
                  x = player.origin.x;
                  y = player.origin.y;
                }
              else
                {
                  // no origin, get eldest node
                  var node = player.nodes.first();
                  for (n in player.nodes)
                    if (n.level > node.level)
                      node = n;
                  x = node.x;
                  y = node.y;
                }
              ui.map.center(x, y);
            }

          ui.logPanel.paint();
          ui.logConsole.update();
          ui.updateStatus();
          ui.map.paint();

          if (difficulty.numPlayers > 1)
            ui.alert("Your turn<br>" + player.fullName, {
              w: 400,
              h: 125,
              shadowOpacity: 1,
            });
        }

      // all cults are done, next turn
      if (newPlayerID < 0)
        {
          turns++;
          currentPlayerID = -1;
          director.turn();
          endTurn();

          // node turns
          for (n in nodes)
            n.turn();

          // expansions
          if (flags.artifacts)
            artifacts.turn();
        }

      // tutorial hooks
      tutorial.play('endTurn');
      if (player.awareness >= 10)
        tutorial.play('awareness');
    }


// fail all appropriate sect tasks
  public function failSectTasks()
    {
      for (c in cults)
        for (s in c.sects)
          if (s.task != null && s.task.checkFailure(s) == true)
            s.clearTask();
    }


// apply current player options
  public function applyPlayerOptions()
    {
      ui.map.paint();
    }


// start counting time
  var timerTime: Float;
  public inline function startTimer(name)
    {
      if (debugTime)
        timerTime = Browser.window.performance.now();
//        timerTime = Date.now().getTime();
    }


// end counting time and display it
  public inline function endTimer(name)
    {
      if (debugTime)
//        trace(name + ": " + (Date.now().getTime() - timerTime) + "ms");
        trace(name + ": " + (Browser.window.performance.now() - timerTime) + "ms");
    }


// main function
  static var instance: Game;
  static function main()
    {
      instance = new Game();
      instance.init();
    }


// =========================================

  // these are changed from debug menu
  public static var debugTime = false; // show execution time of various parts
  public static var debugVis = false; // show node visibility for all cults
  public static var debugNear = false; // show "nearness" of all nodes
  public static var debugAI = false; // show AI debug messages
  public static var debugDirector = false; // show director debug messages
  public static var mapVisible = false; // all map is visible at start

  public static var powerNames: Array<String> =
    [ "Intimidation", "Persuasion", "Bribery", "Virgins" ];
  public static var powerShortNames: Array<String> =
    [ "I", "P", "B", "V", "*" ];
  public static var followerNames: Array<String> =
    [ "Neophyte", "Adept", "Priest" ];
  public static var powerConversionCost: Array<Int> = [2, 2, 2, 1];
  public static var willPowerCost: Int = 2;

  public static var version = "v6.1"; // game version
  public static var followerLevels = 3; // number of follower levels
  public static var numPowers = 3; // number of basic powers
  public static var numFullPowers = 4; // number of basic powers + 1
  public static var upgradeCost = 3; // cost to upgrade follower
  public static var isDebug = false; // debug mode (debug button + extended info window)
}
