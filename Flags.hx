typedef Flags = {
  var noBlitz: Bool; // NOBLITZ - no blitz military victory
  var devoted: Bool; // DEVOTED - allow buffing sects with resources
  var longRituals: Bool; // LONGRITUALS - all rituals take longer

  // expansions
  var artifacts: Bool; // ARTIFACTS
}

class FlagStatic
{
  public static var autoOn = [
    'artifacts' => [ 'noBlitz', 'devoted', 'longRituals' ],
  ];
  public static var autoOff = [
    'noBlitz' => [ 'artifacts' ],
    'devoted' => [ 'artifacts' ],
    'longRituals' => [ 'artifacts' ],
  ];

  public static var names = [
    'noBlitz' => 'No military blitz victory',
    'devoted' => 'Devoted sects',
    'longRituals' => 'Long rituals',
    'artifacts' => 'Artifacts of the Arcane',
  ];

  public static var notes = [
    'noBlitz' => 'Disables automatic victory when all enemy cults are paralyzed.',
    'devoted' => 'Enables spending resources to make sects devoted.',
    'longRituals' => 'Increases needed ritual points for all rituals by a factor of ' + Const.longRitualsRitualPoints + '.',
    'artifacts' => 'Enables Artifacts of the Arcane expansion. Adepts will need artifacts to be upgraded into priests. Automatically enables other flags.',
  ];
}
