// confuse investigator

package sects;

class InvConfuseTask extends Task
{
  public function new(g: Game, ui: UI)
    {
      super(g, ui);
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


// check for task failure
  public override function checkFailure(sect: Sect): Bool
    {
      if (!sect.cult.hasInvestigator || sect.cult.investigator.isHidden)
        return true;

      return false;
    }


// on task complete
  public override function complete(cult: Cult, sect: Sect, points: Int)
    {
      if (cult.investigator == null)
        return;
    
      // all modifiers are in Investigator.hx
    }
}
