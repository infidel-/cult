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
  public static var types = [ 'book', 'dagger', 'skull', 'ankh' ]; // basic
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
#if !demo
    {
      id: 'book',
      x: 8,
      y: 16,
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
      x: 11,
      y: 15,
      names1: [
        'Blade',
        'Cane',
        'Spear',
      ],
    },
    {
      id: 'skull',
      x: 11,
      y: 14,
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
      x: 9,
      y: 12,
      names1: [
        'Gem',
        'Key',
        'Mirror',
        'Scales',
        'Scepter',
        'Sign',
        'Sphere',
        'Star',
        'Statue',
        'Symbol',
        'Tablet',
        'Talisman',
      ],
    },
#end
  ];
  public static var uniqueArtifacts: Map<String, UniqueArtifact> = [
#if !demo
    'mask' => {
      id: 'mask',
      name: 'Mask of Many Faces',
      fluff: 'Offering a gaze into the void, it also<br>cloaks the wearer from mortal eyes.',
      note: '-%v to cult awareness each turn when active',
      val: 2, // awareness mod
      x: 7,
      y: 10,
    },
    'sign' => {
      id: 'sign',
      name: 'Sign of Awakening',
      fluff: 'We are all living in a dream.<br>And for some it\'s time to wake up.',
      note: '%v% chance to kill the investigator on finding',
      val: 20, // investigator kill chance
      x: 5,
      y: 8,
    },
    'hand' => {
      id: 'hand',
      name: 'Guiding Hand',
      fluff: 'The hand that beckons<br>lesser mortals to follow.',
      note: 'All sects grow %v% faster',
      val: 25, // bonus to sect growth speed
      x: 2,
      y: 10,
    },
    'voice' => {
      id: 'voice',
      name: 'Vox Dulcis',
      fluff: 'Those pure of body and soul<br>are enchanted by its beauty.',
      note: 'Owner generates %v virgins each turn',
      val: 2, // bonus to generated resource
      x: 8,
      y: 17,
    },
#end
  ];
}

typedef UniqueArtifact = {
  var id: String;
  var name: String;
  var note: String;
  var fluff: String;
  var val: Int;
  var x: Int;
  var y: Int;
}

typedef ArtifactTypeInfo = {
  var id: String;
  var x: Int;
  var y: Int;
  var names1: Array<String>;
}
