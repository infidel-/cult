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
              s.add(
                "<span class=shadow style='color:var(--artifact-color)' id=info.artifact" + cult.id + '_' + i +
                " title='" + a.info.name + "'>" +
                  a.name + '</span>' +
                " <span class=shadow style='color:white'>L" + a.level + '</span>');
              if (a.node != null)
                s.add(' (' + a.node.name + ')');
              if (i < cult.artifacts.length - 1)
                s.add(', ');
            }
        }
      s.add('<br>');

      return s.toString();
    }

// update cult info tooltips
  public function updateCultInfo(cult: Cult)
    {
      var list = cult.artifacts.list();
      for (i in 0...list.length)
        {
          var a = list[i];
          var note =
            "<span class=shadow style='color:var(--artifact-color)'>" + a.name + '</span>';
          if (a.isUnique)
            note += '<br>' + a.info.note;
          var id = 'info.artifact' + cult.id + '_' + i;
          ui.initTooltip(id);
          ui.updateTip(id, note);
        }
    }
}
