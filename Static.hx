// static stuff

// difficulty info
typedef DifficultyInfo = {
  var level: Int;

  var mapWidth: Int; // map width
  var mapHeight: Int; // map height
  var nodesCount: Int; // nodes count
  var nodeActivationRadius: Int; // node activation radius
  var numCults: Int; // number of cults in game
  var numPlayers: Int; // number of player cults in game
  var numSummonVirgins: Int; // number of virgins needed for summoning

  var upgradeChance: Float; // higher value raises max upgrade chance
  var awarenessResource: Float; // higher value lowers chance of getting resources each turn
  var awarenessUpgrade: Float; // higher value lowers chance of upgrading followers
  var awarenessGain: Float; // higher value lowers chance of gaining new followers

  var investigatorChance: Float; // higher value raises chance of investigator appearing
  var investigatorKill: Float; // higher value raises chance of investigator killing a follower
  var investigatorWillpower: Float; // higher value lowers chance of success in lowering
      // investigator willpower using adepts
  var investigatorTurnVisible: Int; // turn on which new investigator becomes visible
  var investigatorGainWill: Float; // higher value raises chance of investigator gaining will
  var investigatorCultSize: Float; // starting investigator willpower - cult size multiplier (less - easier)

  var maxAwareness: Int; // max awareness for AI to have without using adepts
  var isInfoKnown: Bool; // is cult info for all cults known at start?
  var isOriginKnown: Bool; // is origin known for all cults at start?
  var isDiscovered: Bool; // are cults marked as discovered on start?

  // artifacts expansion
  var artifactMaxAmountIngame: Int; // max amount of artifacts in play
  var artifactBaseSpawnTime: Int; // base artifact time on map
};


class Static
{
  // ======================= Difficulty settings =======================
  public static var difficulty: Array<DifficultyInfo> =
    [
      // easy
      {
        level: 0,

        mapWidth: 780,
        mapHeight: 580,
        nodesCount: 100,
        nodeActivationRadius: 101,
        numCults: 3,
        numPlayers: 1,
        numSummonVirgins: 6,
        upgradeChance: 1.10,
        awarenessResource: 1.25,
        awarenessUpgrade: 0.75,
        awarenessGain: 0.75,
        investigatorChance: 0.50,
        investigatorKill: 0.75,
        investigatorWillpower: 0.75,
        investigatorTurnVisible: 0,
        investigatorGainWill: 0.50,
        investigatorCultSize: 0.05,
        maxAwareness: 10,
        isInfoKnown: true,
        isOriginKnown: true,
        isDiscovered: true,

        artifactMaxAmountIngame: 8,
        artifactBaseSpawnTime: 4,
      },

      // normal
      {
        level: 1,

        mapWidth: 780,
        mapHeight: 580,
        nodesCount: 100,
        nodeActivationRadius: 101,
        numCults: 4,
        numPlayers: 1,
        numSummonVirgins: 9,
        upgradeChance: 1.0,
        awarenessResource: 1.5,
        awarenessUpgrade: 1.0,
        awarenessGain: 1.0,
        investigatorChance: 1.0,
        investigatorKill: 1.0,
        investigatorWillpower: 1.0,
        investigatorTurnVisible: 10,
        investigatorGainWill: 0.75,
        investigatorCultSize: 0.1,
        maxAwareness: 5,
        isInfoKnown: false,
        isOriginKnown: false,
        isDiscovered: false,

        artifactMaxAmountIngame: 6,
        artifactBaseSpawnTime: 2,
      },

      // hard
      {
        level: 2,

        mapWidth: 780,
        mapHeight: 580,
        nodesCount: 100,
        nodeActivationRadius: 101,
        numCults: 4,
        numPlayers: 1,
        numSummonVirgins: 9,
        upgradeChance: 0.90,
        awarenessResource: 1.75,
        awarenessUpgrade: 1.25,
        awarenessGain: 1.25,
        investigatorChance: 1.25,
        investigatorKill: 1.25,
        investigatorWillpower: 1.25,
        investigatorTurnVisible: 2000,
        investigatorGainWill: 1.0,
        investigatorCultSize: 0.15,
        maxAwareness: 5,
        isInfoKnown: false,
        isOriginKnown: false,
        isDiscovered: false,

        artifactMaxAmountIngame: 4,
        artifactBaseSpawnTime: 0,
      },

      // test - 2 players multiplayer
      {
        level: -1,

        mapWidth: 780,
        mapHeight: 580,
        nodesCount: 100,
        nodeActivationRadius: 101,
        numCults: 4,
        numPlayers: 2,
        numSummonVirgins: 9,
        upgradeChance: 1.0,
        awarenessResource: 1.5,
        awarenessUpgrade: 1.0,
        awarenessGain: 1.0,
        investigatorChance: 1.0,
        investigatorKill: 1.0,
        investigatorWillpower: 1.0,
        investigatorTurnVisible: 10,
        investigatorGainWill: 0.75,
        investigatorCultSize: 0.1,
        maxAwareness: 5,
        isInfoKnown: false,
        isOriginKnown: false,
        isDiscovered: false,

        artifactMaxAmountIngame: 6,
        artifactBaseSpawnTime: 2,
      },
    ];


