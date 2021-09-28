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
  public static function bg(?z: Int = 15): DivElement
    {
      var bg = Browser.document.createDivElement();
      bg.className = 'uiBG';
      bg.style.display = 'none';
      bg.style.zIndex = z + '';
      Browser.document.body.appendChild(bg);
      return bg;
    }


// create a button
  public static function button(params: _ButtonParams): DivElement
    {
      var b = js.Browser.document.createDivElement();
      if (params.id != null)
        b.id = params.id;
      b.innerHTML = params.text;
      if (params.bold == null)
        params.bold = true;
      if (params.bold && UI.classicMode)
        b.style.fontWeight = 'bold';
      b.className =
        (params.className != null ? params.className : 'uiButton');
      if (params.fontSize != null)
        b.style.fontSize = params.fontSize + 'px';
      if (!params.flow)
        b.style.position = 'absolute';
      if (params.w != null)
        b.style.width = params.w + 'px';
      if (params.h != null)
        b.style.height = params.h + 'px';
      if (params.x != null)
        b.style.left = params.x + 'px';
      if (params.y != null)
        b.style.top = params.y + 'px';
      params.container.appendChild(b);
      b.onclick = function (e)
        {
          @:privateAccess Game.instance.ui.sound.play('click');
          if (params.func != null)
            params.func(e);
        }
      if (params.title != null)
        {
          b.title = params.title;
          new JQuery("#" + params.id).tooltip({ delay: 0 });
        }
      return b;
    }


// create close button
  public static function closeButton(container: DivElement,
      func: Dynamic -> Void): DivElement
    {
      var w = Std.parseInt(container.style.width);
      var b = Tools.button({
        id: null,
        text: "Close",
        w: 80,
        h: null,
        x: null,
        y: null,
        container: container,
        func: func,
      });
      b.style.left = '50%';
      b.style.bottom = 'var(--close-button-bottom)';
      b.style.transform = 'translate(-50%)';

      return b;
    }


// create a label
  public static function label(params: _LabelParams): DivElement
    {
      var b = Browser.document.createDivElement();
      b.id = params.id;
      b.innerHTML = params.text;
      var rect = b.getBoundingClientRect();
      if (params.bold == null)
        params.bold = true;
      if (params.bold && UI.classicMode)
        b.style.fontWeight = "bold";
//      if (params.fontSize == null)
//        params.fontSize = 20;
      b.style.fontSize = params.fontSize + 'px'; 
      b.style.position = 'absolute';
      if (UI.modernMode)
        b.style.textTransform = 'uppercase';
      if (params.w != null)
        b.style.width = params.w + 'px';
      b.style.height = params.h + 'px';
      if (params.x != null)
        b.style.left = params.x + 'px';
/*
      else b.style.left =
        Std.int((Std.parseInt(params.container.style.width) -
          Std.parseInt(b.style.width)) / 2) + 'px';
*/
      b.style.top = params.y + 'px';
      b.style.userSelect = 'none';
      b.style.color = 'var(--text-color)';
//      b.style.textAlign = 'center';
      params.container.appendChild(b);
      return b;
    }


// create a window
  public static function window(params: _WindowParams): DivElement
    {
      // center window
      var x = Std.int((Browser.window.innerWidth - params.w) / 2);
      var y = Std.int((Browser.window.innerHeight - params.h) / 2);
      if (params.z == null)
        params.z = 10;
      // old kludge
      params.h += 16;
      if (params.border == null)
        params.border = true;

      var border = null;
      if (params.border)
        {
          border = Browser.document.createDivElement();
          if (params.id != null)
            border.id = params.id + 'Border';
          Browser.document.body.appendChild(border);
          border.className = 'uiWindowBorder';
          border.style.display = 'none';
          border.style.zIndex = params.z + '';
          if (params.w != null)
            border.style.width = params.w + 'px';
          if (params.h != null)
            border.style.height = params.h + 'px';
        }

      var w = Browser.document.createDivElement();
      if (params.id != null)
        w.id = params.id + 'Window';
      w.className = 'uiWindow';
      if (params.fontSize != null)
        w.style.fontSize = params.fontSize + 'px';
      if (params.bold)
        w.style.fontWeight = 'bold';
      if (params.w != null)
        w.style.width = (params.w - 16) + 'px';
      if (params.h != null)
        w.style.height = (params.h - 16) + 'px';
      if (params.border)
        border.appendChild(w);
      else Browser.document.body.appendChild(w);

      if (params.shadowLayer == null)
        params.shadowLayer = 15;
      if (params.shadowLayer > 0)
        {
          var bg = Tools.bg(params.shadowLayer);
          if (params.id != null)
            bg.id = params.id + 'BG';
        }

      return w;
    }


// create a textfield
  public static function textfield(params: _TextParams): InputElement
    {
      var t = Browser.document.createInputElement();
      t.id = params.id;
      t.className = 'selectOption';
      t.value = params.text;
      if (params.bold == null)
        params.bold = false;
      if (params.bold)
        t.style.fontWeight = "bold";
      if (params.fontSize == null)
        params.fontSize = 20;
      t.style.fontSize = params.fontSize + 'px';
      t.style.width = params.w + 'px';
      t.style.height = params.h + 'px';
      t.style.left = params.x + 'px';
      t.style.top = params.y + 'px';
      t.style.position = 'absolute';
      t.style.padding = '0px 5px 0px 5px';
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
      if (params.h != null)
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
  @:optional var className: String;
  var w: Int;
  var h: Int;
  var x: Int;
  var y: Int;
  @:optional var flow: Bool;
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
  var w: Int;
  var h: Int;
  var z: Int;

  @:optional var fontSize: Int;
  @:optional var bold: Bool;
  @:optional var shadowLayer: Int;
  @:optional var border: Bool;
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
