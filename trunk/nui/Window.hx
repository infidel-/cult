// window class

import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.Loader;
import nme.net.URLRequest;
import nme.events.MouseEvent;

class Window extends Sprite
{
  public function new(cont: DisplayObjectContainer, params: Dynamic)
    {
      super();
      if (params.image != null)
        {
          var l = new Loader();
          l.load(new URLRequest("data/" + params.image + ".png"));
          var bmp: Bitmap = cast l.content;
          
          var b = new Bitmap(bmp.bitmapData.clone());
          addChild(b);
        }

      if (params.center != null && params.center == true)
        {
          params.x = (cont.width - params.w) / 2;
          params.y = (cont.height - params.h) / 2;
        }
        
      x = params.x;
      y = params.y;
      width = params.w;
      height = params.h;
      visible = false;

      cont.addChild(this);
    }
}

