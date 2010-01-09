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

  public var map: Dynamic; // map element
  var status: Dynamic; // status element
  var logWindow: Dynamic; // log window element
  var logText: Dynamic; // log text element
  var infoWindow: Dynamic; // info window element
  var infoText: Dynamic; // info text element
  var alertWindow: Dynamic; // alert window element
  var alertText: Dynamic; // alert text element

  public static var mapWidth = 800;
  public static var mapHeight = 580;
  public static var tooltipWidth = 100;
  public static var tooltipHeight = 80;
  public static var markerWidth = 15;
  public static var markerHeight = 15;
  public static var nodeVisibility = 101;
  static var colAwareness = "#ff9999";

  public function new(g)
    {
	  game = g;
      music = new Music();
      music.onRandom = updateTrack;
	}


// init game screen
  public function init()
    {
      // log window
      logWindow = Lib.document.createElement("logWindow");
      logWindow.style.visibility = 'hidden';
      logWindow.style.position = 'absolute';
      logWindow.style.zIndex = 20;
      logWindow.style.left = 100;
      logWindow.style.top = 50;
      logWindow.style.width = 800;
      logWindow.style.height = 500;
      logWindow.style.background = '#333333';
	  logWindow.style.border = '4px double #ffffff';
      Lib.document.body.appendChild(logWindow);

      // log text
      logText = Lib.document.createElement("logText");
      logText.style.overflow = 'auto';
      logText.style.position = 'absolute';
      logText.style.left = 10;
      logText.style.top = 10;
      logText.style.width = 780;
      logText.style.height = 450;
      logText.style.background = '#0b0b0b';
	  logText.style.border = '1px solid #777';
      logWindow.appendChild(logText);

      // log close button
      var logClose = createCloseButton(logWindow, 360, 465, 'logClose');
	  logClose.onclick = onLogCloseClick;

      // alert window
      alertWindow = Lib.document.createElement("alertWindow");
      alertWindow.style.visibility = 'hidden';
      alertWindow.style.position = 'absolute';
      alertWindow.style.zIndex = 20;
      alertWindow.style.width = 600;
      alertWindow.style.height = 450;
      alertWindow.style.left = 200; 
      alertWindow.style.top = 50;
      alertWindow.style.background = '#222';
	  alertWindow.style.border = '4px double #ffffff';
      Lib.document.body.appendChild(alertWindow);

      // alert text
      alertText = Lib.document.createElement("alertText");
      alertText.style.overflow = 'auto';
      alertText.style.position = 'absolute';
      alertText.style.left = 10;
      alertText.style.top = 10;
      alertText.style.width = 580;
      alertText.style.height = 400;
      alertText.style.background = '#111';
	  alertText.style.border = '1px solid #777';
      alertWindow.appendChild(alertText);

      // alert close button
      var alertClose = createCloseButton(alertWindow, 260, 415, 'alertClose');
	  alertClose.onclick = onAlertCloseClick;

      // info window
      infoWindow = Lib.document.createElement("infoWindow");
      infoWindow.style.fontSize = 16;
      infoWindow.style.fontWeight = 'bold';
      infoWindow.style.visibility = 'hidden';
      infoWindow.style.position = 'absolute';
      infoWindow.style.zIndex = 20;
      infoWindow.style.left = 100;
      infoWindow.style.top = 45;
      infoWindow.style.width = 800;
      infoWindow.style.height = 520;
      infoWindow.style.background = '#111';
      infoWindow.style.padding = '5 5 5 5';
	  infoWindow.style.border = '4px double #ffffff';
      Lib.document.body.appendChild(infoWindow);

      // info text
      infoText = Lib.document.createElement("logText");
      infoText.style.overflow = 'auto';
      infoText.style.position = 'absolute';
      infoText.style.left = 10;
      infoText.style.top = 10;
      infoText.style.width = 780;
      infoText.style.height = 480;
      infoText.style.background = '#111';
      infoWindow.appendChild(infoText);

      // info close button
      var infoClose = createCloseButton(infoWindow, 365, 490, 'infoClose');
	  infoClose.onclick = onInfoCloseClick;

	  // status screen
      status = e("status");
      status.style.border = 'double white 4px';
      status.style.width = 191;
      status.style.height = mapHeight - 10;
      status.style.position = 'absolute';
      status.style.left = 5;
      status.style.top = 5;
      status.style.padding = 5;
      status.style.fontSize = '12px';
      status.style.overflow = 'hidden';

      var s = "<div style='padding:0 5 5 5; background: #111; height: 20; " +
        "font-weight: bold; font-size:20px;'>Evil Cult v" +
        Game.version + "</div>";

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
		    "<div id='status.powerMark" + i + "' style='width:" + markerWidth +
		    "; height: " + markerHeight +
            "; font-size: 12px; " +
		    "; background:#222; border:1px solid #777; color: " +
            Game.powerColors[i] + ";'>" + 
		    "<center><b>" + Game.powerShortNames[i] +
		    "</b></center></div>" +
		  // name
            "<td><b id='status.powerName" + i + "' " + powerName(i) + "</b>" +
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
                "color:" + Game.powerColors[ii] + "; " +
		    	"text-align:center; font-size: 10px; font-weight: bold; '>" +
		        Game.powerShortNames[ii] + "</div>";

          if (i != 3)
	        s += "<td><div id='status.lowerAwareness" + i + "' " +
			  "style='cursor: pointer; width:12; height:12; " +
		      "background:#222; border:1px solid #777; " +
              "color:" + colAwareness + "; " +
		      "text-align:center; font-size: 10px; font-weight: bold; '>A</div>";
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
	  s += "<span title='" + tipInfo +
        "' id='status.info' class=button>INFO</span> ";
      s += "<span class=button title='" + tipLog + "' id='status.log'>LOG</span> ";
      if (Game.isDebug)
        s += "<span class=button width=10 height=10 id='status.debug'>D</span> ";
      s += "</center>";

      // music player
      s += "<fieldset style='bottom: 5px; margin-top: 10px; height: 60px; padding:0 5 0 5'>";
      s += "<legend>MUSIC</legend>";
      s += "<div id='status.track' " + 
        "style='background: #222; cursor:pointer; font-size:10px; color: #00ff00'> - </div>";
      s += "<center style='padding-top:10px'>";
      s += "<span class=button title='Play' id='status.play'>|></span>&nbsp;&nbsp;";
      s += "<span class=button title='Pause' id='status.pause'>||</span>&nbsp;&nbsp;";
      s += "<span class=button title='Stop' id='status.stop'>[]</span>&nbsp;&nbsp;";
      s += "<span class=button title='Random track' id='status.random'>RANDOM</span>";
      s += "</center></fieldset>";

      // buttons 2
      s += "<center style='padding-top:8px;'><span class=button title='" + tipRestart +
        "' id='status.restart'>RESTART GAME</span>&nbsp;&nbsp;";
      s += "<span class=button title='" + tipAbout +
        "' id='status.about'>ABOUT</span></center>";
      
      status.innerHTML = s;

	  // setting events and tooltips
	  for (i in 0...Game.followerNames.length)
        {
          e("status.follower" + i).title = tipFollowers[i];
          var c = e("status.upgrade" + i);
          c.onclick = onStatusUpgrade;
          c.title = tipUpgrade[i];
        }
	  for (i in 0...(Game.numPowers + 1))
        {
          e("status.powerMark" + i).title = tipPowers[i];
          e("status.powerName" + i).title = tipPowers[i];
          for (ii in 0...Game.numPowers)
		    if (i != ii)
              {
                var c = e("status.convert" + i + ii);
		        c.onclick = onStatusConvert;
                c.title = tipConvert + powerName(ii) + ": " +
                  Game.powerConversionCost[i];
              }

          if (i != 3)
            {
              var c = e("status.lowerAwareness" + i);
		      c.onclick = onStatusLowerAwareness;
              c.title = tipLowerAwareness;
            }
        }
	  e("status.endTurn").onclick = onStatusEndTurn;
	  e("status.info").onclick = onStatusInfo;
	  e("status.log").onclick = onStatusLog;
	  e("status.restart").onclick = onStatusRestart;
	  e("status.about").onclick = onStatusAbout;
      if (Game.isDebug)
        e("status.debug").onclick = onStatusDebug;
      e("status.play").onclick = onStatusPlay;
      e("status.pause").onclick = onStatusPause;
      e("status.stop").onclick = onStatusStop;
      e("status.random").onclick = onStatusRandom;
      e("status.track").onclick = onStatusTrack;
//      if (!Game.isDebug)
//        e("status.debug").style.visibility = 'hidden';

      // map display
      map = e("map");
      map.style.border = 'double white 4px';
      map.style.width = mapWidth;
      map.style.height = mapHeight;
      map.style.position = 'absolute';
      map.style.left = 220;
      map.style.top = 5;
      map.style.overflow = 'hidden';
/*
      new JQuery('map').css({
        border: 'double green 4px',
        width: mapWidth,
        height: mapHeight});
*/
  
      new JQuery('#status *').tooltip({ delay: 0 });
/*
//          JQDialog.alert("NO IE!", function() { });
      new JQuery().ready(function()
        {
          untyped JQDialog.init();
          JQDialog.alert("NO IE!", function() { });
        });
*/
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


  public function onStatusPlay(event)
    {
      music.play();
    }


  public function onStatusPause(event)
    {
      music.pause();
    }


  public function onStatusStop(event)
    {
      music.stop();
    }


  public function onStatusRandom(event)
    {
      music.random();
    }


  public function onStatusTrack(event)
    {
      Lib.window.open(music.getPage(), '');
    }


// show log
  function onStatusLog(event: Dynamic)
    {
      logText.scrollTop = 10000;
      logWindow.style.visibility = 'visible';
    }


// hide log
  function onLogCloseClick(event)
    {
      logWindow.style.visibility = 'hidden';
    }


// hide alert
  function onAlertCloseClick(event)
    {
      alertWindow.style.visibility = 'hidden';
    }


// hide info
  function onInfoCloseClick(event)
    {
      infoWindow.style.visibility = 'hidden';
    }


// try to lower awareness
  public function onStatusLowerAwareness(event: Dynamic)
    {
      if (game.isFinished)
        return;

	  var power = Std.parseInt(getTarget(event).id.substr(21, 1));
      game.player.lowerAwareness(power);
    }


// clear map
  public function clearMap()
    {
      while (map.hasChildNodes())
        map.removeChild(map.firstChild);
    }


// message box 
  public inline function msg(s)
	{
      e('jqDialog_close').style.visibility = 'hidden';
      JQDialog.notify(s, 1);
	}


// debug info button (fdeb)
  function onStatusDebug(event)
    {
      if (game.isFinished)
        return;

      for (i in 0...4)
        game.player.power[i] += 100;
      updateStatus();

/*
      game.player.isRitual = true;
      game.player.ritual = Static.rituals[0];
      game.player.ritualTurns =3;

      game.players[1].isRitual = true;
      game.players[1].ritual = Static.rituals[0];
      game.players[1].ritualTurns = 3;
*/
//    for (p in game.players)
//      p.isDead = true;
/*
    for (p in game.players)
      {
        p.isRitual = true;
        p.ritual = Static.rituals[0];
        p.ritualTurns = 3;
      }
*/    
/*
      for (p in game.players)
        for (i in 0...4)
          if (i != p.id)
            p.wars[i] = true;
*/
//      finish(game.players[1], "summon");
/*
      for (i in 0...(Game.followerNames.length - 1))
        e("status.upgrade" + i).style.visibility = 'visible';
*/
      for (n in game.nodes)
        n.setVisible(game.player, true);

//      game.players[2].summonFinish();
    }


// upgrade button
  function onStatusUpgrade(event: Dynamic)
    {
      if (game.isFinished)
        return;

	  var lvl = Std.parseInt(getTarget(event).id.substr(14, 1));

	  game.player.upgrade(lvl);
    }


// convert button
  function onStatusConvert(event: Dynamic)
    {
      if (game.isFinished)
        return;

	  var from = Std.parseInt(getTarget(event).id.substr(14, 1));
	  var to = Std.parseInt(getTarget(event).id.substr(15, 1));

	  game.player.convert(from, to);
	}


// end turn button
  function onStatusEndTurn(event: Dynamic)
    {
      if (game.isFinished)
        return;

	  game.endTurn();
	}


// restart game button
  function onStatusRestart(event: Dynamic)
    {
      game.restart();
    }


// about game button
  function onStatusAbout(event: Dynamic)
    {
      Lib.window.open("http://code.google.com/p/cult/wiki/About"); 
    }


// compatibility crap
  public function getTarget(event): Dynamic
    {
      if (event == null)
        event = untyped __js__("window.event");
      var t = event.target;
      if (t == null)
        t = event.srcElement;
      return t;
    }

// on clicking node
  public function onNodeClick(event: Dynamic)
    {
      if (game.isFinished)
        return;

      game.player.activate(getTarget(event).node);
    }


// update status window (fups)
  public function updateStatus()
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
        e("status.followers" + i).innerHTML = "" +
          game.player.getNumFollowers(i);

      // update powers
	  for (i in 0...(Game.numPowers + 1))
	    {
          e("status.power" + i).innerHTML = 
            "<b>" + game.player.power[i] + "</b>";
          if (i == 3)
            e("status.powerMod3").innerHTML = " +0-" +
              Std.int(game.player.neophytes / 4 - 0.5);
		  else 
		    e("status.powerMod" + i).innerHTML =
              " +0-" + game.player.powerMod[i];
		}

	  e("status.turns").innerHTML = "" + game.turns;
	  e("status.awareness").innerHTML = "" + game.player.awareness + "%";
 
      // lower awareness buttons visibility
      for (i in 0...Game.numPowers)
        e("status.lowerAwareness" + i).style.visibility = 'hidden';
      if (game.player.adeptsUsed < game.player.adepts &&
          game.player.adepts > 0 && game.player.awareness > 0)
        for (i in 0...Game.numPowers)
          if (game.player.power[i] > 0)
            e("status.lowerAwareness" + i).style.visibility = 'visible';

      // upgrade buttons visibility
      for (i in 0...(Game.followerNames.length - 1))
          e("status.upgrade" + i).style.visibility =
            ((game.player.getNumFollowers(i) >= Game.upgradeCost &&
              game.player.virgins >= i + 1) ?
             'visible' : 'hidden');

      // summon button visibility
      e("status.upgrade2").style.visibility = 
        ((game.player.priests >= Game.upgradeCost &&
          game.player.virgins >= Game.numSummonVirgins) ?
          'visible' : 'hidden');
    }


