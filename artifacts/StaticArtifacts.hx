// static data

package artifacts;

class StaticArtifacts
{
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
      note: '',
      val: 5, // investigator kill chance
    },
    'hand' => {
      id: 'hand',
      name: 'Hand of TODO',
      note: '',
      val: 20, // bonus to sect growth speed
    },
    'ankh' => {
      id: 'ankh',
      name: 'Ankh of TODO',
      note: '',
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
