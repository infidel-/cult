// alert window

import js.html.DivElement;
import js.Browser;

class Alert
{
  var ui: UI;
  var game: Game;

  var window: DivElement; // window element
  var text: DivElement; // text element
  var close: DivElement; // close button
  var bg: DivElement; // background element
  public var isVisible: Bool;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      isVisible = false;
    }



// hide log
  public function onClose(event)
    {
      window.style.display = 'none';
      bg.style.display = 'none';
      Browser.document.body.removeChild(window);
      isVisible = false;
    }


// show alert
  public function show(s: String, opts: _AlertOptions)
    {
      // set default options
      if (opts == null)
        opts = {
          w: 600,
          h: 250,
          shadow: false,
          shadowOpacity: 0.8,
        }
      if (opts.w == null)
        opts.w = 600;
      if (opts.h == null)
        opts.h = 250;
      if (opts.shadow == null)
        opts.shadow = false;
      if (opts.shadowOpacity == null)
        opts.shadowOpacity = 0.8;

      // window
      window = Tools.window({
        id: "windowAlert",
        winW: UI.winWidth,
        winH: UI.winHeight,
//        fontSize: 16,
        bold: true,
        w: opts.w,
        h: opts.h,
        z: 25
      });
      window.style.display = 'none';
      window.style.background = '#222';
      window.style.border = '4px double #ffffff';

      // log text
      text = js.Browser.document.createDivElement();
      text.style.overflow = 'auto';
      text.style.position = 'absolute';
      text.style.left = '10px';
      text.style.top = '10px';
      text.style.width = (opts.w - 20) + 'px';
      text.style.height = (opts.h - 50) + 'px';
      text.style.background = '#111';
      text.style.border = '1px solid #777';
      window.appendChild(text);

      // log close button
      close = Tools.closeButton(window,
        Std.int(opts.w / 2) - 40, opts.h - 33, 'alertClose');
      close.onclick = onClose;

      bg = Tools.bg({
        w: UI.winWidth + 20,
        h: UI.winHeight,
        z: 24
      });

      bg.style.opacity = '' + opts.shadowOpacity;
      text.innerHTML = '<center>' + s + '</center>';
      window.style.display = 'inline';
      bg.style.display = (opts.shadow ? 'inline' : 'none');
      isVisible = true;
    }
}


typedef _AlertOptions = {
  @:optional var w: Int;
  @:optional var h: Int;
  @:optional var shadow: Bool;
  @:optional var shadowOpacity: Float;
}

