// sabotage cult ritual

package sects;

class CultSabotageRitualTask extends Task
{
  public function new(g: Game, ui: UI)
    {
      super(g, ui);
      id = 'cultSabotageRitual';
      name = 'Sabotage ritual';
      type = 'cult';
      isInfinite = true;
      points = 0;
      level = 1;
    }


// check if this task is available for this target
  public override function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      var c: Cult = target;
      if (cult == c || !c.isRitual)
        return false;

      return true;
    }


// check for task failure
  public override function checkFailure(sect: Sect): Bool
    {
      var c: Cult = sect.taskTarget;
      if (!c.isRitual)
        return true;

      return false;
    }


// on task complete
  public override function complete(cult: Cult, sect: Sect, points: Int)
    {
      var c:Cult = sect.taskTarget;
      if (!c.isRitual || c.ritualPoints >= c.ritual.points)
        return;

      var cnt = 0;
      var pts = 0;
      while (true)
        {
          cnt += 100; // 100 points per try
          if (cnt >= points)
            break;

          if (Math.random() * 100 > 75) // chance of success
            continue;

          c.ritualPoints += 1;
          pts += 1;

          if (c.ritualPoints >= c.ritual.points)
            break;
        }

      if (pts > 0)
        log(cult, 'Ritual of ' + c.fullName + ' stalled for ' + pts + ' points.');
    }
}
