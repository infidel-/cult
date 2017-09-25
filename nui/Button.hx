// generic button

import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.Loader;
import nme.net.URLRequest;
import nme.events.MouseEvent;

class Button extends Sprite
{
  var onClickFunc: Dynamic;

  public function new(cont: DisplayObjectContainer, params: Dynamic)
    {
      super();
      if (params.image == null)
        throw "Cannot create button with no image.";

      var l = new Loader();
      l.load(new URLRequest("data/" + params.image + ".png"));
      var bmp: Bitmap = cast l.content;

      var b = new Bitmap(bmp.bitmapData.clone());
      x = params.x;
      y = params.y;
      width = bmp.width;
      height = bmp.height;
      if (params.name != null)
        name = params.name;
      mouseChildren = false;
      onClickFunc = params.onClick;
      addEventListener(MouseEvent.CLICK, onClick);
      if (params.visible != null)
        visible = params.visible;
      addChild(b);

      if (params.label != null) // button label
        {
          var label = new Label(this,
            { x: params.label.x, y: params.label.y,
              w: width, h: height,
              font: params.font,
              text: params.label.text });
        }
      cont.addChild(this);
    }


  public function onClick(e: MouseEvent)
    {
      if (onClickFunc != null)
        onClickFunc(this);
    }


  public static function closeButton(cont: DisplayObjectContainer,
      x: Int, y: Int, onClickFunc: Dynamic): Button
    {
      return new Button(cont,
        { x: x, y: y,
          image: "close",
          onClick: onClickFunc });
    }
}
