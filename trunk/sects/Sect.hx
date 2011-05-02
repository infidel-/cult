// sect class

package sects;

import Static;

class Sect
{
  var game: Game;
  var ui: UI;

  public var name: String; // sect name
  public var leader: Node; // sect leader
  var cult: Cult; // parent cult
  public var size: Int; // sect size
  public var level: Int; // sect level (0-2)

  // current task
  public var task: Task; // task info id
  public var taskPoints: Int; // points to completion
  public var taskTarget: Dynamic; // task target

  public function new(g: Game, uivar: UI, l: Node, c: Cult)
    {
      game = g;
      ui = uivar;
      leader = l;
      cult = c;
      taskPoints = 0;
      size = 10;
      if (l.level == 1)
        size = 50;
      else if (l.level == 2)
        size = 90;
      level = 0;

      // generate a silly name
      var rnd = 4 + Std.int(Math.random() * 4);
      var rnd2 = 3 + Std.int(Math.random() * 4);
      var rnd3 = Std.int(Math.random() * names.length);
      name = leader.name.substr(0, rnd) +
        leader.name.substr(leader.name.indexOf(' '), rnd2) + ' ' +
        names[rnd3];
    }


// set task
  public function setTask(newTask: Task, target: Dynamic)
    {
      task = newTask;
      taskPoints = 0;
      taskTarget = target;
    }


// clear current task
  public function clearTask()
    {
      task = null;
      taskTarget = null;
      taskPoints = 0;
    }


  public function getGrowth(): Int
    {
      return 1 + Std.int(size / 10);
    }


// act on current task - called on each new turn
  public function turn()
    {
      // sect growth
      size += getGrowth();
      var oldlevel = level;
      if (size < 100)
        level = 0;
      else if (size < 250)
        level = 1;
      else if (size < 500)
        level = 2;

      if (level != oldlevel && !cult.isAI)
        ui.log2('cult', cult, name + ' has gained a new level.');

      if (task == null) // no task
        return;

      taskPoints += size; // gain some points
      if (taskPoints < task.points)
        return;

      task.complete(game, ui, cult, this, taskPoints);

      // clean task on finish
      if (!task.isInfinite)
        clearTask();
    }


// act - cult resource gain information
  function cultResourceGainInfo(points: Int)
    {
      var c:Cult = taskTarget;

      if (!cult.isAI)
        ui.log2('cult', cult,
          'Task completed: ' + c.fullName + ' max production - ' +
          c.powerMod[0] + ' ' + UI.powerName(0) + ', ' +
          c.powerMod[1] + ' ' + UI.powerName(1) + ', ' +
          c.powerMod[2] + ' ' + UI.powerName(2) + ', ' +
          c.powerMod[3] + ' ' + UI.powerName(3) + '.');
    }


// act - gather visible node information
  function gatherNodeInfo(points: Int)
    {
      var c:Cult = taskTarget;

      var cnt = 0;
      for (n in c.nodes)
        if (n.isVisible(cult) && !n.isKnown)
          {
            cnt += 10; // 10 points per node
            if (cnt >= points)
              break;

            n.isKnown = true;
            n.update();

          }
    }


// act - sabotage ritual
  function cultSabotageRitual(points: Int)
    {
      var c:Cult = taskTarget;

      if (!c.isRitual)
        return;

      var cnt = 0;
      var pts = 0;
      while (true)
        {
          cnt += 100; // 100 points per try
          if (cnt >= points)
            break;

          if (Math.random() * 100 > 70) // chance of success
            continue;

          c.ritualPoints += 1;
          pts += 1;
        }

      if (pts > 0 && !cult.isAI)
        ui.log2('cult', cult, 'Ritual of ' + c.fullName + ' stalled for ' +
          pts + ' points.');
    }


// act - search for investigator
  function searchInv(points: Int)
    {
      if (cult.investigator == null || !cult.investigator.isHidden)
        return;

      cult.investigator.isHidden = false;

      if (!cult.isAI)
        ui.log2('cult', cult, 'Task completed: Investigator found.');
    }


// is this task available?
  public function taskAvailable(t: Task): Bool
    {
      if (t.id == 'searchInv') // search for investigator
        {
          if (!cult.investigator.isHidden)
            return false;
        }
      else if (t.id == 'confuseInv') // confuse investigator
        {
          if (cult.investigator.isHidden)
            return false;
        }

      return true;
    }


// ======================= Sect Tasks ============================
  public static var taskClasses: Array<Dynamic> = [ CultGeneralInfoTask, CultResourceInfoTask ];

/*    
  public static var availableTasks: Array<SectTaskInfo> =
    [

      {
        id: 'cultResourceGainInfo',
        name: 'Cult resource gains',
        target: 'cult',
        minLevel: 0,
        isInfinite: false,
        points: 30,
      },

      {
        id: 'gatherNodeInfo',
        name: 'Cult nodes',
        target: 'cult',
        minLevel: 0,
        isInfinite: true,
        points: 0,
      },
  // find cult origin - search through visible!
  // find cult generators - search through visible!

      {
        id: 'searchInv',
        name: 'Search for investigator',
        target: 'investigator',
        minLevel: 0,
        isInfinite: false,
        points: 50,
      },

      {
        id: 'confuseInv',
        name: 'Confuse investigator',
        target: 'investigator',
        minLevel: 0,
        isInfinite: true,
        points: 0,
      },

// ================== level 2 =================

      {
        id: 'cultSabotageRitual',
        name: 'Sabotage ritual',
        target: 'cult',
        minLevel: 1,
        isInfinite: true,
        points: 0,
      },
    ];
*/

  static var names0 = [ 'Open', 'Free', 'Rising', 'Strong' ];
  static var names = [ 'Way', 'Path', 'Society', 'Group', 'School', 'Faith', 'Mind', 
    'Love', 'Care', 'Reform', 'State', 'Sun', 'Moon', 'Wisdom' ];
}
