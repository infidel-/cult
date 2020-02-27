// do nothing task - dummy

package sects;

class DoNothingTask extends Task
{
  public function new(g: Game, ui: UI)
    {
      super(g, ui);
      id = 'doNothing';
      name = 'Do Nothing';
      type = '';
      isInfinite = true;
      points = 0;
    }


// check if this task is available for this target
  public override function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      return true;
    }


// on task complete
  public override function complete(cult: Cult, sect: Sect, points: Int)
    {
    }
}
