// new game menu class

import js.Browser;
import js.html.Element;
import js.html.DivElement;
import js.html.InputElement;
import Flags;

class NewGameMenu extends Window
{
  var note: Element;

  public function new(uivar: UI, gvar: Game)
    {
#if electron
      var h = 380;
#else
      var h = 334;
#end
      super(uivar, gvar, 'newGameMenu', 420, h, 20);

      close.innerHTML = 'CANCEL';
      close.style.left = '67%';
      var start = Tools.closeButton(window);
      start.onclick = function(event) { trace('start!'); };
      start.innerHTML = 'START';
      start.style.left = '30%';

      // title
      var title = Tools.label({
        id: 'newGameMenuTitle',
        text: 'START NEW GAME',
        w: 0,
        h: 30,
        x: null,
        y: null,
        fontSize: null,
        container: window
      });
      title.style.width = '100%';
      title.style.textAlign = 'center';
      title.style.fontSize = 'larger';
      title.style.paddingBottom = '10px';

      // menu contents
      var contents = Browser.document.createElement("div");
      contents.id = 'newGameMenuContents';
      contents.className = 'uiText';
      contents.style.userSelect = 'none';
      window.appendChild(contents);

      // difficulty
      var row1 = Browser.document.createElement("div");
      row1.style.display = 'flex';
      contents.appendChild(row1);
      var diff = Browser.document.createElement("div");
      diff.innerHTML = 'Difficulty';
      diff.style.padding= '0px 12px 0px 11px';
      row1.appendChild(diff);
      for (d in Static.difficulty)
        {
          if (d.level < 0)
            continue;

          // label
          var label = Browser.document.createElement("label");
          row1.appendChild(label);
          label.style.paddingRight = '10px';
          label.style.cursor = 'hand';
          label.onmouseout = function(event)
            {
              note.innerHTML = '';
            }
          label.onmouseover = function(event)
            {
              note.innerHTML = d.note;
            }

          // radio button
          var opt:InputElement = cast Browser.document.createElement("input");
          label.appendChild(opt);
          opt.type = 'radio';
          opt.id = 'startDiff' + d.level;
          opt.name = 'startDiff';
          if (d.level == 1)
            opt.defaultChecked = true;
          label.innerHTML += d.name;
        }

      // flags
      var row2 = Browser.document.createElement("div");
      contents.appendChild(row2);
      row2.style.textAlign = 'center';
      row2.style.padding = '5px 0px 5px';
      row2.innerHTML = 'Flags';
      for (f in Reflect.fields(game.flags))
        {
          if (f == 'artifacts')
            continue;
          addCheckbox(contents, 'startFlag_' + f,
            FlagStatic.names[f], FlagStatic.notes[f]);
        }

      // expansions
      var row3 = Browser.document.createElement("div");
      contents.appendChild(row3);
      row3.style.textAlign = 'center';
      row3.style.padding = '5px 0px 5px';
      row3.innerHTML = 'Expansions';
      addCheckbox(contents, 'startFlag_artifacts',
        FlagStatic.names['artifacts'],
        FlagStatic.notes['artifacts']);

      // note
      var row4 = Browser.document.createElement("div");
      contents.appendChild(row4);
      var hr = Browser.document.createElement("hr");
      row4.appendChild(hr);
      note = Browser.document.createElement("div");
      contents.appendChild(note);
      note.style.fontSize = 'smaller';
      note.style.padding = '0px 5px 0px 5px';
//      note.style.textAlign = 'justify';
      note.innerHTML = 'Choose difficulty setting, game flags and expansions.';
    }

// add flag or expansion checkbox
  function addCheckbox(contents: Element, key: String, name: String,
      text: String)
    {
      var row = Browser.document.createElement("label");
      contents.appendChild(row);
      row.style.display = 'flex';
      row.style.cursor = 'hand';
      var cb: InputElement = cast Browser.document.createElement("input");
      row.appendChild(cb);
      cb.type = 'checkbox';
      cb.style.margin = '7px 10px 0px 10px';
      var title = Browser.document.createElement("div");
      row.appendChild(title);
      title.innerHTML = name;
      title.onmouseout = function(event)
        {
          note.innerHTML = '';
        }
      title.onmouseover = function(event)
        {
          note.innerHTML = text;
        }
    }

  override function onShow()
    {
    }

/*
// custom game menu
  function onCustomGame(event: Dynamic)
    {
      ui.customMenu.show();
      onClose(null);
    }


// multiplayer game menu
  function onMultiplayerGame(event: Dynamic)
    {
      ui.mpMenu.show();
      onClose(null);
    }


// load game menu
  function onLoadGame(event: Dynamic)
    {
      ui.loadMenu.show();
      onClose(null);
    }


// save game menu
  function onSaveGame(event: Dynamic)
    {
      ui.saveMenu.show();
      onClose(null);
    }

// start new game
  function onNewGame(event: Dynamic)
    {
      var id = Tools.getTarget(event).id;
      var dif = 0;
      if (id == "newGameEasy")
        dif = 0;
      else if (id == "newGameNormal")
        dif = 1;
      else dif = 2;
      onNewGameReal(dif);
    }


// start for real
  function onNewGameReal(dif: Int)
    {
      onClose(null);
      ui.newGame(dif);
    }
*/


// key press
  public override function onKey(e: Dynamic)
    {
/*
//      trace(e.keyCode);
      // new game - easy
      if (e.keyCode == 49) // 1
        onNewGameReal(0);

      // new game - normal
      else if (e.keyCode == 50) // 2
        onNewGameReal(1);

      // new game - hard
      else if (e.keyCode == 51) // 3
        onNewGameReal(2);

      // custom game
      else if (e.keyCode == 52) // 4
        onCustomGame(null);

      // multiplayer game
      else if (e.keyCode == 53) // 5
        onMultiplayerGame(null);

      // debug game start
      else if (e.keyCode == 88 && Game.isDebug) // x
        {
          onClose(null);
          game.isTutorial = false;
          game.difficultyLevel = 2; // 1 - normal
          game.flags.noBlitz = true;
          game.flags.devoted = true;
          game.flags.longRituals = true;
          game.flags.artifacts = true;
          game.restart();
        }
      // exit menu
      else if (e.keyCode == 27 && !game.isNeverStarted) // ESC
        onClose(null);
*/
    }
}
