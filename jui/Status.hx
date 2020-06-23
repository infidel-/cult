// status block

import js.Browser;
import js.html.DivElement;

class Status
{
  var ui: UI;
  var game: Game;

  var status: DivElement;
  var statusBorder: DivElement;
  var statusUpgrade: Array<DivElement>;
  var statusRitualUnveiling: DivElement;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;

      // status screen
      statusBorder = cast UI.e("statusBorder");
      status = cast UI.e("status");

      var s = '';
      s += '<div id=statusBG><div id=statusFG>';
      s += "<div id='status.cult'>-</div>";

      s += "<fieldset>";
      s += "<legend>FOLLOWERS</legend>";

      // unveiling ritual button
      s += "<div class='uiButton statusConvert statusUpgrade' id='status-ritual-unveiling'>U</div>";

      s += "<table class=statusTable cellpadding=0>";

      // followers
      for (i in 0...Game.followerNames.length)
        {
          s += "<tr style='height:10;'><td id='status.follower" + i + "'>" +
            Game.followerNames[i] + "s";

          // icon
          s += "<td><div class='uiButton statusConvert statusUpgrade' id='status.upgrade" + i + "'>";
          if (i < Game.followerNames.length - 1)
            s += "+";
          else s += "!";
          s += "</div>";

          // number
          s += "<td><span class='statusNumber' id='status.followers" + i +
          "'>0</span>";
        }
      s += "</table></fieldset>";

      s += "<fieldset><legend>RESOURCES</legend>" +
        '<table class=statusTable cellpadding=0';
      s += (UI.modernMode ? '>' : " cellspacing=0>");
      for (i in 0...(Game.numPowers + 1))
        {
          s += "<tr style='";
          if (UI.classicMode && i % 2 == 1)
            s += "background:#101010";
          s += "'><td>";
          // icon
          if (UI.classicMode)
            {
              s += "<div class='status.powerMark' id='status.powerMark" + i + "' style='color: var(--power-color-" + i + ");'>" +
                Game.powerShortNames[i] + "</div>";
            }
          else s += "<img width=20 height=20 src='./data/power-" +
            Game.powerNames[i].toLowerCase() + "-status.png'>";
          // name
          s += "<td><span class=powerText id='status.powerName" + i + "'>" + UI.powerName(i) + "</span>" +

            // level
            "<td><td><span id='status.power" +
            i + "'>0</span><br>" +
            "<span style='font-size:10px' id='status.powerMod" + i +
            "'>0</span>";

          // convert buttons
          s += "<tr style='";
          if (UI.classicMode && i % 2 == 1)
            s += "background:#101010";
          s += "'><td colspan=4><table class=statusResourceTable>" +
            "<tr><td width=20 halign=right>To";
          for (ii in 0...Game.numPowers)
            if (ii != i)
              s += "<td><div class='uiButton statusConvert' id='status.convert" + i + ii + "' " +
                "style='color: var(--power-color-" + ii + "); visibility: hidden;'>" +
                Game.powerShortNames[ii] + "</div>";

          // not for virgins
          if (i != 3)
            {
              s += "<td><div class='uiButton statusConvert' id='status.lowerAwareness" + i + "' " +
                "style='color:var(--awareness-color); visibility: hidden;'>A</div>";
              s += "<td halign=right>" +
                "<div class='uiButton statusConvert' id='status.lowerWillpower" + i + "' " +
                "style='color:var(--willpower-color); visibility: hidden;'>W</div>";
            }
          s += "</table>";
        }
      s += "</table></fieldset>";

      s += "<fieldset>";
      s += "<legend>STATS</legend>";
      s += "<table class=statusTable cellpadding=0>";

      // awareness
      s += "<tr id='status.awRow' title='" + tipAwareness +
        "'><td>Awareness<td><span id='status.awareness'>0</span>";
      // turns
      s += "<tr id='status.tuRow' title='" + tipTurns +
        "'><td>Turns<td><span id='status.turns'>0</span>";

      s += "</table></fieldset>";

      s += "<center style='padding:15 0 2 0'>";

      // buttons
      s += "<span title='" + tipEndTurn +
        "' id='status.endTurn' class='uiButton statusButton'>END TURN</span> ";
      s += "</center>";

