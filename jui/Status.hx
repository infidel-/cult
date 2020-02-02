// status block

import js.Browser;
import js.html.DivElement;

class Status
{
  var ui: UI;
  var game: Game;

  var status: DivElement; // element

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;

      // status screen
      status = cast UI.e("status");
      status.style.border = 'double #777 4px';
      status.style.width = '191px';
      status.style.height = (UI.mapHeight + UI.topHeight - 10) + 'px';
      status.style.position = 'absolute';
      status.style.left = '5px';
      status.style.top = '5px';
      status.style.padding = '5px';
      status.style.fontSize = '12px';
      status.style.overflow = 'hidden';
      status.style.userSelect = 'none';

      var s = "<div id='status.cult' style='padding:0 5 5 5; background: #111; height: 17; " +
        "font-weight: bold; font-size:15px; text-align:center;'>-</div>";

      s += "<fieldset>";
      s += "<legend>FOLLOWERS</legend>";
      s += "<table width=100% cellpadding=0 cellspacing=2 style='font-size:14px'>";

      // followers
      for (i in 0...Game.followerNames.length)
        {
          s += "<tr style='height:10;'><td id='status.follower" + i + "'>" +
            Game.followerNames[i] + "s";

          // icon
          s += "<td><div id='status.upgrade" + i + "' " +
            "style='cursor: pointer; width:12; height:12; " +
            "background:#222; border:1px solid #777; " +
            "color:lightgreen; " +
            (i < Game.followerNames.length - 1 ? "" :
              "text-decoration:blink; ") +
            "text-align:center; font-size: 10px; font-weight: bold; '>";
          if (i < Game.followerNames.length - 1)
            s += "+";
          else s += "!";
          s += "</div>";

          // number
          s += "<td><span id='status.followers" + i +
          "' style='font-weight:bold;'>0</span>";
        }

      s += "</table></fieldset>";

      s += "<fieldset><legend" +
        " style='padding:0 5 0 5;'>RESOURCES</legend>" +
        "<table width=100% cellpadding=0 cellspacing=0 style='font-size:14px'>";
      for (i in 0...(Game.numPowers + 1))
        {
          s += "<tr style='";
          if (i % 2 == 1)
            s += "background:#101010";
          s += "'><td>" +
            // icon
            "<div id='status.powerMark" + i + "' style='width:" + UI.markerWidth +
            "; height: " + UI.markerHeight +
            "; font-size: 12px; " +
            "background:#222; border:1px solid #777; color: " +
            UI.powerColors[i] + ";'>" +
            "<center><b>" + Game.powerShortNames[i] +
            "</b></center></div>" +
          // name
            "<td><b id='status.powerName" + i + "' " + UI.powerName(i) + "</b>" +
          // level
            "<td><td><span id='status.power" +
            i + "'>0</span><br>" +
            "<span style='font-size:10px' id='status.powerMod" + i +
            "'>0</span>";

          // convert buttons
          s += "<tr style='";
          if (i % 2 == 1)
            s += "background:#101010";
          s += "'><td colspan=4><table style='font-size:11px'>" +
            "<tr><td width=20 halign=right>To";
            for (ii in 0...Game.numPowers)
            if (ii != i)
                s += "<td><div id='status.convert" + i + ii + "' " +
                "style='cursor: pointer; width:12; height:12; " +
                "background:#222; border:1px solid #777; " +
                "color:" + UI.powerColors[ii] + "; " +
                "text-align:center; font-size: 10px; font-weight: bold; '>" +
                Game.powerShortNames[ii] + "</div>";

          // not for virgins
          if (i != 3)
            {
              s += "<td><div id='status.lowerAwareness" + i + "' " +
                "style='cursor: pointer; width:12; height:12; " +
                "background:#222; border:1px solid #777; " +
                "color:" + UI.colAwareness + "; " +
                "text-align:center; font-size: 10px; font-weight: bold; '>A</div>";
              s += "<td halign=right><div id='status.lowerWillpower" + i + "' " +
                "style='cursor: pointer; width:12; height:12; " +
                "background:#222; border:1px solid #777; " +
                "color:" + UI.colWillpower + "; " +
                "text-align:center; font-size: 10px; font-weight: bold; '>W</div>";
            }
          s += "</table>";
        }
      s += "</table></fieldset>";

      s += "<fieldset>";
      s += "<legend>STATS</legend>";
      s += "<table cellpadding=0 cellspacing=2 width=100% style='font-size:14px'>";

      // awareness
      s += "<tr id='status.awRow' title='" + tipAwareness +
        "'><td>Awareness<td><span id='status.awareness' " +
        "style='font-weight:bold'>0</span>";
      // turns
      s += "<tr id='status.tuRow' title='" + tipTurns +
        "'><td>Turns<td><span id='status.turns' " +
        "style='font-weight:bold'>0</span>";

