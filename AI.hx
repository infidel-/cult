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
      // free generator -> free node -> owned generator -> owned node
      // --> free but need to convert -> owned but need to convert

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
            activateNodeByConvert(node);

//          else if (ret == "failure")
//            ;
        }
    }


// try to activate node by converting resources
  public function activateNodeByConvert(node: Node)
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
