// sects information ui

import sects.Sect;

class SectsInfo
{
  var ui: UI;
  var game: Game;

  public var window: Dynamic; // window element
  public var list: Dynamic; // list element
  public var text: Dynamic; // text element
  public var menu: Dynamic; // hovering menu element
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
          id: "window",
          center: true,
          winW: UI.winWidth,
          winH: UI.winHeight,
          fontSize: 16,
          bold: true,
          w: 800,
          h: 520,
          z: 20
        });
      window.style.visibility = 'hidden';
      window.style.padding = '5 5 5 5';
	  window.style.border = '4px double #ffffff';

      // list
      list = js.Lib.document.createElement("div");
      list.style.overflow = 'auto';
      list.style.position = 'absolute';
      list.style.left = 10;
      list.style.top = 10;
      list.style.width = 790;
      list.style.height = 480;
      list.style.background = '#111';
      window.appendChild(list);

      // info text
      text = js.Lib.document.createElement("div");
      text.style.overflow = 'auto';
      text.style.position = 'absolute';
      text.style.textAlign = 'center';
      text.style.left = 120;
      text.style.top = 498;
      text.style.width = 130;
      text.style.height = 20;
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
      menu.style.padding = 5;
      menu.style.border = '1px solid';
      menu.style.opacity = 0.9;

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
          e.keyCode == 32) // Space
        {
          onClose(null);
          return;
        }
    }


// hide info
  public function onClose(event)
    {
      window.style.visibility = 'hidden';
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
//      show();
    }


// show info
  public function show()
    {
      var s = '<table style="overflow:auto" cellspacing=3 cellpadding=3 width=100%>' +
        '<tr><th>Name<th>Leader<th>LVL<th>Size<th>Current Task';

      for (sect in game.player.sects)
        {
          s += '<tr style="background:black"><td>' + sect.name + '<td>' + sect.leader.name +
            '<td style="text-align:center">' + (sect.level + 1) + 
            '<td style="text-align:center">' + 
            sect.size + '/' + sect.getMaxSize() + ' (+' + sect.getGrowth() + ')' +
            '<td style="te1xt-align:center">';
/*
          // display sect task
          if (sect.task == null)
            s += '-- None --';
          else
            {
              s += sect.task.name;
              if (!sect.task.isInfinite)
                s += ' (' + sect.taskPoints + '/' + sect.task.points + ')';
            }
          if (sect.task != null)
            {
              if (sect.task.type == 'cult')
                s += ' on ' + cast(sect.taskTarget, Cult).fullName + '<br>';
            }
*/
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
              
                      s += '<option value=' + sect.leader.id + '.' + t.id + '-' + c.id + 
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

                  s += '<option value=' + sect.leader.id + '.' + t.id + '-0 ' +
                    (sect.task != null && sect.task.id == t.id ? ' selected' : '') +
                    '>' + t.name;
                }
              else s += '<option value=' + sect.leader.id + '.' + t.id + '-0' +
                (sect.task != null && sect.task.id == t.id ? ' selected' : '') +
                '>' + t.name;
              
              // points
              if (sect.task != null && sect.task.id == t.id && 
                  !sect.task.isInfinite)
                s += ' (' + sect.taskPoints + '/' + sect.task.points + ')';
            }

          s += '</select>';
        }

      s += '</table>';
      list.innerHTML = s;
      text.innerHTML = 'Sects: ' + game.player.sects.length + '/' +
        game.player.getMaxSects();

      window.style.visibility = 'visible';
      isVisible = true;
    }

/*


// helper: update sect info panel (fis)
  function sectInfo(node: Node)
    {
      var sect = node.sect;
      var s = '';
      s += sect.name + '<br>';
      s += 'Leader: ' + sect.leader.name + '<br>';
      s += 'Level: ' + (sect.level + 1) + '<br>';
      s += 'Size: ' + sect.size + '/' + sect.getMaxSize() +
        ' (+' + sect.getGrowth() + ')<br>';
//      s += 'Growth rate: ' + sect.getGrowth() + '<br>';
      s += '<br>';
      s += 'Current Task: ';
      s += '<br>';
      s += '= Tasks =<br>';
      text.innerHTML = s;
  
      // task buttons
      var tasksAvailable = false;
      for (t in game.sectTasks)
        {
          // no investigator
          if (t.type == 'investigator' && !game.player.hasInvestigator)
            continue;

          // sect is too low-level
          if (t.level > sect.level)
            continue;

          var b = create(text, 'span');
          b.innerHTML = t.name;
          untyped b.taskID = t.id;
          if (t.type != 'cult')
            {
              b.style.cursor = 'pointer';
              b.onclick = onTaskSelect;
            }

          // cult target task - check all other cults and draw cult buttons
          if (t.type == 'cult')
            {
              var isEmpty = true;

              for (c in game.cults)
                {
                  if (c == game.player || !c.isDiscovered[game.player.id] || c.isDead)
                    continue;

                  // check start conditions
                  var ok = t.check(game.player, sect, c);
                  if (!ok)
                    continue;

                  var b2 = create(text, 'span');
                  b2.style.background = UI.nodeColors[c.id];
                  b2.style.border = '1px solid #777';
                  b2.style.cursor = 'pointer';
                  b2.style.marginLeft = '10px';
                  b2.style.fontSize = '11px';
                  b2.style.fontWeight = 'bold';
                  b2.onclick = onTaskSelect;
                  b2.innerHTML = '+';
                  
                  untyped b2.taskID = t.id;
                  untyped b2.cultID = c.id;
                  isEmpty = false;
                }

              if (isEmpty)
                {
                  text.removeChild(b);
                  continue;
                }
            }

          // investigator type task
          else if (t.type == 'investigator')
            {
              var ok = t.check(game.player, sect, null);
              if (!ok)
                {
                  text.removeChild(b);
                  continue;
                }
            }

          create(text, 'br');
          tasksAvailable = true;
        }

      if (!tasksAvailable)
        {
          var b = create(text, 'span');
          b.innerHTML = 'No tasks available.';
        }
    }


// helper: update node info panel (fin)
  function nodeInfo(node: Node)
    {
      var s = '';
      s += node.name + '<br>' +
        Game.followerNames[node.level];
      text.innerHTML = s;

      if (game.player.sects.length >= game.player.getMaxSects())
        return;
    }


// click on list entry
  public function onClick(e: Dynamic)
    {
      var el = Tools.getTarget(e);
      var node = game.getNode(el.nodeID);
      selectedNode = node;
      selectedNodeID = node.id;

      // show node/adept info
      if (node.sect != null)
        sectInfo(node);
      else nodeInfo(node);
      show();
    }


// create a new sect
  public function onCreateSect(e: Dynamic)
    {
      var el = Tools.getTarget(e);
      var node = game.getNode(el.nodeID);

      game.player.createSect(node);
      ui.map.paint();
      show();
    }
*/

// get element shortcut
  public static inline function e(s)
    {
	  return js.Lib.document.getElementById(s);
	}


// create element shortcut
  public static inline function create(parent: Dynamic, s: String)
    {
      var el = js.Lib.document.createElement(s);
      parent.appendChild(el);
      return el; 
    }
}
