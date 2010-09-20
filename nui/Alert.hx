// alert window

import nme.display.DisplayObject;
import nme.text.TextField;
import nme.text.TextFormat;


class Alert
{
  var ui: UI;
  var game: Game;

  public var window: Window; // window element
  public var text: TextField; // text element
  var bg: Background; // background element
  public var isVisible(getIsVisible, null): Bool;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
    }


// init stuff
  public function init()
    {
      bg = new Background(ui.screen);
      window = new Window(ui.screen,
        {
          center: true,
          image: "logbg",
          w: 800,
          h: 500
        });
      var close = new Button(window, 
        { x: 364, y: 469, image: "close", onClick: onClose });

      var tf : TextFormat = new TextFormat();
      tf.font = "FreeSans";
      tf.size = 18;
      text = new TextField();
      text.x = 15;
      text.y = 15;
      text.width = 780;
      text.height = 450;
      text.multiline = true;
      text.wordWrap = true;
      text.textColor = 0xffffff;
      text.selectable = false;
      text.defaultTextFormat = tf;
      window.addChild(text);
/*
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
*/      
    }


// hide
  public function onClose(event)
    {
      window.visible = false;
      bg.visible = false;
    }


// show alert
  public function show(s: String, ?shadow: Bool)
    {
      // temporary de-htmling
      s = StringTools.replace(s, "<br>", "\n");
      var sb = new StringBuf();
      var arr = s.split('<');
      var start = 0;
      for (t in arr)
        sb.add(t.substr(t.indexOf('>') + 1));

      text.text = sb.toString();
//      text.text = '<center>' + s + '</center>';
//      text.text = s;
      window.visible = true;
      bg.visible = shadow;
    }


// getter for isVisible
  function getIsVisible(): Bool
    {
      return window.visible;
    }
}

