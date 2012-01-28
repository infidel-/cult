// sect class

package sects;

import Static;

class Sect
{
  var game: Game;
  var ui: UI;

  public var name: String; // sect name
  public var leader: Node; // sect leader
  public var cult: Cult; // parent cult
  public var size: Int; // sect size
  public var level: Int; // sect level (0-2)

  // current task
  public var task: Task; // task info id
  public var taskPoints: Int; // points to completion
  public var taskTarget: Dynamic; // task target
  public var taskImportant: Bool; // task is important (for sect advisor)

  public function new(g: Game, uivar: UI, l: Node, c: Cult)
    {
      game = g;
      ui = uivar;
      leader = l;
      cult = c;
      taskPoints = 0;
      taskImportant = false;
      size = 10;
      if (l.level == 1)
        size = 50;
      else if (l.level == 2)
        size = 90;
      level = 0;

      // generate a silly name
/*      
      var rnd = 4 + Std.int(Math.random() * 4);
      var rnd2 = 3 + Std.int(Math.random() * 4);
      var rnd3 = Std.int(Math.random() * names.length);
      name = leader.name.substr(0, rnd) +
        leader.name.substr(leader.name.indexOf(' '), rnd2) + ' ' +
        names[rnd3];
*/
      var rnd3 = Std.int(Math.random() * names.length);
      name = leader.name.substr(0, leader.name.indexOf(' ')) +
        leader.name.substr(leader.name.indexOf(' ') + 1, 1) + ' ' +
        names[rnd3];
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
//      trace('setTask ' + newTask.id);
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


  public function getGrowth(): Int
    {
      if (size < getMaxSize())
        return 1 + Std.int(size / 10);
      else return 0;
    }


// act on current task - called on each new turn
  public function turn()
    {
      // sect growth
      size += getGrowth();
      var oldlevel = level;
      if (size < 100)
        level = 0;
      else if (size < 500)
        level = 1;
      else if (size < 1000)
        level = 2;
      else level = 2;

      if (level != oldlevel && !cult.isAI)
        ui.log2(cult, name + ' has gained a new level.',
          { type: 'sect' });

      if (task == null) // no task
        return;

      taskPoints += size; // gain some points
      if (taskPoints < task.points)
        return;

      task.complete(game, ui, cult, this, taskPoints);
      taskPoints = 0;

      // clean task on finish
      if (!task.isInfinite)
        {
          clearTask();

          // check for failure of other tasks
          game.failSectTasks();
        }
    }


// ======================= Sect Tasks ============================
  public static var taskClasses: Array<Dynamic> =
    [ 
      DoNothingTask,
      CultGeneralInfoTask, CultNodeInfoTask,
      CultResourceInfoTask, CultSabotageRitualTask,
      InvSearchTask, InvConfuseTask,
    ];


  static var names0 = [ 'Open', 'Free', 'Rising', 'Strong' ];
  static var names = [ 'Way', 'Path', 'Society', 'Group', 'School', 'Faith', 'Mind', 
    'Love', 'Care', 'Reform', 'State', 'Sun', 'Moon', 'Wisdom' ];
}
