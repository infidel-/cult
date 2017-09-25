// ui for cult info

import nme.text.TextField;
import nme.text.TextFormat;


class Info
{
  var ui: UI;
  var game: Game;

  public var window: Window; // window element
  public var text: TextField; // text element
  public var isVisible(getIsVisible, null): Bool;


  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
    }


// init stuff
  public function init()
    {
      window = new Window(ui.screen,
        {
          center: true,
          image: "logbg",
          w: 800, h: 500
        });

      // close button
      var close = new Button(window,
        { x: 364, y: 469, image: "close", onClick: onClose });

      // log text
      var tf : TextFormat = new TextFormat();
      tf.font = "FreeSans";
      tf.size = 16;
      text = new TextField();
      text.x = 15;
      text.y = 15;
      text.width = 780;
      text.height = 450;
      text.multiline = true;
      text.wordWrap = true;
      text.textColor = 0xffffff;
      text.selectable = false;
      text.defaultTextFormat = tf;
      window.addChild(text);
    }


// hide info
  public function onClose(event)
    {
      window.visible = false;
    }


// show info
  public function show()
    {
      var s = '';

      var i = 0;
      for (p in game.cults)
        {
          // name
          s += '<div style="' + (i == 0 ? 'background:#333333' :
            '') +
            '">';
          if (p.isDead)
            s += '<s>';
          s += UI.cultName(i, p.info);
          if (p.isDead)
            s += '</s> Forgotten';

          // wars
          if (!p.isDead)
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
          if (p.hasInvestigator)
            {
              s += "<span style='font-size: 12px; color: #999999'>Investigator: Level " +
                (p.investigator.level + 1) +
                ', Willpower ' + p.investigator.will + '</span>';
              if (Game.isDebug && p.investigator.isHidden)
                s += " Hidden";
              s += '<br>';
            }
          if (Game.isDebug && p.investigatorTimeout > 0)
            s += "Investigator timeout: " + p.investigatorTimeout + "<br>";

          // debug info
          if (Game.isDebug)
            {
              s += "<span style='font-size: 10px'>";
              for (i in 0...p.power.length)
                {
                  s += UI.powerName(i) + ": " + p.power[i] + " (";
                  if (i < 3)
                    s += p.getResourceChance() + "%) ";
                  else s += (p.neophytes / 4 - 0.5) + ") ";
                }
              s += "<span title='Awareness'>A: " + p.awareness + "%</span> ";
              s += "<span title='Chance of summoning'>ROS: " + p.getUpgradeChance(2) + "%</span> ";
              s += "<span title='Chance of investigator appearing'>IC: " +
                p.getInvestigatorChance() + "%</span> ";
              if (p.hasInvestigator)
                s += "<span title='Chance of investigator reveal'>RC: " +
                  p.investigator.getKillChance() + "%</span> ";
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
          if (!p.isDead)
            {
              s += p.nodes.length + ' followers (' +
                p.neophytes + ' neophytes, ' + p.adepts + ' adepts, ' +
                p.priests + ' priests)';
              if (p.isParalyzed)
                s += " Paralyzed";
              s += '<br>';
            }

          // description
//          s += "<span id='info.toggleNote" + i +
//            "' style='height:10; width:10; font-size:12px; border: 1px solid #777'>+</span>";
//          s += '<br>';
          s += "<span id='info.note" + i + "'>" + p.info.note + "</span>";
//          s += "<span id='info.longnote" + i + "'>" + p.info.longNote + "</span>";
          s += '</div><br><br>';
          i++;
        }

      // temporary de-htmling

      s = StringTools.replace(s, "<br>", "\n");
      var sb = new StringBuf();
      var arr = s.split('<');
      var start = 0;
      for (t in arr)
        sb.add(t.substr(t.indexOf('>') + 1));

      text.text = sb.toString();

//      text.htmlText = s;
      window.visible = true;

/*
      for (i in 0...Game.numCults)
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
*/
    }


// getter for isVisible
  function getIsVisible(): Bool
    {
      return window.visible;
    }
}
