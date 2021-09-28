class Sound
{
  var ui: UI;
  var game: Game;
  var soundVolume: Int;
  var ambienceVolume: Int;
  var lastVoiceTS: Float; // 0 - not playing, -1 - playing, >0 - end time
  var lastVoiceID: Int;
  var lastDroneTS: Float; // 0 - not playing, -1 - playing, >0 - end time
  var lastDroneID: Int;

  public function new(ui: UI, g: Game)
    {
      this.ui = ui;
      this.game = g;
      soundVolume = 100;
      var v = ui.config.get('soundsoundVolume');
      if (v != null)
        soundVolume = Std.parseInt(v);
      ambienceVolume = 100;
      var v = ui.config.get('ambienceVolume');
      if (v != null)
        ambienceVolume = Std.parseInt(v);

      lastVoiceTS = 0;
      lastVoiceID = 0;
      lastDroneTS = 0;
      lastDroneID = 0;
      js.Browser.window.setInterval(checkAmbient, 1000);
    }

// timer - check if voices/drone is playing
  function checkAmbient()
    {
      if (game.isFinished)
        {
          SoundManager.stop('voices');
          SoundManager.stop('drone');
          return;
        }

      // first time
      if (lastVoiceTS == 0)
        playRandomVoices();

      // enough time passed since last one finished
      else if (Sys.time() - lastVoiceTS > 10 + Std.random(10))
        playRandomVoices();

      // first time
      if (lastDroneTS == 0)
        playRandomDrone();

      // enough time passed since last one finished
      else if (Sys.time() - lastDroneTS > 10 + Std.random(10))
        playRandomDrone();
    }

// pick random voices file and play it
  function playRandomVoices()
    {
      if (lastVoiceTS == -1)
        return;
      var rnd = 1;
      while (rnd == lastVoiceID)
        rnd = 1 + Std.random(8);
      lastVoiceID = rnd;
      trace('voices  ' + rnd + ' ' + lastVoiceTS);
      SoundManager.createSound({
        id: 'voices',
        url: 'data/sound/voices0' + rnd + '.mp3',
        volume: ambienceVolume,
      });
      lastVoiceTS = -1;
      SoundManager.play('voices', {
        onfinish: function() {
          lastVoiceTS = Sys.time();
          trace('voices over');
        }
      });
    }

// pick random drone file and play it
  function playRandomDrone()
    {
      if (lastDroneTS == -1)
        return;
      var rnd = 1;
      while (rnd == lastDroneID)
        rnd = 1 + Std.random(10);
      lastDroneID = rnd;
      trace('drone ' + rnd + ' ' + lastDroneTS);
      SoundManager.createSound({
        id: 'drone',
        url: 'data/sound/drone' +
          (rnd < 10 ? '0' : '') + rnd + '.mp3',
        volume: ambienceVolume,
      });
      lastDroneTS = -1;
      SoundManager.play('drone', {
        onfinish: function() {
          lastDroneTS = Sys.time();
          trace('drone over');
        }
      });
    }

// load all sounds
  static var sounds = [
    'click',
    'click-fail',
    'final-ritual-start',
    'unveiling-ritual-start',
    'unveiling-ritual-finish',
  ];
  public function init()
    {
      for (s in sounds)
        SoundManager.createSound({
          id: s,
          url: 'data/sound/' + s + '.mp3',
          volume: soundVolume,
        });
    }

// play a sound
  public function play(id: String)
    {
      SoundManager.play(id, { volume: soundVolume });
    }

// increase sound volume
  public function increaseSoundVolume()
    {
      var v = soundVolume;
      v += 10;
      if (v > 100) 
        v = 100;
      if (v == soundVolume)
        return;
      soundVolume = v;
      ui.config.set('soundVolume', '' + soundVolume);
    }

// decrease sound volume
  public function decreaseSoundVolume()
    {
      var v = soundVolume;
      v -= 10;
      if (v < 0)
        v = 0;
      if (v == soundVolume)
        return;
      soundVolume = v;
      ui.config.set('soundVolume', '' + soundVolume);
    }

// increase ambience volume
  public function increaseAmbienceVolume()
    {
      var v = ambienceVolume;
      v += 10;
      if (v > 100) 
        v = 100;
      if (v == ambienceVolume)
        return;
      ambienceVolume = v;
      ui.config.set('ambienceVolume', '' + ambienceVolume);
      SoundManager.setVolume('voices', ambienceVolume);
      SoundManager.setVolume('drone', ambienceVolume);
    }

// decrease ambience volume
  public function decreaseAmbienceVolume()
    {
      var v = ambienceVolume;
      v -= 10;
      if (v < 0)
        v = 0;
      if (v == ambienceVolume)
        return;
      ambienceVolume = v;
      ui.config.set('ambienceVolume', '' + ambienceVolume);
      SoundManager.setVolume('voices', ambienceVolume);
      SoundManager.setVolume('drone', ambienceVolume);
    }
}

