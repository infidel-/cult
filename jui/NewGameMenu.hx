// new game menu class

import js.Browser;
import js.html.Element;
import js.html.DivElement;
import js.html.InputElement;
import js.html.SelectElement;
import js.html.OptionElement;
import Flags;

class NewGameMenu extends Window
{
  var note: Element;
  var cult: SelectElement;

  public function new(uivar: UI, gvar: Game)
    {
#if electron
      var h = 394;
#else
      var h = 374;
#end
      super(uivar, gvar, 'newGameMenu', 420, h, 20);

      close.innerHTML = 'CANCEL';
      close.style.left = '67%';
      var start = Tools.closeButton(window);
      start.onclick = onStart;
      start.innerHTML = 'START';
      start.style.left = '30%';

      // title
      var title = Tools.label({
        id: 'newGameMenuTitle',
        text: 'START NEW GAME',
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

      // menu contents
      var contents = Browser.document.createElement("div");
      contents.id = 'newGameMenuContents';
      contents.className = 'uiText';
      contents.style.userSelect = 'none';
      window.appendChild(contents);

      // cult name
      var row0 = Browser.document.createElement("div");
      row0.style.display = 'flex';
      contents.appendChild(row0);
      var cultLabel = Browser.document.createElement("div");
      cultLabel.innerHTML = 'Cult';
      cultLabel.style.padding= '0px 12px 0px 11px';
      row0.appendChild(cultLabel);
      cult = cast Browser.document.createElement("select");
      cult.className = 'selectOption';
      cult.style.fontSize = '20px';
      row0.appendChild(cult);
      var idx = 0;
      for (c in Static.cults)
        {
          var opt: OptionElement =
            cast Browser.document.createElement("option");
          opt.value = '' + (idx++);
          opt.innerHTML = c.name;
          cult.appendChild(opt);
        }
      cult.onmouseout = function(event)
        {
          note.innerHTML = '';
        }
      cult.onmouseover = function(event)
        {
          note.innerHTML = 'The choice of cult is purely cosmetical.';
        }

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
#if demo
      row2.style.color = UI.getVar('--text-color-disabled');
#end
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
#if demo
      row3.style.color = UI.getVar('--text-color-disabled');
#end
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
#if demo
      row.style.cursor = 'not-allowed';
#else
      row.style.cursor = 'hand';
#end
      var cb: InputElement = cast Browser.document.createElement("input");
      row.appendChild(cb);
      cb.id = key;
      cb.type = 'checkbox';
      cb.style.margin = '7px 10px 0px 10px';
      cb.onclick = function(event)
        {
          var cb: InputElement = cast Tools.getTarget(event);
          var id = cb.id.substr(cb.id.indexOf('_') + 1);
          var arr = null;
          if (cb.checked) // auto on/off
            arr = FlagStatic.autoOn[id];
          else arr = FlagStatic.autoOff[id];
          if (arr == null)
            return;
          for (tid in arr)
            {
              var t: InputElement = cast UI.e('startFlag_' + tid);
              t.checked = cb.checked;
            }
        }
#if demo
      cb.disabled = true;
#end
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
#if demo
      title.style.color = UI.getVar('--text-color-disabled');
#end
    }

  override function onShow()
    {
      bg.style.display = 'none';
    }

// start new game
  function onStart(event: Dynamic)
    {
      // get difficulty
      var dif = -1;
      for (d in Static.difficulty)
        {
          if (d.level < 0)
            continue;
          var opt: InputElement = cast UI.e('startDiff' + d.level);
          if (opt.checked)
            dif = d.level;
        }

      // get flags
      var flags: Flags = Reflect.copy(game.flagDefaults);
      for (f in Reflect.fields(flags))
        {
          var opt: InputElement = cast UI.e('startFlag_' + f);
          if (opt.checked)
            Reflect.setField(flags, f, true);
        }
      game.flags = flags;
      onNewGameReal(dif);
    }

// start for real
  function onNewGameReal(dif: Int)
    {
      // selected cult
      var opt: OptionElement = cast cult.selectedOptions.item(0);
      var cultID = Std.parseInt(opt.value);
/*
      trace(dif);
      trace(game.flags);
*/
      ui.mainMenu.onClose(null);
      onClose(null);
      ui.newGame(dif, null, cultID);
    }

// key press
  public override function onKey(e: Dynamic)
    {
      // exit menu
      if (e.keyCode == 27) // ESC
        onClose(null);

      // new game - easy
      else if (e.keyCode == 49) // 1
        onNewGameReal(0);

      // new game - normal
      else if (e.keyCode == 50) // 2
        onNewGameReal(1);

      // new game - hard
      else if (e.keyCode == 51) // 3
        onNewGameReal(2);
    }
}
