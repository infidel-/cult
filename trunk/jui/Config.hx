// configuration

class Config
{
  public function new()
    {}


// get a stored variable (cookie)
  public inline function get(name: String)
    {
      return untyped getCookie(name);
    }


// get a stored variable (cookie)
  public inline function set(name: String, val: String)
    {
      return untyped setCookie(name, val,
        untyped __js__("new Date(2015, 0, 0, 0, 0, 0, 0)"));
    }
}
