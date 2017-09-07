// status block

import nme.text.TextField;
import nme.text.TextFormat;
import nme.display.MovieClip;
import nme.display.Loader;
import nme.display.DisplayObject;
import nme.display.Bitmap;
import nme.net.URLRequest;
import nme.events.MouseEvent;

typedef ButtonArray = Array<Button>;

class Status
{
  var ui: UI;
  var game: Game;

  public var screen: MovieClip; // status clip
  var followers: Array<TextField>;
  var powers: Array<TextField>;
  var powersMod: Array<TextField>;
  var awareness: TextField;
  var turns: Label;
  var upgrade: ButtonArray;
  var lowerAwareness: ButtonArray;
  var lowerWillpower: ButtonArray;
  var convert: Array<ButtonArray>;
  var debug: Button;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      followers = new Array<TextField>();
      powers = new Array<TextField>();
      powersMod = new Array<TextField>();
      upgrade = new ButtonArray();
      lowerAwareness = new ButtonArray();
      lowerWillpower = new ButtonArray();
      convert = new Array<ButtonArray>();
      for (i in 0...3)
        convert[i] = new ButtonArray();
    }


// init everything
  public function init()
    {
      screen = new MovieClip();
      screen.x = 0;
      screen.y = 0;
      screen.width = Map.x - 10;
      screen.height = UI.winHeight - 10;
      ui.screen.addChild(screen);

      Label.defaultFont = "FreeSans";

      var tf : TextFormat = new TextFormat();
      tf.font = 'FreeSans';
      tf.size = 18;
      tf.bold = true;

      // title
      var title = new Label(screen,
        { x: 14, y: 12, w: 190, h: 25,
          font: { size: 18, bold: true },
          text: "Evil Cult " + Game.version });

      var l = new Loader();
      l.load(new URLRequest("data/lower_awareness.png"));
      var law: Bitmap = cast l.content;
      l.load(new URLRequest("data/lower_willpower.png"));
      var lwp: Bitmap = cast l.content;

      // follower numbers
      for (i in 0...Game.followerLevels)
        {
          followers[i] = new Label(screen, 
            { x: 172, y: 58 + i * 20, w: 36, h: 19,
              font: { size: 15, bold: true },
              text: "0" });
          upgrade[i] = new Button(screen,
            { x: 154, y: 63 + i * 20,
              name: "upgrade" + i,
              image: (i < 2 ? "upgrade" : "upgrade2"),
              onClick: onUpgrade,
              visible: false });
        }

      // power
      tf.size = 15;
      for (i in 0...(Game.numPowers + 1))
	    {
          powers[i] = new Label(screen, 
            { x: 160, y: 154 + i * 51, w: 36, h: 19,
              font: { size: 15, bold: true },
              text: "0" });

          var cnt = 0;
	  	  for (ii in 0...Game.numPowers) // convert buttons
			if (ii != i)
              convert[ii][i] = new Button(screen,
                { x: 45 + (cnt++) * 17, y: 184 + i * 51,
                  name: "convert" + i + ii,
                  image: "convert" + ii, 
                  onClick: onConvert,
                  visible: false });

          // not for virgins
          if (i != 3)
            {
              lowerAwareness[i] = new Button(screen,
                { x: 45 + 2 * 17, y: 184 + i * 51,
                  name: "lowerAwareness" + i,
                  image: "lower_awareness",
                  onClick: onLowerAwareness,
                  visible: false });
              lowerWillpower[i] = new Button(screen,
                { x: 45 + 3 * 17, y: 184 + i * 51,
                  name: "lowerWillpower" + i,
                  image: "lower_willpower",
                  onClick: onLowerWillpower,
                  visible: false });
            }
        }

      // power mods
      for (i in 0...(Game.numPowers + 1))
        powersMod[i] = new Label(screen,
          { x: 160, y: 174 + i * 51, w: 36, h: 19,
            font: { size:10 }, text: "+0 - 0" });

      // awareness and turns labels
      awareness = new Label(screen,
        { x: 160, y: 383, w: 36, h: 19,
          font: { size: 15, bold: true },
          text: "0%" });
      turns = new Label(screen,
        { x: 160, y: 403, w: 36, h: 19,
          font: { size: 15, bold: true },
          text: "0" });

      // buttons
      var endTurn = new Button(screen,
        { x: 26, y: 450, image: "endturn",
          onClick: onEndTurn });
      var info = new Button(screen,
        { x: 113, y: 450, image: "info",
          onClick: onInfo });
      var log = new Button(screen,
        { x: 161, y: 450, image: "log",
          onClick: onLog });
      debug = new Button(screen,
        { x: 104, y: 500, image: "debug",
          onClick: onDebug });
      debug.visible = Game.isDebug;
      var mainMenu = new Button(screen,
        { x: 67, y: 540, image: "mainmenu",
          onClick: onMainMenu });
    }


  public function onPlay(event)
    {
      ui.music.play();
    }


  public function onPause(event)
    {
      ui.music.pause();
    }


  public function onStop(event)
    {
      ui.music.stop();
    }


  public function onRandom(event)
    {
      ui.music.random();
    }


  public function onTrack(event)
    {
//      Browser.window.open(ui.music.getPage(), '');
    }