      // music player
      s += "<fieldset id='musicplayer'>";
      s += "<legend>MUSIC</legend>";
      s += "<div id='status.track'>-<br>-<br>-</div>";
      s += "<center style='padding-top:2px'>";
      s += "<span class='uiButton statusButton musicButton2' title='Play' id='status.play'>PLAY</span>&nbsp;&nbsp;";
      s += "<span class='uiButton statusButton musicButton2' title='Pause' id='status.pause'>PAUSE</span>&nbsp;&nbsp;";
      s += "<span class='uiButton statusButton musicButton2' title='Stop' id='status.stop'>STOP</span>&nbsp;&nbsp;";
      s += "<span class='uiButton statusButton musicButton2' title='Random track' id='status.random'>RANDOM</span>";
      s += "</center></fieldset>";

      // buttons 2
      s += "<center style='padding-top:12px;'><span class='uiButton statusButton' title='" + tipMainMenu +
        "' id='status.mainMenu'>MAIN MENU</span></center>";
      if (Game.isDebug)
        s += '<div id=status.debug></div>';
      s += '</div></div>';

      status.innerHTML = s;

      var player: DivElement = cast UI.e('musicplayer');
      var b = Tools.button({
        id: 'status.musicPlus',
        text: '+',
        className: 'uiButton statusButton musicButton',
        w: null,
        h: null,
        x: null,
        y: null,
        container: player,
        title: "Click to increase music volume.",
        func: function (ev: Dynamic)
          {
            ui.music.increaseVolume();
          }
        });
      b.style.position = null;
      var b = Tools.button({
        id: 'status.musicMinus',
        text: '-',
        className: 'uiButton statusButton musicButton',
        w: null,
        h: null,
        x: null,
        y: null,
        container: player,
        title: "Click to decrease music volume.",
        func: function (ev: Dynamic)
          {
            ui.music.decreaseVolume();
          }
        });
      b.style.position = null;