  // ======================= Cults ============================

  public static var cults: Array<CultInfo> =
    [
      // your cult
      { name: "Cult&nbsp;of&nbsp;Elder&nbsp;God",
        note: "The cult still lives.",
        longNote: "At the very dawn of humanity the Great Old Ones whispered their fell secrets in dreams to those who would listen to such grim tidings, and those ancient disciples formed a cult which has never died out since. Hidden in the dark distant corners of the Earth, they wait for the day when the stars are right again and the mighty Elder God will rise from his slumber under the deep waters, bringing the Earth beneath his sway once more.",
        summonStart: "The seas tremble and shake as He Who Sleeps begins to awaken, rogue waves and typhoons disrupting shipping worldwide. Lightning flashes down from cloudless skies, striking people as those nearby watch them burst into flame. The night is sharper and clearer than it has been in a century, the stars dazzling pinpricks of light that seem to wheel about in mysterious patterns, baffling astronomers. And as people awaken from poorly-remembered dreams, the faintest of dark whispers still linger in the air.",
        summonFinish: "Eternal night falls upon the Earth, the stars locked in place and burning brighter than ever before, forming eldritch patterns no human can look upon for long without going mad. The oceans steam, then boil, as the Elder God rises from his long sleep, his feet crushing people and buildings alike as he strides the planet once more. To look upon him is to lose oneself to his thrall, madness and ecstasy conjoined. What little remains of humanity struggles to hide away from the twisted sky and the thundering steps of He Who Has Awakened, but it is only a matter of time before his disciples find them and pull them out, screaming, into the darkness and light...",
        summonFail: "The oceans quiet back down as the Elder God returns to his restless slumber, although several unseasonal hurricanes still lash the shores. The murky red of light pollution once again spreads across the night sky, calming the populace even as more than a few scientists express their disappointment. The acolytes of He Who Sleeps once again return to the shadows, and the world returns to relative peace, although many still wake in a cold sweat, the words of a dead language dancing on their tongue, alien voices echoing in their dreams." },

      { name: "Pharaonic&nbsp;Slumber",
        note: "A group that wants to put the entire world to sleep, feeding on the nightmares of the dreamers.",
        longNote: "Abhumans from a dark dimension close to ours came to Earth thousands of years ago, trading their magics and technology with the Egyptians for control of their people's minds when they slept, for they fed upon nightmares. With the secret help of the Roman Empire, the Egyptians drove the abhumans into hiding. But they have returned, and their goal has grown with time: the permanent slumber of the world.",
        summonStart: "As the Pharaonic Slumber's power grows, the world enters a state of controlled drowsiness. People go to bed earlier and sleep later, their dreams plagued with thoughts of sweeping sands and dark figures. Short naps at work become almost commonplace, and as the abhumans feed upon the dreaming energies of the world, everyone feels less and less energetic. All the more reason to take a bit of a rest...",
        summonFinish: "The world drifts off to sleep, some even slumping to the sidewalk where they were just walking or barely managing to bring their vehicles to a stop. The abhumans come out in force, walking amongst the dreaming populace, feeding hungrily upon the horrid dreams foisted upon them by the dark magics. A few humans manage to keep themselves awake a bit longer on massive doses of amphetamines, but soon they too crash into the darkness of eternal slumber, screaming into unconsciousness as they see the burning red eyes of those who've come to consume their thoughts.",
        summonFail: "People shake off the dozing state that had captured them. Sales of coffee and cola rocket temporarily, an odd spike that intrigues many commentators, and for a moment humanity is more awake than it has ever been before. Soon, however, old habits return, and some are still plagued by dreams of windswept deserts they have never before seen and cloaked figures that move in a way that somehow feels inhuman, dreams that feel more real than reality." },

      { name: "Blooded&nbsp;Mask",
        note: "A group devoted to ripping away the masks people wear and revealing the insane reality beyond.",
        longNote: "Those who peer too long into the Abyss find that it stares back at them, and the Blooded Mask has long gazed into the ineffable world beyond our own. Affiliated with no Elder God, or perhaps all of them, the Blooded Mask longs to show humanity the brutal truths that hide behind the consensual reality. The truths drive those who see them insane, filling them with a desire to show others as well, and the Blooded Mask are the original converts.",
        summonStart: "A rash of cases of schizophrenia and paranoid delusions becomes an epidemic.  World health organizations struggle to understand environmental factors behind the increasing numbers of psychotic breaks and irrational behaviour across the world, unaware of the rituals the Blooded Mask are enacting.  The only clue is an increased incidence of individuals trying to claw their eyes out, often babbling about seeing <i>the truth</i> better without them.",
        summonFinish: "Even the most stable individuals become gripped by the desire to see beyond the veil. Plucking their eyes out, almost as one, humanity peers out of bloody sockets into the screaming void of alien truth that had, until then, been hidden to most. The Bloody Veil's incantations brought to their climax, the world becomes a madhouse of screaming blind horror, people stumbling through living nightmares in colours their minds were never meant to comprehend, groping past those others wandering in the same strange geometries.",
        summonFail: "The outbreak of madness draws to a close, the circumstances at its end as mysterious as when it began. Sanity returns to some of those who saw the underlying truth, but those who blinded themselves are relegated to sanitariums around the world, their screaming reverberating in the halls of the buildings, unable to stop seeing the horrifying ur-reality. A small number of painters attempt to incorporate the colours they saw in their madness into their work, and the epileptic seizures their paintings evoke cause the black ops divisions of the world's governments to destroy all evidence of their work." },

      { name: "Universal&nbsp;Lambda",
        note: "Programmers who want to turn humanity into a vast processing machine.",
        longNote: "In the early seventies, a secret government project uncovered the changes necessary to turn any human brain into an efficient, soulless computer.  Little did the project know that it had been subverted by a dark cult. The Universal Lambda works to refine that now-defunct project's results: the turning of every human being into cogs of a huge machine, a distributed network for the vast living intellect of the Elder God.",
        summonStart: "The Universal Lambda's cybermantic machinations begin to influence the entire world.  People start to walk in unconscious lockstep down the streets; crime and accident rates drop as the rituals rewire minds to be more and more regimented.  People make fewer choices, locking themselves into patterns without realizing the steady loss of free will.",
        summonFinish: "Their rituals complete, the Universal Lambda turns the world into a well-oiled machine. Bodies still move around, taking part in the same rote behavior they did before, but the minds of the populace are gone. Instead of thinking independent thoughts, humanity's brains run the code that allows The Machine to run in our dimension. The tiny flickers of free will brought upon by every birth are quickly consumed by the overwhelming cybermantic magics enveloping the world; all are just parts of the giant soulless entity... ",
        summonFail: "The eerily constant behavior of humanity slowly returns to its regular froth of chaos. People still occasionally slip into the robotic state they exhibited mere days before, but the rising rate of accidents and deaths heralds the return of free will, for better or worse." },

    { name: "Drowned",
      note: "Vengeful spirits determined to drown the rest of the world.",
      longNote: "Over the millennia, hundreds of thousands of people have drowned in the oceans, lakes, and rivers of the world. Most of them pass peacefully into oblivion, but some linger, warped by the experience of their death. Over time, those who remain have gathered together in an undead cabal. They want the rest of the world to join them in their watery graves, and will stop at nothing to make it happen.",
      summonStart: "It begins to rain. A slow drizzle at first, the entire world is soon enveloped in an unending thunderstorm, water pouring from the heavens without an end in sight. Low-lying regions begin to flood, and it is only a matter of time before even the highest ground is inundated.",
      summonFinish: "The heavy rains turn torrential.  The sea level rises inexorably as humanity crowds further and further up into the mountains.  Still the rains come, still the waters climb.  Every death in the water adds to the power of the Drowned, the force of the neverending rain.  Many take to boats in an attempt to survive on the surface of the sea, only to find that no ship remains seaworthy; leaks spring up in unlikely places, and soon every vessel succumbs to the inexorable pull of the dark depths below.  The last gasp of humanity is a doomed man standing on the peak of Everest, and then he goes under once. Twice. He is gone.",
      summonFail: "The rains slacken, first to a light patter, then a drizzle, then nothing but the usual patterns of storms and showers. Commentators argue that the excess water had to come from somewhere, but within days everything seems to have returned to equilibrium, the ghost rains drying up into nothing.  Scientists are at a loss to explain the phenomenon, but the rest of the world returns to its routine, although many glance at the sky whenever a cloud darkens the day, worried that it might once again begin to rain forever." },

    { name: "Manipulators",
      note: "Powerful magicians who wish to enslave humanity.",
      longNote: "For centuries, men in power have desired the ability to make their subjects obey their every whim. Some have used force, or fear, but none have been completely successful. A group of powerful male magicians, many of whom control powerful multinational corporations, are determined to succeed where others have failed.  Through the use of mind-manipulation magic, memetic manipulation, and subtle influence in world governments, they plan to make every other man, woman, and child on the planet their slaves, forced into fulfilling the Manipulators' dark desires.",
      summonStart: "The Manipulators start their ultimate ritual with a slow but insidious assault on the psyches of the world, using traditional advertising techniques combined with subtle dark magics.  Much of their work is couched in the comforting form of mass media, convincing people that the old inhibited days are over, that a new dawn of peace, prosperity, and happiness is on the horizon, subtly hinting that a chosen few will be the ones to lead humanity into the new golden age.  Many are skeptical, but many more are taken in by the Manipulators' careful schemes, as the magics work their way on the minds of the converted and unconverted alike.",
      summonFinish: "The Manipulators' control of the world becomes more and more overt, their supposedly-benign stewardship turning into outright worship by the masses. Their magics turn support into adulation, appreciation into unfettered desire; the world wants, needs to fulfill their every whim, no matter the consequence. People of all genders and ages disappear into the gleaming palaces, their bodies and minds used for unmentionable new rituals. The diversity of humanity is now nothing more than a living, breathing mass of clay for the Manipulators to sculpt as they desire. And their desires are manifold indeed.",
      summonFail: "What at first seemed like the genuine rise of a new era of freedom and prosperity turns sour, many of its proponents discovered to be frauds and freaks.  The Manipulators themselves stay behind the scenes, protected by layers of misdirection and human shields, but the effects of their manipulations begin to fade.  People once again assert contrary views with candor; for a moment, they view the mass media with a genuinely critical eye.  Then the time passes, advertisements and packaged views reasserting their mundane control on the opinions, just another day in this modern life." },
    {
      name: "The Frozen Dream",
      note: "A group of ice demons that want to freeze the world.",
      longNote: "Led by unholy denizens of frozen wastes, The Frozen Dream works to turn the world into an eternal winter horrorland, full of ice demons and frosthounds cavorting in the terrible chill. What little can survive in the icy bleakness will be hunted for sport.",
      summonStart: "As The Frozen Dream begins their dark rituals, temperatures across the world begin to drop. Winter has become bitterly frigid, spring and fall too cold for the plants, and summer a wan shadow of its former self. Weather patterns spiral out of control, and food crops wither and die.",
      summonFinish: "Their dark ritual complete, The Frozen Dream's grasp upon the Earth becomes stronger. The biting cold becomes unbearable, freezing and shattering plants and animals alike still on the surface. What little humanity remains is ensconced deep underground, but the unnatural chill manages to penetrate even those bastions, slowly but surely. It is only a matter of time before the thin flame of natural life is extinguished by the icy winds that blow across the planet.",
      summonFail: "The unnatural chill of recent days begins to fade, the world scrambling to repair what damage can be fixed. Many still shiver uncontrollably when a gust of cool air blows past them, a psychic remnant of the grasp The Frozen Dream nearly had upon the Earth."
    },
    {
      name: "The Slake",
      note: "Emotional vampires who feed on ecstasy and horror.",
      longNote: "Legends passed down for generations speak of vampires, those who consume the blood of mankind. Little do most know that those stories contain the dim shine of truth: twisted creatures among humanity, drinking in strong emotion and leaving shattered husks. With the world ripe for the plucking, the Slake want nothing more than to turn it all into an eternal feeding ground.",
       summonStart: "The Slake begin to draw on their stores of distilled emotions, slowly drawing the world into a heightened sense of existence. Petty disputes flare into armed conflicts, teetering towards full-fledged wars; long-hidden passions and desires erupt into a re-flowering of hedonism. On the edges of it all, the vampires drink and drink, powering their dark magics ever further...",
        summonFinish: "Society collapses into an orgy of violence and ecstasy. Nation-states collapse as they destroy each other in terrible attacks and counterattacks, while those back home fall into reckless passion, destroying relationships and souls alike as the Slake consume it all. They leave only a small number of chattel alive, to procreate and destroy as they drain them, one by one, until the end of time.",
         summonFail: "The strange passions that had gripped the world fade like a bad dream, the world shaking off the heightened sense of everything with little more than whispers of concern. A wild season, nothing more, the media proclaims, a self-fulfilling prophecy. The Slake retreat for a while, to gather their powers once again for another attempt at goading the world into providing the emotions they crave." }
/*
    {
      name: "",
      note: "",
      longNote: "",
      summonStart: "",
      summonFinish: "",
      summonFail: ""
    }
*/
    ];


// ======================== Rituals ==========================

