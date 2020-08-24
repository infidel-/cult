// cult artifacts storage
package artifacts;

import _SaveGame;

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
      // active mask degrades awareness each turn
      if (hasUnique('mask'))
        {
          var info = StaticArtifacts.uniqueArtifacts['mask'];
          if (cult.awarenessBase > 0)
            cult.awarenessBase -= info.val;
          if (cult.awarenessBase < 0)
            cult.awarenessBase = 0;
        }
    }

// ritual points
  public function getRitualPoints(): Int
    {
      if (cult.isAI)
        return cult.priests * cult.difficulty.artifactPriestRitualPointsAI;
      var pts = 0;
      for (a in storage)
        if (a.node != null)
          pts += a.level;
      return pts;
    }

// check if we can upgrade a priest
  public function canUpgrade(level: Int): Bool
    {
      if (cult.isAI)
        return true;
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
      if (cult.isAI)
        return;
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
      var m = node.name + ' becomes a priest binding with ' + art.name + '.';
      cult.logAndPanel(m, { symbol: 'A' });
      if (node != null && !cult.fluffShown['artifactBound'])
        {
          ui.alert('<h2>ARTIFACT BOUND</h2><div class=fluff>' +
          Static.template('artifactBound', {
            art: art.name,
            priest: node.name,
          }) + '</div><br>' + m, { h: 340 });
          cult.fluffShown['artifactBound'] = true;
        }

      // voice: +2 generated virgins
      if (art.id == 'voice')
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
      if (cult.isAI || node.artifact == null)
        return;

      cult.logAndPanel(node.artifact.name + ' is lost with the priest.',
        { symbol: 'A' });
      storage.remove(node.artifact);
      if (node.artifact.isUnique)
        game.artifacts.deleted.push(node.artifact.id);
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
      if (!hasUnique('sign'))
        return;
      var artifact = getUnique('sign');
      var info = StaticArtifacts.uniqueArtifacts['sign'];
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

// save info
  public function save(): _SaveCultArtifacts
    {
      var o: _SaveCultArtifacts = {
        storage: [],
      };
      for (a in storage)
        o.storage.push({
          name: a.name,
          id: a.id,
          level: a.level,
          isUnique: a.isUnique,
          node: (a.node != null ? a.node.id : -1),
        });
      return o;
    }

// load info
  public function load(obj: _SaveCultArtifacts)
    {
      for (a in obj.storage)
        {
          var art: CultArtifact = {
            name: a.name,
            id: a.id,
            level: a.level,
            isUnique: a.isUnique,
            node: (a.node >= 0 ? game.getNode(a.node) : null),
            info: StaticArtifacts.uniqueArtifacts[a.id],
          };
          storage.push(art);

          // fix node link
          if (art.node != null)
            art.node.artifact = art;
        }
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
