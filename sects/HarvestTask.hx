// harvest sect for resources

package sects;

class HarvestTask extends Task
{
  public function new(g: Game, ui: UI)
    {
      super(g, ui);
      id = 'harvest';
      name = 'Harvest for resources';
      type = 'none';
      points = 100;
      level = 1;
    }


// get task name
  public override function getName(sect: Sect)
    {
      return name + ' (+' + res[sect.level] + ')';
    }


// check if this task is available for this target
  public override function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      return true;
    }


// on task complete
  public override function complete(cult: Cult, sect: Sect, points: Int)
    {
      cult.removeSect(sect.leader, null);
      var text = sect.name + ' was harvested for ';
      var val = res[sect.level];
      var id = Std.random(3);
      if (Std.random(100) < 25)
        id = 3;
      text += val + ' ' + UI.powerName(id) + '.';
      cult.power[id] += val;
      log(cult, text);
      ui.alert(text, { h: 110 });
    }


  static var res = [ 0, 10, 25 ];
}
