// temporary message window

import js.html.DivElement;
import js.Browser;

class Message
{
  var ui: UI;
  var game: Game;
  var timer: Int;

  var text: DivElement; // text element
  public var isVisible: Bool;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      isVisible = false;
      timer = null;
    }



// hide window
  public function onClose(event)
    {
      Browser.document.body.removeChild(text);
      isVisible = false;
    }


// timer to close window
  function runTimer()
    {
      onClose(null);
    }


// show window
  public function show(s: String)
    {
      // message window already visible, remove
      if (isVisible)
        onClose(null);

      if (timer != null)
        Browser.window.clearTimeout(timer);
      timer = Browser.window.setTimeout(runTimer, 1500);

      var w = 11 * (s.length + 4) + 40;

      text = Browser.document.createDivElement();
      text.className = 'messageText';
      text.innerHTML = s;
      Browser.document.body.appendChild(text);

      text.style.display = 'inline';
      isVisible = true;
    }
}

