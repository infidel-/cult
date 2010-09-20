// text label

import nme.display.DisplayObjectContainer;
import nme.text.TextField;
import nme.text.TextFormat;


class Label extends TextField
{
  public static var defaultFont = "Times";

  public function new(cont: DisplayObjectContainer, params: Dynamic)
    {
      super();

      x = params.x;
      y = params.y;
      width = params.w;
      height = params.h;
      textColor = 0xffffff;
      selectable = false;
      multiline = true;

      var tf : TextFormat = new TextFormat();
      tf.font = defaultFont;
      tf.size = params.font.size;
      if (params.font.bold != null && params.font.bold == true)
        tf.bold = true;
      if (params.center == true)
        tf.align = "center";
      defaultTextFormat = tf;

//      text = params.text;
      htmlText = params.text;
      trace(params.text);
      cont.addChild(this);
    }


// center label
  public function center()
    {
      x = (parent.width - width) / 2;
      y = (parent.height - height) / 2;
    }
}
