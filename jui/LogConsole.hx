// log console

import js.Browser;
import js.html.DivElement;
import js.html.MouseEvent;

class LogConsole
{
  var ui: UI;
  var game: Game;

  var window: DivElement; // window element
  var text: DivElement; // text element

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;

      window = Browser.document.createDivElement();
      window.id = 'logConsole';
      Browser.document.body.appendChild(window);

      // log text
      text = Browser.document.createDivElement();
      text.id = 'logConsoleText';
      window.appendChild(text);
      show(ui.config.getBool('consoleLog'));
    }

// add message to cult log
  public function getRenderedMessage(s: String): String
    {
      return
        "<span style='color:var(--text-color-log-time)'>" +
        DateTools.format(Date.now(), "%H:%M:%S") +
        "</span>" +
        " Turn " + (game.turns + 1) + ": " + s + "<br>";
    }

// toggle console on mouse over
  public function check(event: MouseEvent)
    {
      if (!ui.config.getBool('consoleLog'))
        return;
      var consoleRect = window.getBoundingClientRect();
      if (consoleRect.x < event.clientX &&
          consoleRect.y < event.clientY &&
          event.clientX < consoleRect.x + consoleRect.width &&
          event.clientY < consoleRect.y + consoleRect.height)
        window.style.opacity = '0.1';
      else window.style.opacity = '1.0';
    }

// show/hide
  public inline function show(val: Bool)
    {
      window.style.visibility = (val ? 'visible' : 'hidden');
    }


// clear log
  public function clear()
    {
      text.innerHTML = "";
    }


  public function update()
    {
      text.innerHTML = game.player.logMessagesTurn;
      text.scrollTop = 10000;
    }


  public function resize()
    {
      if (game.isNeverStarted)
        return;

      window.style.width = (ui.map.mapWidth - ui.map.minimap.width - 5) + 'px';
    }
}
