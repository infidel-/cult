// main expansion manager class
package artifacts;

class ArtifactManager
{
  var game: Game;
  var ui: UI;

  public function new(g: Game, uivar: UI)
    {
      game = g;
      ui = uivar;
    }


// spawn a new one on map
  public function spawn()
    {
      // TODO: check for max arts

      // find free position
      var pos = game.findFreeSpot(UI.vars.markerWidth);
      if (pos == null)
        return;

      // node attributes
      var node = new ArtifactNode(game, ui, pos.x, pos.y,
        game.lastNodeIndex++);

      for (c in game.cults)
        if (!c.isAI)
          node.setVisible(c, true);

      node.level = Std.random(3);
      node.updateLinks();
      node.update();
      game.nodes.push(node);
      game.player.highlightNode(node);
    }

// cult activates artifact on map
  public function activate(cult: Cult, node: Node): String
    {
      // remove from map
      game.removeNode(node);

      var artifact: CultArtifact = {
        name: 'Test Cult Artifact',
        level: 1 + node.level,
      };
      cult.artifacts.add(artifact);
      ui.log2(cult, cult.fullName + ' is now in possession of ' + artifact.name + '.', { symbol: 'A' });
      
      return 'ok';
    }

// turn passing
  public function turn()
    {
    }
}
