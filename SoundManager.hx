// js sound library

extern class SoundManager implements Dynamic
{
  static function stop(id: String): Void;
  static function play(id: String, ?options: SoundPlayOptions): Dynamic;
  static function togglePause(id: Dynamic): Void;
  static function createSound(p1: Dynamic): Dynamic;
  static function destroySound(id: String): Void;
  static function stopAll(): Void;
  @:overload(function(id: String, vol: Int): Dynamic {})
  static function setVolume(vol: Int): Void;
}

typedef SoundPlayOptions = {
  @:optional var volume: Int;
  @:optional var onfinish: Void -> Void;
}

