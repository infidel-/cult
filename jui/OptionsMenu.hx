// options menu class

import js.Browser;
import js.html.DivElement;
import js.html.InputElement;
import js.html.Element;

typedef OptionInfo =
{
  var name: String; // element name (and parameter name too)
  var title: String; // parameter title
  var note: String; // parameter note
  var type: String; // parameter type
  @:optional var y: Int; // optional y
};


class OptionsMenu extends Window
{
  var elements: List<Element>; // ui elements
  var contents: DivElement;
  var musicVolume: InputElement;
  var soundVolume: InputElement;
  var ambienceVolume: InputElement;

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
      note: 'Sect advisor will automatically give tasks to sects depending on the situation',
      y: 64,
    },
    {
      name: 'fullscreen',
      type: 'bool',
      title: 'Fullscreen',
      note: 'Enable or disable fullscreen mode'
    },
    {
      name: 'animation',
      type: 'bool',
      title: 'Animations',
      note: 'Enable or disable map animations'
    },
    {
      name: 'consoleLog',
      type: 'bool',
      title: 'Log Console',
      note: 'Enable or disable log console'
    },
  ];


  public function new(uivar: UI, gvar: Game)
    {
      super(uivar, gvar, 'options', 800, 390, 20);

      // title
      var title = Tools.label({
        id: 'optionsTitle',
        text: 'OPTIONS',
        w: null,
        h: null,
        x: null,
        y: 2,
        fontSize: null,
        container: window
      });
      title.style.width = '100%';
      title.style.textAlign = 'center';
      title.style.fontSize = 'larger';
      title.style.paddingBottom = '10px';

      contents = Browser.document.createDivElement();
      contents.className = 'uiText';
      contents.style.top = '27px';
      contents.style.height = '76%';
      window.appendChild(contents);
    }


// show main menu
  override function onShow()
    {
      contents.innerHTML = '';
      bg.style.display = 'none';

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
                w: 70,
                h: null,
                x: 240,
                y: y,
                fontSize: 14,
                container: contents
              });
              untyped el.checked = game.options.getBool(info.name);
            }
          else el = Tools.textfield({
            id: info.name,
            text: '' + game.options.get(info.name),
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
            y: (info.y != null ? info.y : y),
            fontSize: 14,
            bold: false,
            container: contents
          });

          y += 30;

          elements.add(el);
        }

      // music volume
      y += 30;
      Tools.label({
        id: 'labelMusicVolume',
        text: 'Music volume',
        w: 240,
        h: 20,
        x: 10,
        y: y,
        fontSize: 14,
        container: contents
      });
      Tools.button({
        id: 'musicVolumeDown',
        text: "-",
        className: 'uiButton',
        w: 16,
        h: 16,
        x: 230,
        y: y,
        fontSize: 14,
        container: contents,
        func: function(e) {
          ui.music.decreaseVolume();
          musicVolume.value = ui.config.get('musicVolume');
        }
      });
      musicVolume = Tools.textfield({
        id: 'musicVolumeText',
        text: ui.config.get('musicVolume'),
        w: 42,
        h: 20,
        x: 257,
        y: y,
        fontSize: 16,
        container: contents
      });
      musicVolume.readOnly = true;
      Tools.button({
        id: 'musicVolumeUp',
        text: "+",
        className: 'uiButton',
        w: 16,
        h: 16,
        x: 302,
        y: y,
        fontSize: 14,
        container: contents,
        func: function(e) {
          ui.music.increaseVolume();
          musicVolume.value = ui.config.get('musicVolume');
        }
      });
      y += 30;

      // sound volume
      Tools.label({
        id: 'labelSoundVolume',
        text: 'Sound volume',
        w: 240,
        h: 20,
        x: 10,
        y: y,
        fontSize: 14,
        container: contents
      });
      Tools.button({
        id: 'soundVolumeDown',
        text: "-",
        className: 'uiButton',
        w: 16,
        h: 16,
        x: 230,
        y: y,
        fontSize: 14,
        container: contents,
        func: function(e) {
          ui.sound.decreaseSoundVolume();
          soundVolume.value = ui.config.get('soundVolume');
        }
      });
      soundVolume = Tools.textfield({
        id: 'soundVolumeText',
        text: ui.config.get('soundVolume'),
        w: 42,
        h: 20,
        x: 257,
        y: y,
        fontSize: 16,
        container: contents
      });
      soundVolume.readOnly = true;
      Tools.button({
        id: 'soundVolumeUp',
        text: "+",
        className: 'uiButton',
        w: 16,
        h: 16,
        x: 302,
        y: y,
        fontSize: 14,
        container: contents,
        func: function(e) {
          ui.sound.increaseSoundVolume();
          soundVolume.value = ui.config.get('soundVolume');
        }
      });
      y += 30;

      // ambience volume
      Tools.label({
        id: 'labelAmbienceVolume',
        text: 'Ambience volume',
        w: 240,
        h: 20,
        x: 10,
        y: y,
        fontSize: 14,
        container: contents
      });
      Tools.button({
        id: 'ambienceVolumeDown',
        text: "-",
        className: 'uiButton',
        w: 16,
        h: 16,
        x: 230,
        y: y,
        fontSize: 14,
        container: contents,
        func: function(e) {
          ui.sound.decreaseAmbienceVolume();
          ambienceVolume.value = ui.config.get('ambienceVolume');
        }
      });
      ambienceVolume = Tools.textfield({
        id: 'ambienceVolumeText',
        text: ui.config.get('ambienceVolume'),
        w: 42,
        h: 20,
        x: 257,
        y: y,
        fontSize: 16,
        container: contents
      });
      ambienceVolume.readOnly = true;
      Tools.button({
        id: 'ambienceVolumeUp',
        text: "+",
        className: 'uiButton',
        w: 16,
        h: 16,
        x: 302,
        y: y,
        fontSize: 14,
        container: contents,
        func: function(e) {
          ui.sound.increaseAmbienceVolume();
          ambienceVolume.value = ui.config.get('ambienceVolume');
        }
      });
      y += 30;
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

          // save option and config
          game.options.set(info.name, value);
          ui.config.set(info.name, '' + value);

          // sect advisor off, clear task importance flag
          if (!game.isFinished && info.name == 'sectAdvisor' && !value)
            for (s in game.player.sects)
              s.taskImportant = false;

          // enable animations
          if (info.name == 'animation' && value)
            ui.map.enableAnimations();

          if (info.name == 'consoleLog')
            ui.logConsole.show(value);
        }

      var fs = game.options.getBool('fullscreen');
      if (ui.fullscreen != fs)
        ui.setFullscreen(fs);
      ui.map.paint();
    }


// key press
  public override function onKey(e: Dynamic)
    {
      // exit menu
      if (e.keyCode == 27) // ESC
        onClose(null);
    }
}
