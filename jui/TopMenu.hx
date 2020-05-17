// top menu

import js.Browser;
import js.html.DivElement;

class TopMenu
{
  var ui: UI;
  var game: Game;

  var panel: DivElement;
  var manual: DivElement;
  var about: DivElement;
  var advanced: DivElement;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;

      // panel element
      panel = Browser.document.createDivElement();
      panel.id = 'topPanel';
      Browser.document.body.appendChild(panel);

      Tools.button({
        id: 'cults',
        text: "CULTS",
        className: 'topButton uiButton',
        w: 70,
        h: null,
        x: 20,
        y: null,
        container: panel,
        title: "Click to view cults information (or press <span class=shadow style=\"color:white\">C</span>).",
        func: onCults
      });

      Tools.button({
        id: 'sects',
        text: "SECTS",
        className: 'topButton uiButton',
        w: 70,
        h: null,
        x: 110,
        y: null,
        container: panel,
        title: "Click to view sects controlled by your cult (or press <span class=shadow style=\"color:white\">S</span>).",
        func: onSects
      });

      Tools.button({
        id: 'log',
        text: "LOG",
        className: 'topButton uiButton',
        w: 70,
        h: null,
        x: 200,
        y: null,
        container: panel,
        title: "Click to view message log (or press <span class=shadow style=\"color:white\">L</span>).",
        func: onLog
      });

      Tools.button({
        id: 'options',
        text: "OPTIONS",
        className: 'topButton uiButton',
        w: 100,
        h: null,
        x: 290,
        y: null,
        container: panel,
        title: "Click to view options (or press <span class=shadow style=\"color:white\">O</span>).",
        func: onOptions
      });

      if (Game.isDebug)
        Tools.button({
          id: 'debug',
          text: "DEBUG",
          className: 'topButton uiButton',
          w: 70,
          h: null,
          x: 410,
          y: null,
          container: panel,
          title: "Click to open debug menu (or press <span class=shadow style=\"color:white\">D</span>).",
          func: onDebug
        });

      manual = Tools.button({
        id: 'manual',
        text: "MANUAL",
        className: 'topButton uiButton',
        w: 84,
        h: null,
        x: 597,
        y: null,
        container: panel,
        title: "Click&nbsp;to&nbsp;open&nbsp;the&nbsp;manual&nbsp;(or&nbsp;press&nbsp;<span class=shadow style=\"color:white\">M</span>).",
        func: function(event: Dynamic)
          {
#if electron
            ui.manual.show();
#else
            Browser.window.open("https://github.com/infidel-/cult/wiki/Manual");
#end
          }
      });

      about = Tools.button({
        id: 'about',
        text: "ABOUT",
        className: 'topButton uiButton',
        w: 70,
        h: null,
        x: 700,
        y: null,
        container: panel,
        // kludge to fix tooltip display
        title: "Click&nbsp;to&nbsp;open&nbsp;About&nbsp;page.",
        func: function(event: Dynamic)
          {
            ui.alert(
              '<center style="font-size:19px;font-weight:bold">About</center><br>' +
              'Code by Max Kowarski &lt;starinfidel@gmail.com&gt;<br>' +
#if electron
              'Texts by Phil Bordelon &lt;http://blortblort.org/&gt;<br>' +
              'Music by Jeremy Rice &lt;https://curious-inversions.bandcamp.com&gt;<br><br>' +
#else
              'Texts by Phil Bordelon &lt;<a target=_blank href="http://blortblort.org/">blortblort.org</a>&gt;<br>' +
              'Music by Jeremy Rice &lt;<a target=_blank href="https://curious-inversions.bandcamp.com">curious-inversions.bandcamp.com</a>&gt;<br><br>' +
#end
              '<span style="font-size:12px">Unfortunately, due to the fact that the music sources were lost at some point, you cannot purchase the music you listen to in the game. But there\'s a lot of newer works on the Bandcamp page, please check it out.</span><br><br>' +
              'Unceasing gratitude to the man who has acquainted us all with the blasphemous effulgence of cosmic horror - H.P.Lovecraft.<br><br>' +
#if electron
              'This project uses icons made by Pixel perfect, Nikita Golubev, Vitaly Gorbachev, wanicon, and Freepik from www.flaticon.com.', {
#else
              'This project uses icons made by Pixel perfect, Nikita Golubev, Vitaly Gorbachev, wanicon, and Freepik from <a target=_blank href="https://www.flaticon.com">www.flaticon.com</a>.', {
#end
              w: 750,
              h: 300,
              center: false,
              fontSize: 14,
            });
          }
      });

      advanced = Tools.button({
        id: 'advanced',
        text: "A",
        w: 12,
        h: 12,
        x: 774,
        y: 29,
        fontSize: 10,
        container: panel,
        // kludge to fix tooltip display
        title: "Click&nbsp;to&nbsp;toggle&nbsp;advanced&nbsp;map&nbsp;mode&nbsp;(or&nbsp;press&nbsp;<span class=shadow style=\"color:white\">A</span>).",
        func: onAdvanced
      });
      if (UI.modernMode)
        advanced.style.top = '25px';
    }


  public function onCults(event: Dynamic)
    {
      ui.info.show();
    }


  public function onSects(e: Dynamic)
    {
      ui.sects.show();
    }


  public function onLog(event: Dynamic)
    {
      ui.logWindow.show();
    }


  public function onOptions(event: Dynamic)
    {
      ui.options.show();
    }


  public function onDebug(event)
    {
      if (game.isFinished || !Game.isDebug)
        return;

      ui.debug.show();
    }


  public function onAdvanced(event)
    {
      game.player.options.set('mapAdvancedMode',
        !game.player.options.getBool('mapAdvancedMode'));
      ui.map.paint();
    }


// resize menu
  public function resize()
    {
      var panelRect = panel.getBoundingClientRect();
      panel.style.width = (Browser.window.innerWidth -
        panelRect.left - 8) + 'px';
      var x = Std.parseInt(panel.style.width) -
        Std.parseInt(about.style.width) - 30;
      about.style.left = x + 'px';
      x -= (Std.parseInt(manual.style.width) + 20);
      manual.style.left = x + 'px';

      var marginx = UI.getVarInt('--advanced-mode-margin-x');
      advanced.style.left = (Browser.window.innerWidth -
        Std.parseInt(advanced.style.width) - panelRect.left -
        marginx) + 'px';
    }
}
