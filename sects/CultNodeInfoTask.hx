// cult visible nodes info

package sects;

class CultNodeInfoTask extends Task
{
  public function new(g: Game, ui: UI)
    {
      super(g, ui);
      id = 'cultNodeInfo';
      name = 'Cult nodes';
      type = 'cult';
      isInfinite = true;
      points = 0;
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
  public override function complete(cult: Cult, sect: Sect, points: Int)
    {
      var c:Cult = sect.taskTarget;

      var cnt = 0;
      for (n in c.nodes)
        if (n.isVisible(cult) && !n.isKnown[cult.id])
          {
            cnt += 10; // 10 points per node
            if (cnt >= points)
              break;

            n.isKnown[cult.id] = true;
            n.update();
          }
    }
}