// update track name in status
  public function updateTrack()
    {
      e("status.track").innerHTML = music.getName();
    }


// finish game window (ffin)
  public function finish(player, state)
    {
      var msg = "<div style='text-size: 20px'><b>Game over</b></div><br>";

      if (state == "summon" && !player.isAI)
        {
          msg += "The stars were right. The Elder God was summoned in " +
            game.turns + " turns.";
          track("winGame", "summon", game.turns);
        }

      else if (state == "summon" && player.isAI)
        {
          msg += cultName(player.id, player.info) +
            " has completed the " + Static.rituals[0].name + ".<br><br>" +
            untyped player.info.summonFinish;
          track("loseGame", "summon", game.turns);
        }

      else if (state == "conquer" && !player.isAI)
        {
          msg += cultName(player.id, player.info) + " has taken over the world in " +
            game.turns + " turns. The Elder Gods are pleased.";
          track("winGame", "conquer", game.turns);
        }

      else if (state == "conquer" && player.isAI)
        {
          msg += cultName(player.id, player.info) + " has taken over the world. You fail.";
          track("loseGame", "conquer", game.turns);
        }

      else if (state == "wiped")
        {
          msg += cultName(player.id, player.info) + " was wiped away completely. " +
            "The Elder God lies dormant beneath the sea, waiting.";
          track("loseGame", "wiped", game.turns);
        }

      alert(msg);
    }


