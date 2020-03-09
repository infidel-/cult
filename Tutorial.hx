// tutorial strings and state

class Tutorial
{
  var game: Game;
  var ui: UI;
  var tags: Map<String, Bool>;

  public function new(g: Game, ui: UI)
    {
      this.game = g;
      this.ui = ui;
      tags = new Map();
    }


// play tutorial part by its tag if it hasn't already played'
  public function play(tag: String)
    {
      if (!game.isTutorial)
        return;
      if (tags[tag])
        return;
      
//      trace('play ' + tag);

      tags[tag] = true;
      var str = strings[tag];
      for (s in str)
        ui.alert(s, { h: 180 });
    }


  static var strings = [
    'start' => [
      'Greetings. You are playing a game about nefarious cults vying for world domination (or destruction). You are controlling one of these cults.',
      'Your cult consists of followers which have three different categories. You can see their numbers on the left in the status window. The map window shows the icons that represent your followers and potential followers.',
      'In the beginning of the game you only have one follower. This is the origin of your cult. To grow your cult you need to gain new followers by clicking their icons on the map.',
      'Press the End Turn button in the status window to continue.',
    ],

    'endTurn' => [
      'To gain followers you need to spend common resources. You can see all your resources in the status window on the left.',
      'There are three common resources in the game and one special. ' + UI.powerName(0) + ', ' + UI.powerName(1) + ' and ' + UI.powerName(2) + ' are common resources and are used directly to gain new followers.',
      'You can convert any common resource to another one at a 2:1 ratio. There is also a special resource - ' + UI.powerName(3) + '. You will need ' + UI.powerName(3) + ' for rituals and you can convert them to common resources at a 1:1 ratio.',
      'Common resources are produced by special "generator" followers. They have a thicker outline around their icons on the map. ' + UI.powerName(3) + ' are found by all your neophytes.',
      'Your cult origin is a generator. The tooltip for the follower icon shows its information including the resource it generates. On each new turn all your generators will produce resources.',
      'The resource icon on top of the map icon shows which resource you need to gain that follower. Try to gain a new follower by clicking on one of the icons with gray circle around it. If you do not have enough resources of that type, convert them.',
    ],

    'gainNode' => [
      'Each time you gain a new follower, one or more lines will appear from them to adjacent followers.',
      'These lines symbolize a direct connection from one follower to another.',
      'Resource generators can be protected by having three separate connections to them from your other followers. Common followers cannot be protected.',
      'Protect your origin by gaining three followers adjacent to it.',
    ],

    'originProtected' => [
      'Good, your origin is now protected. It means that before your opponents can attack it they will have to first take over the followers around until the origin has less than three connections to it.',
      'If the cult loses its origin, it will become paralyzed for some time. Try to keep your origin protected.',
      'Continue expanding your cult.',
    ],

    'gainSect' => [
'Oh, joy! One of your followers has gained their own little sect. Sects are very useful to handle menial tasks like gathering information about your opponents.',
'They can also help you find the next investigator when they inevitably appear and confuse them. You can check out your sects in the sects window.',
'By default the sect tasks are handled automatically with the help of the AI advisor. They grow by themselves and new tasks will appear when your sects reaches level 2.',
'A sect will be disbanded if its puppeteer is lost.',
    ],

    'awareness' => [
      'Each time you gain a new follower by spending resources, public awareness of your cult rises. You can see it in the status window. ',
      'The higher it is, the more difficult it is to gain new followers or upgrade them. To lower awareness you need adepts. You can gain adepts by upgrading your neophyte followers in a ritual using virgins.',
      'Upgrading is done by pressing the + button near the neophytes amount in the status window. The button becomes visible if you have at least 3 neophytes and 1 virgin.',
      'Try to gain an adept.',
    ],

    'gainAdept' => [
      'You have gained your first adept. You can now spend common resources to lower public awareness. Any single adept can only be used once per turn to do it.',
      "Coincidentally, you've opened yourself up to the potential investigators. There's a chance that an intrepid investigator will learn about the existence of your cult.",
      'To minimize that chance, keep the awareness low.',
    ],

    'investigator' => [
      "Oh, my. Looks like you've gained the attention of one of those pesky little investigators. You can see the investigator information in the cults window.",
      'The investigator has a level and willpower. Each turn they will try to attack the number of your followers equal to their level.',
      "The investigator's willpower is their desire to work against your cult. You need to lower it to zero as quickly as possible. When it goes to zero, they disappear.",
      'However, currently the investigator is hidden and you cannot attack them. One of your sects is working on finding them.',
      'In the meantime try to lower awareness closer to zero. That will help with protecting your followers from investigator attacks.',
    ],

    'investigatorFound' => [
      'One of your sects has managed to find out where the investigator is hiding.',
      'Now your adepts can use common resources to lower their willpower. You do have multiple adepts, right?',
    ],

    'investigatorDead' => [
      'Finally. The investigator has lost the will to go on fighting and is out of the cosmic equation. You are free to continue.',
      'That is, until the next one appears. But we already know how to deal with them, correct?',
    ],

    'sectLevel2' => [
      'One of your sects has managed to grow up to level 2. Now it will try to sabotage the rituals of your opponents when necessary. And it can be sacrificed to stop an investigator or harvested for resources.',
      'Sacrificing the sect to stop an investigator will significantly reduce their willpower but will destroy the sect in the process. Not to worry, the puppeteer will create a new one to replace it.',
      "Harvesting the sect is also a one-time task. In this case your cult will acquire a stash of resources. Of course, you can leave the sect alone, but where's the fun in that?",
    ],

    'discoverCult' => [
      "You have discovered one of the other cults I've been talking about. They are ruthless, psychopathic and willing to bring the end of the world as we know it. Just like you are.",
      'Your sects will first automatically gather information about the cult size and then will go on to research every new cult follower you uncover.',
      'Leave your sects to gather information and plan for eventual hostilities. After all, only one cult will be the one to lead the Earth into glorious new age (hopefully, yours).',
    ],

    'cultParalyzed' => [
      'Tsk, tsk, tsk. Looks like your cult has lost its origin before I could teach you the basics of world domination. The Elder God will be very disappointed.',
      'You cannot gain any new followers while your cult is paralyzed. Wait for now and reflect on what went wrong. If your cult manages to survive for some time, you will gain a new origin.',
    ],

    'gain3Adepts' => [
'You have 3 adepts now. That and 2 virgins is enough to upgrade one of them into a priest. Whether to do that right now is up to you, of course, but only priests can perform rituals.',
'  You will need 3 priests and a sizable amount of virgins to start summoning the Elder God. If the summoning is a success, you will win the game.',
    ],

    'gainPriest' => [
      'Praise the Elder God! You have a priest now. A single priest and 5 virgins is enough to perform the ritual of Unveiling. This ritual will show where all other cult origins are located on the map.',
      'During the ritual each priest contributes a point to the execution. You need a fixed amount of points to finish the ritual. That means the more priests you have, the quicker you will complete the ritual.',
      "Don't forget that public awareness lowers the chance of success. It's a good idea to keep it low for the moment when the ritual finishes.",
    ],

    'enemyFinalRitual' => [
      'Oh, bother. One of your enemies has started performing their Final Ritual. If they are successful, you will lose the game.',
      "If you have any sects of level 2 and higher, they are already focused on sabotaging it (unless they're busy with the investigator).",
      'To stall the ritual even more, you can try to gain their priests if you have access to them on the map. If the enemy cult loses its origin, the ritual will be stopped completely.',
    ],
  ];
}