      // setting events and tooltips
      statusUpgrade = [];
      for (i in 0...Game.followerNames.length)
        {
          e("status.follower" + i).title = tipFollowers[i];
          statusUpgrade.push(cast e("status.upgrade" + i));
          var c = statusUpgrade[i];
          c.onclick = onUpgrade;
          c.title = tipUpgrade[i];
        }
      statusRitualUnveiling = cast e('status-ritual-unveiling');
      statusRitualUnveiling.onclick = onRitual;
      for (i in 0...(Game.numPowers + 1))
        {
          if (UI.classicMode)
            {
              e("status.powerMark" + i).title = tipPowers[i];
              e("status.powerName" + i).title = tipPowers[i];
            }
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


// ritual button
  function onRitual(event: Dynamic)
    {
      if (game.isFinished)
        return;

      var id = Tools.getTarget(event).id.substr(14);
      game.player.startRitual(id);
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

      // clear messages for this turn
      game.player.logMessagesTurn = '';

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
            "<br>Chance to gain each unit: <span class=shadow style='color:white'>" +
            game.player.getResourceChance() + "%</span>";
          updateTip("status.powerMark" + i, s);
          updateTip("status.powerName" + i, s);
        }
      for (i in 0...Game.followerLevels)
        {
          updateTip("status.follower" + i, tipFollowers[i]);
          updateTip("status.upgrade" + i, tipUpgrade[i] +
            ((game.flags.artifacts && i == 1) ?
             ' You also need an artifact.' : '') +
            "<br>Chance of success: <span class=shadow style='color:white'>" +
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
              ((game.player.power[i] >= Game.powerConversionCost[i] &&
                !game.isFinished) ?
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
              s = '' + adepts;

//              s = "<span style='color:var(--adepts-color)'>" + adepts + "</span>";
            }
          var el = e("status.followers" + i);
          el.innerHTML = s;
          if (i == 1 && game.player.adepts > 0)
            {
              el.style.color = 'var(--adepts-color)';
              el.className = 'shadow statusNumber';
            }
          else
            {
              el.style.color = 'var(--text-color)';
              el.className = 'statusNumber';
            }
        }

      // update powers
      for (i in 0...(Game.numPowers + 1))
        {
          e("status.power" + i).innerHTML =
            "<b>" + game.player.power[i] + "</b>";
          if (i == 3) // virgins
            {
              var t = ' +0';
              if (game.player.maxVirgins() > 0)
                t += '-' +
                  (game.player.maxVirgins() + game.player.powerMod[i]);
              e("status.powerMod3").innerHTML = t;
            }
          else
            {
              var t = ' +0';
              if (game.player.powerMod[i] > 0)
                t = ' +0-' + game.player.powerMod[i];
              e("status.powerMod" + i).innerHTML = t;
            }
        }

      e("status.turns").innerHTML = "" + game.turns;
      var aw = e("status.awareness");
      aw.innerHTML = "" + game.player.awareness + "%";
      var col = 0;
      if (game.player.awareness >= 20)
        col = 2;
      else if (game.player.awareness >= 10)
        col = 1;
      if (UI.modernMode)
        aw.style.background = 'var(--awareness-text-color-' + col + ')';
      else aw.style.color = 'var(--awareness-text-color-' + col + ')';
      aw.className = (col > 0 ? 'blinking' : '');

      // lower awareness buttons visibility
      for (i in 0...Game.numPowers)
        e("status.lowerAwareness" + i).style.visibility = 'hidden';
      if (!game.isFinished &&
          game.player.adeptsUsed < game.player.adepts &&
          game.player.adepts > 0 &&
          game.player.awareness > 0)
        for (i in 0...Game.numPowers)
          if (game.player.power[i] > 0)
            e("status.lowerAwareness" + i).style.visibility = 'visible';

      // lower willpower buttons visibility
      for (i in 0...Game.numPowers)
        e("status.lowerWillpower" + i).style.visibility = 'hidden';
      if (!game.isFinished &&
          game.player.hasInvestigator &&
          !game.player.investigator.isHidden &&
          game.player.adeptsUsed < game.player.adepts &&
          game.player.adepts > 0)
        for (i in 0...Game.numPowers)
          if (game.player.power[i] >= Game.willPowerCost)
            e("status.lowerWillpower" + i).style.visibility = 'visible';

      // upgrade buttons visibility
      for (i in 0...Game.followerNames.length)
        statusUpgrade[i].className =
          (game.player.canUpgrade(i) ?
           'uiButton statusConvert statusUpgrade' :
           'uiButtonDisabled statusConvert statusUpgrade');
      statusRitualUnveiling.className =
        (game.player.canStartRitual('unveiling') ?
         'uiButton statusConvert statusUpgrade' :
         'uiButtonDisabled statusConvert statusUpgrade');
      e("status.endTurn").style.visibility =
        (!game.isFinished ? 'visible' : 'hidden');

      updateTip("status.follower2",
        Static.rituals['summoning'].priests + " priests and " +
        game.difficulty.numSummonVirgins +
        " virgins are needed to summon the Elder God.");
      updateTip("status.upgrade2",
        "To perform the " + Static.rituals['summoning'].name +
        " you need " + Static.rituals['summoning'].priests +
        " priests and " + game.difficulty.numSummonVirgins + " virgins.<br>" +
        "<li>The more society is aware of the cult the harder it is to " +
        "summon Elder God.");
      updateTip('status-ritual-unveiling',
        Static.rituals['unveiling'].note);

      if (Game.isDebug)
        e('status.debug').innerHTML = ui.info.getDebugInfo(game.player, true);
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

  static var tipPowers: Array<String> = [
    UI.powerName(0) + " is needed to gain new followers.",
    UI.powerName(1) + " is needed to gain new followers.",
    UI.powerName(2) + " is needed to gain new followers.",
    UI.powerName(3) + " are gathered by your neophytes.<br>" +
    "They are needed for rituals to upgrade your<br>followers " +
    "and also for the final ritual of summoning."
  ];
  static var tipConvert = "Cost to convert to ";
  static var tipUpgrade: Array<String> = [
    "To gain an adept you need " + Game.upgradeCost +
    " neophytes and 1 virgin.",
    "To gain a priest you need " + Game.upgradeCost +
    " adepts and 2 virgins.",
    '',
  ];
  static var tipFollowers: Array<String> = [
    "Neophytes can find some virgins if they're lucky.",
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
  static var tipEndTurn = "Click to end current turn (or press <span class=shadow style=\"color:white\">E</span>).";
  static var tipMainMenu = "Click to open main menu (or press <span class=shadow style=\"color:white\">ESC</span>).";
}
