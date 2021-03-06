// custom menu class

import js.html.DivElement;
import js.html.Element;

typedef DifficultyUIInfo =
{
  var name: String; // element name (and parameter name too)
  var title: String; // parameter title
  var note: String; // parameter note
  var type: String; // parameter type
};


class CustomMenu extends Window
{
  var difElements: List<Element>; // ui elements

  public function new(uivar: UI, gvar: Game)
    {
      super(uivar, gvar, 'customMenu', 1000, 536, 20);

      var title = Tools.label({
        id: 'titleLabel',
        text: 'Custom game parameters',
        w: null,
        h: null,
        x: 320,
        y: 2,
        container: window
      });
      title.style.fontSize = 'larger';

      var divel = js.Browser.document.createElement("div");
      divel.className = 'uiText';
      divel.style.top = '4.5%';
      divel.style.height = '81%';
      window.appendChild(divel);

      difElements = new List();
      var y = 10;

      for (info in difElementInfo)
        {
          // parameter label
          Tools.label({
            id: 'label' + info.name,
            text: info.title,
            w: 300,
            h: 20,
            x: 10,
            y: y,
            fontSize: 14,
            container: divel
            });

          // parameter field
          var el: Element = null;

          if (info.type == 'bool')
            el = Tools.checkbox({
              id: info.name,
              text: '' + Reflect.field(Static.difficulty[2], info.name),
              w: 70,
              h: null,
              x: 320,
              y: y,
              fontSize: 14,
              container: divel
            });
          else
            {
              el = Tools.textfield({
                id: info.name,
                text: '' + Reflect.field(Static.difficulty[2], info.name),
                w: 70,
                h: 20,
                x: 320,
                y: y,
                fontSize: 14,
                container: divel
              });
            }

          // parameter note
          Tools.label({
            id: 'note' + info.name,
            text: info.note,
            w: 540,
            h: 20,
            x: 410,
            y: y,
            fontSize: 14,
            bold: false,
            container: divel
          });

          y += 30;

          difElements.add(el);
        }

      var b = Tools.button({
        id: 'startCustomGame',
        text: "Start",
        w: 80,
        h: null,
        x: null,
        y: null,
        container: window,
        func: onStartGame
      });
      b.style.left = '33%';
      b.style.bottom = '3%';
      b.style.transform = 'translate(-50%)';

      close.style.left = '66%';
      close.style.bottom = '3%';
      close.style.transform = 'translate(-50%)';
    }


  public function onStartGame(e: Dynamic)
    {
      var dif: Dynamic = { level: -1 };

      for (info in difElementInfo)
        {
          var el = null;
          for (e in difElements)
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
          Reflect.setField(dif, info.name, value);
        }

//      trace(dif);
      if (dif.numPlayers < 1)
        dif.numPlayers = 1;
      if (dif.numCults < 2)
        dif.numCults = 2;
      if (dif.numPlayers > 8)
        dif.numPlayers = 8;
      if (dif.numCults > 8)
        dif.numCults = 8;

      ui.newGame(-1, dif);
      onClose(null);
      ui.mainMenu.onClose(null);
    }


// key press
  public override function onKey(e: Dynamic)
    {
      // exit menu
      if (e.keyCode == 27) // ESC
        onClose(null);
    }


// hide main menu
  override function onCloseHook()
    {
      ui.mainMenu.show();
    }


  static var difElementInfo: Array<DifficultyUIInfo> = [
    {
      name: 'mapWidth',
      type: 'int',
      title: 'Map width',
      note: 'Map width in pixels'
    },
    {
      name: 'mapHeight',
      type: 'int',
      title: 'Map height',
      note: 'Map height in pixels'
    },
    {
      name: 'nodesCount',
      type: 'int',
      title: 'Amount of nodes',
      note: 'Amount of nodes on map'
    },
    {
      name: 'nodeActivationRadius',
      type: 'int',
      title: 'Activation radius',
      note: 'Node activation radius (node can be activated only when the player has an adjacent node in that radius)'
    },
    {
      name: 'numCults',
      type: 'int',
      title: 'Number of cults (2-8)',
      note: 'Number of cults in game'
    },
    {
      name: 'numPlayers',
      type: 'int',
      title: 'Number of human players (1-8)',
      note: 'Number of human players in game'
    },
    {
      name: 'numSummonVirgins',
      type: 'int',
      title: 'Number of virgins for the final ritual',
      note: 'Number of virgins needed to perform final ritual'
    },
    {
      name: 'upgradeChance',
      type: 'float',
      title: 'Max upgrade chance',
      note: 'Higher value raises max upgrade chance'
    },
    {
      name: 'awarenessResource',
      type: 'float',
      title: 'Resource chance awareness mod',
      note: 'Higher value lowers chance of getting resources each turn'
    },
    {
      name: 'awarenessUpgrade',
      type: 'float',
      title: 'Upgrade chance awareness mod',
      note: 'Higher value lowers chance of upgrading followers'
    },
    {
      name: 'awarenessGain',
      type: 'float',
      title: 'Gain follower chance awareness mod',
      note: 'Higher value lowers chance of gaining new followers'
    },
    {
      name: 'investigatorChance',
      type: 'float',
      title: 'Investigator: Appearing chance',
      note: 'Higher value raises chance of investigator appearing'
    },
    {
      name: 'investigatorKill',
      type: 'float',
      title: 'Investigator: Kill follower chance',
      note: 'Higher value raises chance of investigator killing a follower'
    },
    {
      name: 'investigatorWillpower',
      type: 'float',
      title: 'Investigator: Willpower lower chance',
      note: 'Higher value lowers chance of adepts lowering investigator willpower'
    },
    {
      name: 'investigatorTurnVisible',
      type: 'int',
      title: 'Investigator: Turn to become visible',
      note: 'Turn on which new investigator becomes visible'
    },
    {
      name: 'investigatorGainWill',
      type: 'float',
      title: 'Investigator: Chance of gaining will',
      note: 'Higher value raises chance of investigator gaining will'
    },
    {
      name: 'investigatorCultSize',
      type: 'float',
      title: 'Investigator: Cult size mod',
      note: 'Starting investigator willpower - cult size multiplier (less - easier)'
    },
    {
      name: 'maxAwareness',
      type: 'int',
      title: 'AI: Max awareness',
      note: 'Max awareness for AI to have without using adepts'
    },
    {
      name: 'isInfoKnown',
      type: 'bool',
      title: 'Cult info known at start?',
      note: 'Is cult info for all cults known at start?'
    },
    {
      name: 'isOriginKnown',
      type: 'bool',
      title: 'Origin info known at start?',
      note: 'Is origin known for all cults at start?'
    },
    {
      name: 'isDiscovered',
      type: 'bool',
      title: 'Cults discovered at start?',
      note: 'Are cults marked as discovered on start?'
    },
  ];
}
