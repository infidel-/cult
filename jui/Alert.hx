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
  var bg: DivElement; // background element
  var yesFunc: Void -> Void; // current yes handler
  var noFunc: Void -> Void; // current no handler
  public var isYesNo: Bool;
  public var isVisible: Bool;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      isYesNo = false;
      isVisible = false;
      queue = new List();
      yesFunc = null;
      noFunc = null;
    }



// hide window
  public function onClose(event)
    {
      border.style.display = 'none';
      bg.style.display = 'none';
      Browser.document.body.removeChild(border);
      Browser.document.body.removeChild(bg);
      isVisible = false;

      ui.sound.stopOnClose();

      // messages in queue - show next message
      if (queue.length > 0)
        {
          var x = queue.pop();
          show(x.msg, x.opts);
        }
    }


// yes button pressed
  public function onYes(event)
    {
      if (yesFunc != null)
        yesFunc();
      onClose(event);
    }


// yes button pressed
  public function onNo(event)
    {
      if (noFunc != null)
        noFunc();
      onClose(event);
    }


// show window
// NOTE: height 90px - one line
// h: UI.getVarInt('--alert-window-min-height'),
// NOTE: height 110px - two lines
// h: UI.getVarInt('--alert-window-height-2lines'),
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
      if (opts.yesNo)
        isYesNo = true;
      else isYesNo = false;
      if (opts.w == null)
        opts.w = 600;
      if (opts.h == null)
        opts.h = 250;
      if (s.length < 46) // short messages - small window
        opts.h = UI.getVarInt('--alert-window-min-height');
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

      // yes/no dialog
      if (opts.yesNo != null)
        {
          var yes = Tools.closeButton(window, onYes);
          yes.innerHTML = 'Yes';
          yes.style.left = '33%';
          yesFunc = opts.onYes;

          var no = Tools.closeButton(window, function(e) {
            if (opts.onNo != null)
              opts.onNo();
            onClose(e);
          });
          no.innerHTML = 'No';
          no.style.left = '66%';
          if (opts.onNo != null)
            noFunc = opts.onNo;
        }
      else
        {
          // close button
          var close = Tools.closeButton(window, onClose);
          if (queue.length > 0)
            close.innerHTML = 'Next';
        }

      var html = '';
      if (opts.img != null)
        {
          if (opts.center)
            html += '<center>';
          html += '<img class=tutorial-img' +
            (opts.center ? '-center' : '') +
            ' src="data/' + opts.img + '.png"/>';
          if (opts.center)
            html += '</center>';
        }
      if (opts.center)
        html += '<center>' + s + '</center>';
      else html += s;
      text.innerHTML = html;
      border.style.display = 'inline';
      bg.style.display = 'inline';
      isVisible = true;
      if (opts.sound != null)
        ui.sound.play(opts.sound);
    }
}


typedef _AlertOptions = {
  @:optional var w: Int;
  @:optional var h: Int;
  @:optional var shadow: Bool;
  @:optional var shadowOpacity: Float;
  @:optional var center: Bool;
  @:optional var fontSize: Int;
  @:optional var yesNo: Bool;
  @:optional var onYes: Void -> Void;
  @:optional var onNo: Void -> Void;
  @:optional var img: String;
  @:optional var sound: String;
}

