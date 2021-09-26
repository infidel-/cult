// manual window
#if electron
import js.node.Fs;
import js.Node.__dirname;
#end
import js.Browser;
import js.html.DivElement;
import js.html.InputElement;

class Manual extends Window
{
  var text: DivElement; // text element
  var search: InputElement; // search box

  public function new(uivar: UI, gvar: Game)
    {
      super(uivar, gvar, 'manual', 800, 536, 20);

      text = Browser.document.createDivElement();
      text.className = 'uiText';
      text.style.fontSize = '14px';
      window.appendChild(text);

      search = Tools.textfield({
        id: 'manualSearch',
        text: '',
        w: 200,
        h: 25,
        x: 320,
        y: 20,
        fontSize: 18,
        container: window,
      });
      search.style.visibility = 'hidden';
      search.placeholder = 'Type text to search';

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
              if (l.indexOf('_') >= 0 || l.indexOf('**') >= 0)
                parseDecoration(s, l.substring(3));
              else s.add(l.substring(3));
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

              s.add('<h' + firstIndex + ' id=h' + headerCnt +
              " style='font-weight:900'>");
              
              var lastIndex = l.length - 1;
              while (l.charAt(lastIndex) == '#')
                lastIndex--;
              var tmp = l.substring(firstIndex, lastIndex);
              if (firstIndex == 2 && headerCnt > 0)
                contents.add('<br>');
              if (firstIndex == 3)
                contents.add('&nbsp;&nbsp;&nbsp;');
              if (firstIndex == 4)
                contents.add('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
              contents.add('<a href="#h' + headerCnt + '">');
              contents.add(tmp);
              contents.add('</a><br>');
              s.add(tmp);
              s.add('</h' + firstIndex + '>');
              headerCnt++;
              continue;
            }

          s.add('<p>');
          if (l.indexOf('_') >= 0 || l.indexOf('**') >= 0)
            parseDecoration(s, l);

          else
            {
              s.add(l);
//              s.add('<br>');
            }
          s.add('</p>');
        }
      text.innerHTML = contents.toString() + s.toString();
      text.scrollTop = 0;
#end
    }

// parse line for font decoration tags
  function parseDecoration(s: StringBuf, l: String)
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
          else if (ch == '*' && i < l.length - 1 &&
              l.charAt(i + 1) == '*')
            {
              isBold = !isBold;
              if (isBold)
                s.add("<span style='font-weight:900'>");
              else s.add('</span>');
              i++;
            }
          else s.add(ch);

          i++;
        }
    }

  override function onKey(e: Dynamic)
    {
      var searchVisible = (search.style.visibility == 'visible');
      if (searchVisible)
        {
          // ctrl-f
          if (e.keyCode == 70 && e.ctrlKey)
            {
              Browser.window.getSelection().removeAllRanges();
              search.focus();
            }
          else if (e.keyCode == 27)
            search.style.visibility = 'hidden';
          else if (e.keyCode == 13)
            {
              var ret = Browser.window.find(search.value,
                false, false, true);
              if (ret)
                {
                  var el = Browser.window.getSelection().anchorNode.parentElement;
                  untyped el.scrollIntoView({ behavior: 'smooth'});
                }
            }
        }
      else
        {
          // ctrl-f
          if (e.keyCode == 70 && e.ctrlKey)
            {
              search.value = '';
              search.style.visibility = 'visible';
              search.focus();
            }
          // ESC
          else if (e.keyCode == 27)
            onClose(null);
        }
    }

// show log
  override function onShow()
    {
      text.scrollTop = 0;
    }
  override function onCloseHook()
    {
      search.style.visibility = 'hidden';
    }
}
