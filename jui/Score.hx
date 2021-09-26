// high scores window

import js.Browser;
import js.html.DivElement;
import js.html.SpanElement;
import sects.Sect;

class Score extends Window
{
  var text: DivElement; // text element

  public function new(uivar: UI, gvar: Game)
    {
      super(uivar, gvar, 'score', 500, 250, 20);

      text = js.Browser.document.createDivElement();
      text.className = 'uiText';
      window.appendChild(text);
    }

  override function onShow()
    {
      var time = Std.int(Sys.time() - game.startTS);
      text.innerHTML =
        'You have made ' + game.turns + ' turns so far.<br>Time passed: ' +
        game.highScores.convertTime(time) + '.' +
        game.highScores.getTable(0);
    }
}
