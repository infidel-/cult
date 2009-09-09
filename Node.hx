// node class


class Node
{
  public var power: Array<Dynamic>; // intimidation, persuasion, bribe, worship
  public var powerGenerated: Array<Dynamic>;
  public var marker: Dynamic;
  public var x: Int;
  public var y: Int;
  public var centerX: Int;
  public var centerY: Int;
  public var isOwned: Bool;
  public var isGenerator: Bool;

  public function new(map, newx, newy, index: Int)
    {
      isOwned = false;
	  isGenerator = false;
      power = [0, 0, 0, 0];
	  powerGenerated = [0, 0, 0, 0];
      marker = null;
      
	  x = newx;
      y = newy;
      centerX = x + Math.round(UI.markerWidth / 2);
      centerY = y + Math.round(UI.markerHeight / 2);

      marker = js.Lib.document.createElement("map.node" + index);
	  marker.node = this;
	  marker.style.innerHTML = ' ';
	  marker.style.background = '#222';
	  marker.style.border = '1px solid #777';
	  marker.style.width = UI.markerWidth;
	  marker.style.height = UI.markerHeight;
	  marker.style.position = 'absolute';
	  marker.style.left = x;
	  marker.style.top = y;
	  marker.style.visibility = 'hidden';
	  marker.style.textAlign = 'center';
	  marker.style.fontWeight = 'bold';
//      marker.style.fontSize = '14px';
	  marker.style.zIndex = 20;
	  marker.style.cursor = 'pointer';
	  map.appendChild(marker);
    }


// update node display
  public function update()
    {
      var s = "";
      for (i in 0...4)
        if (power[i] > 0)
		  {
            s += "<b style='color:" + Game.powerColors[i] + "'>" +
              Game.powerNames[i] + "</b> " + power[i] + "<br>";
			marker.innerHTML = Game.powerShortNames[i];
            marker.style.color = Game.powerColors[i];
		  }

	  marker.style.background = '#111';
      if (isOwned)
        marker.style.background = '#555';
	  if (isGenerator)
		{
		  marker.style.border = '3px solid #aaa';
		  s += "<br>Generates:<br>";
	      for (i in 0...4)
     	    if (powerGenerated[i] > 0)
          	  s += "<b style='color:" + Game.powerColors[i] + "'>" +
                Game.powerNames[i] + "</b> " +
			    powerGenerated[i] + "<br>";
		}

	  marker.title = s;
    }


// calculate distance between this node and the other one
  public function distance(node: Node): Float
    {
      return Math.sqrt((node.x - x) * (node.x - x) +
        (node.y - y) * (node.y - y));
    }


// set/unset generator flag
  public function setGenerator(isgen: Bool)
    {
	  isGenerator = isgen;
	  update();
	}


// set owned flag
  public function setOwned(isown: Bool)
    {
      isOwned = isown;
      update();
    }
}
