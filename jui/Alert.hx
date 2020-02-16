// alert window

import js.html.DivElement;
import js.Browser;

class Alert
{
  var ui: UI;
  var game: Game;

  var queue: List<{ msg: String, opts: _AlertOptions }>; // message queue
  var window: DivElement; // window element
  var border: DivElement; // border element
  var text: DivElement; // text element
  var close: DivElement; // close button
  var bg: DivElement; // background element
  public var isVisible: Bool;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      isVisible = false;
      queue = new List();
    }



// hide window
  public function onClose(event)
    {
      border.style.display = 'none';
      bg.style.display = 'none';
      Browser.document.body.removeChild(border);
      Browser.document.body.removeChild(bg);
      isVisible = false;

      // messages in queue - show next message
      if (queue.length > 0)
        {
          var x = queue.pop();
          show(x.msg, x.opts);
        }
    }


// show window
  public function show(s: String, opts: _AlertOptions)
    {
      // alert window already visible, push to queue
      if (isVisible)
        {
          queue.add({
            msg: s,
            opts: opts
          });
          return;
        }

      // set default options
      if (opts == null)
        opts = {
          w: 600,
          h: 250,
          shadow: true,
          shadowOpacity: 0.8,
          center: true,
        }
      if (opts.w == null)
        opts.w = 600;
      if (opts.h == null)
        opts.h = 250;
      if (s.length < 46) // short messages - small window
        opts.h = 90;
      if (opts.shadow == null)
        opts.shadow = true;
      if (opts.shadowOpacity == null)
        opts.shadowOpacity = 0.8;
      if (opts.center == null)
        opts.center = true;

      // window
      window = Tools.window({
        id: "alert",
        shadowLayer: 24,
        fontSize: opts.fontSize,
        bold: true,
        w: opts.w,
        h: opts.h,
        z: 25
      });
      border = cast UI.e('alertBorder');
      bg = cast UI.e('alertBG');

      // text
      text = Browser.document.createDivElement();
      text.className = 'uiText';
      window.appendChild(text);

      // close button
      close = Tools.closeButton(window);
      close.onclick = onClose;

      if (opts.center)
        text.innerHTML = '<center>' + s + '</center>';
      else text.innerHTML = s;
      text.style.height = '78%';
      border.style.display = 'inline';
      bg.style.display = 'inline';
      isVisible = true;
    }
}


typedef _AlertOptions = {
  @:optional var w: Int;
  @:optional var h: Int;
  @:optional var shadow: Bool;
  @:optional var shadowOpacity: Float;
  @:optional var center: Bool;
  @:optional var fontSize: Int;
}

