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
      points = 30;
    }


// check if this task is available for this target
  public override function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      var c: Cult = target;
      if (cult == c || c.isInfoKnown)
        return false;

      return true;
    }


// on task complete
  public override function complete(game: Game, ui: UI, cult: Cult, sect: Sect, points: Int)
    {
      var c:Cult = sect.taskTarget;

      if (!cult.isAI)
        ui.log2('cult', cult,
          'Task completed: ' + c.fullName + ' has ' +
          c.power[0] + ' ' + UI.powerName(0) + ', ' +
          c.power[1] + ' ' + UI.powerName(1) + ', ' +
          c.power[2] + ' ' + UI.powerName(2) + ', ' +
          c.power[3] + ' ' + UI.powerName(3) + '.');
    }
}
