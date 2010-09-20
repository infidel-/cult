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
          id: "window",
          center: true,
          winW: UI.winWidth,
          winH: UI.winHeight,
          fontSize: 18,
          w: 800,
          h: 500,
          z: 14
        });
      window.style.visibility = 'hidden';
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
      window.style.visibility = 'hidden';
      isVisible = false;
    }


// add message to log
  public function add(s: String, ?doShow: Bool)
    {
//      if (logPrevTurn != game.turns)
//        logText.innerHTML += "<center style='font-size:10px'>...</center><br>";
      text.innerHTML += 
        "<span style='color:#888888'>" +
        DateTools.format(Date.now(), "%H:%M:%S") +
        "</span>" +
        " Turn " + (game.turns + 1) + ": " + s + "<br>";
      if (doShow == null || doShow == true)
        show();
      logPrevTurn = game.turns;
    }


// clear log
  public function clear()
    {
      text.innerHTML = "";
    }


// show log
  public function show()
    {
      text.scrollTop = 10000;
      window.style.visibility = 'visible';
      isVisible = true;
    }
}
