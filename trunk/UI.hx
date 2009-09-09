// ui class for cult

import js.Lib;
import js.Dom;

//extern class JQuery extends Dummy {}
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
  var status: Dynamic;

  public static var mapWidth = 800;
  public static var mapHeight = 580;
  public static var tooltipWidth = 100;
  public static var tooltipHeight = 80;
  public static var markerWidth = 20;
  public static var markerHeight = 20;
  public static var nodeVisibility = 101;

  public function new(g)
    {
	  game = g;
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
        "font-weight: bold; font-size:20px;'>Cult v1</div><br>";

      s += "<fieldset>";
      s += "<legend>FOLLOWERS</legend>";
      s += "<table width=100% style='font-size:14px'>";

      // nodes
      for (i in 0...Game.followerNames.length)
        s += "<tr><td>" + Game.followerNames[i] + "s" +

          // icon
	      "<td><div id='status.upgrade" + i + "' " +
		  "style='cursor: pointer; width:12; height:12; " +
		  "background:#222; border:1px solid #777; " +
          "color:lightgreen; " +
		  "text-align:center; font-size: 10px; font-weight: bold; '>+</div>" +

          // number
          "<td><span id='status.followers" + i +
          "' style='font-weight:bold;'>0</span>";

      s += "</table></fieldset><br>";

      s += "<fieldset><legend" +
        " style='padding:0 5 0 5;color:lightgray;'>POWER RESERVE</legend>" +
        "<table width=100% cellpadding=3 cellspacing=0 style='font-size:14px'>";
      for (i in 0...4)
	    {
          s += "<tr style='";
          if (i % 2 == 1)
            s += "background:#101010";
          s += "'><td>" + 
	  	  // icon
		    "<div style='width:" + markerWidth +
		    "; height: " + markerHeight +
            "; font-size: 16px; " +
		    "; background:#222; border:1px solid #777; color: " +
            Game.powerColors[i] + ";'>" + 
		    "<center><b>" + Game.powerShortNames[i] +
		    "</b></center></div>" +
		  // name
		    "<td><b style='color:" + Game.powerColors[i] + ";'>" +
            Game.powerNames[i] + "</b>" +
		  // level
		    "<td><td><span id='status.power" +
		    i + "'>0</span><br>" +
            "<span style='font-size:10px' id='status.powerMod" + i +
            "'>0</span>";

		  // convert buttons
	  	  s += "<tr style='";
          if (i % 2 == 1)
            s += "background:#101010";
          s += "'><td colspan=4><table style='font-size:12px'>" +
            "<tr><td width=25 halign=right>To";
	  	  for (ii in 0...4)
			if (ii != i)
	      	  s += "<td><div id='status.convert" + i + ii + "' " +
			    "style='cursor: pointer; width:12; height:12; " +
		        "background:#222; border:1px solid #777; " +
                "color:" + Game.powerColors[ii] + "; " +
		    	"text-align:center; font-size: 10px; font-weight: bold; '>" +
		    	Game.powerShortNames[ii] + "</div>";
		  s += "</table>";
          s += "<tr height=5>";
		}
      s += "</table></fieldset>";


      s += "<fieldset>";
      s += "<legend>STATS</legend>";
      s += "<table width=100% style='font-size:14px'>";

      // turns
	  s += "<tr><td>Turns<td><span id='status.turns' "+
		  "style='font-weight:bold'>0</span>";

      s += "</table></fieldset><br>";

      // end turn button
	  s += "<br><center><button id='status.endTurn'>End<br>turn</button> ";
	 
      if (Game.isDebug)
        s += "<button id='status.debug'>DBG</button> ";

      // restart button
      s += "<button id='status.restart'>Restart</button></center>";
      
      status.innerHTML = s;

	  // setting events
	  for (i in 0...Game.followerNames.length)
		e("status.upgrade" + i).onclick = onStatusUpgrade;
	  for (i in 0...4)
	    for (ii in 0...4)
		  if (i != ii)
		    e("status.convert" + i + ii).onclick = onStatusConvert;
	  e("status.endTurn").onclick = onStatusEndTurn;
	  e("status.restart").onclick = onStatusRestart;
      e("status.debug").onclick = onStatusDebug;

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
//      e('jqDialog_box').style.width = '220';
//      e('jqDialog_box').style.height = '40';
      JQDialog.notify(s, 1);
	}


// debug info button
  function onStatusDebug(event)
    {
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
	  for (i in 0...4)
	    {
          e("status.power" + i).innerHTML = 
            "<b>" + game.power[i] + "</b>";
		  if (game.powerMod[i] > 0)
		    e("status.powerMod" + i).innerHTML =
              " +" + game.powerMod[i];
		  else
		    e("status.powerMod" + i).innerHTML =
              " " + game.powerMod[i];
		}
	
	  e("status.turns").innerHTML = "" + game.turns;

      // count number of nodes by level
      var cnt = new Array<Int>();
      for (i in Game.followerNames)
        cnt.push(0);
      for (n in game.nodes)
        if (n.isOwned)
          cnt[n.level]++;
      for (i in 0...cnt.length)
        e("status.followers" + i).innerHTML = "" + cnt[i];

      // upgrade buttons visibility
      for (i in 0...Game.followerNames.length)
//        if (cnt[i] >= Game.upgradeCost)
          e("status.upgrade" + i).style.visibility = 
            (cnt[i] >= Game.upgradeCost ? 'visible' : 'hidden');

    }


// finish game window
  public function finish(playerWon)
    {
      e('jqDialog_close').style.visibility = 'hidden';
//      e('jqDialog_box').style.width = '400';
//      e('jqDialog_box').style.height = '50';

      if (playerWon == 1)
        JQDialog.alert("You have taken over the world in " + game.turns +
          " turns.", onStatusRestart); }


// get element shortcut
  public static inline function e(s)
    {
	  return Lib.document.getElementById(s);
	}
}
