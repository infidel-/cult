// sect tasks advisor

package sects;

class Advisor
{
  var game: Game;

  public function new(g: Game)
    {
      game = g;
    }


// helper: check if cult has any sect on this task
  function cultHasSectOnTask(cult: Cult, id: String, ?target: Dynamic): Bool
    {
      for (s in cult.sects)
        if (s.task != null && s.task.id == id && s.taskTarget == target)
          return true;
      return false;
    }


// helper: find best sect for task
  function findBestSectForTask(cult: Cult, id: String,
      taskVeryImportant: Bool): Sect
    {
      // get task info
      var task = null;
      for (t in game.sectTasks)
        if (t.id == id)
          {
            task = t;
            break;
          }
    
      // first pass - find any sect that can do task in 1 turn and largest sect
      var largestSect = null;
      var largestSize = 0;
      var minimalSect = null;
      var minimalSize = 10000;
      for (s in cult.sects)
        {
          if (!s.isAdvisor)
            continue;

          if (s.taskImportant && !taskVeryImportant)
            continue;

          // minimal sect that can do task in 1 turn
          if (s.size >= task.points && s.size < minimalSize)
            {
              minimalSect = s;
              minimalSize = s.size;
            }

          // largest sect
          if (s.size > largestSize)
            {
              largestSect = s;
              largestSize = s.size;
            }
        }

      // we have a sect that can do task in 1 turn
      if (minimalSect != null)
        return minimalSect;

      return largestSect;
    }


// run advisor
  public function run(cult: Cult)
    {
      // cult has no sects
      if (cult.sects.length == 0)
        return;

      // cult has hidden investigator
      if (cult.hasInvestigator && cult.investigator.isHidden)
        {
          // check if any sect is on the task to find it
          if (!cultHasSectOnTask(cult, 'invSearch'))
            {
              var s = findBestSectForTask(cult, 'invSearch', true);
              if (s == null)
                return;
              s.setTaskByID('invSearch');
              s.taskImportant = true;
            }
        }

      // cult has known investigator
      else if (cult.hasInvestigator)
        {
          for (s in cult.sects)
            if ((s.task == null || s.task.id != 'invConfuse') &&
                s.isAdvisor)
              {
                s.setTaskByID('invConfuse');
                s.taskImportant = true;
              }

          return;
        }

      // sabotage ritual (focus on one if multiple)
      var ritualCult = null;
      for (c in game.cults)
        if (c != cult && c.isRitual && c.ritual.id == 'summoning')
          {
            ritualCult = c;
            break;
          }
      if (ritualCult != null)
        {
          for (s in cult.sects)
            if ((s.task == null || !s.taskImportant) &&
                s.isAdvisor && s.level >= 1)
              {
                s.setTaskByID('cultSabotageRitual', ritualCult);
                s.taskImportant = true;
              }
        }

      // check if all cults info is known
      for (c2 in game.cults)
        {
          if (c2 == cult ||
              !c2.isDiscovered[cult.id] ||
              c2.isInfoKnown[cult.id])
            continue;

          // check if some sect is on that task
          if (cultHasSectOnTask(cult, 'cultGeneralInfo'))
            continue;

          // info unknown, set some sect on task
          var s = findBestSectForTask(cult, 'cultGeneralInfo', false);
          if (s == null)
            break;
//          trace('setTaskByID ' + c2.name);
          s.setTaskByID('cultGeneralInfo');
          s.taskImportant = true;
        }

      // default task - node info on random cult
      for (s in cult.sects)
        if ((s.task == null || !s.taskImportant) && s.isAdvisor)
          s.setTaskByID('cultNodeInfo');
    }
}
