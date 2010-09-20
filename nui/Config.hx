// config class

import neko.io.File;

class Config
{
  var ui: UI;
  var game: Game;
  var fileName: String;

  var list: Hash<String>;

  public function new(uivar: UI, gamevar: Game, fname: String)
    {
      ui = uivar;
      game = gamevar;
      fileName = fname;
      list = new Hash<String>();

      load();
    }


// get value
  public function get(key: String): String
    {
      return list.get(key);
    }


// get int value
  public function getInt(key: String): Int
    {
      return Std.parseInt(list.get(key));
    }


// set value
  public function set(key: String, val: String)
    {
      list.set(key, val);
      save();
    }


// load config
  public function load()
    {
      var str: String = null;
      try {
        str = File.getContent(fileName);
        }
      catch (e: Dynamic)
        { return; }
      if (str.length == 0)
        return;
      var arr = str.split("\n");
      for (s in arr)
        {
          s = StringTools.trim(s);
          if (s.charAt(0) == '#' || s.length == 0) continue;

          var key = StringTools.trim(s.substr(0, s.indexOf('=')));
          var val = StringTools.trim(s.substr(s.indexOf('=') + 1));
//          trace("[" + key + "] [" + val + "]");
          list.set(key, val);
        }

      // post-load stuff
      if (getInt('debug') == 1)
        Game.isDebug = true;
    }


// save config
  public function save()
    {
      var f = File.write(fileName, true);
      for (key in list.keys())
        f.writeString(key + " = " + list.get(key) + "\n");
      f.close();
    }
}
