// cult artifacts storage
package artifacts;

class CultArtifacts
{
  var game: Game;
  var cult: Cult;
  var storage: Array<CultArtifact>;
  public var length(get, null): Int;

  public function new(g: Game, c: Cult)
    {
      game = g;
      cult = c;
      storage = [];
    }

// upgrade a node
  public function onUpgrade(node: Node)
    {
      // pick an artifact - highest level first
      var art: CultArtifact = null;
      for (a in storage)
        if (art == null || (art != null && a.level > art.level))
          art = a;
      art.node = node;
      node.artifact = art;
      cult.logAndPanel(node.name + ' becomes a priest binding with ' + art.name + '.',
        { symbol: 'A' });
    }

// lose a node
  public function onLose(node: Node)
    {
      if (node.artifact == null)
        return;

      cult.logAndPanel(node.artifact.name + ' is lost with the priest.',
        { symbol: 'A' });
      storage.remove(node.artifact);
      node.artifact = null;
    }

  public function add(a: CultArtifact)
    {
      storage.push(a);
    }

  public function list()
    {
      return storage;
    }

  public function iterator()
    {
      return storage.iterator();
    }

  function get_length(): Int
    {
      return storage.length;
    }
}
