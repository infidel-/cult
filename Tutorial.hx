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


// disable tutorial by tag
  public function disable(tag: String)
    {
      if (!game.isTutorial)
        return;
      tags[tag] = true;
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
        ui.alert(s[1], {
          center: (s[0] == null || s[0] == 'tutorial-ritual'),
          img: s[0],
          h: 180
        });
    }


  static var strings = [
    'start' => [
      [ 'tutorial-test', 'Greetings. You are playing a game about nefarious cults vying for world domination (or destruction). You are controlling one of these cults.' ],
      [ 'tutorial-followers', 'Your cult consists of followers who have three different categories. You can see their numbers on the left in the status window.' ],
      [ 'tutorial-followers-map', 'The map window shows the icons that represent your followers and persons of interest.' ],
      [ 'tutorial-followers-origin', 'At the beginning of the game, you only have one follower. This is the origin of your cult. To grow your cult you need to gain new followers by clicking their icons on the map.' ],
      [ 'tutorial-endturn', 'Press the End Turn button in the status window to continue.' ],
    ],

    'endTurn' => [
      [ 'tutorial-resources1', 'To gain followers you need to spend common resources. You can see all your resources in the status window on the left.' ],
      [ null, 'There are three common resources in the game and one special. ' + UI.powerName(0) + ', ' + UI.powerName(1) + ' and ' + UI.powerName(2) + ' are common resources and are used directly to gain new followers.' ],
      [ null, 'You can convert any common resource to another one at a 2:1 ratio. There is also a special resource - ' + UI.powerName(3) + '. You will need ' + UI.powerName(3) + ' for rituals and you can convert them to common resources at a 1:1 ratio.' ],
      [ 'tutorial-resources-gen', 'Common resources are produced by special "generator" followers. They have a thicker outline around their icons on the map. ' + UI.powerName(3) + ' are obtained by your neophytes.' ],
      [ 'tutorial-followers-origin', 'Your cult origin is a generator. The tooltip for the follower icon shows its information including the resource it generates. On each new turn, all your generators will produce resources.' ],
      [ 'tutorial-resources-capture', 'The resource icon on top of the map icon shows which resource you need to gain that follower. Try to gain a new follower by clicking on their icon. If you do not have enough resources of that type, convert them.' ],
    ],

    'gainNode' => [
      [ 'tutorial-followers-map', 'Each time you gain a new follower, one or more lines will appear from them to adjacent followers.' ],
      [ 'tutorial-followers-map', 'These lines symbolize a direct connection from one follower to another.' ],
      [ 'tutorial-resources-protect', 'Resource generators can be protected by having three separate connections to them from your other followers. Common followers cannot be protected.' ],
      [ 'tutorial-resources-protect-origin', 'Protect your origin by gaining three followers adjacent to it.' ],
    ],

    'originProtected' => [
      [ null, 'Good, your origin is now protected. It means that before your opponents can attack it they will have to first take over the followers around until the origin has less than three connections to it.' ],
      [ null, 'If the cult loses its origin, it will become paralyzed for some time. Try to keep your origin protected.' ],
      [ null, 'Continue expanding your cult.' ],
    ],

    'gainSect' => [
      [ null, 'Oh, joy! One of your followers has gained their own little sect. Sects are very useful to handle menial tasks like gathering information about your opponents.' ],
      [ 'tutorial-sects', 'They can also help you find the next investigator when they inevitably appear and confuse them. You can check out your sects in the sects window.' ],
      [ null, 'By default, the sect tasks are handled automatically with the help of an AI advisor. They grow by themselves and new tasks will appear upon reaching level 2.' ],
      [ null, 'A sect will be disbanded if its puppeteer is lost.' ],
    ],

    'awareness' => [
      [ 'tutorial-awareness', 'Each time you gain a new follower by spending resources, public awareness of your cult rises. You can see it in the status window. ' ],
      [ null, 'The higher it is, the more difficult it is to gain new followers or upgrade them. To lower awareness you need adepts. You can gain adepts by upgrading your neophyte followers in a ritual using ' + UI.powerName(3) + '.' ],
      [ 'tutorial-upgrade1', 'Upgrading is done by pressing the + button near the neophytes amount in the status window. The upgrade button becomes active if you have at least 3 neophytes and 1 virgin.' ],
      [ null, 'Try to gain an adept.' ],
    ],

    'gainAdept' => [
      [ null, 'You have gained your first adept. You can now spend common resources to lower public awareness. Any single adept can only be used once per turn to do it.' ],
      [ 'tutorial-adept-use', 'To use an adept, click on A button near the common resource name in the status window on the left.' ],
      [ null, "Coincidentally, you've opened yourself up to the potential investigators. There's a chance that an intrepid investigator will learn about the existence of your cult." ],
      [ null, 'To minimize that chance, keep the awareness low.' ],
    ],

    'investigator' => [
      [ 'tutorial-cults', "Oh, my. It looks like you've gained the attention of one of those pesky little investigators. You can see the investigator information in the cults window." ],
      [ null, 'The investigator has a level and willpower. Each turn they will try to attack the number of your followers equal to their level.' ],
      [ null, "The investigator's willpower is their desire to work against your cult. You need to lower it to zero as quickly as possible. When it goes down to zero, they disappear." ],
      [ 'tutorial-inv', 'However, currently, the investigator is hidden and you cannot attack them. One of your sects is working on finding them.' ],
      [ null, 'In the meantime try to keep awareness close to zero. That will help with protecting your followers from investigator attacks.' ],
    ],

    'investigatorFound' => [
      [ null, 'One of your sects has managed to find out where the investigator is hiding.' ],
      [ 'tutorial-inv-attack', 'Now your adepts can use common resources to lower their willpower. Use the W button near the resource name.' ],
      [ null, 'You do have multiple adepts, right?' ],
    ],

    'investigatorDead' => [
      [ null, 'Finally. The investigator has lost the will to go on fighting and is out of the cosmic equation. You are free to continue.' ],
      [ null, 'That is, until the next one appears. But we already know how to deal with them, correct?' ],
    ],

    'sectLevel2' => [
      [ null, 'One of your sects has managed to grow up to level 2. Now it will try to sabotage the rituals of your opponents when necessary. And it can be sacrificed to stop an investigator or harvested for resources.' ],
      [ 'tutorial-sacrifice', 'Sacrificing the sect to stop an investigator will significantly reduce their willpower but will destroy the sect in the process.' ],
      [ 'tutorial-harvest', "Harvesting the sect is also a one-time operation. In this case, your cult will acquire a stash of resources instead." ],
      [ null, "Not to worry, the puppeteer will create a new sect to replace the old one. And, of course, you can leave it alone, but where's the fun in that?" ],
    ],

    'discoverCult' => [
      [ null, "You have discovered one of the other cults I've been talking about. They are ruthless, psychopathic and willing to bring the end of the world as we know it. Just like you are." ],
      [ null, 'Your sects will first automatically gather information about the cult size and then will go on to research every new cult follower you uncover.' ],
      [ null, 'Leave your sects to gather information and plan for eventual hostilities. After all, only one cult will be the one to lead the Earth into a glorious new age (hopefully, yours).' ],
    ],

    'discoverCultNoSects' => [
      [ null, "You have discovered one of the other cults I've been talking about. They are ruthless, psychopathic and willing to bring the end of the world as we know it. Just like you are." ],
      [ null, 'You cannot get any information about other cults unless you have sects. They will automatically gather information about the cult size and then will go on to research every new cult follower you uncover.' ],
      [ null, 'Expand carefully to at least 4 followers to get a sect and plan for eventual hostilities. After all, only one cult will be the one to lead the Earth into a glorious new age (hopefully, yours).' ],
    ],

    'cultParalyzed' => [
      [ null, 'Tsk, tsk, tsk. It seems that your cult has lost its origin before I could teach you the basics of world domination. The Elder God will be very disappointed.' ],
      [ null, 'You cannot gain any new followers while your cult is paralyzed. Wait for now and reflect on what went wrong. If your cult manages to survive for some time, you will gain a new origin.' ],
    ],

    'gain3Adepts' => [
      [ 'tutorial-3adepts', 'You have 3 adepts now. That and 2 ' + UI.powerName(3) + ' are enough to upgrade one of them into a priest. Whether to do that right now is up to you, of course, but only priests can perform rituals.' ],
      [ null, 'You will need 3 priests and a sizable amount of ' + UI.powerName(3) + ' to start summoning the Elder God. If the summoning is a success, you will win the game.' ],
    ],

    'gainPriest' => [
      [ 'tutorial-priest', 'Praise the Elder God! You have a priest now. A single priest and 5 ' + UI.powerName(3) + ' is enough to perform the ritual of Unveiling. This ritual will show where all other cult origins are located on the map.' ],
      [ null, 'During the ritual, each priest contributes a point to its execution every turn. You need a fixed amount of points to finish the ritual. That means the more priests you have, the quicker you will complete it.' ],
      [ 'tutorial-ritual', 'You can see the ritual progress in the cults information window.' ],
      [ null, "Don't forget that public awareness lowers the chance of success. It's a good idea to keep it low for the moment when the ritual finishes." ],
    ],

    'enemyFinalRitual' => [
      [ null, 'Oh, bother. One of your enemies has started performing their Final Ritual. If they are successful, you will lose the game.' ],
      [ null, "If you have any sects of level 2 and higher, they are already focused on sabotaging it (unless they're busy with the investigator)." ],
      [ null, 'To stall the ritual even more, you can try to convert their priests if you see them on the map. If the enemy cult loses its origin, the ritual will be stopped completely.' ],
    ],
  ];
}
