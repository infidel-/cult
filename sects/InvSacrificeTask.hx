// sacrifice sect

package sects;

class InvSacrificeTask extends Task
{
  public function new(g: Game, ui: UI)
    {
      super(g, ui);
      id = 'invSacrifice';
      name = 'Sacrifice to investigator';
      type = 'investigator';
      points = 100;
      level = 1;
    }

// get task name
  public override function getName(sect: Sect)
    {
      return name + ' (-' + will[sect.level] + ' WP)';
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
      if (!sect.cult.hasInvestigator ||
          sect.cult.investigator.isHidden)
        return true;

      return false;
    }


// on task complete
  public override function complete(cult: Cult, sect: Sect, points: Int)
    {
      if (!cult.hasInvestigator)
        return;
    
      cult.investigator.lowerWillpower(will[level]);
      cult.removeSect(sect.leader, 'sacrifice');
    }


  static var will = [ 0, 5, 10 ];
}
