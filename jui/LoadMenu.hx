// load game menu

import js.Browser;
import js.html.DivElement;
#if electron
import electron.renderer.Remote;
import haxe.Json;
import js.node.Fs;
#end
import _SaveGame;

class LoadMenu extends Window
{
  var saveButtons: Array<DivElement>;
  var saveExist: Array<Bool>;

  public function new(uivar: UI, gvar: Game)
    {
#if electron
      var h = 464;
#else
      var h = 200;
#end
      super(uivar, gvar, 'loadMenu', 350, h, 25);

      Tools.label({
        id: 'loadMenuTitle',
        text: 'LOAD GAME',
        w: 260,
        h: 30,
        x: null,
        y: null,
        fontSize: null,
        container: window
      });

      // load menu contents
      var contents: DivElement = cast Browser.document.createElement("div");
      contents.id = 'saveMenuContents';
      window.appendChild(contents);
      saveButtons = [];
      for (i in 0...UI.maxSaves)
        {
          var b = Tools.button({
            id: 'load' + i,
            text: '&lt;EMPTY&gt;',
            className: 'uiButton statusButton saveMenuButton',
            w: null,
            h: null,
            x: null,
            y: null,
            flow: true,
            container: contents,
            func: onLoadGame
          });
          saveButtons.push(b);
        }
    }

// show load menu
  override function onShow()
    {
      // form the list of saved games
      saveExist = [];
      for (i in 0...UI.maxSaves)
        {
          var b = saveButtons[i];
          try {
            var files = ui.saveMenu.getFileNames(i);
            var s = Fs.readFileSync(files[0], 'utf8');
            var obj: _SaveInfo = Json.parse(s);
            b.className = 'uiButton statusButton saveMenuButton';
            b.innerHTML = obj.date + '<hr><span class=saveMenuText2>' +
              'TURNS ' + obj.turns + ': ' +
              obj.difficulty.toUpperCase() + ', ' +
              (obj.flags != '' ? obj.flags : 'DEFAULT FLAGS') + '</span>';
            saveExist.push(true);
            continue;
          }
          catch (e: Dynamic)
            {}

          // no save
          b.innerHTML = '&lt;EMPTY&gt;';
          b.className = 'uiButtonDisabled statusButton saveMenuButton';
          saveExist.push(false);
        }
    }

// load game
  function onLoadGame(event: Dynamic)
    {
      var b = Tools.getTarget(event);
      var n = Std.parseInt(b.id.substring(4));

      if (!saveExist[n])
        return;
      onLoadReal(n);
    }

// load a game (real)
  function onLoadReal(n: Int)
    {
#if electron
      var state = 0;
      try {
        var files = ui.saveMenu.getFileNames(n);
        var str = Fs.readFileSync(files[1], 'utf8');
        state++;
        var obj = Json.parse(str);
        game.load(obj);
        trace('game loaded from ' + files[1]);
        state++;
      }
      catch (e: Dynamic)
        {
          ui.msg('Could not load game.');
          ui.onError('Could not load game.', '', 0, 0, e);
        }

      if (state == 2)
        ui.msg('Game loaded.');
#end

      onClose(null);
    }

// key press
  public override function onKey(e: Dynamic)
    {
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
}
