// ui class for cult

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
  public var info: Info; // cult info block
  public var logWindow: Log; // log block
  public var alertWindow: Alert; // alert block
  public var debug: Debug; // debug menu block
  public var map: Map; // map block


  public function new(g)
    {
	  game = g;
	}


// init game screen
  public function init()
    {
      logWindow = new Log(this, game);
      alertWindow = new Alert(this, game);
      info = new Info(this, game);
      debug = new Debug(this, game);
      status = new Status(this, game);
      map = new Map(this, game); 
      music = new Music();
      mainMenu = new MainMenu(this, game);
      music.onRandom = status.updateTrack;
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
          track("winGame diff:" + game.difficultyLevel, "summon", game.turns);
        }

      else if (state == "summon" && cult.isAI)
        {
          msg += cult.fullName +
            " has completed the " + Static.rituals[0].name + ".<br><br>" +
            untyped cult.info.summonFinish;
          track("loseGame diff:" + game.difficultyLevel, "summon", game.turns);
        }

      else if (state == "conquer" && !cult.isAI)
        {
          msg += cult.fullName + " has taken over the world in " +
            game.turns + " turns. The Elder Gods are pleased.";
          track("winGame diff:" + game.difficultyLevel, "conquer", game.turns);
        }

      else if (state == "conquer" && cult.isAI)
        {
          msg += cult.fullName + " has taken over the world. You fail.";
          track("loseGame diff:" + game.difficultyLevel, "conquer", game.turns);
        }

      else if (state == "wiped")
        {
          msg += cult.fullName + " was wiped away completely. " +
            "The Elder God lies dormant beneath the sea, waiting.";
          track("loseGame diff:" + game.difficultyLevel, "wiped", game.turns);
        }

      alert(msg);
    }


// show colored power name
  public static function powerName(i)
    {
      return "<span style='color:" + Game.powerColors[i] + "'>" +
        Game.powerNames[i] + "</span>";
    }


// show colored cult name
  public static function cultName(i, info)
    {
      return "<span style='color:" + Game.cultColors[i] + "'>" +
        info.name + "</span>";
    }


// message with confirmation
  public function alert(s)
    {
      alertWindow.show(s);
    }


// add message to log
  public function log(s: String, ?show: Bool)
    {
      logWindow.add(s, show);
    }


// clear log
  public function clearLog()
    {
      logWindow.clear();
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


// get a stored variable (cookie)
  public inline function getVar(name: String)
    {
      return untyped getCookie(name);
    }


// get a stored variable (cookie)
  public inline function setVar(name: String, val: String)
    {
      return untyped setCookie(name, val,
        untyped __js__("new Date(2015, 0, 0, 0, 0, 0, 0)"));
    }



// =========================== ui vars ================================

  public static var winWidth = 1024;
  public static var winHeight = 600;
  public static var mapWidth = 800;
  public static var mapHeight = 580;
  public static var tooltipWidth = 100;
  public static var tooltipHeight = 80;
  public static var markerWidth = 15;
  public static var markerHeight = 15;
  public static var nodeVisibility = 101;
  public static var colAwareness = "#ff9999";
  public static var colWillpower = "#bbbbbb";
}
