// sects information ui

import js.html.DivElement;
import sects.Sect;

class SectsInfo
{
  var ui: UI;
  var game: Game;

  public var window: DivElement; // window element
  public var list: DivElement; // list element
  public var text: DivElement; // text element
  public var menu: DivElement; // hovering menu element
  public var isVisible: Bool;

  var selectedNode: Node; // selected node
  var selectedNodeID: Int; // selected node id (to store when window closed)


  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      isVisible = false;
      selectedNode = null;
      selectedNodeID = 0;
  
      // window
      window = Tools.window(
        {
          id: "windowSects",
          center: true,
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

      // list
      list = js.Browser.document.createDivElement();
      list.style.overflow = 'auto';
      list.style.position = 'absolute';
      list.style.left = '10px';
      list.style.top = '10px';
      list.style.width = '790px';
      list.style.height = '480px';
      list.style.background = '#111';
      window.appendChild(list);

      // info text
      text = js.Browser.document.createDivElement();
      text.style.overflow = 'auto';
      text.style.position = 'absolute';
      text.style.textAlign = 'center';
      text.style.left = '120px';
      text.style.top = '498px';
      text.style.width = '130px';
      text.style.height = '20px';
      text.style.background = '#111';
      window.appendChild(text);

      // hovering menu
      menu = Tools.window(
        {
          id: "sectsMenuWindow",
          center: true,
          winW: UI.winWidth,
          winH: UI.winHeight,
          fontSize: 16,
          w: 200,
          h: 280,
          z: 3000
        });
      menu.style.padding = '5px';
      menu.style.border = '1px solid';
      menu.style.opacity = '0.9';

      // close button
      var close = Tools.closeButton(window, 365, 493, 'infoClose');
	  close.onclick = onClose;
    }


// key press
  public function onKey(e: Dynamic)
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


// hide info
  public function onClose(event)
    {
      window.style.display = 'none';
      isVisible = false;
      list.innerHTML = '';
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
  public function show()
    {
      var s = '<table style="overflow:auto" cellspacing=3 cellpadding=3 width=100%>' +
        '<tr><th>Name<th>Leader<th>LVL<th>Size<th>Current Task<th>AI';

      for (sect in game.player.sects)
        {
          s += '<tr style="background:black"><td>' + sect.name + 
//            (Game.isDebug ? ' ' + sect.taskImportant : '') +
            '<td>' + sect.leader.name +
            '<td style="text-align:center">' + (sect.level + 1) + 
            '<td style="text-align:center">' + 
            sect.size + '/' + sect.getMaxSize() + ' (+' + sect.getGrowth() + ')' +
            '<td style="te1xt-align:center">';

          s += "<select class=secttasks onchange='Game.instance.ui.sects.onSelect(this.value)'>";
//          "<option value=" + sect.leader.id + ".none>-- None --";
          
          for (t in game.sectTasks)
            {
              // no investigator
              if (t.type == 'investigator' && !game.player.hasInvestigator)
                continue;

              // sect is too low-level
              if (t.level > sect.level)
                continue;

              // cult target task - check all other cults and draw cult buttons
              if (t.type == 'cult')
                {
                  for (c in game.cults)
                    {
                      if (c == game.player || !c.isDiscovered[game.player.id] || c.isDead)
                        continue;

                      // check start conditions
                      var ok = t.check(game.player, sect, c);
                      if (!ok)
                        continue;
              
                      s += '<option class=secttasks value=' + sect.leader.id + '.' + t.id + '-' + c.id + 
                        (sect.task != null && sect.task.id == t.id &&
                          sect.taskTarget == c ? ' selected' : '') +
                        '>' + t.name + ': ' + c.name;
                    }
                }

              // investigator type task
              else if (t.type == 'investigator')
                {
                  var ok = t.check(game.player, sect, null);
                  if (!ok)
                    continue;

                  s += '<option class=secttasks value=' + sect.leader.id + '.' + t.id + '-0 ' +
                    (sect.task != null && sect.task.id == t.id ? ' selected' : '') +
                    '>' + t.name;
                }
              else s += '<option class=secttasks value=' + sect.leader.id + '.' + t.id + '-0' +
                (sect.task != null && sect.task.id == t.id ? ' selected' : '') +
                '>' + t.name;
              
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

      window.style.display = 'inline';
      isVisible = true;
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
	  return js.Browser.document.getElementById(s);
	}


// create element shortcut
  public static inline function create(parent: Dynamic, s: String)
    {
      var el = js.Browser.document.createElement(s);
      parent.appendChild(el);
      return el; 
    }
}
