// cult artifacts storage
package artifacts;

class CultArtifacts
{
  var ui: UI;
  var game: Game;
  var cult: Cult;
  var storage: Array<CultArtifact>;
  public var length(get, null): Int;

  public function new(g: Game, u: UI, c: Cult)
    {
      ui = u;
      game = g;
      cult = c;
      storage = [];
    }

// end turn
  public function turn()
    {
      // active book degrades awareness each turn
      if (hasUnique('book'))
        {
          var info = StaticArtifacts.uniqueArtifacts['book'];
          cult.awareness -= info.val;
        }
    }

// ritual points
  public function getRitualPoints(): Int
    {
      var pts = 0;
      for (a in storage)
        if (a.node != null)
          pts += a.level;
      return pts;
    }

// check if we can upgrade a priest
  public function canUpgrade(level: Int): Bool
    {
      if (level < 1)
        return true;

      for (a in storage)
        if (a.node == null)
          return true;
      return false;
    }

// upgrade a node
  public function onUpgrade(node: Node)
    {
      // pick an artifact - highest level first
      var art: CultArtifact = null;
      for (a in storage)
        if (a.node == null)
          {
            if (art == null || (art != null && a.level > art.level))
              art = a;
          }
      art.node = node;
      node.artifact = art;
      cult.logAndPanel(node.name + ' becomes a priest binding with ' + art.name + '.',
        { symbol: 'A' });

      // ankh: +2 generated virgins
      if (art.id == 'ankh')
        {
          node.isGenerator = true;
          node.powerGenerated[3] += art.info.val;
          cult.powerMod[3] += art.info.val; // update cache
          ui.updateStatus();
        }
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

// returns true if cult has this artifact activated
  public function hasUnique(id: String): Bool
    {
      for (a in storage)
        if (a.node != null && a.isUnique &&
            StaticArtifacts.uniqueArtifacts[a.id].id == id)
          return true;
      return false;
    }

// returns the artifact
  public function getUnique(id: String): CultArtifact
    {
      for (a in storage)
        if (a.isUnique && StaticArtifacts.uniqueArtifacts[a.id].id == id)
          return a;
      return null;
    }

// sect found investigator
  public function onInvestigatorFound(sect: sects.Sect)
    {
      // kill on finding chance
      if (!hasUnique('dagger'))
        return;
      var artifact = getUnique('dagger');
      var info = StaticArtifacts.uniqueArtifacts['dagger'];
      if (Std.random(100) > info.val)
        {
          cult.log(artifact.node.name + ' fails to dispose of the investigator with the power of ' + info.name + '.');
          return;
        }

      ui.log2(cult, 'Wielding the power of ' +
        info.name + ', ' + artifact.node.name + ' disposes of the investigator.',
        { symbol: 'I' });
      cult.killInvestigator();
    }

// get sect growth bonus
  public function getSectGrowthMod(sect: sects.Sect): Float
    {
      if (!hasUnique('hand'))
        return 1.0;
      var info = StaticArtifacts.uniqueArtifacts['hand'];
      return (100.0 + info.val ) / 100.0;
    }

  // ==================================================

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
