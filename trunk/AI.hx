// ai class

class AI extends Player
{
  public function new(gvar, uivar, id)
    {
      super(gvar, uivar, id);
      isAI = true;
    }


// ai entry point
  function aiTurn()
    {
      // TODO real AI: loop over nodes getting all interesting targets
      // that can be conquered
      // then sort targets by priority like this :
      // owned node by cult in war with this one
      // free generator -> 
      // free node -> 
      // owned generator with < 3 links ->
      // owned node ->
      // free but need to convert -> 
      // owned but need to convert

      // try to upgrade followers
      aiUpgradeFollowers();

      // try to lower awareness
      aiLowerAwareness();

      // try to summon
      aiSummon();

      // loop over visible nodes activating them one by one
      for (node in game.nodes)
        {
          if (node.owner == this || !node.isVisible(this))
            continue;

          // try to activate and get result
          var ret = activate(node);
          if (ret == "ok")
            continue;

          // check if player can convert resources for a try
          if (ret == "notEnoughPower")
            aiActivateNodeByConvert(node);

          // node is a generator with links, should try to cut them
          else if (ret == "hasLinks")
            1;
        }
    }


// try to upgrade followers
  function aiUpgradeFollowers()
    {
      if (virgins == 0)
        return;

      // aim for 5 adepts, try only when chance > 70%
      if (adepts < 5 && getUpgradeChance(0) > 70 && virgins > 0)
        {
//          if (Game.debugAI)
//            trace(name + " virgins: " + virgins);
          // spend all virgins on upgrades
          while (true)
            {
              if (virgins < 1 || adepts >= 5)
                break;
              upgrade(0);

              if (Game.debugAI)
                trace(name + " upgrade neophyte, adepts: " + adepts);
            }
          return;
        }

      // aim for 3 priests, try only when chance > 60%
      if (priests < 3 && getUpgradeChance(1) > 60 && virgins > 1)
        {
          // spend all virgins on upgrades
          while (true)
            {
              if (virgins < 2 || priests >= 3)
                break;
              upgrade(1);

              if (Game.debugAI)
                trace("!!! " + name + " upgrade adept, priests: " + priests);
            }
          return;
        }
    }


// try to lower awareness
  function aiLowerAwareness()
    {
      if (awareness < 10 || adepts == 0)
        return;
  
      var prevAwareness = awareness;

      // spend all we have
      for (i in 0...Game.numPowers)
        while (power[i] > 0 && adeptsUsed < adepts && awareness >= 10)
          lowerAwareness(i);

      if (Game.debugAI && awareness != prevAwareness)
        trace(name + " awareness " + prevAwareness + "% -> " + awareness + "%");
    }


// try to summon elder god
  public function aiSummon()
    {
      if (priests < 3 || virgins < 9 && getUpgradeChance(2) > 60)
        return;

      if (Game.debugAI)
        trace(name + " TRY SUMMON!");

      summon();
    }


// try to activate node by converting resources
  public function aiActivateNodeByConvert(node: Node)
    {
      // check for resources (1 res max assumed)
      var resNeed = -1;
	  for (i in 0...Game.numPowers)
		if (power[i] < node.power[i])
          resNeed = i;

      // check if we can convert resources
      // resources are not pooled and virgins are not spent
      var resConv = -1;
      for (i in 0...Game.numPowers)
        if (i != resNeed)
          if (Std.int(power[i] / Game.powerConversionCost[i]) >
              node.power[resNeed])
            resConv = i;

      // no suitable resource found
      if (resConv < 0)
        return;

      for (i in 0...node.power[resNeed])
        convert(resConv, resNeed);

      activate(node);
    }
}
