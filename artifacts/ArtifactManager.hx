// main expansion manager class
package artifacts;

import Static;

class ArtifactManager
{
  var game: Game;
  var ui: UI;
  public var deleted: Array<String>;

  public function new(g: Game, uivar: UI)
    {
      game = g;
      ui = uivar;
      deleted = [];

      // apply artifact note templates
      for (key in StaticArtifacts.uniqueArtifacts.keys())
        {
          var info = StaticArtifacts.uniqueArtifacts[key];
          if (info.note.indexOf('%v') >= 0)
            info.note = StringTools.replace(info.note, '%v', '' + info.val);
        }
    }

// on game restart
  public function onRestart()
    {
      deleted = [];
    }

// get total number of artifacts ingame
  public function getTotalArtifacts(): Int
    {
      // NOTE: in multiplayer we do not calculate the artifacts number with all player cults
      var cnt = game.player.artifacts.length;
      for (n in game.nodes)
        if (n.type == 'artifact')
          cnt++;
      return cnt;
    }

// spawn a new one on map
// NOTE: check for max number is in sect task
  public function spawn()
    {
      // everything is based on node level
      var level = Std.random(3);

      // find most distant quadrant from player origin
      var dist = 0.0;
      var quad: Quadrant = null;
      for (q in game.mapQuadrants8x8)
        {
          var d = Static.distance(
            game.player.origin.x,
            game.player.origin.y,
            Std.int(q.x1 + (q.x2 - q.x1) / 2.0),
            Std.int(q.y1 + (q.y2 - q.y1) / 2.0));
          if (d <= dist)
            continue;

          dist = d;
          quad = q;
        }

      // find all quadrants that have distance in the needed third
//      trace('level:' + level);
//      trace('dist:' + dist);
      var mindist = level * dist / 3;
      var maxdist = (level + 1) * dist / 3;
      var quads = [];
//      trace('mindist:' + mindist);
//      trace('maxdist:' + maxdist);
      for (q in game.mapQuadrants8x8)
        {
          var d = Static.distance(
            game.player.origin.x,
            game.player.origin.y,
            Std.int(q.x1 + (q.x2 - q.x1) / 2.0),
            Std.int(q.y1 + (q.y2 - q.y1) / 2.0));
          if (d < mindist || d > maxdist)
            continue;

          quads.push(q);
        }
      if (quads.length == 0)
        {
          trace('BUG: no quads');
          return;
        }

      // find free position in random quad
      var pos = game.findFreeSpotQuad(quads[Std.random(quads.length)],
        UI.vars.markerWidth);
//      var pos = game.findFreeSpot(UI.vars.markerWidth);
      if (pos == null)
        {
          trace('BUG: no free spot');
          return;
        }

      // node attributes
      var node = new ArtifactNode(game, ui, pos.x, pos.y,
        game.lastNodeIndex++);
      node.level = level;
      // level equals the amount of resource types needed
      node.power = [ 0, 0, 0, 0 ];
      for (i in 0...(level + 1))
        {
          var id = 0;
          while (true)
            {
              id = Std.random(node.power.length);
              if (node.power[id] > 5)
                continue;
              break;
            }
          node.power[id] += 3 + Std.random(4);
          if (node.power[id] > 10)
            node.power[id] = 10;
        }

      // chance of making it unique
      if (level == 2)
        makeUnique(node);

      // TEST
/*
      node.isUnique = true;
      node.artifactID = 'mask';
      node.artifactInfo = StaticArtifacts.uniqueArtifacts[node.artifactID];
      node.name = node.artifactInfo.name;
*/

      // calculate timer
      var dist = game.player.origin.distance(node);
      node.turns = game.difficulty.artifactBaseSpawnTime +
        Std.int(dist / game.difficulty.nodeActivationRadius);
/*
      trace(node.turns + ' = ' +
        game.difficulty.artifactBaseSpawnTime + ' + ' +
        Std.int(dist / game.difficulty.nodeActivationRadius) +
        ' (dist:' + dist + ' / rad:' +
        game.difficulty.nodeActivationRadius + ')');
*/
      if (node.turns > 9)
        node.turns = 9;

      // make it visible for all human players
      for (c in game.cults)
        if (!c.isAI)
          node.setVisible(c, true);

      node.updateLinks();
      node.update();
      game.nodes.push(node);
      game.player.highlightNode(node);
    }

// try to make artifact node unique
  function makeUnique(node: ArtifactNode)
    {
// NOTE: all level 3 arts are unique for now if it's possible
//      if (Std.random(100) > 10)
//        return;

      // check if player has max number of unique artifacts
      var count = 0;
      for (a in game.player.artifacts)
        if (a.isUnique)
          count++;
      if (count >= game.difficulty.artifactMaxUnique)
        return;

      // pick available
      var tmp = [];
      for (id in StaticArtifacts.uniqueArtifacts.keys())
        if (!Lambda.has(deleted, id))
          {
            // check if any cult has it
            var ok = true;
            for (c in game.cults)
              if (!c.isAI && c.artifacts.getUnique(id) != null)
                {
                  ok = false;
                  break;
                }
            if (!ok)
              continue;

            tmp.push(id);
          }

      // check if any are on the map already
      for (n in game.nodes)
        if (n.type == 'artifact')
          {
            var art: ArtifactNode = cast n;
            if (art.isUnique)
              tmp.remove(art.artifactID);
          }
      if (tmp.length == 0)
        return;

      // make unique
      node.isUnique = true;
      node.artifactID = tmp[Std.random(tmp.length)];
      node.artifactInfo = StaticArtifacts.uniqueArtifacts[node.artifactID];
      node.name = node.artifactInfo.name;
    }

// cult activates artifact on map
  public function activate(cult: Cult, node: ArtifactNode): String
    {
      // remove from map
      game.removeNode(node);

      var artifact: CultArtifact = {
        name: node.name,
        level: 1 + node.level,
        isUnique: node.isUnique,
        id: node.artifactID,
        info: StaticArtifacts.uniqueArtifacts[node.artifactID],
      };
      cult.artifacts.add(artifact);
      ui.log2(cult, cult.fullName + ' is now in possession of ' +
        artifact.name + '.', { symbol: 'A' });
      ui.updateStatus();
      
      return 'ok';
    }

// turn passing
  public function turn()
    {
    }
}
