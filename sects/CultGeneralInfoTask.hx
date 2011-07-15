// general cult info

package sects;

class CultGeneralInfoTask extends Task
{
  public function new()
    {
      super();
      id = 'cultGeneralInfo';
      name = 'Cult information';
      type = 'cult';
      points = 30;
    }


// check if this task is available for this target
  public override function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      var c: Cult = target;
      if (cult == c || c.isInfoKnown[cult.id])
        return false;

      return true;
    }


// on task complete
  public override function complete(game: Game, ui: UI, cult: Cult, sect: Sect, points: Int)
    {
      var c:Cult = sect.taskTarget;
      c.isInfoKnown[cult.id] = true;
  
      log(cult, 'Task completed: Information about ' + c.fullName + ' gathered.');

      for (n in c.nodes)
        if (n.isVisible(c))
          n.update();
    }
}
