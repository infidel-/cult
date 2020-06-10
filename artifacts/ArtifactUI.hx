package artifacts;

class ArtifactUI
{
  var game: Game;
  var ui: UI;

  public function new(g: Game, uivar: UI)
    {
      game = g;
      ui = uivar;
    }

// artifacts info in cult info window
  public function getInfoString(cult: Cult): String
    {
      var s = new StringBuf();

      s.add('Artifacts: ');
      if (cult.artifacts.length == 0)
        s.add('None');
      else
        {
          var list = cult.artifacts.list();
          for (i in 0...list.length)
            {
              var a = list[i];
              s.add(a.name + " <span class=shadow style='color:white'>L" + a.level + '</span>');
              if (a.node != null)
                s.add(' (' + a.node.name + ')');
              if (i < cult.artifacts.length - 1)
                s.add(', ');
            }
        }
      s.add('<br>');

      return s.toString();
    }
}