// create close button
  function createCloseButton(container: Dynamic, x: Int, y: Int, name: String)
    {
      var b: Dynamic = Lib.document.createElement(name);
      b.innerHTML = '<b>Close</b>';
      b.style.fontSize = 20;
      b.style.position = 'absolute';
      b.style.width = 80;
      b.style.height = 25;
      b.style.left = x;
      b.style.top = y;
      b.style.background = '#111';
	  b.style.border = '1px outset #777';
	  b.style.cursor = 'pointer';
      b.style.textAlign = 'center';
      container.appendChild(b);
      return b;
    }


// show info screen (finf)
  function onStatusInfo(event: Dynamic)
    {
      var s = '';

      var i = 0;
      for (p in game.players)
        {
          // name
          s += '<div style="' + (i == 0 ? 'background:#333333' : 
            '') +
            '">';
          if (p.isDead)
            s += '<s>';
          s += cultName(i, p.info);
          if (p.isDead)
            s += '</s> Forgotten';

          // wars
          if (!p.isDead)
            {
              var w = '';
              for (i in 0...p.wars.length)
                if (p.wars[i])
                  w += cultName(i, game.players[i].info) + ' ';
              if (w != '')
                s += ' wars: ' + w;
            }
          s += '<br>';

          // debug info
          if (Game.isDebug)
            {
              s += "<span style='font-size: 10px'>";
              for (i in 0...p.power.length)
                {
                  s += powerName(i) + ": " + p.power[i] + " (";
                  if (i < 3)
                    s += p.getResourceChance() + "%) ";
                  else s += (p.neophytes / 4 - 0.5) + ") ";
                }
              s += "Awareness: " + p.awareness + "% ";
              s += "ROS: " + p.getUpgradeChance(2) + "% ";
              s += "</span><br>";
            }

          // ritual
          if (p.isRitual == true)
            {
              var turns = Std.int(p.ritualPoints / p.priests);
              if (p.ritualPoints % p.priests > 0)
                turns += 1;
              s += "Casting <span title='" + p.ritual.note +
                "' id='info.ritual" + i +
                "' style='color:#ffaaaa'>" + p.ritual.name +
                "</span>, " + (p.ritual.points - p.ritualPoints) + "/" +
                p.ritual.points + " points, " + turns +
                " turns left<br>";
            }

          // followers
          s += p.nodes.length + ' followers (' +
            p.neophytes + ' neophytes, ' + p.adepts + ' adepts, ' +
            p.priests + ' priests)';
          if (p.isParalyzed)
            s += " Paralyzed";
          s += '<br>';

          // description
          s += "<span id='info.toggleNote" + i +
            "' style='height:10; width:10; font-size:12px; border: 1px solid #777'>+</span>";
          s += '<br>';
          s += "<span id='info.note" + i + "'>" + p.info.note + "</span>";
          s += "<span id='info.longnote" + i + "'>" + p.info.longNote + "</span>";
          s += '</div><hr>';
          i++;
        }

      infoText.innerHTML = s;
      infoWindow.style.visibility = 'visible';

      for (i in 0...Game.numPlayers)
        {
          e("info.longnote" + i).style.display = 'none';
          var c:Dynamic = e("info.toggleNote" + i);
          c.style.cursor = 'pointer';
          c.noteID = i;
          c.onclick =
            function(event) 
              {
                var t: Dynamic = event.target;
                if (t.innerHTML == '+')
                  {
                    t.innerHTML = '&mdash;';
                    e("info.longnote" + t.noteID).style.display = 'block';
                    e("info.note" + t.noteID).style.display = 'none';
                  }
                else
                  {
                    t.innerHTML = '+';
                    e("info.longnote" + t.noteID).style.display = 'none';
                    e("info.note" + t.noteID).style.display = 'block';
                  }
              };
        }
    }


