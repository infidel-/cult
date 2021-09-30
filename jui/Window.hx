// window class

import js.Browser;
import js.html.DivElement;

class Window
{
  var ui: UI;
  var game: Game;
  var id: Int;
  var name: String;

  var border: DivElement; // window border element
  var window: DivElement; // window element
  var bg: DivElement; // background element
  var close: DivElement; // close button element
  public var isVisible: Bool;
  static var lastID = 0;


  public function new(uivar: UI, gvar: Game, name: String,
      w: Int, h: Int, z: Int)
    {
      this.name = name;
      id = lastID++;
      ui = uivar;
      game = gvar;
      isVisible = false;

      window = Tools.window({
        id: name,
        w: w,
        h: h,
        z: z
      });
      border = cast UI.e(name + 'Border');
      bg = cast UI.e(name + 'BG');
      close = Tools.closeButton(window, onClose);
    }


// show window
  public function show()
    {
      ui.sound.play('window-open');
      border.style.display = 'inline';
      bg.style.display = 'inline';
      close.style.visibility = 'visible';
      isVisible = true;
      onShow();
    }


// show hook
  dynamic function onShow()
    {}


// key press
  public dynamic function onKey(e: Dynamic)
    {}


// hide window
  public function onClose(event: Dynamic)
    {
      ui.sound.play('window-close');
      border.style.display = 'none';
      bg.style.display = 'none';
      isVisible = false;
      onCloseHook();
    }


// on window close hook
  dynamic function onCloseHook()
    {}
}
