// ui class for cult
// js version

import js.Lib;
import js.Dom;


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
  public var info: Info; // cult info block
  public var logWindow: Log; // log block
  public var alertWindow: Alert; // alert block
  public var debug: Debug; // debug menu block
  public var map: Map; // map block
  public var config: Config; // configuration
  public var logPanel: LogPanel; // log panel
  public var top: TopMenu; // top menu block
  public var sects: SectsInfo; // sects info block


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
      map = new Map(this, game); 
      music = new Music();
      mainMenu = new MainMenu(this, game);
      loadMenu = new LoadMenu(this, game);
      saveMenu = new SaveMenu(this, game);
      top = new TopMenu(this, game);
      sects = new SectsInfo(this, game);
      music.onRandom = status.updateTrack;

      Lib.document.onkeyup = onKey;
    }


// on key press
  function onKey(e: Dynamic)
    {
//      var key = (Lib.window.event) ? Lib.window.event.keyCode : event.keyCode;
      var key = e.keyCode;
//      trace(key);

      var windowOpen = (loadMenu.isVisible || saveMenu.isVisible ||
        mainMenu.isVisible || debug.isVisible || alertWindow.isVisible ||
        logWindow.isVisible || info.isVisible || sects.isVisible);

      if (loadMenu.isVisible) // load menu keys
        loadMenu.onKey(e);

      else if (saveMenu.isVisible) // save menu keys
        saveMenu.onKey(e);

      else if (mainMenu.isVisible) // main menu keys
        mainMenu.onKey(e);
        
      else if (debug.isVisible) // debug menu keys
        debug.onKey(e);

      else if (sects.isVisible) // sects keys
        sects.onKey(e);

      // close current window
      else if (e.keyCode == 27 || // ESC
               e.keyCode == 13 || // Enter
               e.keyCode == 32) // Space
        {
          if (alertWindow.isVisible)
            alertWindow.onClose(null);

          else if (logWindow.isVisible)
            logWindow.onClose(null);

          else if (info.isVisible)
            info.onClose(null);
          
          else if (sects.isVisible)
            sects.onClose(null);

          // open main menu
          else mainMenu.show();
        }


      else if (!windowOpen) // these work only without windows open
        {
          // end turn
          if (e.keyCode == 69) // E
            status.onEndTurn(null);

          // cults
          else if (e.keyCode == 67) // C
            top.onCults(null);

          // log
          else if (e.keyCode == 76) // L
            top.onLog(null);

          // debug
          else if (e.keyCode == 68) // D
            top.onDebug(null);

          // sects
          else if (e.keyCode == 83) // S
            top.onSects(null);

          // upgrade neophytes
          else if (e.keyCode == 49) // 1
            game.player.upgrade(0);

          // upgrade adepts 
          else if (e.keyCode == 50) // 2
            game.player.upgrade(1);

          // summon
          else if (e.keyCode == 51) // 3
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
  
      // open map
      for (n in game.nodes)
        n.setVisible(game.player, true);

      alert(msg, true);
    }


// show colored power name
  public static function powerName(i)
    {
      return "<span style='color:" + powerColors[i] + "'>" +
        Game.powerNames[i] + "</span>";
    }


// show colored cult name
  public static function cultName(i, info)
    {
      return "<span style='color:" + Game.cultColors[i] + "'>" +
        info.name + "</span>";
    }


// message with confirmation
  public function alert(s, ?shadow: Bool)
    {
      alertWindow.show(s, shadow);
    }


// add message to log
  public function log(s: String, ?show: Bool)
    {
      logWindow.add(s, false);
      if (show == true || show == null)
        logPanel.add(s);
    }


// add message to log (more info)
  public function log2(type: String, obj: Dynamic, s: String)
    {
      if (type == 'cult') // no messages about unknown cults
        {
          var c:Cult = obj;
          if (!c.isDiscovered)
            return;
        }
      logWindow.add(s, false);
      logPanel.add(s, type, obj);
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
	  return Lib.document.getElementById(s);
	}


// track stuff through google analytics
  public inline function track(action: String, ?label: String, ?value: Int)
    {
      action = "cult " + action +  " " + Game.version;
      if (label == null)
        label = '';
      if (value == null)
        value = 0;
      untyped pageTracker._trackEvent('Evil Cult', action, label, value);
    }



// =========================== ui vars ================================

  public static var powerColors: Array<String> =
    [ "rgb(255, 0, 0)", "rgb(0, 255, 255)", "rgb(0, 255, 0)", "rgb(255, 255, 0)" ];
  public static var nodeColors: Array<String> =
    [ "rgb(0, 85, 0)", "rgb(1, 9, 85)", "rgb(86, 0, 83)", "rgb(80, 80, 0)" ];
  public static var lineColors: Array<String> =
    [ "#55dd55", "#2727D7", "#E052CA", "#D8E151" ];


  public static var winWidth = 1024;
  public static var winHeight = 630;
  public static var mapWidth = 780;
  public static var mapHeight = 580;
  public static var tooltipWidth = 100;
  public static var tooltipHeight = 80;
  public static var markerWidth = 15;
  public static var markerHeight = 15;
  public static var topHeight = 30;

  public static var nodeVisibility = 101;
  public static var colAwareness = "#ff9999";
  public static var colWillpower = "#bbbbbb";

  public static var maxSaves:Int = 5; // max number of saves displayed
}
