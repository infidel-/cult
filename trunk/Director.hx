// AI director

class Director
{
  var game: Game;
  var ui: UI;


  public function new(g: Game, vui: UI)
    {
      game = g;
      ui = vui;
    }


// entry point: director turn
  public function turn()
    {
      if (game.turns < 5) // too soon
        return;

      // find weakest cult
      var cult = findWeakestCult();
    
      giveVirgins(cult);
      doubleGenerators(cult);
    }
  

// give virgins to the cult
  function giveVirgins(cult: Cult)
    {
      if (Math.random() > 0.3)
        return;

      if (cult.maxVirgins() < 1)
        return;

      var n = 1 + Std.int(Math.random() * 2);
      cult.virgins += 2;

      debug('give ' + n + ' virgins to ' + cult.name);
    }


// give resources from generators to the cult
  function doubleGenerators(cult: Cult)
    {
      if (Math.random() > 0.3)
        return;

      var power = [0, 0, 0];

      // each generator has a chance of gaining more resources
      for (node in cult.nodes)
        {
          if (!node.isGenerator)
            continue;

//          if (Math.random() > 0.75)
//            continue;

          // add some power to the pool
          for (i in 0...Game.numPowers)
            if (node.powerGenerated[i] > 0)
              {
                power[i] += node.powerGenerated[i];

                if (Math.random() < 0.1)
                  power[i] += node.powerGenerated[i];
              }
        }

      for (i in 0...Game.numPowers)
        cult.power[i] += power[i];

      debug('give ' + power + ' to ' + cult.name);
    }


// helper: determine cult power
  public function getCultPower(cult: Cult): Int
    {
      var power = 0;
      for (node in cult.nodes)
        {
          power++;
          if (node.isGenerator)
            power++;
        }

      for (p in cult.power)
        power += p;

      return power;
    }

// helper: determine weakest cult
  function findWeakestCult()
    {
      var cult = null;
      var cultPower = 10000;
      for (c in game.cults)
        {
          if (c.isDead)
            continue;
          if (getCultPower(c) < cultPower)
            {
              cult = c;
              cultPower = getCultPower(c);
            }
        }

      return cult;
    }


  inline function debug(s: String)
    {
      if (Game.debugDirector)
        trace(s);
//        trace("<span style='color:purple'>" + s + '</span>');
    }
}
