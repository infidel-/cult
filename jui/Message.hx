// temporary message window

import js.html.DivElement;
import js.Browser;

class Message
{
  var ui: UI;
  var game: Game;
  var timer: Int;

  var window: DivElement; // window element
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
      window.style.display = 'none';
      Browser.document.body.removeChild(window);
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
        id: "windowMessage",
        winW: UI.winWidth,
        winH: UI.winHeight,
//        fontSize: opts.fontSize,
        bold: true,
        w: w,
        h: h,
        z: 30
      });
      window.style.background = '#222';
      window.style.border = '4px double #ffffff';

      // text
      text = js.Browser.document.createDivElement();
      text.style.overflow = 'auto';
      text.style.position = 'absolute';
      text.style.left = '10px';
      text.style.top = '10px';
      text.style.width = (w - 30) + 'px';
      text.style.height = (h - 30) + 'px';
      text.style.padding = '5px';
      text.style.background = '#111';
      text.style.border = '1px solid #777';
      text.innerHTML = '<center>' + s + '</center>';
      window.appendChild(text);

      window.style.display = 'inline';
      isVisible = true;
    }
}