// show colored power name
  static function powerName(i)
    {
      return "<span style='color:" + Game.powerColors[i] + "'>" +
        Game.powerNames[i] + "</span>";
    }


// show colored cult name
  public static function cultName(i, info)
    {
      return "<span style='color:" + Game.playerColors[i] + "'>" +
        info.name + "</span>";
    }


// message with confirmation
  public function alert(s)
    {
      alertText.innerHTML = '<center>' + s + '</center>';
      alertWindow.style.visibility = 'visible';
    }


// add message to log
  var logPrevTurn: Int;
  public function log(s: String, ?show: Bool)
    {
//      if (logPrevTurn != game.turns)
//        logText.innerHTML += "<center style='font-size:10px'>...</center><br>";
      logText.innerHTML += 
        "<span style='color:#888888'>" +
        DateTools.format(Date.now(), "%H:%M:%S") +
        "</span>" +
        " Turn " + (game.turns + 1) + ": " + s + "<br>";
      if (show == null || show == true)
        onStatusLog(null);
      logPrevTurn = game.turns;
    }


// clear log
  public function clearLog()
    {
      logText.innerHTML = "";
    }


// get element shortcut
  public static inline function e(s)
    {
	  return Lib.document.getElementById(s);
	}


// track stuff through google analytics
  public inline function track(action: String, ?label: String, ?value: Int)
    {
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


// ===================== tips ===============

  static var tipPowers: Array<String> =
    [ powerName(0) + " is needed to gain new followers.",
      powerName(1) + " is needed to gain new followers.",
      powerName(2) + " is needed to gain new followers.", 
      powerName(3) + " are gathered by your neophytes.<br>" +
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
      "Adepts can lower society awareness.",
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
  static var tipEndTurn = "Click to end current turn.";
  static var tipInfo = "Click to view cults information.";
  static var tipRestart = "Click to restart a game.";
  static var tipLog = "Click to view message log.";
  static var tipAbout = "Click to go to About page.";
}
