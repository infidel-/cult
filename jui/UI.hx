// ui class for cult
// js version

import js.Browser;
import js.html.KeyboardEvent;
import Alert;
import Static;

#if electron
import js.node.Fs;
#end


@:expose
class UI
{
  var game: Game;
  public var music: Music; // music player

  // ui blocks
  public var status: Status; // status panel
  public var mainMenu: MainMenu; // main menu
  public var newGameMenu: NewGameMenu; // new game menu
  public var loadMenu: LoadMenu; // load menu
  public var saveMenu: SaveMenu; // save menu
  public var customMenu: CustomMenu; // custom menu
  public var mpMenu: MultiplayerMenu; // multiplayer menu
  public var info: Info; // cult info
  public var logWindow: Log; // log
  public var alertWindow: Alert; // alert
  public var debug: Debug; // debug menu
  public var map: MapUI; // map block
  public var config: Config; // configuration
  public var logPanel: LogPanel; // log panel
  public var logConsole: LogConsole; // log console
  public var top: TopMenu; // top menu block
  public var sects: SectsInfo; // sects info block
  public var options: OptionsMenu; // options block
  public var manual: Manual; // ingame manual
  public var messageWindow: Message;
  public var fullscreen: Bool;

  // expansion ui
  public var artifacts: artifacts.ArtifactUI;

  public function new(g)
    {
      game = g;
      config = new Config();
      fullscreen = false;

      untyped  __js__("window.devicePixelRatio = 1;");

      Browser.window.onerror = onError;

      // pick mode
      var url = Browser.window.location.href;
      var isClassic = (StringTools.endsWith(url, 'index.html') ||
        StringTools.endsWith(url, 'app-classic.html'));
      if (StringTools.startsWith(url, 'http'))
        isClassic = true;
      classicMode = isClassic;
      modernMode = !isClassic;
      vars = (isClassic ? classicModeVars : modernModeVars);
    }


