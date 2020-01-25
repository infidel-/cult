// ui class for cult
// js version

import js.Browser;


extern class JQDialog implements Dynamic
{
  static function notify(?p1: Dynamic, ?p2: Dynamic): Void;
  static function alert(?p1: Dynamic, ?p2: Dynamic): Void;
}


class UI
{
  var game: Game;
  public var music: Music; // music player

  // ui blocks
  public var status: Status; // status block
  public var mainMenu: MainMenu; // main menu block
  public var loadMenu: LoadMenu; // load menu block
  public var saveMenu: SaveMenu; // save menu block
  public var customMenu: CustomMenu; // custom menu block
  public var mpMenu: MultiplayerMenu; // multiplayer menu block
  public var info: Info; // cult info block
  public var logWindow: Log; // log block
  public var alertWindow: Alert; // alert block
  public var debug: Debug; // debug menu block
  public var map: MapUI; // map block
  public var config: Config; // configuration
  public var logPanel: LogPanel; // log panel
  public var top: TopMenu; // top menu block
  public var sects: SectsInfo; // sects info block
  public var options: OptionsMenu; // options block


  public function new(g)
    {
      game = g;
      config = new Config();
    }


// init game screen
  public function init()
    {
      logWindow = new Log(this, game);
      logPanel = new LogPanel(this, game);
      alertWindow = new Alert(this, game);
      info = new Info(this, game);
      debug = new Debug(this, game);
      status = new Status(this, game);
      map = new MapUI(this, game);
      music = new Music(this);
      mainMenu = new MainMenu(this, game);
      loadMenu = new LoadMenu(this, game);
      saveMenu = new SaveMenu(this, game);
      customMenu = new CustomMenu(this, game);
      mpMenu = new MultiplayerMenu(this, game);
      top = new TopMenu(this, game);
      sects = new SectsInfo(this, game);
      options = new OptionsMenu(this, game);
      music.onRandom = status.onMusic;

      Browser.document.onkeyup = onKey;
//      Browser.window.onresize = onResize;
    }

/*
// on resizing document
  function onResize(event: Dynamic)
    {
      var w = Browser.window.innerWidth;
      var h = Browser.window.innerHeight;
      if (w < 1050 || h < 680 ||
          (!game.isFinished && game.difficulty != null && game.difficulty.mapWidth <= 780 &&
            game.difficulty.mapHeight <= 580))
        {
          w = 1050;
          h = 680;
        }

      var mw = w - 270;
      var mh = h - UI.topHeight - 40;

      var el = untyped e('map');
      var ctx = el.getContext('2d');
      el.width = mw;
      el.height = mh;
//      el.style.width = '' + mw;
//      el.style.height = '' + mh;

//      map.resize(w - 191, h - UI.topHeight);
      trace(el.style.width + ' ' + el.style.height);
//      trace(ctx.canvas.width + ' ' + ctx.canvas.height);
      map.paint();
      //Browser.window.innerWidth + " " + Browser.window.innerHeight);
    }
*/

// on key press
  function onKey(e: Dynamic)
    {
//      var key = (Browser.window.event) ? Browser.window.event.keyCode : event.keyCode;
      var key = e.keyCode;
//      trace(key);

      var windowOpen = ( loadMenu.isVisible || saveMenu.isVisible ||
        mainMenu.isVisible || debug.isVisible || alertWindow.isVisible ||
        logWindow.isVisible || info.isVisible || sects.isVisible ||
        customMenu.isVisible );

      if (loadMenu.isVisible) // load menu keys
        loadMenu.onKey(e);

      else if (saveMenu.isVisible) // save menu keys
        saveMenu.onKey(e);

      else if (mainMenu.isVisible) // main menu keys
        mainMenu.onKey(e);

      else if (customMenu.isVisible) // custom menu keys
        customMenu.onKey(e);

      else if (mpMenu.isVisible) // multiplayer menu keys
        mpMenu.onKey(e);

      else if (debug.isVisible) // debug menu keys
        debug.onKey(e);

      else if (sects.isVisible) // sects keys
        sects.onKey(e);

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

          // open main menu
          else mainMenu.show();
        }

      // close window
      else if (logWindow.isVisible && e.keyCode == 76) // L
        logWindow.onClose(null);

      else if (info.isVisible && e.keyCode == 67) // C
        info.onClose(null);

      else if (options.isVisible && e.keyCode == 79) // O
        options.onClose(null);

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

          // log
          else if (e.keyCode == 76) // L
            top.onLog(null);

          // main menu
          else if (e.keyCode == 77) // M
            mainMenu.show();

