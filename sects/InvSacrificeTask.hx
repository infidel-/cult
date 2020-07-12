// sacrifice sect

package sects;

class InvSacrificeTask extends Task
{
  public function new(g: Game, ui: UI)
    {
      super(g, ui);
      id = 'invSacrifice';
      name = 'Sacrifice to investigator';
      type = 'investigator';
      points = 100;
      level = 1;
    }

// get task name
  public override function getName(sect: Sect)
    {
      return name + ' (-' + will[sect.level] + ' WP)';
    }


// check if this task is available for this target
  public override function check(cult: Cult, sect: Sect, target: Dynamic): Bool
    {
      if (cult.investigator.isHidden)
        return false;

      return true;
    }


// check for task failure
  public override function checkFailure(sect: Sect): Bool
    {
      if (!sect.cult.hasInvestigator ||
          sect.cult.investigator.isHidden)
        return true;

      return false;
    }


// on task complete
  public override function complete(cult: Cult, sect: Sect, points: Int)
    {
      if (!cult.hasInvestigator)
        return;
    
      var name = cult.investigator.name;
      cult.investigator.lowerWillpower(will[level]);
      cult.removeSect(sect.leader, 'sacrifice');
      if (!cult.hasInvestigator && !cult.fluffShown['sectSacrificed'])
        {
          var num = [ 'two', 'three', 'four', 'five' ];
          ui.alert('<h2>SECT SACRIFICED</h2><div class=fluff>' +
          Static.template('sectSacrificed', {
            inv: name,
            number: num[Std.random(num.length)],
            sect: sect.name,
          }) + '</div><br>' + sect.name + ' was sacrificed to dispose of the investigator.', { h: 340 });

          cult.fluffShown['sectSacrificed'] = true;
        }
    }


  static var will = [ 0, 5, 10 ];
}
