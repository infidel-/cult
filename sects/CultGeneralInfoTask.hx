// general cult info

package sects;

class CultGeneralInfoTask extends Task
{
  public function new(g: Game, ui: UI)
    {
      super(g, ui);
      id = 'cultGeneralInfo';
      name = 'Cult information';
      type = 'info';
      points = 30;
    }


// check if this task is available for this target
  public override function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      // check for unknown cults
      for (c in game.cults)
        {
          if (c == cult ||
              !c.isDiscovered[cult.id] ||
              c.isInfoKnown[cult.id])
            continue;

          return true;
        }

      return false;
    }


// on task complete
  public override function complete(cult: Cult, sect: Sect, points: Int)
    {
      // pick first unknown cult
      for (c in game.cults)
        {
          if (c == cult ||
              !c.isDiscovered[cult.id] ||
              c.isInfoKnown[cult.id])
            continue;

          c.isInfoKnown[cult.id] = true;

          log(cult, 'Task completed: Information about ' + c.fullName + ' gathered.');

/*
      for (n in c.nodes)
        if (n.isVisible(c))
          n.update();
*/
          break;
        }
    }
}
