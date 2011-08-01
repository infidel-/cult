// alert window

class Alert
{
  var ui: UI;
  var game: Game;

  public var window: Dynamic; // window element
  public var text: Dynamic; // text element
  var bg: Dynamic; // background element
  public var isVisible: Bool;

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
//          fontSize: 16,
          bold: true,
          w: 600,
          h: 450,
          z: 25
        });
      window.style.visibility = 'hidden';
      window.style.background = '#222';
	  window.style.border = '4px double #ffffff';

      // log text
      text = js.Lib.document.createElement("div");
      text.style.overflow = 'auto';
      text.style.position = 'absolute';
      text.style.left = 10;
      text.style.top = 10;
      text.style.width = 580;
      text.style.height = 400;
      text.style.background = '#111';
	  text.style.border = '1px solid #777';
      window.appendChild(text);

      // log close button
      var close = Tools.closeButton(window, 260, 415, 'alertClose');
	  close.onclick = onClose;

      bg = Tools.bg({ w: UI.winWidth + 20, h: UI.winHeight, z: 24 });
    }


// hide log
  public function onClose(event)
    {
      window.style.visibility = 'hidden';
      bg.style.visibility = 'hidden';
      isVisible = false;
    }


// show alert
  public function show(s: String, ?shadow: Bool, ?shadowOpacity: Float)
    {
      if (shadowOpacity == null)
        shadowOpacity = 0.8;
      bg.style.opacity = shadowOpacity;
      text.innerHTML = '<center>' + s + '</center>';
      window.style.visibility = 'visible';
      bg.style.visibility = 
        (shadow ? 'visible' : 'hidden');
      isVisible = true;
    }
}

