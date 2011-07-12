// cult resources info

package sects;

class CultResourceInfoTask extends Task
{
  public function new()
    {
      super();
      id = 'cultResourceInfo';
      name = 'Cult resources';
      type = 'cult';
      points = 50;
    }


// check if this task is available for this target
  public override function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      var c: Cult = target;
      if (cult == c)
        return false;

      return true;
    }


// on task complete
  public override function complete(game: Game, ui: UI, cult: Cult, sect: Sect, points: Int)
    {
      var c:Cult = sect.taskTarget;

      cult.log(
        'Task completed: ' + c.fullName + ' has ' +
        c.power[0] + ' (+' + c.powerMod[0] + ') ' + UI.powerName(0) + ', ' +
        c.power[1] + ' (+' + c.powerMod[1] + ') ' + UI.powerName(1) + ', ' +
        c.power[3] + ' (+' + c.powerMod[2] + ') ' + UI.powerName(2) + ', ' +
        c.power[3] + ' (+' + c.powerMod[3] + ') ' + UI.powerName(3) + '.');
    }
}