  public function onError(msg: Dynamic, url: String, line: Int, col: Int, err: Dynamic): Bool
    {
      var d = Date.now();
      var l = d.getHours() + ':' +
        (d.getMinutes() < 10 ? '0' : '') + d.getMinutes() + ':' +
        (d.getSeconds() < 10 ? '0' : '') + d.getSeconds() + ' ' +
        msg + ', ' + err.stack + ', line ' + line + ', col ' + col + '\n';
      trace(l);
#if electron
      try {
        Fs.appendFileSync('log.txt', l);
      }
      catch (e: Dynamic)
        {}
#end
      return false;
    }


// init game screen
  public function init()
    {
      logWindow = new Log(this, game);
      logPanel = new LogPanel(this, game);
      logConsole = new LogConsole(this, game);
      alertWindow = new Alert(this, game);
      info = new Info(this, game);
      debug = new Debug(this, game);
      status = new Status(this, game);
      map = new MapUI(this, game);
      music = new Music(this);
      mainMenu = new MainMenu(this, game);
      newGameMenu = new NewGameMenu(this, game);
      loadMenu = new LoadMenu(this, game);
      saveMenu = new SaveMenu(this, game);
      customMenu = new CustomMenu(this, game);
      mpMenu = new MultiplayerMenu(this, game);
      top = new TopMenu(this, game);
      sects = new SectsInfo(this, game);
      options = new OptionsMenu(this, game);
      manual = new Manual(this, game);
      messageWindow = new Message(this, game);
      music.onRandom = status.onMusic;
      artifacts = new artifacts.ArtifactUI(game, this);

      Browser.document.onkeyup = onKey;
      Browser.window.onresize = onResize;
      onResize(null); // once after game start
    }


// on resizing document
  function onResize(event: Dynamic)
    {
      map.resize();
      top.resize();
      logConsole.resize();
    }


// on key press
  function onKey(e: KeyboardEvent)
    {
//      var key = (Browser.window.event) ? Browser.window.event.keyCode : event.keyCode;
      var key = e.keyCode;
//      trace(key);

      var windowOpen = (
        loadMenu.isVisible ||
        saveMenu.isVisible ||
        mainMenu.isVisible ||
        debug.isVisible ||
        alertWindow.isVisible ||
        logWindow.isVisible ||
        info.isVisible ||
        sects.isVisible ||
        customMenu.isVisible ||
        manual.isVisible ||
        newGameMenu.isVisible ||
        options.isVisible
      );

      // windows keys
      if (loadMenu.isVisible)
        loadMenu.onKey(e);

      else if (saveMenu.isVisible)
        saveMenu.onKey(e);

      else if (mainMenu.isVisible &&
          !newGameMenu.isVisible &&
          !options.isVisible)
        mainMenu.onKey(e);

      else if (customMenu.isVisible)
        customMenu.onKey(e);

      else if (mpMenu.isVisible)
        mpMenu.onKey(e);

      else if (debug.isVisible)
        debug.onKey(e);

      else if (sects.isVisible)
        sects.onKey(e);

      else if (newGameMenu.isVisible)
        newGameMenu.onKey(e);

      // close current window
      else if (e.keyCode == 27 || // ESC
               e.keyCode == 13 || // Enter
               e.keyCode == 32) // Space
        {
          // Enter disabled in Sects info
          if (e.keyCode == 13 && sects.isVisible)
            return;

          if (alertWindow.isVisible)
            alertWindow.onClose(null);

          else if (logWindow.isVisible)
            logWindow.onClose(null);

          else if (info.isVisible)
            info.onClose(null);

          else if (sects.isVisible)
            sects.onClose(null);

          else if (options.isVisible)
            options.onClose(null);

          else if (manual.isVisible)
            manual.onClose(null);

          else if (newGameMenu.isVisible)
            newGameMenu.onClose(null);

          // open main menu
          else if (e.keyCode == 27)
            {
              // since browser forces fullscreen off here, fix state
              fullscreen = false;
              game.options.set('fullscreen', false);
              mainMenu.show();
            }
        }

      // close yes/no dialog with yes
      else if (alertWindow.isVisible && alertWindow.isYesNo)
        {
          if (e.keyCode == 49) // 1
            alertWindow.onYes(null);
          else if (e.keyCode == 50) // 2
            alertWindow.onNo(null);
        }

      // close window
      else if (logWindow.isVisible && e.keyCode == 76) // L
        logWindow.onClose(null);

      else if (info.isVisible && e.keyCode == 67) // C
        info.onClose(null);

      else if (options.isVisible && e.keyCode == 79) // O
        options.onClose(null);

      else if (manual.isVisible && e.keyCode == 77) // M
        manual.onClose(null);

      else if (!windowOpen) // these work only without windows open
        {
          // advanced map mode
          if (e.keyCode == 65) // A
            top.onAdvanced(null);

          // cults
          else if (e.keyCode == 67) // C
            top.onCults(null);

          // debug
          else if (e.keyCode == 68) // D
            top.onDebug(null);

          // end turn
          else if (e.keyCode == 69) // E
            status.onEndTurn(null);

          // fullscreen
          else if (e.keyCode == 70) // F
            setFullscreen(!fullscreen);

          // log
          else if (e.keyCode == 76) // L
            top.onLog(null);

          // manual
          else if (e.keyCode == 77) // M
            manual.show();

          // sects
          else if (e.keyCode == 83) // S
            top.onSects(null);

          // upgrade neophytes
          else if (e.keyCode == 49 && !game.isFinished) // 1
            game.player.upgrade(0);

          // upgrade adepts
          else if (e.keyCode == 50 && !game.isFinished) // 2
            game.player.upgrade(1);

          // summon
          else if (e.keyCode == 51 && !game.isFinished) // 3
            game.player.upgrade(2);
        }
    }


// set fullscreen
  public function setFullscreen(val: Bool)
    {
      if (fullscreen)
        Browser.document.exitFullscreen();
      else Browser.document.documentElement.requestFullscreen();
      fullscreen = !fullscreen;
      game.options.set('fullscreen', val);
    }


// start a new game (common for all ui)
  public function newGame(lvl: Int, ?dif: DifficultyInfo)
    {
      game.isTutorial = false;
      game.difficultyLevel = lvl;
      if (UI.modernMode && lvl >= 0 && lvl < 2 &&
          !game.flags.artifacts)
        alert("Start the tutorial?", {
          yesNo: true,
          onYes: function ()
            {
              game.isTutorial = true;
              game.restart();
            },
          onNo: function ()
            {
              game.restart();
            }
        });
      else game.restart(dif);
    }


// clear map
  public function clearMap()
    {
      map.clear();
    }


// message box
  public inline function msg(s)
    {
      messageWindow.show(s);
    }


// update status block
  public inline function updateStatus()
    {
      status.update();
    }


// finish game window (ffin)
  public function finish(cult: Cult, state: String)
    {
      game.isFinished = true;
      updateStatus();
      var msg = "<div style='text-size: 20px'><b>GAME OVER</b></div><br>";
      var w = 600;
      var h = 250;
      var showHighScore = false;
      var time = Std.int(Sys.time() - game.startTS);

      if (state == "summon" && !cult.isAI)
        {
          alert('<h2>FINAL RITUAL COMPLETED</h2><div class=fluff>' +
            cult.info.summonFinish + '</div><br>' +
            cult.fullName + " has completed the " +
            Static.rituals['summoning'].name + '.',
            { w: 700, h: 440 });

          msg += "The stars were right. The Elder God was summoned in " +
            game.turns + " turns (" +
            game.highScores.convertTime(time) + " of real time).";
          msg += "<h2>YOU WIN</h2>";
          h = 330;
          showHighScore = true;
        }

      else if (state == "conquer" && !cult.isAI)
        {
          alert('<h2>MILITARY VICTORY</h2><div class=fluff>' +
            Static.templates['conquer'] + '</div><br>' +
            cult.fullName + ' has taken over the world.',
            { w: 700, h: 420 });

          msg += cult.fullName + " has taken over the world in " +
            game.turns + " turns (" +
            game.highScores.convertTime(time) + " of real time)." +
            " The Elder God is pleased.";
          msg += "<h2>YOU WIN</h2>";
          h = 330;
          showHighScore = true;
        }

      else if (state == "summon" && cult.isAI)
        {
          alert('<h2>FINAL RITUAL COMPLETED</h2><div class=fluff>' +
            cult.info.summonFinish + '</div><br>' +
            cult.fullName + " has completed the " +
            Static.rituals['summoning'].name + '.',
            { w: 700, h: 440 });

          msg += "<h2>YOU LOSE</h2>";
        }

      else if (state == "conquer" && cult.isAI)
        {
          alert('<h2>MILITARY DEFEAT</h2><div class=fluff>' +
            Static.templates['conquer'] + '</div><br>' +
            cult.fullName + ' has taken over the world.',
            { w: 700, h: 420 });

          msg += cult.fullName + " has taken over the world. You fail.";
          msg += "<h2>YOU LOSE</h2>";
          h = 210;
        }

      else if (state == "wiped")
        {
          msg += cult.fullName + " was wiped away completely. " +
            "The Elder God lies dormant beneath the sea, waiting.";
          msg += "<h2>YOU LOSE</h2>";
          h = 210;
        }

      else if (state == "multiplayerFinish")
        {
          msg += "The great game has ended. Humanity will live.";
          msg += "<h2>YOU ALL LOSE</h2>";
          h = 190;
        }
      if (classicMode)
        h += 5;
#if electron
      if (showHighScore && game.difficultyLevel != -1 &&
          game.isFlagsDefault())
        msg += game.highScores.getTable(time);
      else if (!game.isFlagsDefault())
        msg += 'Flags: ' + game.getFlagsString();
#end

      // open map fully
      for (n in game.nodes)
        {
          n.setVisible(game.player, true);
          n.isKnown[game.player.id] = true;
        }
      map.paint(); // final map repaint

      alert(msg, {
        w: w,
        h: h,
      });
      alert("The game is over. After checking out the results you can open the main menu and start a new one.", {
        w: 600,
        h: (classicMode ? 125 : 110)
      });
    }


// show colored power name
  public static function powerName(i: Int, ?isShort: Bool = false)
    {
      return "<span class=shadow style='color:var(--power-color-" + i + ")'>" +
        (isShort ? Game.powerShortNames[i] : Game.powerNames[i]) + "</span>";
    }


// show colored cult name
  public static function cultName(i: Int, info: CultInfo)
    {
      return "<span class='cultText shadow' style='color:" + UI.vars.cultColors[i] + "'>" +
        info.name + "</span>";
    }


// message with confirmation
  public function alert(s, ?opts: _AlertOptions)
    {
      alertWindow.show(s, opts);
    }


// add message to logs of all player cults who know about this cult (more info)
  public function log2(cultOrigin: Cult, s: String, ?params: Dynamic)
    {
      // no messages about unknown cults
      for (c in game.cults)
        if (c.isDiscovered[cultOrigin.id] ||
            cultOrigin.isDiscovered[c.id])
          {
            c.log(s);

            // skip sect messages is on
            if (params != null && params.type == 'sect' &&
                game.options.getBool('logPanelSkipSects'))
              continue;
            c.logPanel({
              id: -1,
              old: false,
              type: null,
              text: s,
              objID: cultOrigin.id,
              turn: game.turns + 1,
              params: params
            });
          }
    }

// add message to logs of all player cults
  public function logGlobal(s: String, ?params: Dynamic)
    {
      // no messages about unknown cults
      for (c in game.cults)
        {
          c.log(s);

          // skip sect messages is on
          if (params != null && params.type == 'sect' &&
              game.options.getBool('logPanelSkipSects'))
            continue;
          c.logPanel({
            id: -1,
            old: false,
            type: 'none',
            text: s,
            turn: game.turns + 1,
            params: params
          });
        }
    }


// clear log
  public function clearLog()
    {
      logWindow.clear();
      logPanel.clear();
    }


// get element shortcut
  public static inline function e(s)
    {
      return Browser.document.getElementById(s);
    }


// update tooltip for object
  public function updateTip(name: String, tip: String)
    {
      name = "#" + name;
      if (name.indexOf(".") > 0)
        {
          name = name.substr(0, name.indexOf(".")) + "\\" +
            name.substr(name.indexOf("."));
        }
      new JQuery(name).attr('tooltipText', tip);
    }

// init tooltip jquery code for object
  public function initTooltip(name: String)
    {
      name = "#" + name;
      if (name.indexOf(".") > 0)
        {
          name = name.substr(0, name.indexOf(".")) + "\\" +
            name.substr(name.indexOf("."));
        }
      new JQuery(name).tooltip({ delay: 0 });
    }

// get CSS variable
  public static inline function getVar(s: String): String
    {
      return Browser.window.getComputedStyle(
        Browser.document.documentElement).getPropertyValue(s);
    }


// get CSS variable as int
  public static inline function getVarInt(s: String): Int
    {
      return Std.parseInt(getVar(s));
    }



// =========================== ui vars ================================

