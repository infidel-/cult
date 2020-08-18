// sect class

package sects;

import Static;
import _SaveGame;

class Sect
{
  var game: Game;
  var ui: UI;

  public var id: Int; // unique sect id
  public var name: String; // sect name
  public var leader: Node; // sect leader
  public var cult: Cult; // parent cult
  public var size: Int; // sect size
  public var level: Int; // sect level (0-2)
  public var isAdvisor: Bool; // controlled by advisor?
  public var isDevoted: Bool; // sect is currently devoted?

  // current task
  public var task: Task; // task info
  public var taskPoints: Int; // points to completion
  public var taskTarget: Dynamic; // task target
  public var taskImportant: Bool; // task is important (for sect advisor)

  // sect powers
  public var powerID: Int; // DEVOTED: power to buff with
  public var powerStorage: Int; // DEVOTED: power storage

  public function new(g: Game, uivar: UI, l: Node, c: Cult)
    {
      game = g;
      ui = uivar;
      id = (lastSectID++);
      leader = l;
      cult = c;
      taskPoints = 0;
      taskImportant = false;
      size = 10;
      level = 0;
      powerID = 0;
      powerStorage = 0;

      name = generateName();

      isAdvisor = game.options.getBool('sectAdvisor');
      isDevoted = false;
    }


// generate random name
  function generateName(): String
    {
      var patterns = [
        [ '0', ' ', '1' ],
        [ '0', ' ', '2' ],
        [ '1', ' of ', '2' ],
        [ '0', ' ', '1', ' of ', '2' ],
      ];

      // generate a silly name
      var pattern = patterns[Std.random(patterns.length)];
      var buf = new StringBuf();
      for (x in pattern)
        {
          var arr = null;
          if (x == '0')
            arr = names0;
          else if (x == '1')
            arr = names1;
          else if (x == '2')
            arr = names2;
          else
            {
              buf.add(x);
              continue;
            }
          buf.add(arr[Std.random(arr.length)]);
        }
      return buf.toString();

/*
      // generate a silly name
      var rnd = Std.random(100);
      var ret = null;
      if (rnd < 33)
        return names0[Std.random(names0.length)] + ' ' +
          names1[Std.random(names1.length)];
      else if (rnd < 67)
        return names0[Std.random(names0.length)] + ' ' +
          names2[Std.random(names2.length)];
      else
        {
          var name0 = names1[Std.random(names1.length)];
          var name1 = names0[Std.random(names0.length)];
          var name2 = names2[Std.random(names2.length)];
          return name0 + ' of ' + name1 + ' ' + name2;
        }
/*      
      var rnd3 = Std.int(Math.random() * names.length);
      name = leader.name.substr(0, leader.name.indexOf(' ')) +
        leader.name.substr(leader.name.indexOf(' ') + 1, 1) + ' ' +
        names[rnd3];
*/

      return null;
    }

// set task by string id
  public function setTaskByID(taskID: String, ?target: Dynamic)
    {
      for (t in game.sectTasks)
        if (t.id == taskID)
          {
            setTask(t, target);
            return;
          }
    }


// set task
  public function setTask(newTask: Task, target: Dynamic)
    {
      task = newTask;
      taskPoints = 0;
      taskTarget = target;
//      trace(name + ' setTask ' + newTask.id);
    }


// clear current task
  public function clearTask()
    {
      task = null;
      taskTarget = null;
      taskPoints = 0;
      taskImportant = false;
//      trace('clear! ' + taskImportant);
    }


  public function getMaxSize(): Int
    {
      var maxSize = 100;
      if (leader.level == 1)
        maxSize = 500;
      else if (leader.level == 2)
        maxSize = 1000;
      return maxSize;
    }


