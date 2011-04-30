// sects information ui


class SectsInfo
{
  var ui: UI;
  var game: Game;

  public var window: Dynamic; // window element
  public var list: Dynamic; // list element
  public var text: Dynamic; // text element
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
      list.style.width = 200;
      list.style.height = 480;
      list.style.background = '#111';
      window.appendChild(list);

      // info text
      text = js.Lib.document.createElement("div");
      text.style.overflow = 'auto';
      text.style.position = 'absolute';
      text.style.left = 220;
      text.style.top = 10;
      text.style.width = 570;
      text.style.height = 480;
      text.style.background = '#111';
      window.appendChild(text);

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
    }


// helper: add list entry
  function listEntry(name: String, nodeid: Int, isMarked:Bool, isSelected: Bool)
    {
      var el = create(list, 'span');
      el.style.cursor = 'pointer';
      if (isSelected)
        el.style.backgroundColor = '#555555';
      el.innerHTML = (isMarked ? '! ' : '') + name;
      el.onclick = onClick;
      untyped el.nodeID = nodeid;
      create(list, 'br');
    }


// show info
  public function show()
    {
      // !!!DEBUG!!!
//      if (game.player.origin.sect == null)
//        game.player.createSect(game.player.origin);

      if ((selectedNode == null && game.getNode(selectedNodeID) == null) ||
          (selectedNode != null && 
            (selectedNode.owner == null || selectedNode.owner != game.player)))
        {
          selectedNode = null;
          selectedNodeID = 0;
        }
      var s = '';
      list.innerHTML = '';

      var el = create(list, 'span');
      el.innerHTML = '<center><u>Sects (' + game.player.sects.length + '/' +
        game.player.getMaxSects() + ')</u></center>';

      // list of sects
      for (sect in game.player.sects)
        listEntry(sect.name, sect.leader.id, 
          (sect.task != null), (selectedNodeID == sect.leader.id));

      // list of adepts
      var el = create(list, 'span');
      el.innerHTML = '<br><center><u>Adepts</u></center>';
      for (n in game.player.nodes)
        {
          if (n.level != 1 || n.sect != null)
            continue;
  
          listEntry(n.name, n.id, false, (selectedNodeID == n.id));
        }

      // list of neophytes
      var el = create(list, 'span');
      el.innerHTML = '<br><center><u>Neophytes</u></center>';
      for (n in game.player.nodes)
        {
          if (n.level != 0 || n.sect != null)
            continue;

          listEntry(n.name, n.id, false, (selectedNodeID == n.id));
        }

      text.innerHTML = '<center>Select a follower or a sect</center>';
/*
      // !!!DEBUG!!!
      if (selectedNode == null)
        {
          selectedNode = game.player.origin;
          selectedNodeID = selectedNode.id;

        }
*/
      if (selectedNode != null)
        {
          // show node/adept info
          if (selectedNode.sect != null)
            sectInfo(selectedNode);
          else nodeInfo(selectedNode);
        }

      window.style.visibility = 'visible';
      isVisible = true;
    }


// select task
  function onTaskSelect(e: Dynamic)
    {
      var b = Tools.getTarget(e);
      var target = null;
      if (Sect.availableTasks[b.taskID].target == 'cult')
        target = game.cults[b.cultID];

      selectedNode.sect.setTask(b.taskID, target);
      show();
//      sectInfo(selectedNode);
    }


// helper: update sect info panel (fis)
  function sectInfo(node: Node)
    {
      var sect = node.sect;
      var s = '';
      s += sect.name + '<br>';
      s += 'Leader: ' + sect.leader.name + '<br>';
      s += 'Level: ' + (sect.level + 1) + '<br>';
      s += 'Size: ' + sect.size + '<br>';
      s += 'Growth rate: ' + sect.getGrowth() + '<br>';
      s += '<br>';
      s += 'Current Task: ';
      if (sect.task == null)
        s += '-- None --';
      else
        {
          s += sect.task.name;
          if (!sect.task.isInfinite)
            s += ' (' + sect.taskPoints + '/' + sect.task.points + ')';
        }
      s += '<br>';
      if (sect.task != null)
        {
          if (sect.task.target == 'cult')
            s += 'Target: ' + cast(sect.taskTarget, Cult).fullName + '<br>';
        }
      s += '<br>';
      s += '= Tasks =<br>';
      text.innerHTML = s;
  
      // task buttons
      var tasksAvailable = false;
      for (i in 0...Sect.availableTasks.length)
        {
          var t = Sect.availableTasks[i];

          if (!sect.taskAvailable(t)) // check if this task available
            continue;

          var b = create(text, 'span');
          b.innerHTML = t.name;
          untyped b.taskID = i;
          if (t.target != 'cult')
            {
              b.style.cursor = 'pointer';
              b.onclick = onTaskSelect;
            }

          if (t.target == 'cult') // draw cult buttons
            {
              var isEmpty = true;
              for (c in game.cults)
                {
                  if (c == game.player || !c.isDiscovered)
                    continue;

                  if (t.id == 'cultGeneralInfo' && c.isInfoKnown)
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
                  
                  untyped b2.taskID = i;
                  untyped b2.cultID = c.id;
                  isEmpty = false;
                }

              if (isEmpty)
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

      var but = Tools.button({
        id: 'createSect',
        text: "CREATE SECT",
        w: 140,
        h: 20,
        x: 200,
        y: 100,
        fontSize: 16,
        container: text,
        func: onCreateSect
        });
      but.nodeID = node.id;
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
      show();
    }


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
