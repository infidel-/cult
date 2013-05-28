// log window

class Log
{
  var ui: UI;
  var game: Game;

  public var window: Dynamic; // window element
  public var text: Dynamic; // text element
  public var isVisible: Bool;

  var logPrevTurn: Int; // number of previous turn

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      isVisible = false;

      // window
      window = Tools.window(
        {
          id: "windowLog",
          center: true,
          winW: UI.winWidth,
          winH: UI.winHeight,
          fontSize: 18,
          w: 800,
          h: 500,
          z: 14
        });
      window.style.display = 'none';
      window.style.background = '#333333';
	  window.style.border = '4px double #ffffff';

      // log text
      text = js.Lib.document.createElement("div");
      text.style.overflow = 'auto';
      text.style.position = 'absolute';
      text.style.left = 10;
      text.style.top = 10;
      text.style.width = 780;
      text.style.height = 450;
      text.style.background = '#0b0b0b';
	  text.style.border = '1px solid #777';
      window.appendChild(text);

      // log close button
      var close = Tools.closeButton(window, 360, 465, 'logClose');
	  close.onclick = onClose;
    }


// hide log
  public function onClose(event)
    {
      window.style.display = 'none';
      isVisible = false;
    }


// add message to cult log
  public function getRenderedMessage(s: String): String
    {
      return
        "<span style='color:#888888'>" +
        DateTools.format(Date.now(), "%H:%M:%S") +
        "</span>" +
        " Turn " + (game.turns + 1) + ": " + s + "<br>";
    }


// clear log
  public function clear()
    {
      text.innerHTML = "";
    }


// show log
  public function show()
    {
      text.innerHTML = game.player.logMessages;
      text.scrollTop = 10000;
      window.style.display = 'inline';
      isVisible = true;
    }
}
