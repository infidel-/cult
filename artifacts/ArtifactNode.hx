// artifact node
package artifacts;

class ArtifactNode extends Node
{
  public var turns: Int;

  public function new(gvar, uivar, newx, newy, index: Int)
    {
      super(gvar, uivar, newx, newy, index);
      type = 'artifact';
      name = 'TEMP ARTIFACT';
      uiNode = new ArtifactUINode(game, ui, this);
    }

  public override function turn()
    {
      // node timer
      turns--;
      if (turns > 0)
        return;

      // remove from map
      game.removeNode(this);

      ui.logGlobal('The location of ' + name + ' has been obscured again.', { symbol: 'A' });
    }
}
