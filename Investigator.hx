// cult investigator class

class Investigator
{
  public var cult: Cult; // the cult that investigator knows about
  var ui: UI;
  var numTurn: Int;

  public var name: String;
  public var will: Int; // willpower
  public var level: Int; // investigator level
  public var isHidden: Bool; // is hidden?

  public function new(c: Cult, ui: UI)
    {
      cult = c;
      this.ui = ui;
      level = 0;
      will = 1;
      name = GenName.generate();
      numTurn = 0;
      isHidden = true;
    }


// load info
  public function load(obj: Dynamic)
    {
      name = obj.n;
      will = obj.w;
      level = obj.l;
      isHidden = (obj.h == 1 ? true : false);
    }


// save info
  public function save(): Dynamic
    {
      return {
        n: name,
        w: will,
        l: level,
        h: (isHidden ? 1 : 0)
        };
    }


// investigator's turn
  public function turn()
    {
      // on easy stalls on the first turn, horrified by his revelation
      if (numTurn == 0 && cult.difficulty.level == 0)
        {
          numTurn++;
          return;
        }

      // hidden for X turns after appearance
      if (isHidden && numTurn > cult.difficulty.investigatorTurnVisible)
        {
          ui.log2('cult', cult, cult.fullName + " has found out the investigator's location.");
          isHidden = false;
        }
      if (will >= 9) // becomes hidden again on gaining enough willpower
        isHidden = true;

      numTurn++;

      // destroy random followers
      for (i in 0...(level + 1))
        killFollower();

      // low awareness and no ritual, investigator cannot find out about members
      if (cult.awareness < 5 && !cult.isRitual)
        return;

      // gain willpower
      gainWill();

      // during the summoning investigator can gain 1 more willpower
      if (cult.isRitual && 100 * Math.random() < 30)
        gainWill();
    }


// each turn I has a chance of gaining will
  function gainWill()
    {
      if (100 * Math.random() > getGainWillChance())
        return;

      var oldLevel = level;
      will += 1;
      level = Std.int(will / 3);
      if (level > 2)
        level = 2;
      
      if (level > oldLevel && !cult.isAI)
        ui.log2('cult', cult, "The investigator of " + cult.fullName +
          " has gained level " + (level + 1) + ".");
    }


// each turn I has a chance of destroying a follower of the same or lower level
  function killFollower()
    {
      if (100 * Math.random() > getKillChance())
        return;

      // find a node
      var node: Node = null;
      // get highest level follower
      if (cult.isRitual)
        for (n in cult.nodes)
          {
            if (n.level > level || n.isProtected)
              continue;

            if (node != null && n.level <= node.level)
              continue;

            node = n;
          }
      else
      // get random follower
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

      ui.log2('cult', cult, "The investigator revealed the " + cult.fullName + " follower.");
      node.removeOwner();
      if (node.visibility[0])
        node.setHighlighted(true);
    }


// chance of gaining willpower
  public function getGainWillChance():Int
    {
      var chance = Std.int(70 * cult.difficulty.investigatorGainWill);
      for (sect in cult.sects) // decrease chance with each sect
        if (sect.level == 0)
          chance -= 1;
        else if (sect.level == 1)
          chance -= 2;
        else if (sect.level == 2)
          chance -= 5;
      if (chance < 20)
        chance = 20;
  
      return chance;
    }


// chance of killing follower
  public function getKillChance():Int
    {
      var chance = 0;
      if (cult.awareness <= 5)
        chance = Std.int(20 * cult.difficulty.investigatorKill);
      else if (cult.awareness <= 10)
        chance = Std.int(65 * cult.difficulty.investigatorKill);
      else chance = Std.int(70 * cult.difficulty.investigatorKill);

      for (sect in cult.sects) // decrease chance with each sect
        if (sect.level == 0)
          chance -= 1;
        else if (sect.level == 1)
          chance -= 2;
        else if (sect.level == 2)
          chance -= 5;
      if (chance < 5)
        chance = 5;

      return chance;
    }
}
