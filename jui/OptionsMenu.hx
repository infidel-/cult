// options menu class

import js.Browser;
import js.html.DivElement;
import js.html.Element;

typedef OptionInfo =
{
  var name: String; // element name (and parameter name too)
  var title: String; // parameter title
  var note: String; // parameter note
  var type: String; // parameter type
};


class OptionsMenu extends Window
{
  var elements: List<Element>; // ui elements
  var contents: DivElement;

  public static var elementInfo: Array<OptionInfo> = [
/*
      { name: 'investigatorTurnVisible', type: 'int', title: 'Investigator: Turn to become visible',
        note: 'Turn on which new investigator becomes visible' },
      { name: 'investigatorGainWill', type: 'float', title: 'Investigator: Chance of gaining will',
        note: 'Higher value raises chance of investigator gaining will' },
*/
    {
      name: 'mapAdvancedMode',
      type: 'bool',
      title: 'Advanced map mode',
      note: 'Displays additional node information on map'
    },
    {
      name: 'logPanelSkipSects',
      type: 'bool',
      title: 'No sect messages in log panel',
      note: 'Will not show sect messages in log panel'
    },
    {
      name: 'sectAdvisor',
      type: 'bool',
      title: 'Sect advisor',
      note: 'Sect advisor will automatically give tasks to sects depending on the situation'
    },
  ];


  public function new(uivar: UI, gvar: Game)
    {
      super(uivar, gvar, 'options', 800, 536, 20, 493);

/*
      Tools.label({
        id: 'titleLabel',
        text: 'Game Options',
        w: 158,
        h: 30,
        x: null,
        y: 10,
        container: window
      });
*/

      contents = Browser.document.createDivElement();
      contents.className = 'uiText';
      window.appendChild(contents);
    }


// show main menu
  override function onShow()
    {
      contents.innerHTML = '';

      elements = new List();
      var y = 10;

      for (info in elementInfo)
        {
          // parameter label
          Tools.label({
            id: 'label' + info.name,
            text: info.title,
            w: 240,
            h: 20,
            x: 10,
            y: y,
            fontSize: 14,
            container: contents
            });

          // parameter field
          var el: Element = null;

          if (info.type == 'bool')
            {
              el = Tools.checkbox({
                id: info.name,
                text: '',
//                text: '' + game.player.options.get(info.name),
                w: 70,
                h: null,
                x: 240,
                y: y,
                fontSize: 14,
                container: contents
              });
              untyped el.checked = game.player.options.getBool(info.name);
            }
          else el = Tools.textfield({
            id: info.name,
            text: '' + game.player.options.get(info.name),
            w: 70,
            h: 20,
            x: 240,
            y: y,
            fontSize: 14,
            container: contents
          });

          // parameter note
          Tools.label({
            id: 'note' + info.name,
            text: info.note,
            w: 450,
            h: 20,
            x: 310,
            y: y,
            fontSize: 14,
            bold: false,
            container: contents
          });

          y += 30;

          elements.add(el);
        }
    }


// close menu
  override function onCloseHook()
    {
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
            value = Std.parseInt(untyped el.value);
          else if (info.type == 'float')
            value = Std.parseFloat(untyped el.value);
          else if (info.type == 'bool')
            value = untyped el.checked;

          // save option
          game.player.options.set(info.name, value);

          // save to config in single player
          if (game.difficulty.numPlayers == 1)
            ui.config.set(info.name, '' + value);

          // sect advisor off, clear task importance flag
          if (info.name == 'sectAdvisor' && !value)
            for (s in game.player.sects)
              s.taskImportant = false;
        }

      game.applyPlayerOptions(); // apply player options
    }


// key press
  public override function onKey(e: Dynamic)
    {
      // exit menu
      if (e.keyCode == 27) // ESC
        onClose(null);
    }
}
