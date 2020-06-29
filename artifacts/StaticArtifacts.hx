// static data

package artifacts;

class StaticArtifacts
{
// generate random artifact name by type
  public static function getRandomName(typeID: Int): String
    {
      var info = artifacts[typeID];
      return names0[Std.random(names0.length)] + ' ' +
        info.names1[Std.random(info.names1.length)];
    }
  public static var types = [ 'book', 'dagger', 'hand', 'ankh' ];
  public static var names0 = [
    'Ancient',
    'Antique',
    'Arcane',
    'Black',
    'Cryptic',
    'Cursed',
    'Enchanted',
    'Magic',
    'Mystical',
    'Occult',
  ];
  public static var names2 = [
    'of the Believer',
    'of Shadows',
  ];
  public static var artifacts: Array<ArtifactTypeInfo> = [
    {
      id: 'book',
      names1: [
        'Codex',
        'Fragment',
        'Manuscript',
        'Parchment',
        'Script',
        'Scroll',
        'Tome',
        'Tractatus',
        'Treatise',
        'Vellum',
        'Volume',
      ],
    },
    {
      id: 'dagger',
      names1: [
        'Blade',
        'Cane',
        'Spear',
      ],
    },
    {
      id: 'hand',
      names1: [
        'Bone',
        'Eye',
        'Hand',
        'Heart',
        'Limb',
        'Rib',
        'Skull',
        'Spine',
        'Tail',
      ],
    },
    {
      id: 'ankh',
      names1: [
        'Gem',
        'Key',
        'Mask',
        'Mirror',
        'Scales',
        'Scepter',
        'Sign',
        'Sphere',
        'Star',
        'Statue',
        'Tablet',
        'Talisman',
        'Veil',
      ],
    },
  ];
  public static var uniqueArtifacts: Map<String, UniqueArtifact> = [
    'book' => {
      id: 'book',
      name: 'Tome of TODO',
      note: '-%v to cult awareness each turn when active',
      val: 1, // awareness mod
    },
    'dagger' => {
      id: 'dagger',
      name: 'Dagger of TODO',
      note: '%v% chance to kill the investigator on finding',
      val: 10, // investigator kill chance
    },
    'hand' => {
      id: 'hand',
      name: 'Hand of TODO',
      note: 'All sects grow %v% faster',
      val: 25, // bonus to sect growth speed
    },
    'ankh' => {
      id: 'ankh',
      name: 'Ankh of TODO',
      note: 'Owner generates %v virgins each turn',
      val: 2, // bonus to generated resource
    },
  ];
}

typedef UniqueArtifact = {
  var id: String;
  var name: String;
  var note: String;
  var val: Int;
}

typedef ArtifactTypeInfo = {
  var id: String;
  var names1: Array<String>;
}
