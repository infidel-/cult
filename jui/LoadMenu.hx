// load game menu

class LoadMenu
{
  var ui: UI;
  var game: Game;

  var window: Dynamic; // window element
  var bg: Dynamic; // background element
  var close: Dynamic; // close button element
  var key: Dynamic; // key textfield element
  var noSavesFound: Dynamic; // no saves found text
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

      // load menu window
      window = Tools.window(
        {
          id: "loadMenuWindow",
          center: true,
          winW: UI.winWidth,
          winH: UI.winHeight,
          w: 420,
          h: 320,
          z: 25
        });

      Tools.label({
        id: 'loadLabel',
        text: 'Key',
        w: 60,
        h: 30,
        x: 35,
        y: 30,
        container: window
        });

      // text field
      key = Tools.textfield({
        id: 'loadKey',
        text: ui.config.get("owner"),
        w: 205,
        h: 30,
        x: 85,
        y: 30,
        container: window
        });
      key.onclick = onKeyClick;

      Tools.button({ // refresh button
        id: 'loadRefresh',
        text: "Refresh",
        w: 100,
        h: 30,
        x: 300,
        y: 30,
        container: window,
        func: onRefresh
        });

      noSavesFound = Tools.label({
        id: 'loadLabel2',
        text: 'No saves found.',
        w: 200,
        h: 30,
        x: 140,
        y: 150,
        container: window
        });


      // load menu contents
      saves = new Array<Dynamic>();
      saveButtons = new Array<Dynamic>();
      delButtons = new Array<Dynamic>();
      for (i in 0...UI.maxSaves)
        {
          var b = Tools.button({
            id: 'load' + i,
            text: "Load",
            w: 330,
            h: 30,
            x: 35,
            y: 70 + 40 * i,
            container: window,
            func: onLoadGame
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
      close = Tools.closeButton(window, 180, 280, 'loadMenuClose');
      close.onclick = onClose;
    }


// show load menu
  public function show()
    {
      // load list of saved games
      var list = [];
      if (ui.config.get("owner") != '')
        {
          var req = new js.html.XMLHttpRequest();
          req.open("GET", "/save.list?owner=" +
            ui.config.get("owner"), false);
          req.send(null);
          var text = req.responseText;
          list = untyped JSON.parse(text);
        }
      saves = list;

      var i = 0;
      for (b in saveButtons)
        {
          b.style.display = 'none';
          delButtons[i].style.display = 'none';
          i++;
        }

      i = 0;
      noSavesFound.style.display = 'inline';
      for (item in list)
        {
          var b = saveButtons[i];
          if (b == null) break;
//          item.date = item.date.substr(0, item.date.indexOf("."));
          b.innerHTML = item.name;
          b.style.display = 'inline';
          delButtons[i].style.display = 'inline';
          i++;

          noSavesFound.style.display = 'none';
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


// load game
  function onLoadGame(event: Dynamic)
    {
      var b = Tools.getTarget(event);
      var n = Std.parseInt(b.id.substring(4));

      onLoadReal(n);
    }


// load a game (real)
  function onLoadReal(n: Int)
    {
      var save = saves[n];

      // load game
      var req = new js.html.XMLHttpRequest();
      req.open("GET", "/save.load?owner=" +
        ui.config.get("owner") + "&id=" + save.id, false);
      req.send(null);
      var text = req.responseText;
      if (text == "NoSuchSave")
        return;
      var savedGame = untyped JSON.parse(text);
      game.load(savedGame);

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
        onLoadReal(0);

      else if (e.keyCode == 50) // 2
        onLoadReal(1);

      else if (e.keyCode == 51) // 3
        onLoadReal(2);

      else if (e.keyCode == 52) // 4
        onLoadReal(3);

      else if (e.keyCode == 53) // 5
        onLoadReal(4);

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
      noSavesFound.style.display = 'none';
      for (b in saveButtons)
        b.style.display = 'none';
      for (b in delButtons)
        b.style.display = 'none';
      isVisible = false;
    }
}
