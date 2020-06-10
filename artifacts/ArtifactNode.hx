// artifact node
package artifacts;

class ArtifactNode extends Node
{
  public function new(gvar, uivar, newx, newy, index: Int)
    {
      super(gvar, uivar, newx, newy, index);
      type = 'artifact';
      name = 'TEMP ARTIFACT';
    }
}
