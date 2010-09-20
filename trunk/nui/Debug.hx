// debug menu

import nme.display.DisplayObject;
import nme.events.KeyboardEvent;
import nme.ui.Keyboard;

class Debug
{
  var ui: UI;
  var game: Game;

  var window: Window; // window element
  var buttons: Array<Button>;
  public var isVisible(getIsVisible, null): Bool;


  public function new(uivar: UI, gvar: Game)  
    {
      ui = uivar;
      game = gvar;
      buttons = new Array<Button>();
    }


// init stuff
  public function init()
    {
      window = new Window(ui.screen,
        {
          center: true,
          image: "logbg",
          w: 800, h: 500
        });

      // log close button
      var close = new Button(window, 
        { x: 364, y: 469, image: "close", onClick: onClose });

      lastMenuY = -20;
      menuItem = 0;
      addItem('Clear trace', onClearTrace);
      addItem('Give power', onGivePower);
      addItem('Open map', onOpenMap);
      addItem('Investigator: AI', onInvestigatorAI);
      addItem('Investigator: Player', onInvestigatorPlayer);
      addItem('Victory: Summon', onVictorySummon);
      addItem('Total war', onTotalWar);
      addItem('Invisibility toggle', onToggleInvisible);
      addItem('Trace timing toggle', onTiming);
      addItem('Trace AI toggle', onAI);
      addItem('Node vis toggle', onVis);
      addItem('Node near toggle', onNear);
      addItem('Give adepts', onGiveAdepts);
    }


// give adepts 
  function onGiveAdepts(event)
    {
      onGivePower(null);
      for (i in 0...3)
        for (n in game.player.nodes)
          {
            if (n.level < 1 && Math.random() < 0.5)
              n.upgrade();
            for (n2 in n.links)
              if (Math.random() < 0.2)
                game.player.activate(n2);
          }
    }


// clear trace
  function onClearTrace(event)
    {
//      UI.e("haxe:trace").innerHTML = '';
    }


// toggle timing
  function onTiming(event)
    {
      Game.debugTime = !Game.debugTime;
      trace("timing " + (Game.debugTime ? "on" : "off"));
    }


// toggle tracing AI
  function onAI(event)
    {
      Game.debugAI = !Game.debugAI;
      trace("trace ai " + (Game.debugAI ? "on" : "off"));
    }


// toggle tracing visibility
  function onVis(event)
    {
      Game.debugVis = !Game.debugVis;
      for (n in game.nodes)
        n.update();
      trace("node visibility to cults info " + (Game.debugVis ? "on" : "off"));
    }


// toggle tracing nearness
  function onNear(event)
    {
      Game.debugNear = !Game.debugNear;
      for (n in game.nodes)
        n.update();
      trace("node nearness info " + (Game.debugNear ? "on" : "off"));
    }


// player invisibility
  function onToggleInvisible(event)
    {
      game.player.isDebugInvisible = !game.player.isDebugInvisible;
      trace("invisibility " + (game.player.isDebugInvisible ? "on" : "off"));
    }


// total war
  function onTotalWar(event)
    {
      for (p in game.cults)
        for (i in 0...4)
          if (i != p.id)
            p.wars[i] = true;
    }


// win by summoning
  function onVictorySummon(event)
    {
      ui.finish(game.cults[0], "summon");
    }


// unleash investigators on AI cults
  function onInvestigatorAI(event)
    {
      for (c in game.cults)
        if (c.isAI)
          {
            c.hasInvestigator = true;
            c.investigator = new Investigator(c, ui);
          }
    }


// unleash investigator on player cult
  function onInvestigatorPlayer(event)
    {
      for (c in game.cults)
        if (c == game.player)
          {
            c.hasInvestigator = true;
            c.investigator = new Investigator(c, ui);
          }
    }


// give 100 of each power
  public function onGivePower(event)
    {
      for (i in 0...4)
        game.player.power[i] += 100;
      ui.updateStatus();
    }

// open game map
  function onOpenMap(event)
    {
      for (n in game.nodes)
        n.setVisible(game.player, true);
   }


// add menu item
  var lastMenuY: Int;
  var menuItem: Int;
  function addItem(title, func)
    {
      lastMenuY += 30;
      var sym = menuItem + 49;
      if (menuItem > 8)
        sym = menuItem - 9 + 65 + 32;
      var b = new Button(window,
        { x: 20, y: 10 + lastMenuY,
          label: { x: 3, y: 3, 
            text: String.fromCharCode(sym) + " " + title },
          font: { size: 12, bold: true },
          name: String.fromCharCode(sym),
          image: "button",
          onClick: func });
      buttons.push(b);
      menuItem++;
    }


// hide widget
  function onClose(target: DisplayObject)
    {
      window.visible = false;
    }


// show widget
  public function show()
    {
      window.visible = true;
    }


// key press
  public function onKey(e: KeyboardEvent)
    {
      // close current window
      if (e.keyCode == Keyboard.ESCAPE ||
          e.keyCode == Keyboard.ENTER ||
          e.keyCode == Keyboard.SPACE)
        {
          onClose(null);
          return;
        }

      // find out which menu item was pressed
      for (b in buttons)
        if (new String(b.name) == String.fromCharCode(e.keyCode))
          b.onClick(null);
    }


// getter for isVisible
  function getIsVisible(): Bool
    {
      return window.visible;
    }
}
