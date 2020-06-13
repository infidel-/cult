// artifacts: search

package artifacts;

import sects.*;

class ArtSearchTask extends Task
{
  public function new(g: Game, ui: UI)
    {
      super(g, ui);
      id = 'artSearch';
      name = 'Search for artifacts';
      type = 'artifact';
      isInfinite = true;
      points = 0;
      level = 1;
    }


// check if this task is available for this target
  public override function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      return true;
    }


// check for task failure
  public override function checkFailure(sect: Sect): Bool
    {
      return false;
    }


// on task complete
  public override function complete(cult: Cult, sect: Sect, points: Int)
    {
      // roll for chance to spawn
      var chance = 5.0 + sect.size / 50.0;
      if (Std.random(100) > chance)
        return;

      var m = sect.name + ' has uncovered the location of an occult artifact.';
      cult.log(m);
      cult.logPanelShort(m, { symbol: 'A' });

      // spawn artifact
      game.artifacts.spawn();
    }
}
