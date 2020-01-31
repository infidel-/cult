// manual window
#if electron
import js.node.Fs;
import js.Node.__dirname;
#end
import js.html.DivElement;

class Manual
{
  var ui: UI;
  var game: Game;

  var window: DivElement; // window element
  var text: DivElement; // text element
  var bg: DivElement; // background element
  public var isVisible: Bool;

  public function new(uivar: UI, gvar: Game)
    {
      ui = uivar;
      game = gvar;
      isVisible = false;

      // window
      window = Tools.window({
        id: "windowManual",
        winW: UI.winWidth,
        winH: UI.winHeight,
        fontSize: 14,
        w: 800,
        h: 500,
        z: 20
      });
      window.style.display = 'none';
      window.style.background = '#333333';
      window.style.border = '4px double #ffffff';

      text = js.Browser.document.createDivElement();
      text.style.overflow = 'auto';
      text.style.position = 'absolute';
      text.style.left = '10px';
      text.style.top = '10px';
      text.style.width = '770px';
      text.style.height = '440px';
      text.style.padding = '5px';
      text.style.background = '#0b0b0b';
      text.style.border = '1px solid #777';
      window.appendChild(text);

      bg = Tools.bg({ w: UI.winWidth + 20, h: UI.winHeight});
      var close = Tools.closeButton(window, 360, 465, 'logClose');
      close.onclick = onClose;

      // load manual text
#if electron
      var file = Fs.readFileSync(__dirname + '/manual.md', 'utf8');
      var lines = file.split('\n');
      var s = new StringBuf();
      var isList = false;
      var contents = new StringBuf();
      contents.add('<h2>Table of contents</h2>');
      var headerCnt = 0;
      for (l in lines)
        {
          if (l.length == 0)
            continue;

          // list item
          if (l.length >= 3 && l.charAt(0) == ' ' && l.charAt(1) == ' ' &&
              l.charAt(2) == '*')
            {
              if (!isList)
                s.add('<ul>');
              isList = true;
              s.add('<li>');
              s.add(l.substring(3));
              continue;
            }
          else if (isList)
            {
              isList = false;
              s.add('</ul>');
            }

          // header
          if (l.charAt(0) == '#')
            {
              var firstIndex = 1;
              while (l.charAt(firstIndex) == '#')
                firstIndex++;

              s.add('<h' + firstIndex + ' id=h' + headerCnt + '>');
              
              var lastIndex = l.length - 1;
              while (l.charAt(lastIndex) == '#')
                lastIndex--;
              var tmp = l.substring(firstIndex, lastIndex);
              if (firstIndex == 2 && headerCnt > 0)
                contents.add('<br>');
              if (firstIndex == 3)
                contents.add('&nbsp;&nbsp;&nbsp;');
              contents.add('<a href="#h' + headerCnt + '">');
              contents.add(tmp);
              contents.add('</a><br>');
              s.add(tmp);
              s.add('</h' + firstIndex + '>');
              headerCnt++;
              continue;
            }

          if (l.indexOf('_') >= 0 || l.indexOf('**') >= 0)
            {
              var i = 0;
              var isBold = false;
              var isItalic = false;
              var isList = false;
              while (i < l.length)
                {
                  var ch = l.charAt(i);
                  // italic
                  if (ch == '_')
                    {
                      isItalic = !isItalic;
                      if (isItalic)
                        s.add('<i>');
                      else s.add('</i>');
                    }

                  // bold
                  else if (ch == '*' && i < l.length - 1 && l.charAt(i + 1) == '*')
                    {
                      isBold = !isBold;
                      if (isBold)
                        s.add('<b>');
                      else s.add('</b>');
                      i++;
                    }
                  else s.add(ch);

                  i++;
                }
            }

          else
            {
              s.add(l);
              s.add('<br>');
            }
        }
      text.innerHTML = contents.toString() + s.toString();
      text.scrollTop = 0;
#end
    }


// hide window
  public function onClose(event)
    {
      window.style.display = 'none';
      bg.style.display = 'none';
      isVisible = false;
    }


// show log
  public function show()
    {
      text.scrollTop = 0;
      window.style.display = 'inline';
      bg.style.display = 'inline';
      isVisible = true;
    }
}
