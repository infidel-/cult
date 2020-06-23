// search for investigator

package sects;

class InvSearchTask extends Task
{
  public function new(g: Game, ui: UI)
    {
      super(g, ui);
      id = 'invSearch';
      name = 'Search for investigator';
      type = 'investigator';
      points = 50;
    }


// check if this task is available for this target
  public override function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      if (!cult.investigator.isHidden)
        return false;

      return true;
    }


// check for task failure
  public override function checkFailure(sect: Sect): Bool
    {
      if (!sect.cult.hasInvestigator || !sect.cult.investigator.isHidden)
        return true;

      return false;
    }


// on task complete
  public override function complete(cult: Cult, sect: Sect, points: Int)
    {
      if (!cult.hasInvestigator || !cult.investigator.isHidden)
        return;

      cult.investigator.isHidden = false;
      log(cult, 'Task completed: Investigator found.');

      game.tutorial.play('investigatorFound');

      if (game.flags.artifacts)
        cult.artifacts.investigatorFound(sect);
    }
}
