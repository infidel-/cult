// sect task superclass

package sects;

class Task
{
  public var id: String; // task string id
  public var type: String; // task target type (for ui)
  public var name: String; // task name
  public var level: Int; // min sect level needed
  public var points: Int; // amount of points needed to complete (0: complete on next turn)
  public var isInfinite: Bool; // is task neverending? (if true, finish() will be called each turn)

  public function new()
    {
      id = '_empty';
      type = '';
      name = '';
      level = 0;
      points = 0;
      isInfinite = false;
    }


// can this task be activated by this sect?
  public function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      trace('default check(), should not be called!');
      return true;
    }


// check if this task became uncompletable
  public function checkFailure(sect: Sect): Bool
    {
      return false;
    }


// on task complete
  public function complete(game: Game, ui: UI, cult: Cult, sect: Sect, points: Int)
    {
      trace('default complete(), should not be called!');
    }


// log message into cult log
  inline function log(cult: Cult, m: String)
    {
      cult.log(m);
      cult.logPanelShort(m);
    }
}
