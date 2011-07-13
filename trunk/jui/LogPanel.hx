// log panel

import js.Lib;
import js.Dom;

class LogPanel
{
  var ui: UI;
  var game: Game;

  var panel: Dynamic;
  var list: List<Dynamic>;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      list = new List<Dynamic>();

      // panel element
      panel = Lib.document.createElement("div");
      panel.id = 'logPanel';
      panel.style.position = 'absolute';
      panel.style.width = 20;
      panel.style.height = (UI.mapHeight + UI.topHeight + 8);
      panel.style.left = 217;
      panel.style.top = 5;
      panel.style.background = '#090909';
      Lib.document.body.appendChild(panel);
    }


// darken older messages on end turn
  public function endTurn()
    {
      for (e in list)
        e.style.background = '#050505';
    }


// clear and paint all player messages
  public function paint()
    {
      clear();

      for (m in game.player.logPanelMessages)
        {
          // choose symbol/color pair
          var sym = '!';
          var col = 'white';
          if (m.type == 'cult' || m.type == null) // cult-related message
            {
              var cult: Cult = m.obj;
              col = UI.lineColors[cult.id]; 
            }
          else if (m.type == 'cults') // messages relating to 2 cults
            {
              var cult: Cult = m.obj.c1;
              var cult2: Cult = m.obj.c2;
              sym = "<span style='color:" + UI.lineColors[cult.id] + "'>!</span>" +
                "<span style='color:" + UI.lineColors[cult2.id] + "'>!</span>";
            }

          // create element
          var e = Lib.document.createElement("div");
          m.id = list.length;
          e.id = 'log.id' + list.length;
          untyped e.messageID = m.id;
          e.style.position = 'absolute';
          e.style.width = '18';
          e.style.height = '18';
          e.style.left = '0';
          e.style.top = '' + (list.length * 22);
          e.style.background = '#151515';
          e.style.border = '1px solid #999';
          e.style.cursor = 'pointer';
          e.style.fontSize = 15;
          e.style.color = col;
          e.style.fontWeight = 'bold';
          e.style.textAlign = 'center';
          e.innerHTML = sym;
          panel.appendChild(e);

          e.onclick = onClick;
          e.title = "Turn " + m.turn + ": " + m.text;
          new JQuery("#log\\.id" + list.length).tooltip({ delay: 0 });

          list.add(e);
        }
    }


// remove log item
  public function onClick(event: Dynamic)
    {
      // remove item
	  var e:Dynamic = Tools.getTarget(event);
      if (e.parentNode != panel) // hack for !! items
        e = e.parentNode;
      panel.removeChild(e);
      list.remove(e);

      // remove item from log
      for (m in game.player.logPanelMessages)
        if (m.id == e.messageID)
          game.player.logPanelMessages.remove(m);

      // pack items
      var cnt = 0;
      var nodes: HtmlCollection<HtmlDom> = panel.childNodes;
      for (i in 0...nodes.length)
        {
          nodes[i].style.top = '' + (cnt * 24);
          cnt++;
        }
    }


// clear log
  public function clear()
    {
      list.clear();
      while (panel.hasChildNodes())
        panel.removeChild(panel.firstChild);
    }
}
