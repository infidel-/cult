// UI artifact additions
package artifacts;

import js.html.Image;

class ArtifactUI
{
  var game: Game;
  var ui: UI;
  public var mapIconImages: Map<String, Image>; // loaded map icons

  public function new(g: Game, uivar: UI)
    {
      game = g;
      ui = uivar;

      loadImagesModern();
    }

// load images for modern mode
  public function loadImagesModern()
    {
      mapIconImages = new Map();
      for (key in StaticArtifacts.uniqueArtifacts.keys())
        {
          var img = new Image();
          img.src = 'data/artifact-unique-' + key + '.png';
          mapIconImages[key] = img;
        }
      for (key in StaticArtifacts.types)
        {
          var img = new Image();
          img.src = 'data/artifact-' + key + '.png';
          mapIconImages[key] = img;
        }
    }

// artifacts info in cult info window
  public function getInfoString(cult: Cult): String
    {
      var s = new StringBuf();

      s.add('Artifacts: ');
      if (cult.artifacts.length == 0)
        s.add('None<br>');
      else
        {
          s.add('<br>');
          var list = cult.artifacts.list();
          for (i in 0...list.length)
            {
              var a = list[i];
              s.add(
                "&nbsp;&nbsp;&nbsp;<span class=shadow style='color:var(--artifact-color)' id=info.artifact" + cult.id + '_' + i +
                " title='" + a.name + "'>" +
                  a.name + '</span>' +
                " <span class=shadow style='color:white'>L" + a.level + '</span>');
              if (a.node != null)
                s.add(' (' + a.node.name + ')');
              s.add('<br>');
            }
        }

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
            note += '<br>' + a.info.note +
              '<br>(only after the artifact is bound to a priest)' +
              "<br><div class=fluffNote>" +
              a.info.fluff + '</div>';
          var id = 'info.artifact' + cult.id + '_' + i;
          ui.initTooltip(id);
          ui.updateTip(id, note);
        }
    }
}
