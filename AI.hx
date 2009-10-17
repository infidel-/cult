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
      // try to upgrade followers
      aiUpgradeFollowers();

      // try to lower awareness
      aiLowerAwareness();

      // try to summon
      aiSummon();

      // TODO: possibly a point-based weighted prioritization is better
      // and more readable. It also raises thoughts about current AI
      // "mood". Is it in an aggressive mood? +1 for any owned node
      // Is it in a war rage? +1 for any enemy node
      // give/take a point for each node attribute, storing the result

      // loop over visible nodes making a target list with priority
      var list = new Array<Dynamic>();
      for (node in game.nodes)
        {
          if (node.owner == this || !node.isVisible(this))
            continue;

          var item = { node: node, priority: 0 };

          // save priority of this node
          // unprotected enemy generator
          if (node.owner != null && wars[node.owner.id] &&
              canActivate(node) && node.isGenerator && !node.isProtected)
            item.priority = 120;

          // gainable enemy node 
          else if (node.owner != null && wars[node.owner.id] &&
              canActivate(node))
            item.priority = 110;

          // enemy node
          else if (node.owner != null && wars[node.owner.id])
            item.priority = 100;

          // gainable generator
          else if (node.owner == null && node.isGenerator &&
              canActivate(node))
            item.priority = 90;

          // owned gainable generator (yum-yum!)
          else if (node.owner != null && canActivate(node) &&
              node.isGenerator && !node.isProtected)
            item.priority = 80;

          // free node
          else if (node.owner == null && canActivate(node))
            item.priority = 70;

          // owned node
          else if (node.owner != null && canActivate(node) &&
              !node.isProtected)
            item.priority = 60;

          // free but need to convert
          else if (node.owner == null && !canActivate(node))
            item.priority = 50;

          // owned but need to convert and everything else
          else if (node.owner != null && !canActivate(node))
            item.priority = 40;

          // not interesting in everything else
          else continue; 

          list.push(item);
        }

      // sort target list by priority descending
      list.sort(function(x, y) {
        if (x.priority == y.priority)
          return 0;
        else if (x.priority > y.priority)
          return -1;
        else return 1;
        });

//      for (l in list)
//        trace(id + " " + l.priority + " " + l.node.id);

      // loop over target list activating it one by one
      for (item in list)
        {
          var node = item.node;

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
