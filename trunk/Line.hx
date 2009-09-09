// line drawing class

import js.Lib;

class Line
{
  public var startNode: Dynamic;
  public var endNode: Dynamic;
  public var pixels: Array<Dynamic>;


  function new()
	{
	  this.pixels = new Array<Dynamic>();
	}


// make a new line on screen
  public static function paint(screen, startNode, endNode): Dynamic
	{
	  var line = new Line();
	  line.startNode = startNode;
	  line.endNode = endNode;

	  var x: Float = startNode.centerX, y: Float = startNode.centerY;
      var modx = (endNode.centerX - startNode.centerX) / 10,
        mody = (endNode.centerY - startNode.centerY) / 10;

      for (i in 1...10)
        {
		  x += modx;
		  y += mody;

          var pixel = js.Lib.document.createElement("pixel");
		  pixel.style.position = 'absolute';
		  pixel.style.left = Math.round(x) + 'px';
		  pixel.style.top = Math.round(y) + 'px';
		  pixel.style.width = '2';
		  pixel.style.height = '2';
		  pixel.style.background = '#55dd55';
          pixel.style.zIndex = 10;
		  screen.appendChild(pixel);

		  line.pixels.push(pixel);
        }
	}
}