  public static var rituals: Map<String, RitualInfo> =
    [
      'summoning' => {
        id: 'summoning',
        name: 'Final Ritual',
        virgins: 9, // replaced by difficulty.numSummonVirgins
        priests: 3,
        points: 10,
        note: 'Upon completion this cult will reign over the world unchallenged.'
      },
      'unveiling' => {
        id: 'unveiling',
        name: 'Ritual of Unveiling',
        virgins: 5,
        priests: 1,
        points: 3,
        note: 'The ritual of Unveiling will show all cult origins upon completion. Requires 1 priest and 5 virgins to perform.',
      },
    ];


// calculate distance between this node and the other one
  public static inline function distance(x1: Int, y1: Int, x2: Int, y2: Int): Float
    {
      return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    }

// get arbitrary map quadrants
  public static function getQuadrants(difficulty: DifficultyInfo, size: Int): Array<Quadrant>
    {
      var quadrants = [];
      for (yy in 0...size)
        for (xx in 0...size)
          quadrants.push({
            id: xx + size * yy,
            x1: Std.int(xx * difficulty.mapWidth / size),
            y1: Std.int(yy * difficulty.mapHeight / size),
            x2: Std.int((xx + 1) * difficulty.mapWidth / size),
            y2: Std.int((yy + 1) * difficulty.mapHeight / size),
          });

      return quadrants;
    }
}

typedef Quadrant = {
  var id: Int;
  var x1: Int;
  var y1: Int;
  var x2: Int;
  var y2: Int;
}

// ritual info
typedef RitualInfo = {
  var id: String; // string id of ritual (for use in code)
  var name: String; // ritual name
  var note: String; // ritual description
  var virgins: Int; // used virgins
  var priests: Int; // min priests needed
  var points: Int; // points for completion
};

// cult info
typedef CultInfo = {
  var name: String; // cult name
  var note: String; // short description
  var longNote: String; // long description
  var summonStart: String; // text on summoning start
  var summonFinish: String; // text on summoning finish
  var summonFail: String; // text on summoning failure
};

