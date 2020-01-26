// ui for cult info

import js.html.DivElement;

class Info
{
  var ui: UI;
  var game: Game;

  var window: DivElement; // window element
  var bg: DivElement; // background element
  var text: DivElement; // text element
  public var isVisible: Bool;


  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      isVisible = false;

      // window
      window = Tools.window({
        id: "windowInfo",
        winW: UI.winWidth,
        winH: UI.winHeight,
        fontSize: 16,
        bold: true,
        w: 800,
        h: 520,
        z: 20
      });
      window.style.display = 'none';
      window.style.padding = '5 5 5 5';
      window.style.border = '4px double #ffffff';

      // info text
      text = js.Browser.document.createDivElement();
      text.style.overflow = 'auto';
      text.style.position = 'absolute';
      text.style.left = '10px';
      text.style.top = '10px';
      text.style.width = '780px';
      text.style.height = '480px';
      text.style.background = '#111';
      window.appendChild(text);

      bg = Tools.bg({ w: UI.winWidth + 20, h: UI.winHeight});
      var close = Tools.closeButton(window, 365, 493, 'infoClose');
      close.onclick = onClose;
    }


// hide info
  public function onClose(event)
    {
      window.style.display = 'none';
      bg.style.display = 'none';
      isVisible = false;
    }


// show info
  public function show()
    {
      var s = '';

      var i = 0;
      for (p in game.cults)
        {
//          if (!p.isDiscovered) // cult not discovered yet
//            continue;

          // name
          s += '<div style="' + (i == 0 ? 'background:#333333' :
            '') +
            '">';
          if (p.isDead)
            s += '<s>';
          s += (p.isDiscovered[game.player.id] ? p.fullName : '?');
          if (p.isDead)
            s += '</s> Forgotten';

          // wars list
          if (!p.isDead && p.isInfoKnown[game.player.id])
            {
              var w = '';
              for (i in 0...p.wars.length)
                if (p.wars[i])
                  w += UI.cultName(i, game.cults[i].info) + ' ';
              if (w != '')
                s += ' wars: ' + w;
            }
          s += '<br>';

          // investigator info
          if (p.hasInvestigator && p.isInfoKnown[game.player.id])
            {
              s += "<span style='font-size: 12px; color: #999999'>Investigator <span style='color: white'>" +
                p.investigator.name + "</span>";
              if (!p.investigator.isHidden)
                s += ": Level " + (p.investigator.level + 1) +
                ', Willpower ' + p.investigator.will;
              s += '</span>';
              if (p.investigator.isHidden)
                s += " <span style='color:#ffffff'>--- Hidden ---</span>";
              s += '<br>';
            }
          if (Game.isDebug && p.investigatorTimeout > 0 && p.isInfoKnown[game.player.id])
            s += " Investigator timeout: " + p.investigatorTimeout + "<br>";

          // debug info
          if (Game.isDebug)
            {
              s += "<span style='font-size: 10px'>";
              for (i in 0...p.power.length)
                {
                  s += UI.powerName(i, true) + ": " + p.power[i] + " (";
                  if (i < 3)
                    s += p.getResourceChance() + "%) ";
                  else s += (p.neophytes / 4 - 0.5) + ") ";
                }
              s += "<span title='Awareness'>A: " + p.awareness + "%</span> ";
              s += "<span title='Chance of summoning'>ROS: " + p.getUpgradeChance(2) + "%</span> ";
              if (!p.hasInvestigator)
                s += "<span title='Chance of investigator appearing'>IAC: " +
                  p.getInvestigatorChance() + "%</span> ";
              if (p.hasInvestigator)
                {
                  s += "<span title='Chance of investigator reveal'>IRC: " +
                    p.investigator.getKillChance() + "%</span> ";
                  s += "<span title='Chance of investigator willpower raise'>IWC: " +
                    p.investigator.getGainWillChance() + "%</span> ";
                }
              s += "<span title='Cult Power'>PWR: " +
                game.director.getCultPower(p) + "</span> ";
              s += 'Dif: ' + p.difficulty.level;
              s += "</span><br>";
            }

          // ritual
          if (p.isRitual && p.isInfoKnown[game.player.id])
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
          if (!p.isDead && p.isInfoKnown[game.player.id])
            {
              s += p.nodes.length + ' followers (' +
                p.neophytes + ' neophytes, ' + p.adepts + ' adepts, ' +
                p.priests + ' priests)';
              if (p.isParalyzed)
                s += " --- Paralyzed ---";
              s += '<br>';
            }

          // description
//          if (p.isInfoKnown)
            {
              s += "<span id='info.toggleNote" + i +
                "' style='height:10; width:10; font-size:12px; border: 1px solid #777'>+</span>";
              s += '<br>';
              s += "<span id='info.note" + i + "'>" +
                (p.isInfoKnown[game.player.id] ? p.info.note : 'No information.') + "</span>";
              s += "<span id='info.longnote" + i + "'>" +
                (p.isInfoKnown[game.player.id] ? p.info.longNote : 'No information.') + "</span>";
            }
          s += '</div><hr>';
          i++;
        }

      text.innerHTML = s;
      bg.style.display = 'inline';
      window.style.display = 'inline';
      isVisible = true;

      for (i in 0...game.difficulty.numCults)
        {
/*
          if (!game.cults[i].isDiscovered || !game.cults[i].isInfoKnown)
            continue;
          if (e("info.longnote" + i) == null)
            continue;
*/
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


// get element shortcut
  public static inline function e(s)
    {
      return js.Browser.document.getElementById(s);
    }
}