      s += "</table></fieldset>";

      s += "<center style='padding:15 0 2 0'>";

      // buttons
      s += "<span title='" + tipEndTurn +
        "' id='status.endTurn' class=button>END TURN</span> ";
      s += "</center>";

      // music player
      s += "<fieldset id='musicplayer'>";
      s += "<legend>MUSIC</legend>";
      s += "<div id='status.track' style='text-align: center; background: #222; font-size:10px; color: #00ff00; user-select: text'>-<br>-<br>-</div>";
      s += "<center style='padding-top:0px'>";
      s += "<span class=button2 title='Play' id='status.play'>PLAY</span>&nbsp;&nbsp;";
      s += "<span class=button2 title='Pause' id='status.pause'>PAUSE</span>&nbsp;&nbsp;";
      s += "<span class=button2 title='Stop' id='status.stop'>STOP</span>&nbsp;&nbsp;";
      s += "<span class=button2 title='Random track' id='status.random'>RANDOM</span>";
      s += "</center></fieldset>";

      // buttons 2
      s += "<center style='padding-top:12px;'><span class=button title='" + tipMainMenu +
        "' id='status.mainMenu'>MAIN MENU</span></center>";

      status.innerHTML = s;

      Tools.button({
        id: 'status.musicPlus',
        text: '+',
        w: 12,
        h: 12,
        x: 155,
        y: 444,
        fontSize: 10,
        container: status,
        title: "Click to increase music volume.",
        func: function (ev: Dynamic)
          {
            ui.music.increaseVolume();
          }
        });
      Tools.button({
        id: 'status.musicMinus',
        text: '-',
        w: 12,
        h: 12,
        x: 174,
        y: 444,
        fontSize: 10,
        container: status,
        title: "Click to decrease music volume.",
        func: function (ev: Dynamic)
          {
            ui.music.decreaseVolume();
          }
        });

      // setting events and tooltips
      for (i in 0...Game.followerNames.length)
        {
          e("status.follower" + i).title = tipFollowers[i];
          var c = e("status.upgrade" + i);
          c.onclick = onUpgrade;
          c.title = tipUpgrade[i];
          c.style.visibility = 'hidden';
        }
      for (i in 0...(Game.numPowers + 1))
        {
          e("status.powerMark" + i).title = tipPowers[i];
          e("status.powerName" + i).title = tipPowers[i];
          for (ii in 0...Game.numPowers)
            if (i != ii)
              {
                var c = e("status.convert" + i + ii);
                c.onclick = onConvert;
                c.title = tipConvert + UI.powerName(ii) + ": " +
                  Game.powerConversionCost[i];
              }

          if (i != 3)
            {
              var c = e("status.lowerAwareness" + i);
              c.onclick = onLowerAwareness;
              c.title = tipLowerAwareness;
              var c = e("status.lowerWillpower" + i);
              c.onclick = onLowerWillpower;
              c.title = tipLowerWillpower + Game.willPowerCost;
            }
        }
      e("status.endTurn").onclick = onEndTurn;
      e("status.mainMenu").onclick = onMainMenu;
      e("status.play").onclick = onPlay;
      e("status.pause").onclick = onPause;
      e("status.stop").onclick = onStop;
      e("status.random").onclick = onRandom;
      new JQuery('#status *').tooltip({ delay: 0 });
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


// try to lower awareness
  public function onLowerAwareness(event: Dynamic)
    {
      if (game.isFinished)
        return;

      var power = Std.parseInt(Tools.getTarget(event).id.substr(21, 1));
      game.player.lowerAwareness(power);
    }


// try to lower willpower
  public function onLowerWillpower(event: Dynamic)
    {
      if (game.isFinished)
        return;

      var power = Std.parseInt(Tools.getTarget(event).id.substr(21, 1));
      game.player.lowerWillpower(power);
    }


// upgrade button
  function onUpgrade(event: Dynamic)
    {
      if (game.isFinished)
        return;

      var lvl = Std.parseInt(Tools.getTarget(event).id.substr(14, 1));

      game.player.upgrade(lvl);
    }


// convert button
  function onConvert(event: Dynamic)
    {
      if (game.isFinished)
        return;

      var from = Std.parseInt(Tools.getTarget(event).id.substr(14, 1));
      var to = Std.parseInt(Tools.getTarget(event).id.substr(15, 1));

      game.player.convert(from, to);
    }


// end turn button
  public function onEndTurn(event: Dynamic)
    {
      if (game.isFinished)
        return;

      // clear node highlight
      game.player.highlightedNodes.clear();

      // set all messages as old
      for (m in game.player.logPanelMessages)
        m.old = true;

      game.endTurn();
    }


// main menu button
  function onMainMenu(event: Dynamic)
    {
      ui.mainMenu.show();
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
      new JQuery(name).attr('tooltipText', tip);
    }


// update status window (fups)
  public function update()
    {
      e("status.cult").innerHTML = game.player.fullName;

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
        (game.player.adeptsUsed > game.player.adepts ?
          game.player.adepts : game.player.adeptsUsed) +
        " used of " + game.player.adepts);

