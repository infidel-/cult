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

  // map and status divs
  public var map: Dynamic;
  public var music: Music;
  var status: Dynamic;

  public static var mapWidth = 800;
  public static var mapHeight = 580;
  public static var tooltipWidth = 100;
  public static var tooltipHeight = 80;
  public static var markerWidth = 15;
  public static var markerHeight = 15;
  public static var nodeVisibility = 101;
  static var colAwareness = "#ff9999";

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
      "For the ritual of summoning you need " + Game.upgradeCost +
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


  public function new(g)
    {
	  game = g;
      music = new Music();
      music.onRandom = updateTrack;
	}


// init game screen
  public function init()
    {
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

      var s = "<div style='padding:5 5 5 5; " +
        "font-weight: bold; font-size:20px;'>Evil Cult v1</div><br>";

      s += "<fieldset>";
      s += "<legend>FOLLOWERS</legend>";
      s += "<table width=100% style='font-size:14px'>";

      // followers
      for (i in 0...Game.followerNames.length)
        {
          s += "<tr><td id='status.follower" + i + "'>" +
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
        " style='padding:0 5 0 5;color:lightgray;'>RESOURCES</legend>" +
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
      s += "<table width=100% style='font-size:14px'>";

      // awareness
	  s += "<tr title='" + tipAwareness +
        "'><td>Awareness<td><span id='status.awareness' " +
		"style='font-weight:bold'>0</span>";
      // turns
	  s += "<tr title='" + tipTurns +
        "'><td>Turns<td><span id='status.turns' " +
		"style='font-weight:bold'>0</span>";

      s += "</table></fieldset>";

      // end turn button
	  s += "<center style='padding-top:10px'><button id='status.endTurn'>End<br>turn</button> ";
	 
      if (Game.isDebug)
        s += "<button id='status.debug'>DBG</button> ";

      // restart button
      s += "<button id='status.restart'>Restart</button></center>";
      
      s += "<fieldset style='bottom: 5px; margin-top: 10px; padding:0 5 0 5'>";
      s += "<legend>MUSIC</legend>";
      s += "<div id='status.track' " + 
        "style='background: #222; cursor:pointer; font-size:10px; color: #00ff00'> - </div>";
      s += "<table width=100% cellpadding=0 cellspacing=2>";
      s += "<tr><td><button id='status.play'>|></button>";
      s += "<td><button id='status.pause'>||</button>";
      s += "<td><button id='status.stop'>[]</button>";
      s += "<td><button id='status.random'>RND</button>";
      s += "</table></fieldset>";

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
	  e("status.restart").onclick = onStatusRestart;
      e("status.debug").onclick = onStatusDebug;
      e("status.play").onclick = onStatusPlay;
      e("status.pause").onclick = onStatusPause;
      e("status.stop").onclick = onStatusStop;
      e("status.random").onclick = onStatusRandom;
      e("status.track").onclick = onStatusTrack;

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
      new JQuery(function()
        { new JQuery('#status *').tooltip({ delay: 0 }); });

    }


  public function onStatusLowerAwareness(event)
    {
	  var power = Std.parseInt(event.target.id.substr(21, 1));
      game.lowerAwareness(power);
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


// update ui
  public function updateMap()
    {
	  // jquery map tooltip init
	  new JQuery(function()
	   { new JQuery('#map *').tooltip({ delay: 0 }); });
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


// debug info button
  function onStatusDebug(event)
    {
      for (i in 0...(Game.followerNames.length - 1))
        e("status.upgrade" + i).style.visibility = 'visible';

      for (n in game.nodes)
        n.marker.style.visibility = 'visible';
    }


// upgrade button
  function onStatusUpgrade(event)
    {
	  var lvl = Std.parseInt(event.target.id.substr(14, 1));

	  game.upgrade(lvl);
    }


// convert button
  function onStatusConvert(event)
    {
	  var from = Std.parseInt(event.target.id.substr(14, 1));
	  var to = Std.parseInt(event.target.id.substr(15, 1));

	  game.convert(from, to);
	}


// end turn button
  function onStatusEndTurn(event)
    {
	  game.endTurn();
	}


// restart game button
  function onStatusRestart(event)
    {
      game.restart();
    }


// on clicking node
  public function onNodeClick(event)
    {
      var node: Dynamic = event.target.node;
      game.activate(node);
    }


// update status window (fups)
  public function updateStatus()
    {
      // update tooltips
	  for (i in 0...(Game.numPowers + 1))
        {
          var s = tipPowers[i] + "<br>Chance to gain each unit: " +
            game.getResourceChance() + "%";
          e("status.powerMark" + i).title = s;
          e("status.powerName" + i).title = s;
        }
      for (i in 0...game.numFollowers.length)
        e("status.upgrade" + i).title = tipUpgrade[i] +
          "<br>Chance of success: " + game.getUpgradeChance(i) + "%";

      // convert buttons
	  for (i in 0...(Game.numPowers + 1))
        for (ii in 0...Game.numPowers)
          {
            if (i == ii) continue;

            var c = e("status.convert" + i + ii);
            c.style.visibility = 
              (game.power[i] >= Game.powerConversionCost[i] ? 'visible' :
               'hidden');
          }

      for (i in 0...game.numFollowers.length)
        e("status.followers" + i).innerHTML = "" + game.numFollowers[i];

      // update powers
	  for (i in 0...(Game.numPowers + 1))
	    {
          e("status.power" + i).innerHTML = 
            "<b>" + game.power[i] + "</b>";
          if (i == 3)
            e("status.powerMod3").innerHTML = " +0-" +
              Std.int(game.numFollowers[0] / 4 - 0.5);
		  else 
		    e("status.powerMod" + i).innerHTML =
              " +0-" + game.powerMod[i];
		}

	  e("status.turns").innerHTML = "" + game.turns;
	  e("status.awareness").innerHTML = "" + game.awareness + "%";
  
      for (i in 0...Game.numPowers)
        e("status.lowerAwareness" + i).style.visibility = 'hidden';
      if (game.adeptsUsed < game.numFollowers[1] &&
          game.numFollowers[1] > 0)
        for (i in 0...Game.numPowers)
          if (game.power[i] > 0)
            e("status.lowerAwareness" + i).style.visibility = 'visible';

      // upgrade buttons visibility
      for (i in 0...(Game.followerNames.length - 1))
          e("status.upgrade" + i).style.visibility =
            ((game.numFollowers[i] >= Game.upgradeCost &&
              game.power[3] >= i + 1) ?
             'visible' : 'hidden');

      // summon button visibility
      e("status.upgrade2").style.visibility = 
        ((game.numFollowers[2] >= Game.upgradeCost &&
          game.power[3] >= Game.numSummonVirgins) ?
          'visible' : 'hidden');
    }


// update track name in status
  public function updateTrack()
    {
      e("status.track").innerHTML = music.getName();
    }


// finish game window
  public function finish(state)
    {
      e('jqDialog_close').style.visibility = 'hidden';

      if (state == "summon")
        JQDialog.alert("The stars were right. The Elder God was summoned in " +
          game.turns +
          " turns.", onStatusRestart);

      else if (state == "conquer")
        JQDialog.alert("The cult has taken over the world in " +
          game.turns + " turns. The Elder Gods are pleased. ", onStatusRestart);
    }


// show colored power name
  static function powerName(i)
    {
      return "<span style='color:" + Game.powerColors[i] + "'>" +
        Game.powerNames[i] + "</span>";
    }


// message with confirmation
  public function alert(s)
    {
      JQDialog.alert(s);
    }


// get element shortcut
  public static inline function e(s)
    {
	  return Lib.document.getElementById(s);
	}
}
