// ui class for cult
// nme version

import nme.Lib;
import nme.ui.Keyboard;
import nme.display.MovieClip;
import nme.display.DisplayObject;
import nme.display.Loader;
import nme.net.URLRequest;
import nme.events.KeyboardEvent;
import nme.Timer;


class UI
{
  public var game: Game;
  public var screen: MovieClip; // screen variable

  public var music: Music; // music player

  // ui blocks
  public var status: Status; // status block
  public var mainMenu: MainMenu; // main menu block
  public var info: Info; // cult info block
  public var logWindow: Log; // log block
  public var alertWindow: Alert; // alert block
  public var debug: Debug; // debug menu block
  public var map: Map; // map block
  public var config: Config; // configuration

  var bg: DisplayObject;
  var msgText: Label;


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
      config = new Config(this, game, "cultrc");

      // grabs control
      Lib.create(onLoad, winWidth, winHeight, 30.0, 0, 0,
        "Evil Cult " + Game.version, "");
    }


// screen created, init everything
  public function onLoad()
    {
      screen = Lib.current;

      var l = new Loader();
      l.load(new URLRequest("data/bg.png"));
      bg = l.content;
      screen.addChild(bg);

      map.init();
      status.init();
      mainMenu.init();
      logWindow.init();
      alertWindow.init();
      info.init();
      debug.init();
      Lib.stage.addEventListener(KeyboardEvent.KEY_UP, onKey);

      msgText = new Label(screen, // message text
        { x: 1, y: 1, w: 1, h: 30,
          font: { size: 18 },
          center: true, text: "" });
      msgText.opaqueBackground = 0x111111;
      msgText.visible = false;

      mainMenu.show();
    }


// key press
  public function onKey(e: KeyboardEvent)
    {
//      log2("UI.onKey(" + e.keyCode + ")");

      if (mainMenu.isVisible) // main menu keys
        mainMenu.onKey(e);

      else if (debug.isVisible) // debug menu keys
        debug.onKey(e);

      // end turn
      else if (e.keyCode == Keyboard.E ||
          e.keyCode == Keyboard.E + 32)
        status.onEndTurn(null);

      // info
      else if (e.keyCode == Keyboard.I ||
          e.keyCode == Keyboard.I + 32)
        status.onInfo(null);

      // log
      else if (e.keyCode == Keyboard.L ||
          e.keyCode == Keyboard.L + 32)
        status.onLog(null);

      // debug
      else if (e.keyCode == Keyboard.D ||
          e.keyCode == Keyboard.D + 32)
        status.onDebug(null);

      // close current window
      else if (e.keyCode == Keyboard.ESCAPE ||
               e.keyCode == Keyboard.ENTER ||
               e.keyCode == Keyboard.SPACE)
        {
          if (alertWindow.isVisible)
            alertWindow.onClose(null);

          else if (logWindow.isVisible)
            logWindow.onClose(null);

          else if (info.isVisible)
            info.onClose(null);

          // open main menu
          else mainMenu.show();
        }

      // exit
      else if (e.keyCode == Keyboard.Q ||
               e.keyCode == Keyboard.Q + 32)
        Lib.close();
        
      // upgrade neophytes
      else if (e.keyCode == Keyboard.NUMBER_1)
        game.player.upgrade(0);

      // upgrade adepts 
      else if (e.keyCode == Keyboard.NUMBER_2)
        game.player.upgrade(1);

      // summon
      else if (e.keyCode == Keyboard.NUMBER_3)
        game.player.upgrade(2);
    }


// clear map
  public function clearMap()
    {
      map.clear();
    }


// message box 
  public function msg(s)
	{
      msgText.text = s;
      msgText.width = msgText.textWidth;
      msgText.center();
      msgText.visible = true;
      Timer.delay(msgHide, 1000);
	}


// hide msg - called in timer
  public function msgHide()
    {
      msgText.visible = false;
    }


// update status block
  public function updateStatus()
    {
      status.update();
    }


// finish game window (ffin)
  public function finish(cult: Cult, state: String)
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


      // temporary de-htmling
      msg = StringTools.replace(msg, "<br>", "\n");
      var sb = new StringBuf();
      var arr = msg.split('<');
      var start = 0;
      for (t in arr)
        sb.add(t.substr(t.indexOf('>') + 1));

      msg = sb.toString();

      alert(msg, true);
    }


// show colored power name
  public static function powerName(i): String
    {
      return "<font color='" + UI.powerColors[i] + "'>" +
        Game.powerNames[i] + "</font>";
    }


// show colored cult name
  public static function cultName(i, info): String
    {
      return "<font color='" + Game.cultColors[i] + "'>" +
        info.name + "</font>";
//      return info.name;
    }


// message with confirmation
  public function alert(s, ?shadow: Bool)
    {
      alertWindow.show(s, shadow);
    }


// add message to log
  public function log(s: String, ?show: Bool)
    {
      logWindow.add(s, show);
    }


// add to debug log
  public static inline function log2(s: String)
    {
      neko.Lib.println(s);
    }


// clear log
  public function clearLog()
    {
      logWindow.clear();
    }


// track stuff through google analytics
  public inline function track(action: String, ?label: String, ?value: Int)
    {
      // not available
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

  public static var powerColorsString: Array<String> =
    [ "#ff0000", "#00ffff", "#00ff00", "#ffff00" ];
  public static var powerColors: Array<Int> =
    [ 0xff0000, 0x00ffff, 0x00ff00, 0xfff00 ];
  public static var nodeColors: Array<Int> =
    [ 0x005500, 0x010955, 0x560053, 0x505000 ];
  public static var nodeNeutralColor: Int = 0x111111;
  public static var lineColors: Array<Int> =
    [ 0x55dd55, 0x2727D7, 0xE052CA, 0xD8E151 ];
}
