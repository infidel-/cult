// save game menu

import js.Browser;
import js.html.DivElement;
#if electron
import electron.renderer.Remote;
import haxe.Json;
import js.node.Fs;
#end
import _SaveGame;

class SaveMenu extends Window
{
  var saveButtons: Array<DivElement>;

  public function new(uivar: UI, gvar: Game)
    {
#if electron
      var h = 464;
#else
      var h = 200;
#end
      super(uivar, gvar, 'saveMenu', 350, h, 25);

      Tools.label({
        id: 'saveMenuTitle',
        text: 'SAVE GAME',
        w: 260,
        h: 30,
        x: null,
        y: null,
        fontSize: null,
        container: window
      });

      // save menu contents
      var contents: DivElement = cast Browser.document.createElement("div");
      contents.id = 'saveMenuContents';
      window.appendChild(contents);
      saveButtons = [];
      for (i in 0...UI.maxSaves)
        {
          var b = Tools.button({
            id: 'save' + i,
            text: '&lt;EMPTY&gt;',
            className: 'uiButton statusButton saveMenuButton',
            w: null,
            h: null,
            x: null,
            y: null,
            flow: true,
            container: contents,
            func: onSaveGame
          });
          saveButtons.push(b);
        }
    }

// show save menu
  override function onShow()
    {
      // form the list of saved games
      for (i in 0...UI.maxSaves)
        {
          var b = saveButtons[i];
          try {
            var files = getFileNames(i);
            var s = Fs.readFileSync(files[0], 'utf8');
            var obj: _SaveInfo = Json.parse(s);
            b.innerHTML = obj.date + '<hr><span class=saveMenuText2>' +
              'TURNS ' + obj.turns + ': ' +
              obj.difficulty.toUpperCase() + ', ' +
              (obj.flags != '' ? obj.flags : 'DEFAULT FLAGS') + '</span>';
            continue;
          }
          catch (e: Dynamic)
            {}

          // no save
          b.innerHTML = '&lt;EMPTY&gt;';
        }
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
#if electron
      var files = getFileNames(n);

      // info
      var info = game.saveInfo();
      var str = Json.stringify(info, null, '  ');
      Fs.writeFileSync(files[0], str, 'utf8');
      trace('info saved to ' + files[0]);

      // save
      var obj = game.save();
      var str = Json.stringify(obj, null, '  ');
      Fs.writeFileSync(files[1], str, 'utf8');
      trace('game saved to ' + files[1]);

      ui.msg('Game saved.');
#end

      onClose(null);
    }

// get save info and save game file names
  public function getFileNames(i: Int): Array<String>
    {
#if electron
      return [
        (UI.classicMode ? 'classic_' : '') +
          'save' + (i < 10 ? '0' : '') + (i + 1) + '_info.json',
        (UI.classicMode ? 'classic_' : '') +
          'save' + (i < 10 ? '0' : '') + (i + 1) + '.json',
      ];
#end

      return null;
    }

// key press
  public override function onKey(e: Dynamic)
    {
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
}
