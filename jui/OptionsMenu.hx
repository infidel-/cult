// options menu class


typedef OptionInfo =
{
  var name: String; // element name (and parameter name too)
  var title: String; // parameter title
  var note: String; // parameter note
  var type: String; // parameter type
};


class OptionsMenu
{
  var ui: UI;
  var game: Game;

  var window: Dynamic; // window element
  var bg: Dynamic; // background element
  var close: Dynamic; // close button element
  public var isVisible: Bool;
  var elements: List<Dynamic>; // ui elements

  static var elementInfo: Array<OptionInfo> =
    [
/*
      { name: 'investigatorTurnVisible', type: 'int', title: 'Investigator: Turn to become visible',
        note: 'Turn on which new investigator becomes visible' },
      { name: 'investigatorGainWill', type: 'float', title: 'Investigator: Chance of gaining will',
        note: 'Higher value raises chance of investigator gaining will' },
*/
      { name: 'mapAdvancedMode', type: 'bool', title: 'Advanced map mode',
        note: 'Displays additional node information on map' },
      { name: 'logPanelSkipSects', type: 'bool', title: 'No sect messages in log panel',
        note: 'Will not show sect messages in log panel' },
      { name: 'sectAdvisor', type: 'bool', title: 'Sect advisor',
        note: 'Sect advisor will automatically give tasks to sects depending on the situation' },
    ];


  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      isVisible = false;

      // window
      window = Tools.window(
        {
          id: "optionMenuWindow",
          center: true,
          winW: UI.winWidth,
          winH: UI.winHeight,
          w: 1000,
          h: 500,
          z: 20
        });
    }


// show main menu
  public function show()
    {
      window.innerHTML = '';

      Tools.label({
        id: 'titleLabel',
        text: 'Game Options',
        w: 300,
        h: 30,
        x: 420,
        y: 10,
        container: window
        });

      var divel = js.Lib.document.createElement("div");
      divel.style.background = '#030303';
      divel.style.left = '10';
      divel.style.top = '40';
      divel.style.width = '980';
      divel.style.height = '400';
      divel.style.position = 'absolute';
      divel.style.overflow = 'auto';
      window.appendChild(divel);

      elements = new List<Dynamic>();
      var y = 10;
      
      for (info in elementInfo)
        {
          // parameter label
          Tools.label({
            id: 'label' + info.name,
            text: info.title,
            w: 300,
            h: 20,
            x: 10,
            y: y,
            fontSize: 14,
            container: divel
            });

          // parameter field
          var el = null;

          if (info.type == 'bool')
            {
              el = Tools.checkbox({
                id: info.name,
//                text: '' + game.player.options.get(info.name),
                w: 70,
                h: 20,
                x: 320,
                y: y,
                fontSize: 14,
                container: divel
                });
              el.checked = game.player.options.getBool(info.name);
            }
          else el = Tools.textfield({
            id: info.name,
            text: '' + game.player.options.get(info.name),
            w: 70,
            h: 20,
            x: 320,
            y: y,
            fontSize: 14,
            container: divel
            });

          // parameter note
          Tools.label({
            id: 'note' + info.name,
            text: info.note,
            w: 540,
            h: 20,
            x: 410,
            y: y,
            fontSize: 14,
            bold: false,
            container: divel
            });

          y += 30;
          
          elements.add(el);
        }

      bg = Tools.bg({ w: UI.winWidth + 20, h: UI.winHeight});
      close = Tools.closeButton(window, 460, 460, 'optionMenuClose');
	  close.onclick = onClose;

      // make window visible
      window.style.visibility = 'visible';
      bg.style.visibility = 'visible';
      close.style.visibility = 'visible';
      isVisible = true;
    }


// close menu
  public function onClose(e: Dynamic)
    {
      var dif: Dynamic = { level: -1 };
      UI.e("haxe:trace").innerHTML = "";

      // save all options for current player
      for (info in elementInfo)
        {
          var el = null;
          for (e in elements)
            if (e.id == info.name)
              {
                el = e;
                break;
              }

          var value: Dynamic = null;
          if (info.type == 'int')
            value = Std.parseInt(el.value);
          else if (info.type == 'float')
            value = Std.parseFloat(el.value);
          else if (info.type == 'bool')
            value = el.checked;

          // save option
          game.player.options.set(info.name, value);

          // sect advisor off, clear task importance flag
          if (info.name == 'sectAdvisor' && !value)
            for (s in game.player.sects)
              s.taskImportant = false;
        }

      game.applyPlayerOptions(); // apply player options
      realClose();
    }


// key press
  public function onKey(e: Dynamic)
    {
      // exit menu
      if (e.keyCode == 27) // ESC
        onClose(null);
    }


  function realClose()
    {
      window.style.visibility = 'hidden';
      bg.style.visibility = 'hidden';
      close.style.visibility = 'hidden';
      isVisible = false;
    }
}
