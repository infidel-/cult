// confuse investigator

package sects;

class InvConfuseTask extends Task
{
  public function new()
    {
      super();
      id = 'invConfuse';
      name = 'Confuse investigator';
      type = 'investigator';
      isInfinite = true;
      points = 0;
    }


// check if this task is available for this target
  public override function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      if (cult.investigator.isHidden)
        return false;

      return true;
    }


// on task complete
  public override function complete(game: Game, ui: UI, cult: Cult, sect: Sect, points: Int)
    {
      if (cult.investigator == null)
        return;
  
      trace('Confuse investigator: TODO!');
    }
}
