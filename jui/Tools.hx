// misc gui tools

import js.Lib;

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
  public static function bg(params: Dynamic): Dynamic
    {
      if (params.z == null)
        params.z = 15;

      var bg: Dynamic = js.Lib.document.createElement("div");
      bg.style.visibility = 'hidden';
      bg.style.position = 'absolute';
      bg.style.zIndex = params.z;
      bg.style.width = params.w;
      bg.style.height = params.h;
      bg.style.left = 0; 
      bg.style.top = 0;
      bg.style.opacity = 0.8;
      bg.style.background = '#000';
      js.Lib.document.body.appendChild(bg);
      return bg;
    }


// create a button
  public static function button(params: Dynamic): Dynamic
    {
      var b: Dynamic = Lib.document.createElement("div");
      b.id = params.id;
      b.innerHTML = params.text;
      if (params.bold == null)
        params.bold = true;
      if (params.bold)
        b.style.fontWeight = "bold";
      if (params.fontSize == null)
        params.fontSize = 20;
      b.style.fontSize = params.fontSize;
      b.style.position = 'absolute';
      b.style.width = params.w;
      b.style.height = params.h;
      b.style.left = params.x;
      b.style.top = params.y;
      b.style.background = '#111';
	  b.style.border = '1px outset #777';
	  b.style.cursor = 'pointer';
      b.style.textAlign = 'center';
      params.container.appendChild(b);
      if (params.func != null)
        b.onclick = params.func;
      return b;
    }


// create close button
  public static function closeButton(container: Dynamic, x: Int, y: Int, name: String)
    {
      var b = Tools.button({
        id: name,
        text: "Close",
        width: 80,
        height: 25,
        x: x,
        y: y,
        container: container
        });
      return b;
    }


// create a window
  public static function window(params: Dynamic): Dynamic
    {
      // center window
      if (params.winW != null)
        params.x = (params.winW - params.w) / 2;
      if (params.winH != null)
        params.y = (params.winH - params.h) / 2;
      if (params.z == null)
        params.z = 10;

      var w = Lib.document.createElement("div");
      w.id = params.id;
      w.style.visibility = 'hidden';
      w.style.position = 'absolute';
      w.style.zIndex = params.z;
      w.style.width = params.w;
      w.style.height = params.h;
      w.style.left = params.x; 
      w.style.top = params.y;
      if (params.fontSize != null)
        w.style.fontSize = params.fontSize;
      if (params.bold)
        w.style.fontWeight = 'bold';
      w.style.background = '#222';
	  w.style.border = '4px double #ffffff';
      Lib.document.body.appendChild(w);

      return w;
    }
}

