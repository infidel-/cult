// sects information ui

import js.Browser;
import js.html.DivElement;
import js.html.SpanElement;
import sects.Sect;

class SectsInfo extends Window
{
  var list: DivElement; // list element
  var text: DivElement; // text element
  var menu: DivElement; // hovering menu element

  var selectedNode: Node; // selected node
  var selectedNodeID: Int; // selected node id (to store when window closed)


  public function new(uivar: UI, gvar: Game)
    {
      super(uivar, gvar, 'sects', 800, 536, 20);

      selectedNode = null;
      selectedNodeID = 0;

      // list
      var sectsBG = Browser.document.createDivElement();
      sectsBG.id = 'sectsBGIMG';
      window.appendChild(sectsBG);
      var sectsFG = Browser.document.createDivElement();
      sectsFG.id = 'sectsFG';
      sectsFG.className = 'uiTextFG';
      sectsBG.appendChild(sectsFG);
      list = Browser.document.createDivElement();
      list.id = 'sectsList';
//      list.className = 'uiText';
      sectsFG.appendChild(list);

      // info text
      text = js.Browser.document.createDivElement();
      text.className = 'cultInfoLabel';
      window.appendChild(text);

      // hovering menu
      menu = Tools.window({
        id: "sectsMenuWindow",
        fontSize: 16,
        w: 200,
        h: 280,
        z: 3000
      });
      menu.style.padding = '5px';
      menu.style.border = '1px solid';
      menu.style.opacity = '0.9';
    }


// key press
  public override function onKey(e: Dynamic)
    {
      // close current window
      if (e.keyCode == 27 || // Esc
          e.keyCode == 13 || // Enter
          e.keyCode == 32 || // Space
          e.keyCode == 83) // S
        {
          onClose(null);
          return;
        }
    }


// select task for a sect
  public function onSelect(strID: String)
    {
      var dotIndex = strID.indexOf('.');
      var dashIndex = strID.indexOf('-');
      var nodeID = Std.parseInt(strID.substr(0, dotIndex));
      var taskID = strID.substr(dotIndex + 1, dashIndex - dotIndex - 1);
      var targetID = Std.parseInt(strID.substr(dashIndex + 1));

//      trace(nodeID + ' ' + taskID + ' ' + targetID);

      // find this sect
      var sect = null;
      for (s in game.player.sects)
        if (s.leader.id == nodeID)
          {
            sect = s;
            sect.isAdvisor = false;
            break;
          }

      // clear task
      if (taskID == 'doNothing')
        {
          sect.clearTask();
          show();
          return;
        }

      var task = null;
      for (t in game.sectTasks)
        if (t.id == taskID)
          {
            task = t;
            break;
          }

      if (task == null)
        return;

      var target = null;
      if (task.type == 'cult')
        target = game.cults[targetID];

      sect.setTask(task, target);
      show();
    }


// show info
  override function onShow()
    {
      var s = '<table class=uiListSects cellspacing=3 cellpadding=3>' +
        '<tr><th>Info<th>Size<th>Current Task<th>AI';

      for (sect in game.player.sects)
        {
          s += '<tr class=uiListSectsRow><td>' + sect.name +
            ' <span class=shadow style="color:white">L' + (sect.level + 1) + '</span>, (' +
            sect.leader.name + ')';
          if (game.flags.devoted) // DEVOTED: counter and button
            {
              var isDisabled =
                (game.player.power[sect.powerID] <= 0 ||
                 (sect.level == 2 && sect.getMaxSize() == sect.size));
              s += ', <span id=sect.powerCount' + sect.id + '>' +
                sect.powerStorage + '</span>' +
                "&nbsp;<span class='uiButton" +
                  (isDisabled ? 'Disabled' : '') +
                  " spanButton' id='sect.powerSpend" + sect.id + "' " +
                  "style='color: var(--power-color-" + sect.powerID + ");'>" +
                  Game.powerShortNames[sect.powerID] + "</span>";
            }
          s += '<td style="text-align:center">' +
            sect.size + '/' + sect.getMaxSize() +
            ' <span id=sect.growth' + sect.id + ' class=uiListSectsPlus>(+' + sect.getGrowth() + ')</span>' +
            '<td>';

          s += "<select class=selectOption onchange='Game.instance.ui.sects.onSelect(this.value)'>";
//          "<option value=" + sect.leader.id + ".none>-- None --";

          for (t in game.sectTasks)
            {
              // no investigator
              if (t.type == 'investigator' && !game.player.hasInvestigator)
                continue;

              // skip expansion tasks if they're not available
              if (t.type == 'artifact' && !game.flags.artifacts)
                continue;

              // sect is too low-level
              if (t.level > sect.level)
                continue;

              // cult target task - check all other cults and draw cult buttons
              if (t.type == 'cult')
                {
                  for (c in game.cults)
                    {
                      if (c == game.player ||
                          !c.isDiscovered[game.player.id] ||
                          c.isDead)
                        continue;

                      // check start conditions
                      var ok = t.check(game.player, sect, c);
                      if (!ok)
                        continue;

                      s += '<option class=selectOption value=' + sect.leader.id + '.' + t.id + '-' + c.id +
                        (sect.task != null && sect.task.id == t.id &&
                          sect.taskTarget == c ? ' selected' : '') +
                        '>' + t.getName(sect) + ': ' + c.name;
                    }
                }

              // untargeted task
              else
                {
                  var ok = t.check(game.player, sect, null);
                  if (!ok)
                    continue;

                  s += '<option class=selectOption value=' + sect.leader.id + '.' + t.id + '-0 ' +
                    (sect.task != null && sect.task.id == t.id ? ' selected' : '') +
                    '>' + t.getName(sect);
                }

              // points
              if (sect.task != null && sect.task.id == t.id &&
                  !sect.task.isInfinite)
                s += ' (' + sect.taskPoints + '/' + sect.task.points + ')';
            }

          s += '</select>';

          s += '<td style="text-align:center">' +
            '<input type="checkbox" name="sectai' + sect.leader.id + '" ' +
            (sect.isAdvisor ? 'checked' : '') +
            ' onchange="Game.instance.ui.sects.onAdvisor(' + sect.leader.id +
            ', this.checked)">';
        }

      s += '</table>';
      list.innerHTML = s;
      text.innerHTML = 'Sects: ' + game.player.sects.length + '/' +
        game.player.getMaxSects();

      // DEVOTED: update tooltips
      if (game.flags.devoted)
        for (sect in game.player.sects)
          {
            ui.initTooltip('sect.powerSpend' + sect.id);
            ui.updateTip('sect.powerSpend' + sect.id,
              'Spend ' + sect.getPowerPerTurn() + ' ' +
              UI.powerName(sect.powerID) +
              ' per turn to make the sect devoted.' +
              '<br>When the sect is devoted: ' +
              '<li>It grows ' + Const.devotedGrowthBonus + '% faster.' +
              '<li>It gains ' + Const.devotedTaskPointsBonus + '% more task points.' +
              '<li>It adds to the base cult awareness each turn.');
            var btn: SpanElement = cast UI.e('sect.powerSpend' + sect.id);
            btn.onclick = onClickSpendPower;
          }

      window.style.display = 'inline';
      bg.style.display = 'inline';
      isVisible = true;
    }

// DEVOTED: spend power to buff sect
  function onClickSpendPower(event)
    {
      ui.sound.play('click');
      var target = Tools.getTarget(event);
      var sectID = Std.parseInt(target.id.substr(15));
      var sect = game.player.getSect(sectID);
      sect.spendPower();
      var counter = UI.e('sect.powerCount' + sectID);
      counter.innerHTML = '' + sect.powerStorage;
      if (game.player.power[sect.powerID] <= 0)
        target.className = 'uiButtonDisabled spanButton';
      counter.innerHTML = '' + sect.powerStorage;
      var growth = UI.e('sect.growth' + sectID);
      growth.innerHTML = '(+' + sect.getGrowth() + ')';
    }

// checkbox click callback
  public function onAdvisor(leaderID: Int, checked: Bool)
    {
//      trace(leaderID + ' ' + checked);

      for (sect in game.player.sects)
        if (sect.leader.id == leaderID)
          {
            sect.isAdvisor = checked;
            break;
          }
    }


// get element shortcut
  public static inline function e(s)
    {
      return Browser.document.getElementById(s);
    }


// create element shortcut
  public static inline function create(parent: Dynamic, s: String)
    {
      var el = Browser.document.createElement(s);
      parent.appendChild(el);
      return el;
    }
}
