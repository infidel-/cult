// multiplayer menu class

import js.html.DivElement;
import js.html.Element;

typedef MPUIInfo =
{
  var name: String; // element name (and parameter name too)
  var title: String; // parameter title
  var type: String; // parameter type
  var params: Dynamic; // additional parameters
};

class MultiplayerMenu
{
  var ui: UI;
  var game: Game;

  var window: DivElement; // window element
  var bg: DivElement; // background element
  var close: DivElement; // close button element
  public var isVisible: Bool;
  var difElements: List<Element>; // ui elements

  static var difElementInfo: Array<MPUIInfo> =
    [
      {
        name: 'numCults',
        type: 'int',
        title: 'Number of cults (2-8)',
        params: null
      },
      {
        name: 'numPlayers',
        type: 'int',
        title: 'Number of human players (1-8)',
        params: null
      },
      {
        name: 'difficulty',
        type: 'select',
        title: 'Game difficulty',
        params: [ 'Easy', 'Normal', 'Hard' ]
      },
      {
        name: 'mapSize',
        type: 'select',
        title: 'Map size',
        params: [ 'Small', 'Medium', 'Large', 'Huge' ]
      },
    ];


  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      isVisible = false;

      // main menu window
      window = Tools.window(
        {
          id: "mpMenuWindow",
          center: true,
          winW: UI.winWidth,
          winH: UI.winHeight,
          w: 450,
          h: 220,
          z: 20
        });

      Tools.label({
        id: 'titleLabel',
        text: 'Multiplayer game parameters',
        w: 350,
        h: 30,
        x: 50,
        y: 10,
        container: window
        });

      var divel = js.Browser.document.createElement("div");
      divel.style.background = '#030303';
      divel.style.left = '10';
      divel.style.top = '40';
      divel.style.width = '430';
      divel.style.height = '130';
      divel.style.position = 'absolute';
      divel.style.overflow = 'none';
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
              w: 100,
              h: 20,
              x: 320,
              y: y,
              fontSize: 14,
              container: divel
              });
          else if (info.type == 'select')
            {
              el = js.Browser.document.createElement("select");
              el.id = info.name;
              el.style.width = '100';
              el.style.height = '20';
              el.style.left = '320';
              el.style.top = '' + y;
              el.style.fontSize = '14px';
              el.style.position = 'absolute';
              el.style.color = '#ffffff';
              el.style.background = '#111';
              var s = "<select class=secttasks onchange='Game.instance.ui.mpMenu.onSelect(this.value)'>";
              var list: Array<String> = info.params;
              for (item in list)
                s += '<option class=secttasks>' + item;
              s += '</select>';
              el.innerHTML = s;
              divel.appendChild(el);
            }
          else el = Tools.textfield({
            id: info.name,
            text: '' + Reflect.field(Static.difficulty[2], info.name),
            w: 100,
            h: 20,
            x: 320,
            y: y,
            fontSize: 14,
            container: divel
            });

          y += 30;

          difElements.add(el);
        }

      Tools.button({
        id: 'startMultiplayerGame',
        text: "Start",
        w: 80,
        h: 25,
        x: 100,
        y: 180,
        container: window,
        func: onStartGame
        });

      bg = Tools.bg({ w: UI.winWidth + 20, h: UI.winHeight});
      close = Tools.closeButton(window, 320, 180, 'mpMenuClose');
      close.onclick = onClose;
    }


// get value for parameter
  public function getInfoValue(info: MPUIInfo): Dynamic
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
      else if (info.type == 'select')
        {
          var list: Array<String> = info.params;
          var id = -1;
          for (i in 0...list.length)
            if (list[i] == untyped el.value)
              {
                value = i;
                break;
              }
        }
      else if (info.type == 'bool')
        value = untyped el.checked;

      return value;
    }


  public function onStartGame(e: Dynamic)
    {
      var dif: Dynamic = { level: -1 };

      // get difficulty level
      var level = getInfoValue(difElementInfo[2]);

      // copy over stuff from this difficulty level
      for (f in Reflect.fields(Static.difficulty[level]))
        Reflect.setField(dif, f,
          Reflect.field(Static.difficulty[level], f));

      // set stuff changed by player
      for (info in difElementInfo)
        {
          var value = getInfoValue(info);
          if (info.name == 'numCults')
            dif.numCults = value;
          else if (info.name == 'numPlayers')
            dif.numPlayers = value;
          else if (info.name == 'mapSize')
            {
              // small
              if (value == 0)
                {
                  dif.mapWidth = 780;
                  dif.mapHeight = 580;
                  dif.nodesCount = 100;
                }

              // medium
              else if (value == 1)
                {
                  dif.mapWidth = 1170;
                  dif.mapHeight = 870;
                  dif.nodesCount = 225;
                }

              // large
              else if (value == 2)
                {
                  dif.mapWidth = 1560;
                  dif.mapHeight = 1160;
                  dif.nodesCount = 400;
                }

              // huge
              else if (value == 3)
                {
                  dif.mapWidth = 3120;
                  dif.mapHeight = 2320;
                  dif.nodesCount = 1600;
                }
            }
        }

//      trace(dif);
      if (dif.numPlayers < 2)
        dif.numPlayers = 2;
      if (dif.numCults < 2)
        dif.numCults = 2;
      if (dif.numPlayers > 8)
        dif.numPlayers = 8;
      if (dif.numCults > 8)
        dif.numCults = 8;

      game.restart(-1, dif);

      realClose();
    }


// show main menu
  public function show()
    {
      window.style.display = 'inline';
      bg.style.display = 'inline';
      close.style.display = 'inline';
      isVisible = true;
    }


// key press
  public function onKey(e: Dynamic)
    {
      // exit menu
      if (e.keyCode == 27) // ESC
        onClose(null);
    }


  function realClose()
    {
      window.style.display = 'none';
      bg.style.display = 'none';
      close.style.display = 'none';
      isVisible = false;
    }


// hide main menu
  function onClose(event: Dynamic)
    {
      realClose();

      ui.mainMenu.show();
    }
}
