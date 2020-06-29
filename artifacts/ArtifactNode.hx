// artifact node
package artifacts;

class ArtifactNode extends Node
{
  public var turns: Int;
  public var artifactType: String;
  public var artifactTypeID: Int;
  public var isUnique: Bool;
  public var artifactID: String;

  public function new(gvar, uivar, newx, newy, index: Int)
    {
      super(gvar, uivar, newx, newy, index);
      type = 'artifact';
      artifactTypeID = Std.random(StaticArtifacts.types.length);
      artifactType = StaticArtifacts.types[artifactTypeID];
      name = StaticArtifacts.getRandomName(artifactTypeID);
      isUnique = false;
      artifactID = '';
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