          // options
          else if (e.keyCode == 79) // O
            top.onOptions(null);

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


// clear map
  public function clearMap()
    {
      map.clear();
    }


// message box
  public inline function msg(s)
    {
      e('jqDialog_close').style.visibility = 'hidden';
      JQDialog.notify(s, 1);
    }


// update status block
  public function updateStatus()
    {
      status.update();
    }


// finish game window (ffin)
  public function finish(cult: Cult, state)
    {
      map.paint(); // final map repaint
      var msg = "<div style='text-size: 20px'><b>Game over</b></div><br>";

      if (state == "summon" && !cult.isAI)
        {
          msg += "The stars were right. The Elder God was summoned in " +
            game.turns + " turns.";
          msg += "<br><br><center><b>YOU WON</b></center>";
          track("winGame diff:" + game.difficultyLevel, "summon", game.turns);
        }

      else if (state == "summon" && cult.isAI)
        {
          msg += cult.fullName +
            " has completed the " + Static.rituals[0].name + ".<br><br>" +
            untyped cult.info.summonFinish;
          msg += "<br><br><center><b>YOU LOSE</b></center>";
          track("loseGame diff:" + game.difficultyLevel, "summon", game.turns);
        }

      else if (state == "conquer" && !cult.isAI)
        {
          msg += cult.fullName + " has taken over the world in " +
            game.turns + " turns. The Elder Gods are pleased.";
          msg += "<br><br><center><b>YOU WON</b></center>";
          track("winGame diff:" + game.difficultyLevel, "conquer", game.turns);
        }

      else if (state == "conquer" && cult.isAI)
        {
          msg += cult.fullName + " has taken over the world. You fail.";
          msg += "<br><br><center><b>YOU LOSE</b></center>";
          track("loseGame diff:" + game.difficultyLevel, "conquer", game.turns);
        }

      else if (state == "wiped")
        {
          msg += cult.fullName + " was wiped away completely. " +
            "The Elder God lies dormant beneath the sea, waiting.";
          msg += "<br><br><center><b>YOU LOSE</b></center>";
          track("loseGame diff:" + game.difficultyLevel, "wiped", game.turns);
        }

      else if (state == "multiplayerFinish")
        {
          msg += "The great game has ended. Humanity will live.";
          msg += "<br><br><center><b>YOU ALL LOSE</b></center>";
          track("loseGame diff:" + game.difficultyLevel, "multiplayerFinish", game.turns);
        }

      // open map
      for (n in game.nodes)
        n.setVisible(game.player, true);

      alert(msg, true);
    }


// show colored power name
  public static function powerName(i, ?isShort: Bool)
    {
      return "<span style='color:" + powerColors[i] + "'>" +
        (isShort ? Game.powerShortNames[i] : Game.powerNames[i]) + "</span>";
    }


// show colored cult name
  public static function cultName(i, info)
    {
      return "<span style='color:" + UI.cultColors[i] + "'>" +
        info.name + "</span>";
    }


// message with confirmation
  public function alert(s, ?shadow: Bool, ?shadowOpacity: Float)
    {
      alertWindow.show(s, shadow, shadowOpacity);
    }


// add message to logs of all player cults who know about this cult (more info)
  public function log2(cultOrigin: Cult, s: String, ?params: Dynamic)
    {
      // no messages about unknown cults
      for (c in game.cults)
        if (c.isDiscovered[cultOrigin.id] || cultOrigin.isDiscovered[c.id])
          {
            c.log(s);

            // skip sect messages is on
            if (params != null && params.type == 'sect' &&
                c.options.getBool('logPanelSkipSects'))
              continue;
            c.logPanel({
              id: -1,
              old: false,
              type: null,
              text: s,
              obj: cultOrigin,
              turn: game.turns + 1,
              params: params });
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


// track stuff through google analytics
  public inline function track(action: String, ?label: String, ?value: Int)
    {
      action = "cult " + action +  " " + Game.version;
      if (label == null)
        label = '';
      if (value == null)
        value = 0;
#if !electron
      untyped pageTracker._trackEvent('Evil Cult', action, label, value);
#end
    }



// =========================== ui vars ================================

  public static var powerColors: Array<String> =
    [ "rgb(255, 0, 0)", "rgb(0, 255, 255)", "rgb(0, 255, 0)", "rgb(255, 255, 0)" ];
//  public static var nodeColors: Array<String> =
//    [ "rgb(0, 85, 0)", "rgb(1, 9, 85)", "rgb(86, 0, 83)", "rgb(80, 80, 0)" ];
  public static var nodePixelColors: Array<Array<Int>> =
    [ [ 85, 221, 85 ], [ 39, 39, 215 ], [ 224, 82, 202 ], [ 216, 225, 81 ],
      [ 9, 136, 255 ], [ 96, 150, 18 ], [ 168, 87, 0 ], [ 153, 0, 9 ] ];
  public static var nodeNeutralPixelColors: Array<Int> = [ 120, 120, 120 ];
  public static var lineColors: Array<String> =
    [ "#55dd55", "#2727D7", "#E052CA", "#D8E151",
      "#0988ff", "#609612", "#a85700", "#990009"
    ];
  public static var cultColors: Array<String> =
    [ "#00B400", "#2F43FD", "#B400AE", "#B4AE00",
      "#0988ff", "#609612", "#a85700", "bb000b" ];


  public static var winWidth = 1024;
  public static var winHeight = 630;
  public static var mapWidth = 780;
  public static var mapHeight = 580;
  public static var tooltipWidth = 100;
  public static var tooltipHeight = 80;
  public static var markerWidth = 15;
  public static var markerHeight = 15;
  public static var topHeight = 30;

//  public static var nodeVisibility = 101;
  public static var colAwareness = "#ff9999";
  public static var colWillpower = "#bbbbbb";

  public static var maxSaves:Int = 5; // max number of saves displayed
}