  static var classicModeVars = {
    cultColors: [
      "#00B400",
      "#2F43FD",
      "#B400AE",
      "#B4AE00",
      "#0988ff",
      "#609612",
      "#a85700",
      "bb000b"
    ],
    lineColors: [
      "#55dd55",
      "#2727D7",
      "#E052CA",
      "#D8E151",
      "#0988ff",
      "#609612",
      "#a85700",
      "#990009"
    ],
    nodePixelColors: [
      [ 85, 221, 85 ],
      [ 39, 39, 215 ],
      [ 224, 82, 202 ],
      [ 216, 225, 81 ],
      [ 9, 136, 255 ],
      [ 96, 150, 18 ],
      [ 168, 87, 0 ],
      [ 153, 0, 9 ]
    ],
    nodeNeutralPixelColors: [
      'person' => [ 120, 120, 120 ],
      'artifact' => [ 250, 250, 250 ],
    ],
    markerWidth: 15,
    markerHeight: 15,
    scaleFactor: 1.0,
  };
  static var modernModeVars = {
    cultColors: [
      '#009933', // green
      '#FF3366', // pink
      '#009999', // cyan
      '#ff9900', // orange
      '#FF3300', // yellow
      '#3300CC', // blue
      '#660099', // violet
      '#330000', // red
      '#999999', // neutral
    ],
    lineColors: [ // same as cult
      '#009933', // green
      '#FF3366', // pink
      '#009999', // cyan
      '#ff9900', // orange
      '#FF3300', // yellow
      '#3300CC', // blue
      '#660099', // violet
      '#330000', // red
    ],
    nodePixelColors: [
      [ 0, 153, 51 ], // green
      [ 255, 51, 102 ], // pink
      [ 0, 153, 153 ], // cyan
      [ 255, 151, 0 ], // orange
      [ 255, 51, 0 ], // yellow
      [ 51, 60, 254 ], // blue
      [ 142, 0, 193 ], // violet
      [ 51, 0, 0 ] // red
    ],
    nodeNeutralPixelColors: [
      'person' => [ 150, 150, 150 ],
      'artifact' => [ 255, 255, 255 ],
    ],
    markerWidth: 60,
    markerHeight: 60,
    scaleFactor: 4.0, // sqrt(60 * 60 + 60 * 60) / sqrt(15 * 15 + 15 * 15)
  };
  public static var modernPowerImages = [
    'power-intimidation',
    'power-persuasion',
    'power-bribery',
    'power-virgins',
    'power-multi', // NOTE: has to be last!
  ];
  public static var modernGeneratorColors = [
    null, // green
    [ null, 'b0', 'd0' ], // pink
    null, // cyan
    [ null, 'a0', 'c0' ], // orange
    [ null, 'a0', 'c0' ], // yellow
    null, // blue
    null, // violet
    null, // red
    [ null, '60', 'c0' ], // neutral
  ];

  public static var modernMode = true; // modern mode flag
  public static var classicMode = false; // classic mode flag
  public static var vars = modernModeVars;

  public static var maxSaves = 5; // max number of saves displayed
}
