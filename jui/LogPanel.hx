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
      Browser.document.body.appendChild(panel);
    }


// clear and paint all player messages
  public function paint()
    {
      clear();

      for (m in game.player.logPanelMessages)
        {
          // choose symbol/color pair
          var sym = '';
          var col = '#e7e7e7';
          if (m.type == 'cult' || m.type == null) // cult-related message
            {
              var cult: Cult = m.obj;
              col = UI.vars.lineColors[cult.id];
            }
          else if (m.type == 'cults') // messages relating to 2 cults
            {
              var cult: Cult = m.obj.c1;
              var cult2: Cult = m.obj.c2;
              sym = "<span style='color:" + UI.vars.lineColors[cult.id] + "'>I</span>" +
                "<span style='color:" + UI.vars.lineColors[cult2.id] + "'>I</span>";
            }
          if (m.params != null && m.params.symbol != null)
             sym = m.params.symbol;

          // create element
          var e = Browser.document.createDivElement();
          m.id = list.length;
          e.id = 'log.id' + list.length;
          e.className = 'uiButton ' +
            (m.old ? 'logPanelItemOld' : 'logPanelItemNew');
          e.style.background = col;
          untyped e.messageID = m.id;
          e.style.top = '' + (list.length * 22);
//          e.style.color = col;
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