// try to lower awareness
  public function onLowerAwareness(target: DisplayObject)
    {
      if (game.isFinished)
        return;

      var name = new String(target.name);
	  var power = Std.parseInt(name.substr(14, 1));
      game.player.lowerAwareness(power);
    }


// try to lower willpower
  public function onLowerWillpower(target: DisplayObject)
    {
      if (game.isFinished)
        return;

      var name = new String(target.name);
	  var power = Std.parseInt(name.substr(14, 1));
      game.player.lowerWillpower(power);
    }


// upgrade button
  function onUpgrade(target: DisplayObject)
    {
      if (game.isFinished)
        return;

      var name = new String(target.name);
	  var lvl = Std.parseInt(name.substr(7, 1));
	  game.player.upgrade(lvl);
    }


// convert button
  function onConvert(target: DisplayObject)
    {
      if (game.isFinished)
        return;
    
      var name = new String(target.name);
	  var from = Std.parseInt(name.substr(7, 1));
      var to = Std.parseInt(name.substr(8, 1));
	  game.player.convert(from, to);
	}


// show log
  public function onLog(target: DisplayObject)
    {
      ui.logWindow.show();
    }


// end turn button
  public function onEndTurn(target: DisplayObject)
    {
      if (game.isFinished)
        return;

	  game.endTurn();
	}


// main menu button
  function onMainMenu(target: DisplayObject)
    {
      ui.mainMenu.show();
    }


// about game button
  function onAbout(target: DisplayObject)
    {
//      Browser.window.open("http://code.google.com/p/cult/wiki/About"); 
    }


// debug info button
  public function onDebug(target: DisplayObject)
    {
      if (game.isFinished || !Game.isDebug)
        return;

      ui.debug.show();
    }


// show info screen
  public function onInfo(target: DisplayObject)
    {
      ui.info.show();
    }


// update tooltip for object
  function updateTip(name, tip)
    {
//      e(name).title = tip;
      name = "#" + name;
      if (name.indexOf(".") > 0)
        {
          name = name.substr(0, name.indexOf(".")) + "\\" +
            name.substr(name.indexOf("."));
        }
//      new JQuery(name).attr('tooltipText', tip);
    }