  static var growth = [ 12, 8, 6 ];
  public function getGrowth(): Int
    {
      if (size < getMaxSize())
        {
          var val = 1.0 + (1.0 * size / growth[leader.level]);
          // DEVOTED: bonus from devoted
          if (game.flags.devoted && powerStorage >= getPowerPerTurn())
            val *= (100.0 + Const.devotedGrowthBonus) / 100.0;
          // ARTIFACT: bonus from hand
          if (game.flags.artifacts)
            val *= cult.artifacts.getSectGrowthMod(this);
          return Std.int(val);
        }
      else return 0;
    }
/*
OLD:
  19: 103
  36: 540
  // 43: 1059 
x = 10; for (let i = 0; i < 37; i++) { x += 1 + Math.floor(x / 10); console.log(i + ': ' + ); };

NEW (skip 2 to get correct turn):
x = 10; for (let i = 2; i < 37; i++) { x += 1 + Math.floor(x / 8); console.log(i + ': ' + ); };
neophyte (10, x/12):
  25:106
  44:506
  // 53:1047
adept (10, x/8):
  18:106
  31:510
  // 37:1037
priest (10, x/6):
  14:100
  25:557
  // 29:1034
*/


// act on current task - called on each new turn
  public function turn()
    {
      // sect growth
      size += getGrowth();
      if (size > getMaxSize())
        size = getMaxSize();
      var oldlevel = level;
      if (size < 100)
        level = 0;
      else if (size < 500)
        level = 1;
      else if (size < 1000)
        level = 2;
      else level = 2;

      if (level != oldlevel && !cult.isAI)
        {
          ui.log2(cult,
            name + ' has gained a new level (new tasks available!).',
            { type: 'sect', symbol: 's' });
          if (level == 1)
            game.tutorial.play('sectLevel2');
        }

      // DEVOTED: power spend
      if (game.flags.devoted)
        {
          if (powerStorage >= getPowerPerTurn())
            {
              powerStorage -= getPowerPerTurn();
              isDevoted = true;
            }
          else isDevoted = false;
        }

      if (task == null) // no task
        return;

      taskPoints += getSizePoints(); // gain some points
      if (taskPoints < task.points)
        return;

      // complete task - can die (sacrifice)
      task.complete(cult, this, taskPoints);
      taskPoints = 0;
      if (leader == null) // dead
        return;

      // clean task on finish
      if (!task.isInfinite)
        {
          clearTask();

          // check for failure of other tasks
          game.failSectTasks();
        }
    }

// get sect points relative to sect size
  public function getSizePoints()
    {
      var val = size;
      // DEVOTED: task points bonus
      if (isDevoted)
        val = Std.int(val * (100.0 + Const.devotedTaskPointsBonus) / 100.0);
      return val;
    }

// DEVOTED: spend sect power
  public function spendPower()
    {
      if (cult.power[powerID] <= 0)
        return;
      cult.power[powerID]--;
      powerStorage++;
      ui.updateStatus();
    }

// DEVOTED: power spent per turn to receive devoted status
  public inline function getPowerPerTurn(): Int
    {
      return Const.devotedPowerPerTurn[level];
    }

// save info
  public function save(): _SaveSect
    {
      return {
        id: id,
        name: name,
        leader: leader.id,
        cult: cult.id,
        size: size,
        level: level,
        isAdvisor: isAdvisor,
        isDevoted: isDevoted,
        task: task.id,
        taskPoints: taskPoints,
        taskTarget: (taskTarget != null ? taskTarget.id : -1),
        taskImportant: taskImportant,
        powerID: powerID,
        powerStorage: powerStorage,
      };
    }

// load info
  public function load(obj: _SaveSect)
    {
      id = obj.id;
      name = obj.name;
      // NOTE: leader, cult are setup in Cult.hx
      size = obj.size;
      level = obj.level;
      isAdvisor = obj.isAdvisor;
      isDevoted = obj.isDevoted;
      // NOTE: we assume task target is cult
      setTaskByID(obj.task, game.cults[obj.taskTarget]);
      taskPoints = obj.taskPoints;
      taskImportant = obj.taskImportant;
      powerID = obj.powerID;
      powerStorage = obj.powerStorage;
    }

// ======================= Sect Tasks ============================
  public static var taskClasses: Array<Dynamic> = [
    DoNothingTask,
    CultGeneralInfoTask,
    CultNodeInfoTask,
    CultResourceInfoTask,
    CultSabotageRitualTask,
    InvSearchTask,
    InvConfuseTask,
    InvSacrificeTask,
    artifacts.ArtSearchTask,
    HarvestTask,
  ];


  static var names0 = [
    'Absolute',
    'Balanced',
    'Bare',
    'Boundless',
    'Caring',
    'Clear',
    'Eternal',
    'Free',
    'Fresh',
    'Friendly',
    'Gentle',
    'Giving',
    'Happy',
    'Honest',
    'Infinite',
    'Innate',
    'Noble',
    'Open',
    'Peaceful',
    'Perfect',
    'Primordial',
    'Relaxed',
    'Rising',
    'Strong',
    'Spirited',
    'Superior',
    'Surpassing',
    'Tenacious',
    'Transcendent',
    'Unlocked',
    'Yawning',
  ];
  static var names1 = [
    'Gathering',
    'Journey',
    'Movement',
    'Group',
    'Path',
    'Road',
    'School',
    'Society',
    'Teaching',
    'Way',
  ];
  static var names2 = [
    'Ascendance',
    'Advancement',
    'Bliss',
    'Care',
    'Devotion',
    'Embrace',
    'Faith',
    'Energy',
    'Goodness',
    'Joy',
    'Love',
    'Loyalty',
    'Mind',
    'Motion',
    'Moon',
    'Power',
    'Progress',
    'Reform',
    'Stamina',
    'State',
    'Star',
    'Stars',
    'Sun',
    'Vigor',
    'Vitality',
    'Wisdom',
  ];
  static var lastSectID = 0;
}
