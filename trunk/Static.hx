// static stuff

// difficulty info
typedef DifficultyInfo = {
  var level: Int;
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
  };


class Static
{
  // ======================= Difficulty settings =======================
  public static var difficulty: Array<DifficultyInfo> = 
    [
      // easy
      {
        level: 0,
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
      },

      // normal
      {
        level: 1,
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
      },

      // hard
      {
        level: 2,
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
      },
    ];


  // ======================= Cults ============================

  public static var cults: Array<CultInfo> =
    [
      // your cult
      { name: "Cult of Elder God",
        note: "The cult still lives.",
        longNote: "At the dawn of humanity the great old ones told their secrets in dreams to the first men, who formed a cult which had never died... Hidden in distant and dark places of the world, waiting for the day when the stars will be right again and the mighty Elder God will rise from his slumber under the deep waters to bring the earth beneath his sway once more.",
        summonStart: "",
        summonFinish: "",
        summonFail: "" },

      { name: "Pharaonic Slumber",
        note: "A group that wants to put the entire world to sleep, feeding on the nightmares of the dreamers.",
        longNote: "Abhumans from a dark dimension close to ours came to Earth thousands of years ago, trading their magics and technology with the Egyptians for control of their people's minds when they slept, for they fed upon nightmares. With the secret help of the Roman Empire, the Egyptians drove the abhumans into hiding. But they have returned, and their goal has grown with time: the permanent slumber of the world.",
        summonStart: "As the Pharaonic Slumber's power grows, the world enters a state of controlled drowsiness. People go to bed earlier and sleep later, their dreams plagued with thoughts of sweeping sands and dark figures. Short naps at work become almost commonplace, and as the abhumans feed upon the dreaming energies of the world, everyone feels less and less energetic. All the more reason to take a bit of a rest...",
        summonFinish: "The world drifts off to sleep, some even slumping to the sidewalk where they were just walking or barely managing to bring their vehicles to a stop. The abhumans come out in force, walking amongst the dreaming populace, feeding hungrily upon the horrid dreams foisted upon them by the dark magics. A few humans manage to keep themselves awake a bit longer on massive doses of amphetamines, but soon they too crash into the darkness of eternal slumber, screaming into unconsciousness as they see the burning red eyes of those who've come to consume their thoughts.",
        summonFail: "People shake off the dozing state that had captured them. Sales of coffee and cola rocket temporarily, an odd spike that intrigues many commentators, and for a moment humanity is more awake than it has ever been before. Soon, however, old habits return, and some are still plagued by dreams of windswept deserts they have never before seen and cloaked figures that move in a way that somehow feels inhuman, dreams that feel more real than reality." },

      { name: "Blooded Mask",
        note: "A group devoted to ripping away the masks people wear and revealing the insane reality beyond.",
        longNote: "Those who peer too long into the Abyss find that it stares back at them, and the Blooded Mask has long gazed into the ineffable world beyond our own. Affiliated with no Elder God, or perhaps all of them, the Blooded Mask longs to show humanity the brutal truths that hide behind the consensual reality. The truths drive those who see them insane, filling them with a desire to show others as well, and the Blooded Mask are the original converts.",
        summonStart: "A rash of cases of schizophrenia and paranoid delusions becomes an epidemic.  World health organizations struggle to understand environmental factors behind the increasing numbers of psychotic breaks and irrational behaviour across the world, unaware of the rituals the Blooded Mask are enacting.  The only clue is an increased incidence of individuals trying to claw their eyes out, often babbling about seeing <i>the truth</i> better without them.",
        summonFinish: "Even the most stable individuals become gripped by the desire to see beyond the veil. Plucking their eyes out, almost as one, humanity peers out of bloody sockets into the screaming void of alien truth that had, until then, been hidden to most. The Bloody Veil's incantations brought to their climax, the world becomes a madhouse of screaming blind horror, people stumbling through living nightmares in colours their minds were never meant to comprehend, groping past those others wandering in the same strange geometries.",
        summonFail: "The outbreak of madness draws to a close, the circumstances at its end as mysterious as when it began. Sanity returns to some of those who saw the underlying truth, but those who blinded themselves are relegated to sanitariums around the world, their screaming reverberating in the halls of the buildings, unable to stop seeing the horrifying ur-reality. A small number of painters attempt to incorporate the colours they saw in their madness into their work, and the epileptic seizures their paintings evoke cause the black ops divisions of the world's governments to destroy all evidence of their work." },

      { name: "Universal Lambda",
        note: "Programmers who want to turn humanity into a vast processing machine.",
        longNote: "In the early seventies, a secret goverment project uncovered the changes necessary to turn any human brain into an efficient, soulless computer.  Little did the project know that it had been subverted by the dark cult. The Universal Lambda works to refine that now-defunct project's results: the turning of every human being into cogs of a huge machine, a distributed network for the vast living intellect of the Elder God.",
        summonStart: "The Universal Lambda's cybermantic machinations begin to influence the entire world.  People start to walk in unconscious lockstep down the streets; crime and accident rates drop as the rituals rewire minds to be more and more regimented.  People make fewer choices, locking themselves into patterns without realizing the steady loss of free will.",
        summonFinish: "Their rituals complete, the Universal Lambda turns the world into a well-oiled machine. Bodies still move around, taking part in the same rote behavior they did before, but the minds of the populace are gone. Instead of thinking independent thoughts, humanity's brains run the code that allows The Machine to run in our dimension. The tiny flickers of free will brought upon by every birth are quickly consumed by the overwhelming cybermantic magics enveloping the world; all are just parts of the giant soulless entity... ",
        summonFail: "The eerily constant behavior of humanity slowly returns to its regular froth of chaos. People still occasionally slip into the robotic state they exhibited mere days before, but the rising rate of accidents and deaths heralds the return of free will, for better or worse." },

    { name: "Drowned",
      note: "Vengeful spirits determined to drown the rest of the world.",
      longNote: "Over the millennia, hundreds of thousands of people have drowned in the oceans, lakes, and rivers of the world. Most of them pass peacefully into oblivion, but some linger, warped by the experience of their death. Over time, those who remain have gathered together in an undead cabal. They want the rest of the world to join them in their watery graves, and will stop at nothing to make it happen.",
      summonStart: "It begins to rain. A slow drizzle at first, the entire world is soon enveloped in an unending thunderstorm, water pouring from the heavens without an end in sight. Low-lying regions begin to flood, and it is only a matter of time before even the highest ground is inundated.",
      summonFinish: "The heavy rains turn torrential.  The sea level rises inexorably as humanity crowds further and further up into the mountains.  Still the rains come, still the waters climb.  Every death in the water adds to the power of the Drowned, the force of the neverending rain.  Many take
      to boats in an attempt to survive on the surface of the sea, only to find that no ship remains seaworthy; leaks spring up in unlikely places, and soon every vessel succumbs to the inexorable pull of the dark depths below.  The last gasp of humanity is a doomed man standing on the peak of Everest, and then he goes under once. Twice. He is gone.",
      summonFail: "The rains slacken, first to a light patter, then a drizzle, then nothing but the usual patterns of storms and showers. Commentators argue that the excess water had to come from somewhere, but within days everything seems to have returned to an equilibrium, the ghost rains drying up into nothing.  Scientists are at a loss to explain the phenomenon, but the
      rest of the world returns to its routine, although many glance at the sky whenever a cloud darkens the day, worried that it might once again begin to rain forever." },

    { name: "Manipulators",
      note: "Powerful magicians who wish to enslave humanity.",
      longNote: "For centuries, men in power have desired the ability to make their subjects obey their every whim. Some have used force, or fear, but none have been completely successful. A group of powerful male magicians, many of whom control powerful multinational corporations, are determined to succeed where others have failed.  Through the use of mind-manipulation magic, memetic manipulation, and subtle influence in world governments, they plan to make every other man, woman, and child on the planet their slaves, forced into fulfilling the Manipulators' dark desires.",
      summonStart: "The Manipulators start their ultimate ritual with a slow but insidious assault on the psyches of the world, using traditional advertising techniques combined with subtle dark magics.  Much of their work is couched in the comforting form of mass media, convincing people that the
      old inhibited days are over, that a new dawn of peace, prosperity, and happiness is on the horizon, subtly hinting that a chosen few will be the ones to lead humanity into the new golden age.  Many are skeptical, but many more are taken in by the Manipulators' careful schemes, as the magics work their way on the minds of the converted and unconverted alike.",
      summonFinish: "The Manipulators' control of the world becomes more and more overt, their supposedly-benign stewardship turning into outright worship by the masses. Their magics turn support into adulation, appreciation into unfettered desire; the world wants, needs to fulfill their every whim, no matter the consequence. People of all genders and ages disappear into the gleaming palaces, their bodies and minds used for unmentionable new rituals. The diversity of humanity is now nothing more than a living, breathing mass of clay for the Manipulators to sculpt as they desire. And their desires are manifold indeed.",
      summonFail: "What at first seemed like the genuine rise of a new era of freedom and prosperity turns sour, many of its proponents discovered to be frauds and freaks.  The Manipulators themselves stay behind the scenes, protected by layers of misdirection and human shields, but the effects
      of their manipulations begin to fade.  People once again assert contrary views with candor; for a moment, they view the mass media with a genuine critical eye.  Then the time passes, advertisements and packaged views reasserting their mundane control on the opinions, just another day in this modern life." }
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

  public static var rituals: Array<RitualInfo> =
    [
      // the first one is reserved for ritual of summoning!
      {
        id: "summoning",
        name: "Final Ritual",
        points: 9,
        note: "Upon completion this cult will reign over the world unchallenged."
      }
    ];
}


// ritual info
typedef RitualInfo =
  {
    var id: String; // string id of ritual (for use in code)
    var name: String; // ritual name
    var note: String; // ritual description
    var points: Int; // points for completion
  };

// cult info
typedef CultInfo =
  {
    var name: String; // cult name
    var note: String; // short description
    var longNote: String; // long description
    var summonStart: String; // text on summoning start
    var summonFinish: String; // text on summoning finish
    var summonFail: String; // text on summoning failure
  };

