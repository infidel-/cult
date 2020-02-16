// temporary message window

import js.html.DivElement;
import js.Browser;

class Message
{
  var ui: UI;
  var game: Game;
  var timer: Int;

  var window: DivElement; // window element
  var border: DivElement; // border element
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
      border.style.display = 'none';
      Browser.document.body.removeChild(border);
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
      var h = 60;

      // window
      window = Tools.window({
        id: "message",
        shadowLayer: 0,
        bold: true,
        w: w,
        h: h,
        z: 30,
      });
      border = cast UI.e('messageBorder');

      // text
      text = js.Browser.document.createDivElement();
      text.className = 'uiText';
      text.style.height = '52%';
      text.innerHTML = '<center>' + s + '</center>';
      window.appendChild(text);

      border.style.display = 'inline';
      isVisible = true;
    }
}