      // convert buttons
      for (i in 0...(Game.numPowers + 1))
        for (ii in 0...Game.numPowers)
          {
            if (i == ii) continue;

            var c = e("status.convert" + i + ii);
            c.style.visibility =
              (game.player.power[i] >= Game.powerConversionCost[i] ?
               'visible' : 'hidden');
          }

      for (i in 0...Game.followerLevels)
        {
          var s = "" + game.player.getNumFollowers(i);

          // adepts used
          if (i == 1 && game.player.adepts > 0)
            {
              var adepts = game.player.adepts - game.player.adeptsUsed;
              if (adepts < 0)
                adepts = 0;
              s = "<span style='color:#55dd55'>" + adepts + "</span>";
            }
          e("status.followers" + i).innerHTML = s;
        }

      // update powers
      for (i in 0...(Game.numPowers + 1))
        {
          e("status.power" + i).innerHTML =
            "<b>" + game.player.power[i] + "</b>";
          if (i == 3)
            e("status.powerMod3").innerHTML = " +0-" +
              game.player.maxVirgins();
          else
            e("status.powerMod" + i).innerHTML =
              " +0-" + game.player.powerMod[i];
        }

      e("status.turns").innerHTML = "" + game.turns;
      var aw = e("status.awareness");
      aw.innerHTML = "" + game.player.awareness + "%";
      var col = 'white';
      if (game.player.awareness >= 20)
        col = '#ff2222';
      else if (game.player.awareness >= 10)
        col = '#ffff44';
      aw.style.color = col;

      // lower awareness buttons visibility
      for (i in 0...Game.numPowers)
        e("status.lowerAwareness" + i).style.visibility = 'hidden';
      if (game.player.adeptsUsed < game.player.adepts &&
          game.player.adepts > 0 && game.player.awareness > 0)
        for (i in 0...Game.numPowers)
          if (game.player.power[i] > 0)
            e("status.lowerAwareness" + i).style.visibility = 'visible';

      // lower willpower buttons visibility
      for (i in 0...Game.numPowers)
        e("status.lowerWillpower" + i).style.visibility = 'hidden';
      if (game.player.hasInvestigator && !game.player.investigator.isHidden &&
          game.player.adeptsUsed < game.player.adepts && game.player.adepts > 0)
        for (i in 0...Game.numPowers)
          if (game.player.power[i] >= Game.willPowerCost)
            e("status.lowerWillpower" + i).style.visibility = 'visible';

      // upgrade buttons visibility
      for (i in 0...Game.followerNames.length)
        e("status.upgrade" + i).style.visibility =
          (game.player.canUpgrade(i) ? 'visible' : 'hidden');

      updateTip("status.follower2",
        "3 priests and " + game.difficulty.numSummonVirgins +
          " virgins are needed to summon the Elder God.");
      updateTip("status.upgrade2",
        "To perform the " + Static.rituals[0].name +
        " you need " + Game.upgradeCost +
        " priests and " + game.difficulty.numSummonVirgins + " virgins.<br>" +
        "<li>The more society is aware of the cult the harder it is to " +
        "summon Elder God.");
    }


// update track name in status
  public function onMusic()
    {
      e("status.track").innerHTML = ui.music.getName();
    }


// get element shortcut
  public static inline function e(s)
    {
      return Browser.document.getElementById(s);
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
      '',
      ];
  static var tipFollowers: Array<String> =
    [ "Neophytes can find some virgins if they're lucky.",
      "Adepts can lower society awareness and investigator's willpower.",
      ''
      ];
  static var tipTurns = "Shows the number of turns passed from the start.";
  static var tipAwareness =
    "Shows how much human society is aware of the cult.<br>" +
    "<li>The greater awareness is the harder it is to do anything:<br>" +
    "gain new followers, resources or make rituals.<br> " +
    "<li>Adepts can lower the society awareness using resources.<br>" +
    "<li>The more adepts you have the more you can lower awareness each turn." +
    "<li>With very low awareness the cult can stay undetected by an investigator.";
  static var tipLowerAwareness =
    "Your adepts can use resources to lower society awareness.";
  static var tipLowerWillpower =
    "Your adepts can use resources to lower willpower of an investigator.<br>Cost: ";
  static var tipEndTurn = "Click to end current turn (or press <span style=\"color:white\">E</span>).";
  static var tipMainMenu = "Click to open main menu (or press <span style=\"color:white\">ESC</span>).";
}
