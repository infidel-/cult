// misc gui tools

import js.Browser;
import js.html.Element;
import js.html.DivElement;
import js.html.InputElement;

class Tools
{
// compatibility crap - get a target element from event
  public static function getTarget(event): Dynamic
    {
      if (event == null)
        event = untyped __js__("window.event");
      var t = event.target;
      if (t == null)
        t = event.srcElement;
      return t;
    }


// background shadow
  public static function bg(params: { w: Int, h: Int, ?z: Int }): DivElement
    {
      if (params.z == null)
        params.z = 15;

      var bg = js.Browser.document.createDivElement();
      bg.style.display = 'none';
      bg.style.position = 'absolute';
      bg.style.zIndex = params.z + '';
      bg.style.width = (params.w - 10) + 'px';
      bg.style.height = params.h + 'px';
      bg.style.left = '0px';
      bg.style.top = '0px';
      bg.style.opacity = '0.8';
      bg.style.background = '#000';
      js.Browser.document.body.appendChild(bg);
      return bg;
    }


// create a button
  public static function button(params: _ButtonParams): DivElement
    {
      var b = js.Browser.document.createDivElement();
      b.id = params.id;
      b.innerHTML = params.text;
      if (params.bold == null)
        params.bold = true;
      if (params.bold)
        b.style.fontWeight = 'bold';
      if (params.fontSize == null)
        params.fontSize = 20;
      b.className = 'uiButton';
      b.style.fontSize = params.fontSize + 'px';
      b.style.position = 'absolute';
      b.style.width = params.w + 'px';
      b.style.height = params.h + 'px';
      b.style.left = params.x + 'px';
      b.style.top = params.y + 'px';
/*
      b.style.background = '#111';
      b.style.border = '1px outset #777';
      b.style.cursor = 'pointer';
      b.style.textAlign = 'center';
*/
      params.container.appendChild(b);
      if (params.func != null)
        b.onclick = params.func;
      if (params.title != null)
        {
          b.title = params.title;
          new JQuery("#" + params.id).tooltip({ delay: 0 });
        }
      return b;
    }


// create close button
  public inline static function closeButton(container: DivElement,
      x: Int, y: Int, name: String): DivElement
    {
      var b = Tools.button({
        id: name,
        text: "Close",
        w: 80,
        h: 25,
        x: x,
        y: y,
        container: container
        });
      return b;
    }


// create a label
  public static function label(params: _LabelParams): DivElement
    {
      var b = js.Browser.document.createDivElement();
      b.id = params.id;
      b.innerHTML = params.text;
      if (params.bold == null)
        params.bold = true;
      if (params.bold)
        b.style.fontWeight = "bold";
      if (params.fontSize == null)
        params.fontSize = 20;
      b.style.fontSize = params.fontSize + 'px'; 
      b.style.position = 'absolute';
      b.style.width = params.w + 'px';
      b.style.height = params.h + 'px';
      b.style.left = params.x + 'px';
      b.style.top = params.y + 'px';
      b.style.userSelect = 'none';
//      b.style.textAlign = 'center';
      params.container.appendChild(b);
      return b;
    }


// create a window
  public static function window(params: _WindowParams): DivElement
    {
      // center window
      if (params.winW != null)
        params.x = Std.int((params.winW - params.w) / 2);
      if (params.winH != null)
        params.y = Std.int((params.winH - params.h) / 2);
      if (params.z == null)
        params.z = 10;

      var w = Browser.document.createDivElement();
      w.id = params.id;
      w.style.display = 'none';
      w.style.position = 'absolute';
      w.style.zIndex = params.z + '';
      w.style.width = params.w + 'px';
      w.style.height = params.h + 'px';
      w.style.left = params.x + 'px';
      w.style.top = params.y + 'px';
      if (params.fontSize != null)
        w.style.fontSize = params.fontSize + 'px';
      if (params.bold)
        w.style.fontWeight = 'bold';
      w.style.background = '#222';
      w.style.border = '4px double #ffffff';
      Browser.document.body.appendChild(w);

      return w;
    }


// create a textfield
  public static function textfield(params: _TextParams): InputElement
    {
      var t = Browser.document.createInputElement();
      t.id = params.id;
      t.value = params.text;
      if (params.bold == null)
        params.bold = false;
      if (params.bold)
        t.style.fontWeight = "bold";
      if (params.fontSize == null)
        params.fontSize = 20;
      t.style.color = '#ffffff';
      t.style.fontSize = params.fontSize + 'px';
      t.style.position = 'absolute';
      t.style.width = params.w + 'px';
      t.style.height = params.h + 'px';
      t.style.left = params.x + 'px';
      t.style.top = params.y + 'px';
      t.style.background = '#111';
      t.style.paddingLeft = '5px';
      t.style.border = '1px outset #777';
      params.container.appendChild(t);
      return t;
    }


// create a checkbox
  public static function checkbox(params: _CheckboxParams): InputElement
    {
      var t = Browser.document.createInputElement();
      t.id = params.id;
      t.value = params.text;
      t.type = 'checkbox';
      if (params.bold == null)
        params.bold = false;
      if (params.bold)
        t.style.fontWeight = "bold";
      if (params.fontSize == null)
        params.fontSize = 20;
      t.style.color = '#ffffff';
      t.style.fontSize = params.fontSize + 'px';
      t.style.position = 'absolute';
      t.style.width = params.w + 'px';
      t.style.height = params.h + 'px';
      t.style.left = params.x + 'px';
      t.style.top = params.y + 'px';
      t.style.background = '#111';
      t.style.paddingLeft = '5px';
      t.style.border = '1px outset #777';
      params.container.appendChild(t);
      return t;
    }
}


typedef _ButtonParams = {
  var id: String;
  @:optional var title: String;
  var text: String;
  var w: Int;
  var h: Int;
  var x: Int;
  var y: Int;
  @:optional var fontSize: Int;
  var container: DivElement; 
  @:optional var func: Dynamic -> Void; 
  @:optional var bold: Bool;
}


typedef _LabelParams = {
  var id: String;
  var text: String;
  var w: Int;
  var h: Int;
  var x: Int;
  var y: Int;
  var container: Element; 
  @:optional var fontSize: Int;
  @:optional var bold: Bool;
}


typedef _WindowParams = {
  var id: String;
  var winW: Int;
  var winH: Int;
  var w: Int;
  var h: Int;
  @:optional var x: Int;
  @:optional var y: Int;
  var z: Int;

  @:optional var fontSize: Int;
  @:optional var bold: Bool;
}


typedef _TextParams = {
  var id: String;
  var text: String;
  var w: Int;
  var h: Int;
  var x: Int;
  var y: Int;
  var container: Element; 
  @:optional var fontSize: Int;
  @:optional var bold: Bool;
}


typedef _CheckboxParams = {
  var id: String;
  var text: String;
  var w: Int;
  var h: Int;
  var x: Int;
  var y: Int;
  var container: Element; 
  @:optional var fontSize: Int;
  @:optional var bold: Bool;
}
