// shaded background

import nme.display.DisplayObjectContainer;
import nme.display.Shape;

class Background extends Shape
{
  public function new(cont: DisplayObjectContainer)
    {
      super();

      width = cont.width;
      height = cont.height;
      graphics.beginFill(0, 0.8);
      graphics.drawRect(0, 0, cont.width, cont.height);
      visible = false;

      cont.addChild(this);
    }
}
