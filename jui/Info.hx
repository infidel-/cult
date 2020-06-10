// ui for cult info

import js.Browser;
import js.html.DivElement;

class Info extends Window
{
  var text: DivElement; // text element


  public function new(uivar: UI, gvar: Game)
    {
      super(uivar, gvar, 'cultInfo', 800, 536, 20, 493);

      // info text
      text = Browser.document.createDivElement();
      text.className = 'uiText';
      text.style.fontSize = '16px';
      window.appendChild(text);
    }


// show info
  override function onShow()
    {
      var s = '';

      var i = 0;
      for (p in game.cults)
        {
//          if (!p.isDiscovered) // cult not discovered yet
//            continue;

          // name
          s += '<div class="cultInfoBlock" style="' + (i == 0 ? 'background:var(--text-select-bg)' :
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
              s += "<span class=cultInfoInv1>Investigator <span class=cultInfoInv2>" +
                p.investigator.name + "</span>";
              if (!p.investigator.isHidden)
                s += ": Level " + (p.investigator.level + 1) +
                ', Willpower ' + p.investigator.will;
              s += '</span>';
              if (p.investigator.isHidden)
                s += " <span class=cultInfoInv3>&lt;Hidden&gt;</span>";
              s += '<br>';
            }
          if (Game.isDebug && p.investigatorTimeout > 0 && p.isInfoKnown[game.player.id])
            s += " Investigator timeout: " + p.investigatorTimeout + "<br>";

          // debug info
          if (Game.isDebug)
            s += getDebugInfo(p, false);

          // ritual
          if (p.isRitual && p.isInfoKnown[game.player.id])
            {
              var turns = Std.int(p.ritualPoints / p.priests);
              if (p.ritualPoints % p.priests > 0)
                turns += 1;
              s += "Performing <span class=shadow title='" + p.ritual.note +
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

          // artifacts
          if (game.flags.artifacts && !p.isAI)
            s += ui.artifacts.getInfoString(p);

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
          var p = game.cults[i];

          new JQuery('#info\\.ritual' + i).tooltip({ delay: 0 });

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


// form debug info string
  public function getDebugInfo(p: Cult, status: Bool): String
    {
      var s = "<span style='font-size: 10px'>";
      for (i in 0...p.power.length)
        {
          s += UI.powerName(i, true) + ": " + p.power[i] + " (";
          if (i < 3)
            s += '+0-' + p.powerMod[i] + ', ' +
              p.getResourceChance() + "%), ";
          else s += '+0-' + p.maxVirgins() + "), ";
          if (status)
            s += '<br>';
        }
      s += "<span title='Awareness'>A: " + p.awareness + "%</span>, ";
      if (status)
        s += '<br>';
      s += "<span title='Chance of summoning'>ROS: " + p.getUpgradeChance(2) + "%</span>, ";
      if (status)
        s += '<br>';
      if (!p.hasInvestigator)
        s += "<span title='Chance of investigator appearing'>IAC: " +
          p.getInvestigatorChance() + "%</span>, ";
      if (p.hasInvestigator)
        {
          s += "<span title='Chance of investigator reveal'>IRC: " +
            p.investigator.getKillChance() + "%</span>, ";
          s += "<span title='Chance of lowering investigator willpower'>IWLC: " +
            p.investigator.getGainWillChance() + "%</span>, ";
          s += "<span title='Chance of investigator willpower raise'>IWC: " +
            p.getLowerWillChance() + "%</span>, ";
        }
      if (status)
        s += '<br>';
      s += "<span title='Cult Power'>PWR:&nbsp;" +
        game.director.getCultPower(p) + "</span>, ";
      s += 'Dif: ' + p.difficulty.level;
      s += "</span><br>";

      return s;
    }


// get element shortcut
  public static inline function e(s)
    {
      return js.Browser.document.getElementById(s);
    }
}
