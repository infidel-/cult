// log panel

import js.Browser;
import js.html.DivElement;
import js.html.Element;

class LogPanel
{
  var ui: UI;
  var game: Game;

  var panel: DivElement;
  var list: List<DivElement>;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      list = new List();

      // panel element
      panel = Browser.document.createDivElement();
      panel.id = 'logPanel';
      panel.style.position = 'absolute';
      panel.style.width = '20px';
      panel.style.height = (UI.mapHeight + UI.topHeight + 8) + 'px';
      panel.style.left = '217px';
      panel.style.top = '5px';
      panel.style.background = '#090909';
      Browser.document.body.appendChild(panel);
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
              col = UI.vars.lineColors[cult.id];
            }
          else if (m.type == 'cults') // messages relating to 2 cults
            {
              var cult: Cult = m.obj.c1;
              var cult2: Cult = m.obj.c2;
              sym = "<span style='color:" + UI.vars.lineColors[cult.id] + "'>!</span>" +
                "<span style='color:" + UI.vars.lineColors[cult2.id] + "'>!</span>";
            }
          if (m.params != null && m.params.symbol != null)
             sym = m.params.symbol;

          // create element
          var e = Browser.document.createDivElement();
          m.id = list.length;
          e.id = 'log.id' + list.length;
          untyped e.messageID = m.id;
          e.style.position = 'absolute';
          e.style.width = '18';
          e.style.height = '18';
          e.style.left = '0';
          e.style.top = '' + (list.length * 22);
          e.style.background = (m.old ? '#050505' : '#151515');
          e.style.border = (m.old ? '1px solid #999' : '1px solid #fff');
          e.style.cursor = 'pointer';
          e.style.fontSize = '15px';
          e.style.color = col;
          e.style.fontWeight = 'bold';
          e.style.textAlign = 'center';
          e.style.setProperty('-webkit-user-select', 'none');
          if (m.params != null && m.params.important)
            e.style.textDecoration = 'blink';
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
      var nodes = panel.childNodes;
      for (i in 0...nodes.length)
        {
          var el: Element = cast nodes[i];
          el.style.top = (cnt * 24) + 'px';
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
