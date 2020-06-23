// cult artifact
package artifacts;

import artifacts.StaticArtifacts;

typedef CultArtifact = {
  var name: String;
  var id: String;
  var level: Int;
  var isUnique: Bool;
  @:optional var node: Node;
  var info: UniqueArtifact;
}
