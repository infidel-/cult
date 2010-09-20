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
      panel.style.height = (UI.mapHeight + 8);
      panel.style.left = 217;
      panel.style.top = 5;
      panel.style.background = '#111';
      Lib.document.body.appendChild(panel);
    }


// add item to log
  public function add(text: String)
    {
      // clear log if too many items
      if (list.length >= 24)
        clear();

      // create element
      var e = Lib.document.createElement("div");
      e.id = 'log.id' + list.length;
      e.style.position = 'absolute';
      e.style.width = '20';
      e.style.height = '20';
      e.style.left = '0';
      e.style.top = '' + (list.length * 24);
      e.style.background = '#222';
	  e.style.border = '1px solid #999';
	  e.style.cursor = 'pointer';
      e.style.fontSize = 15;
      e.style.color = 'white';
      e.style.fontWeight = 'bold';
      e.style.textAlign = 'center';
      e.innerHTML = '!';
      panel.appendChild(e);

	  e.onclick = onClick;
      e.title = "Turn " + (game.turns + 1) + ": " + text;
      new JQuery("#log\\.id" + list.length).tooltip({ delay: 0 });

      list.add(e);
    }


// remove log item
  public function onClick(event: Dynamic)
    {
      // remove item
	  var e = Tools.getTarget(event);
      panel.removeChild(e);
      list.remove(e);

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
