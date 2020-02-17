// log window

import js.Browser;
import js.html.DivElement;

class Log extends Window
{
  var text: DivElement; // text element

  var logPrevTurn: Int; // number of previous turn

  public function new(uivar: UI, gvar: Game)
    {
      super(uivar, gvar, 'log', 800, 536, 20, 493);

      // log text
      var logBG = Browser.document.createDivElement();
      logBG.id = 'logBGIMG';
      window.appendChild(logBG);
      var logFG = Browser.document.createDivElement();
      logFG.id = 'logFG';
      logFG.className = 'uiTextFG';
      logBG.appendChild(logFG);
      text = Browser.document.createDivElement();
//      text.className = 'uiText';
      text.style.fontSize = '16px';
      text.style.padding = '10px';
      text.id = 'logText';
      logFG.appendChild(text);
    }


// add message to cult log
  public function getRenderedMessage(s: String): String
    {
      return
        "<span style='color:var(--text-color-log-time)'>" +
        DateTools.format(Date.now(), "%H:%M:%S") +
        "</span>" +
        " Turn " + (game.turns + 1) + ": " + s + "<br>";
    }


// clear log
  public function clear()
    {
      text.innerHTML = "";
    }


  override function onShow()
    {
      text.innerHTML = game.player.logMessages;
      text.scrollTop = 10000;
    }
}
