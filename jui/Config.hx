// configuration
#if electron
import haxe.Json;
import js.node.Fs;
#end

class Config
{
#if electron
  var obj: {
    hasPlayed: String,
    logPanelSkipSects: String,
    mapAdvancedMode: String,
    sectAdvisor: String,
    music: String,
    musicVolume: String,
    animation: String,
    consoleLog: String,
  }
#end

  public function new()
    {
#if electron
//      trace('reading settings.json');
      obj = {
        hasPlayed: null,
        logPanelSkipSects: 'false',
        mapAdvancedMode: 'false',
        music: '1',
        musicVolume: '100',
        sectAdvisor: 'true',
        animation: 'true',
        consoleLog: 'false',
      };
      try {
        var s = Fs.readFileSync('settings.json', 'utf8');
        var obj2 = Json.parse(s);

        // copy existing fields into the object
        for (f in Reflect.fields(obj2))
          Reflect.setField(obj, f, Reflect.field(obj2, f));
      }
      catch (e: Dynamic)
        {}
#end
    }


// get a stored variable
  public inline function get(name: String): String
    {
#if electron
      var val = Reflect.field(obj, name);
//      trace('get ' + name + ' = ' + val);
      return val;
#else
      return untyped getCookie(name);
#end
    }


// get a int variable
  public function getInt(name: String): Int
    {
      var str = get(name);
      if (str == null)
        return 0;

      return Std.parseInt(str);
    }


// get a bool variable
  public function getBool(name: String): Bool
    {
      var str = get(name);
      if (str == null)
        return false;

      return (str == 'true');
    }


// get a stored variable
  public inline function set(name: String, val: String)
    {
#if electron
      if (Reflect.field(obj, name) == val)
        return;
//      trace('set ' + name + ' ' + val);
      Reflect.setField(obj, name, val);
      Fs.writeFileSync('settings.json',
        Json.stringify(obj, null, '  '), 'utf8');
#else
      return untyped setCookie(name, val,
        untyped __js__("new Date(2015, 0, 0, 0, 0, 0, 0)"));
#end
    }
}
