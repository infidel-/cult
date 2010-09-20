// log window

import nme.display.DisplayObject;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.events.MouseEvent;

class Log
{
  var ui: UI;
  var game: Game;

  public var window: Window; // window element
  public var text: TextField; // text element
  public var isVisible(getIsVisible, null): Bool;

  var logPrevTurn: Int; // number of previous turn

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
    }


// init stuff
  public function init()
    {
      window = new Window(ui.screen,
        {
          center: true,
          image: "logbg",
          w: 800,
          h: 500
        });

      // log close button
      var close = new Button(window, 
        { x: 364, y: 469, image: "close", onClick: onClose });

      // log text
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
//      text.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll);
//      text.addEventListener(MouseEvent.CLICK, onScrollDown);
      window.addChild(text);

      var scrollUp = new Button(window, 
        { x: 782, y: 14, image: "scroll_up", name: "scrollUp",
          onClick: onScroll });
      var scrollDown = new Button(window, 
        { x: 782, y: 451, image: "scroll_down", name: "scrollDown",
          onClick: onScroll });

/*
      for (i in 0...200)
        add("test " + i);
        //"Test ar close = Tools.closeButton(window, 360, 465, 'logClose');", false);
*/        
    }


// hide log
  public function onClose(target)
    {
      window.visible = false;
    }


// add message to log
  public function add(s: String, ?doShow: Bool)
    {
//      if (logPrevTurn != game.turns)
//        logText.innerHTML += "<center style='font-size:10px'>...</center><br>";
/*
      text.innerHTML += 
        "<span style='color:#888888'>" +
        DateTools.format(Date.now(), "%H:%M:%S") +
        "</span>" +
        " Turn " + (game.turns + 1) + ": " + s + "<br>";
*/     
      text.text += DateTools.format(Date.now(), "%H:%M:%S") + 
        " Turn " + (game.turns + 1) + ": " + s + "\n";
      if (doShow == null || doShow == true)
        show();
      logPrevTurn = game.turns;
    }


// scrolling
  public function onScroll(target: DisplayObject)
    {
//      var scrollV: Int = 0 + text.scrollV;
      var name = new String(target.name);
      trace("b:" + text.scrollV + " " + target.name);
      if (name == "scrollUp")
        text.scrollV -= 1;
//        {
//          scrollV = scrollV - 1;
//        }
      else text.scrollV += 1;
      trace("a:" + text.scrollV);

//      text.scrollV = scrollV;
      trace(text.scrollV + " max:" + text.maxScrollV);
    }


// clear log
  public function clear()
    {
      text.text = "";
//      text.innerHTML = "";
    }


// show log
  public function show()
    {
//      text.scrollV = text.maxScrollV + 20;
      window.visible = true;
    }


// getter for isVisible
  function getIsVisible(): Bool
    {
      return window.visible;
    }
}
