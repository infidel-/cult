// cult investigator class

class Investigator
{
  public var cult: Cult; // the cult that investigator knows about
  var ui: UI;
  var numTurn: Int;

  public var will: Int; // willpower
  public var level: Int; // investigator level

  public function new(c: Cult, ui: UI)
    {
      cult = c;
      this.ui = ui;
      level = 0;
      will = 1;
      numTurn = 0;
    }


// investigator's turn
  public function turn()
    {
      // stalls on the first turn, horrified by his revelation
      if (numTurn == 0)
        return;

      // gain willpower
      gainWill();

      // destroy random follower
      killFollower();

      numTurn++;
    }


// each turn I has a chance of gaining will
  function gainWill()
    {
      if (100 * Math.random() > 80)
        return;

      var oldLevel = level;
      will += 1;
      level = Std.int(will / 3);
      
      if (level > oldLevel && !cult.isAI)
        ui.log("The investigator of " + cult.fullName +
          " has gained level " + (level + 1) + ".");
    }


// each turn I has a chance of destroying a follower of the same or lower level
  function killFollower()
    {
      if (100 * Math.random() > 80)
        return;

      // find a node
      var node = null;
      for (n in cult.nodes)
        {
          if (n.level > level || n.isProtected)
            continue;

          node = n;

          if (Math.random() > 0.5)
            break;
        }

      if (node == null)
        return;

      ui.log("The investigator revealed the " + cult.fullName + " follower.");
      node.removeOwner();
    }
}
