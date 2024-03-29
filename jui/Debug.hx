// debug menu

import js.Browser;
import js.html.DivElement;

class Debug extends Window
{
  var menu: DivElement; // menu element
  var buttons: Array<DivElement>;


  public function new(uivar: UI, gvar: Game)
    {
      super(uivar, gvar, 'debug', 800, 536, 20);
      buttons = [];

      // internals
      menu = Browser.document.createDivElement();
      menu.className = 'uiText';
      window.appendChild(menu);

      lastMenuY = -20;
      menuItem = 0;
      addItem(0, 'Give power', onGivePower);
      addItem(0, 'Open map', onOpenMap);
      addItem(0, 'Investigator: AI', onInvestigatorAI);
      addItem(0, 'Investigator: Player', onInvestigatorPlayer);
      addItem(0, 'Victory: Summon', function(event) {
        ui.finish(game.cults[0], "summon");
      });
      addItem(0, 'AI Victory: Summon', function(event) {
        ui.finish(game.cults[1], "summon");
      });
      addItem(0, 'Total war', onTotalWar);
      addItem(0, 'Invisibility toggle', onToggleInvisible);
      addItem(0, 'Trace timing toggle', onTiming);
      addItem(0, 'Trace AI toggle', onAI);
      addItem(0, 'Node vis toggle', onVis);
      addItem(0, 'Node near toggle', onNear);
      addItem(0, 'Give adepts', onGiveAdepts);
      addItem(0, 'Upgrade sects', onUpgradeSects);
      lastMenuY = -20;
      addItem(1, 'Trace Director toggle', onDirector);
      addItem(1, 'Artifacts: Spawn', function(event)
        {
          if (game.flags.artifacts)
            game.artifacts.spawn();
        });
      addItem(1, 'Victory: Conquer', function(event) {
        ui.finish(game.cults[0], "conquer");
      });
      addItem(1, 'AI Victory: Conquer', function(event) {
        ui.finish(game.cults[1], "conquer");
      });
    }


// upgrade sects
  function onUpgradeSects(event)
    {
      for (s in game.player.sects)
        s.size += 100;
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
              if (Math.random() < 0.2 && game.player.canActivate(n2))
                game.player.activate(n2);
          }
      game.player.awarenessBase = 0;
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


// toggle tracing director
  function onDirector(event)
    {
      Game.debugDirector = !Game.debugDirector;
      trace("trace director " + (Game.debugDirector ? "on" : "off"));
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

// unleash investigators on AI cults
  function onInvestigatorAI(event)
    {
      for (c in game.cults)
        if (c.isAI)
          {
            c.hasInvestigator = true;
            c.investigator = new Investigator(c, ui, game);
          }
    }


// unleash investigator on player cult
  function onInvestigatorPlayer(event)
    {
      for (c in game.cults)
        if (c == game.player)
          {
            c.hasInvestigator = true;
            c.investigator = new Investigator(c, ui, game);
          }
    }


// give 100 of each power
  function onGivePower(event)
    {
      for (i in 0...4)
        game.player.power[i] += 100;
      ui.updateStatus();
    }

// open game map
  function onOpenMap(event)
    {
      for (n in game.nodes)
        {
          n.setVisible(game.player, true);
          n.isKnown[game.player.id] = true;
        }

      for (c in game.cults)
        {
          c.isInfoKnown[game.player.id] = true;
          for (n in c.nodes)
            n.update();
        }
      ui.map.paint();
   }


// add menu item
  var lastMenuY: Int;
  var menuItem: Int;
  function addItem(row: Int, title: String, func)
    {
      lastMenuY += 30;
      var sym = menuItem + 49;
      if (menuItem > 8)
        sym = menuItem - 9 + 65 + 32;
      var b = Tools.button({
        id: 'menuItem' + lastMenuY,
        fontSize: 12,
        bold: false,
        text: String.fromCharCode(sym) + " " + title,
        w: 200,
        h: 22,
        x: 10 + row * 210,
        y: lastMenuY,
        container: menu,
        func: function(event) {
          func(event);
          ui.map.paint();
          onClose(null);
        }
      });
      untyped b.name = String.fromCharCode(sym);
      buttons.push(b);
      menuItem++;
    }


// key press
  public override function onKey(e: Dynamic)
    {
      // close current window
      if (e.keyCode == 27 || // Esc
          e.keyCode == 13 || // Enter
          e.keyCode == 32) // Space
        {
          onClose(null);
          return;
        }

      // find out which menu item was pressed
      for (b in buttons)
        if (untyped b.name == String.fromCharCode(e.keyCode).toLowerCase())
          {
            b.onclick(null);
            break;
          }
    }
}
