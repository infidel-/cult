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
    
      if (Math.random() > 0.5)
        return;

      if (cult.maxVirgins() < 1)
        return;
//      cult.virgins++;

//      debug('give virgins to ' + cult.name);
    }


// helper: determine weakest cult
  function findWeakestCult()
    {
      var cult = null;
      var cultPower = 10000;
      for (c in game.cults)
        if (c.nodes.length < cultPower)
          {
            cult = c;
            cultPower = c.nodes.length;
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
