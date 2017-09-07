// save game menu

class SaveMenu
{
  var ui: UI;
  var game: Game;

  var window: Dynamic; // window element
  var bg: Dynamic; // background element
  var close: Dynamic; // close button element
  var key: Dynamic; // key textfield element
  var noKey: Dynamic; // no key found
  var keyFocused: Bool; // is textfield focused?
  var saveButtons: Array<Dynamic>; // saves buttons
  var delButtons: Array<Dynamic>; // delete buttons
  var saves: Array<Dynamic>; // saves
  public var isVisible: Bool;


  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      isVisible = false;

      // save menu window
      window = Tools.window(
        {
          id: "saveMenuWindow",
          center: true,
          winW: UI.winWidth,
          winH: UI.winHeight,
          w: 420,
          h: 320,
          z: 25
        });

      Tools.label({
        id: 'saveLabel',
        text: 'Key',
        w: 60,
        h: 30,
        x: 35,
        y: 30,
        container: window
        });

      // text field
      key = Tools.textfield({
        id: 'saveKey',
        text: ui.config.get("owner"),
        w: 205,
        h: 30,
        x: 85,
        y: 30,
        container: window
        });
      key.onclick = onKeyClick;

      Tools.button({ // refresh button
        id: 'saveRefresh',
        text: "Refresh",
        w: 100,
        h: 30,
        x: 300,
        y: 30,
        container: window,
        func: onRefresh
        });

      noKey = Tools.label({
        id: 'loadLabel2',
        text: 'Type in key to proceed.',
        w: 270,
        h: 30,
        x: 90,
        y: 150,
        container: window
        });

      // save menu contents
      saves = new Array<Dynamic>();
      saveButtons = new Array<Dynamic>();
      delButtons = new Array<Dynamic>();
      for (i in 0...UI.maxSaves)
        {
          var b = Tools.button({
            id: 'save' + i,
            text: "...",
            w: 330,
            h: 30,
            x: 35,
            y: 70 + 40 * i,
            container: window,
            func: onSaveGame
            });
          saveButtons.push(b);
          var b2 = Tools.button({
            id: 'del' + i,
            text: "X",
            w: 20,
            h: 30,
            x: 380,
            y: 70 + 40 * i,
            container: window,
            func: onDelGame
            });
          delButtons.push(b2);
        }

      bg = Tools.bg({ w: UI.winWidth + 20, h: UI.winHeight});
      close = Tools.closeButton(window, 180, 280, 'saveMenuClose');
	  close.onclick = onClose;
    }


// show save menu
  public function show()
    {  
      for (b in delButtons)
        b.style.display = 'none';

      // load list of saved games
      if (ui.config.get("owner") != '' && ui.config.get("owner") != null)
        {
          var req = new js.html.XMLHttpRequest();
          req.open("GET", "/save.list?owner=" +
            ui.config.get("owner"), false);
          req.send(null);
          var text = req.responseText;
          var list = untyped JSON.parse(text);

          saves = list;

          for(b in saveButtons)
            {
              b.style.display = 'inline';
              b.innerHTML = '---';
            }
      
          var i = 0;
          for (item in list)
            {
              var b = saveButtons[i];
              if (b == null) break;
              b.innerHTML = item.name;
              delButtons[i].style.display = 'inline';
              i++;
            }

          noKey.style.display = 'none';
        }
      else
        {
          for (b in saveButtons)
            b.style.display = 'none';

          noKey.style.display = 'inline';
        }

      key.value = ui.config.get("owner");
      window.style.display = 'inline';
      bg.style.display = 'inline';
      close.style.display = 'inline';
      isVisible = true;
      keyFocused = false;
    }


// click on key textfield
  function onKeyClick()
    {
      keyFocused = true;
    }


// refresh 
  function onRefresh(event: Dynamic)
    {
      ui.config.set("owner", key.value);
      show();
    }


// save game 
  function onSaveGame(event: Dynamic)
    {
      var b = Tools.getTarget(event);
      var n = Std.parseInt(b.id.substring(4));
     
      onSaveReal(n);
    }


// save a game (real)
  function onSaveReal(n: Int)
    {
      var save = saves[n];
      var id = 0;
      if (save != null)
        id = save.id;
    
      // save game
      var name = Date.now().toString();
      var req = new js.html.XMLHttpRequest();
      req.open("POST", "/save.save?owner=" +
        ui.config.get("owner") + "&id=" + id +
        "&name=" + name +
        "&version=" + Game.version, false);
      var obj = game.save();
      var str:String = untyped JSON.stringify(obj);
//      var str = hxjson2.JSON.encode(obj);
//      trace("length:" + str.length + " " + str);
      req.send(str);
      var text = req.responseText;
      if (text == "TooBig")
        {
          ui.alert("Save file too big (" + Std.int(str.length / 1024) +
            "kb)! Contact me to raise limit.");
          return;
        }
      else if (text == "TooManySaves")
        {
          ui.alert("Too many saved games already.");
          return;
        }

      onClose(null);    
    }


// del game
  function onDelGame(event: Dynamic)
    {
      var b = Tools.getTarget(event);
      var n = Std.parseInt(b.id.substring(3));
     
      onDelReal(n);
    }


// delete a game
  function onDelReal(n: Int)
    {
      var save = saves[n];
    
      // delete game
      var req = new js.html.XMLHttpRequest();
      req.open("GET", "/save.delete?owner=" +
        ui.config.get("owner") + "&id=" + save.id, false);
      req.send(null);
      var text = req.responseText;

      show();
    }


// key press
  public function onKey(e: Dynamic)
    {
      if (keyFocused) return;

      if (e.keyCode == 49) // 1
        onSaveReal(0);

      else if (e.keyCode == 50) // 2
        onSaveReal(1);

      else if (e.keyCode == 51) // 3
        onSaveReal(2);

      else if (e.keyCode == 52) // 4
        onSaveReal(3);

      else if (e.keyCode == 53) // 5
        onSaveReal(4);

      // exit menu
      else if (e.keyCode == 27) // ESC
        onClose(null);
    }


// hide menu
  function onClose(event: Dynamic)
    {
      window.style.display = 'none';
      bg.style.display = 'none';
      close.style.display = 'none';
      noKey.style.display = 'none';
      for (b in delButtons)
        b.style.display = 'none';
      for (b in saveButtons)
        b.style.display = 'none';
      isVisible = false;
    }
}
