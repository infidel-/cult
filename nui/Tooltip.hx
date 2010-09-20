// tooltip class

import nme.display.DisplayObject;
import nme.events.MouseEvent;
import nme.Lib;


class Tooltip
{
  var label: Label;
  var text: String;
  var obj: DisplayObject;

  public function new(obj: DisplayObject, ?textvar: String)
    {
      obj.addEventListener(MouseEvent.MOUSE_OVER, onOver);
      obj.addEventListener(MouseEvent.MOUSE_OUT, onOut);
      this.obj = obj;
      
      if (textvar == null)
        textvar = "";
      text = textvar;
    }


// set tooltip text
  public function setText(s: String)
    {
      text = s;
    }


// mouse over
  public function onOver(e: MouseEvent)
    {
      // create text label
      label = new Label(Lib.current,
        { x: 10, y: 10, w: 10, h: 10,
          font: { size: 18 },
          text: text });
      label.opaqueBackground = 0x111111;
      label.visible = false;
      label.width = label.textWidth;
      label.height = label.textHeight;

      // find real x,y of object
      var dx = 0.0, dy = 0.0;
      var parent = obj.parent;
      while (parent != null)
        {
          dx += parent.x;
          dy += parent.y;
          parent = parent.parent;
        }
      
      var x = obj.x + dx + 30;
      var y = obj.y + dy + 30;

      if (x + label.width + 10 > Lib.current.width)
        x = Lib.current.width - label.width - 10;
      if (y + label.height + 10 > Lib.current.height)
        y = Lib.current.height - label.height - 10;
      if (obj.x + dx - 10 > x && obj.x + dx + 20 < x + label.width)
        x = obj.x + dx - 10 - label.width;
      label.x = x;
      label.y = y;
      label.visible = true;
    }


// mouse out
  public function onOut(e: MouseEvent)
    {
      label.parent.removeChild(label);
      label = null;
    }
}
