// cult visible nodes info

package sects;

class CultNodeInfoTask extends Task
{
  public function new(g: Game, ui: UI)
    {
      super(g, ui);
      id = 'cultNodeInfo';
      name = 'Cult nodes';
      type = 'info';
      isInfinite = true;
      points = 0;
    }


// check if this task is available for this target
  public override function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      return true;
    }


// on task complete
  public override function complete(cult: Cult, sect: Sect, points: Int)
    {
      // find any unknown nodes and mark them as known until points run out
      for (c in game.cults)
        {
          if (c == cult || !c.isDiscovered[cult.id] || c.isDead)
            continue;

          var cnt = 0;
          for (n in c.nodes)
            if (n.isVisible(cult) && !n.isKnown[cult.id])
              {
                cnt += 20; // points per node
                if (cnt >= points)
                  break;

                n.isKnown[cult.id] = true;
                n.update();
              }
          if (cnt >= points)
            break;
        }
    }
}
