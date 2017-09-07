// player options

class Options
{
  var cult: Cult;
  var list: Map<String, Dynamic>; // player options

  public function new(c: Cult)
    {
      cult = c;
      list = new Map();
    }


// set value
  public function set(key: String, val: Dynamic)
    {
//      trace(cult.id + ' set ' + key + ' ' + val );
      if (val == false)
        list.remove(key);
      else list.set(key, val);
    }


// get value
  public function get(key: String): Dynamic
    {
      return list.get(key);
    }


// get bool value
  public function getBool(key: String): Bool
    {
      var ret = list.get(key);
      if (ret == null)
        return false;
      return ret;
    }
}
