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
    owner: String,
    music: String,
    musicVolume: String,
  }
#end

  public function new()
    {
#if electron
//      trace('reading settings.json');
      obj = {
        hasPlayed: null,
        owner: null,
        music: '1',
        musicVolume: '100',
      };
      try {
        var s = Fs.readFileSync('settings.json', 'utf8');
        obj = Json.parse(s);
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
