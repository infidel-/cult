// sect class

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
  public var task: SectTaskInfo; // task info id
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
      name = leader.name + "' Sect";
    }


// set task
  public function setTask(id: Int, target: Dynamic)
    {
      task = Sect.availableTasks[id];
      taskPoints = 0;
      taskTarget = target;
    }


// act on current task - called on each new turn
  public function turn()
    {
      // sect growth
      size++;
      var oldlevel = level;
      if (size < 100)
        level = 0;
      else if (size < 500)
        level = 1;
      else if (size < 1000)
        level = 2;

      if (level != oldlevel && !cult.isAI)
        ui.log2('cult', cult, name + ' has gained a new level.');

      if (task == null) // no task
        return;

      taskPoints += size; // gain some points
      if (taskPoints < task.points)
        return;

      // call task finish handler
      var method = Reflect.field(this, task.id);
      if (method != null)
        Reflect.callMethod(this, method, []);
//      if (task.id == 'gatherCultInfo')
//        gatherCultInfo();

      // clean task on finish
      if (!task.isInfinite)
        {
          task = null;
          taskTarget = null;
          taskPoints = 0;
        }
    }


// act - gather cult information
  function gatherCultInfo()
    {
      var c:Cult = taskTarget;
      c.isInfoKnown = true;

      if (!cult.isAI)
        ui.log2('cult', cult, 'Task completed: Information about ' + c.fullName + ' gathered.');

      for (n in c.nodes)
        if (n.isVisible(c))
          n.update();
    }


// act - search for investigator
  function searchInv()
    {
      if (cult.investigator == null || !cult.investigator.isHidden)
        return;

      cult.investigator.isHidden = false;

      if (!cult.isAI)
        ui.log2('cult', cult, 'Task completed: Investigator found.');
    }


// is this task available?
  public function taskAvailable(t: SectTaskInfo): Bool
    {
      if (t.target == 'investigator' && !cult.hasInvestigator)
        return false;

      if (t.id == 'gatherCultInfo') // gather cult information
        {
          var isEmpty = true;
          for (c in game.cults)
            {
              if (c == game.player || !c.isDiscovered || c.isInfoKnown)
                 continue;

              isEmpty = false;
            }

          return !isEmpty;
        }
      else if (t.id == 'searchInv') // search for investigator
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

  public static var availableTasks: Array<SectTaskInfo> =
    [
      {
        id: 'gatherCultInfo',
        name: 'Gather cult information',
        target: 'cult',
        isInfinite: false,
        points: 30,
      },

  // find cult origin - search through visible!
  // find cult generators - search through visible!
  // ? find cult follower levels - search through visible

      {
        id: 'searchInv',
        name: 'Search for investigator',
        target: 'investigator',
        isInfinite: false,
        points: 50,
      },

      {
        id: 'confuseInv',
        name: 'Confuse investigator',
        target: 'investigator',
        isInfinite: true,
        points: 0,
      },
    ];
}


// sect task info
typedef SectTaskInfo =
  {
    var id: String; // task string id
    var target: String; // task target (for ui)
    var name: String; // task name
    var points: Int; // amount of points needed to complete (0: complete on next turn)
    var isInfinite: Bool; // is task neverending?
  };

