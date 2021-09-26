// high scores table

#if electron
import haxe.Json;
import js.node.Fs;
#end

class HighScores
{
  var game: Game;
  var ui: UI;

  public function new(g: Game, ui: UI)
    {
      this.game = g;
      this.ui = ui;
    }


#if electron
// get high scores table for display
  public function getTable(time: Int): String
    {
      var s = new StringBuf();

      // read file contents
      var obj: HighScoresTable = {
        version: 1,
        list: [
          { turns: [], time: [] },
          { turns: [], time: [] },
          { turns: [], time: [] },
        ],
      };
      try {
        var str = Fs.readFileSync('highscores.json', 'utf8');
        obj = Json.parse(str);
      }
      catch (e: Dynamic)
        {}

      // update new records
      var turns = obj.list[game.difficultyLevel].turns;
      turns.push({
        score: game.turns,
        ts: Std.int(Sys.time()),
      });
      turns.sort(sort);
      while (turns.length > 3)
        turns.pop();

      var timearr = obj.list[game.difficultyLevel].time;
      timearr.push({
        score: time,
        ts: Std.int(Sys.time()),
      });
      timearr.sort(sort);
      while (timearr.length > 3)
        timearr.pop();

      // save updated tables
      if (time > 0)
        Fs.writeFileSync('highscores.json', Json.stringify(obj), 'utf8');

      // show table
      var idx = 0;
      s.add('<div class=boxes>');
      for (rows in [
          obj.list[game.difficultyLevel].turns,
          obj.list[game.difficultyLevel].time ])
        {
          s.add('<div class=box' + (idx == 0 ? 'left' : 'right') + '><h2>');
          s.add(idx == 0 ? 'Best Turns' : 'Best Time');
          s.add('</h2>');
          for (row in rows)
            {
              s.add(
                DateTools.format(Date.fromTime(row.ts * 1000.0),
                  "%d %b %Y"));
              s.add(': ');
              if (idx == 1)
                s.add(convertTime(row.score));
              else s.add(row.score + ' turns');
              s.add('<br>');
            }
          s.add('</div>');

          idx++;
        }
      s.add('</table>');

      return s.toString();
    }


// seconds to string
  public function convertTime(t: Int): String
    {
      var s = new StringBuf();
/*
      if (t >= 3600)
        {
          var hr = Std.int(t / 3600.0);
          s.add(hr);
          s.add(':');
          t -= hr * 3600;
        }
*/
      if (t >= 60)
        {
          var min = Std.int(t / 60.0);
          if (min < 10)
            s.add('0');
          s.add(min);
          s.add(':');
          t -= min * 60;
        }
      else s.add('00:');
      if (t < 10)
        s.add('0');
      s.add(t);

      return s.toString();
    }

  function sort(v1: HighScoresRecord, v2: HighScoresRecord)
    {
      if (v1.score > v2.score)
        return 1;
      else if (v1.score < v2.score)
        return -1;
      else return 0;
    }
#end
}


typedef HighScoresTable = {
  var version: Int;
  var list: Array<{
    var turns: Array<HighScoresRecord>;
    var time: Array<HighScoresRecord>;
  }>;
}

typedef HighScoresRecord = {
  var score: Int;
  var ts: Int;
}
