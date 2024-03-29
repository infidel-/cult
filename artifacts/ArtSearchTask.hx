// artifacts: search

package artifacts;

import sects.*;

class ArtSearchTask extends Task
{
  var bonusChance: Int;

  public function new(g: Game, ui: UI)
    {
      super(g, ui);
      id = 'artSearch';
      name = 'Search for artifacts';
      type = 'artifact';
      isInfinite = true;
      points = 0;
      level = 1;
      bonusChance = 0;
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

// chance of finding artifact
  public override function getDebugName(sect: Sect): String
    {
      return ' (' + Std.int(getChance(sect)) + '%)';
    }

  public function getChance(sect: Sect): Float
    {
      return bonusChance + 5.0 + sect.getSizePoints() / 50.0;
    }


// on task complete
  public override function complete(cult: Cult, sect: Sect, points: Int)
    {
      // roll for chance to spawn
      var chance = getChance(sect);
      if (Std.random(100) > chance)
        {
          bonusChance += 2; // grows each turn
          return;
        }
      bonusChance = 0; // resets on each success

      // max number reached, spawn not available
      if (game.artifacts.getTotalArtifacts() >=
          game.difficulty.artifactMaxAmountIngame)
        return;

      var m = sect.name + ' has uncovered the location of an occult artifact.';
      cult.log(m);
      cult.logPanelShort(m, {
        symbol: 'A',
        color: UI.getVar('--artifact-color'),
      });
      // spawn artifact
      var node = game.artifacts.spawn();
      if (node == null)
        return;
      if (!cult.fluffShown['artifactFound'])
        {
          ui.alert('<h2>ARTIFACT FOUND</h2><div class=fluff>' +
          Static.template('artifactFound', {
            name: node.name,
          }) + '</div><br>' + m, {
            h: 340,
            sound: 'artifact-find',
          });
          cult.fluffShown['artifactFound'] = true;
        }
      else ui.alert(sect.name + ' has uncovered the location of ' +
        node.name + '.', {
          h: UI.getVarInt('--alert-window-height-2lines'),
          sound: 'artifact-find',
        });
    }
}