// update status window (fups)
  public function update()
    {
      // update tooltips
	  for (i in 0...(Game.numPowers + 1))
        {
          var s = tipPowers[i] + 
            "<br>Chance to gain each unit: <span style='color:white'>" +
            game.player.getResourceChance() + "%</span>";
          updateTip("status.powerMark" + i, s);
          updateTip("status.powerName" + i, s);
        }
      for (i in 0...Game.followerLevels)
        {
          updateTip("status.follower" + i, tipFollowers[i]);
          updateTip("status.upgrade" + i, tipUpgrade[i] +
            "<br>Chance of success: <span style='color:white'>" +
            game.player.getUpgradeChance(i) + "%</span>");
        }
      updateTip("status.followers1",
        game.player.adeptsUsed + " used of " + game.player.adepts);

      // convert buttons
	  for (i in 0...(Game.numPowers + 1))
        for (ii in 0...Game.numPowers)
          {
            if (i == ii) continue;

            convert[ii][i].visible = 
              (game.player.power[i] >= Game.powerConversionCost[i]);
          }

      for (i in 0...Game.followerLevels) // update follower numbers
        {
          var s = "" + game.player.getNumFollowers(i);

          // adepts used
          if (i == 1 && game.player.adepts > 0)
            {
              s = "<font color='#55dd55'>" +
                (game.player.adepts - game.player.adeptsUsed) +
                "</font>";
            }
          s = "" + game.player.getNumFollowers(i); // vm crash workaround 
          followers[i].htmlText = s;
        }

	  for (i in 0...(Game.numPowers + 1)) // update powers
	    {
          powers[i].text = "" + game.player.power[i];
          if (i == 3)
            powersMod[i].text = " +0 - " +
              Std.int(game.player.neophytes / 4 - 0.5);
          else powersMod[i].text = 
            " +0 - " + game.player.powerMod[i];
		}

      turns.text = "" + game.turns;
      awareness.text = game.player.awareness + "%";

      // lower awareness buttons visibility
      for (i in 0...Game.numPowers)
        lowerAwareness[i].visible = false;
      if (game.player.adeptsUsed < game.player.adepts &&
          game.player.adepts > 0 && game.player.awareness > 0)
        for (i in 0...Game.numPowers)
          if (game.player.power[i] > 0)
            lowerAwareness[i].visible = true;

      // lower willpower buttons visibility
      for (i in 0...Game.numPowers)
        lowerWillpower[i].visible = false;
      if (game.player.hasInvestigator && !game.player.investigator.isHidden &&
          game.player.adeptsUsed < game.player.adepts && game.player.adepts > 0)
        for (i in 0...Game.numPowers)
          if (game.player.power[i] >= Game.willPowerCost)
            lowerWillpower[i].visible = true;

      // upgrade buttons visibility
      for (i in 0...(Game.followerNames.length - 1))
        upgrade[i].visible = game.player.canUpgrade(i);
    }


// update track name in status
  public function updateTrack()
    {
//      e("status.track").innerHTML = ui.music.getName();
    }


// get element shortcut
  public static inline function e(s)
    {
//	  return Browser.document.getElementById(s);
	}


// ===================== tips ===============

  static var tipPowers: Array<String> =
    [ UI.powerName(0) + " is needed to gain new followers.",
      UI.powerName(1) + " is needed to gain new followers.",
      UI.powerName(2) + " is needed to gain new followers.", 
      UI.powerName(3) + " are gathered by your neophytes.<br>" +
      "They are needed for rituals to upgrade your<br>followers " +
      "and also for the final ritual of summoning." ];
  static var tipConvert = "Cost to convert to ";
  static var tipUpgrade: Array<String> =
    [ "To gain an adept you need " + Game.upgradeCost +
      " neophytes and 1 virgin.",
      "To gain a priest you need " + Game.upgradeCost +
      " adepts and 2 virgins.",
      "To perform the " + Static.rituals[0].name +
      " you need " + Game.upgradeCost +
      " priests and " + Game.numSummonVirgins + " virgins.<br>" +
      "<li>The more society is aware of the cult the harder it is to " +
      "summon Elder God."];
  static var tipFollowers: Array<String> =
    [ "Neophytes can find some virgins if they're lucky.",
      "Adepts can lower society awareness and investigator's willpower.",
      "3 priests and " + Game.numSummonVirgins + 
      " virgins are needed to summon the Elder God." ];
  static var tipTurns = "Shows the number of turns passed from the start.";
  static var tipAwareness =
    "Shows how much human society is aware of the cult.<br>" +
    "<li>The greater awareness is the harder it is to do anything:<br>" +
    "gain new followers, resources or make rituals.<br> " +
    "<li>Adepts can lower the society awareness using resources.<br>" +
    "<li>The more adepts you have the more you can lower awareness each turn.";
  static var tipLowerAwareness =
    "Your adepts can use resources to lower society awareness.";
  static var tipLowerWillpower =
    "Your adepts can use resources to lower willpower of an investigator.<br>Cost: ";
  static var tipEndTurn = "Click to end current turn.";
  static var tipInfo = "Click to view cults information.";
  static var tipMainMenu = "Click to open main menu.";
  static var tipLog = "Click to view message log.";
  static var tipAbout = "Click to go to About page.";
}
