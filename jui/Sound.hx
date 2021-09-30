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
  var soundsRandom: Map<String, Array<String>>;
  var lastSoundTS: Map<String, Float>;

  public function new(ui: UI, g: Game)
    {
      this.ui = ui;
      this.game = g;
      soundVolume = 100;
      var v = ui.config.get('soundVolume');
      if (v != null)
        soundVolume = Std.parseInt(v);
      ambienceVolume = 100;
      var v = ui.config.get('ambienceVolume');
      if (v != null)
        ambienceVolume = Std.parseInt(v);
      soundsRandom = [];
      lastSoundTS = [];

      lastVoiceTS = 0;
      lastVoiceID = 0;
      lastDroneTS = 0;
      lastDroneID = 0;
      js.Browser.window.setInterval(checkAmbient, 100);
    }

// timer - check if voices/drone is playing
  function checkAmbient()
    {
      // check if someone is casting final ritual
      var isRitual = false;
      for (c in game.cults)
        if (c.isRitual && c.ritual.id == 'summoning')
          {
            isRitual = true;
            break;
          }
      if (game.isFinished || !isRitual)
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
    'final-ritual-success',
    'final-ritual-success-other',
    'final-ritual-fail',
    'victory',
    'defeat',
    'unveiling-ritual-start',
    'unveiling-ritual-finish',
    'node-gain1',
    'node-gain2',
    'node-gain3',
    'node-gain4',
    'node-gain5',
    'node-fail-female1',
    'node-fail-female2',
    'node-fail-female3',
    'node-fail-female4',
    'node-fail-female5',
    'node-fail-female6',
    'node-fail-female7',
    'node-fail-female8',
    'node-fail-female9',
    'node-fail-male1',
    'node-fail-male2',
    'node-fail-male3',
    'node-fail-male4',
    'node-fail-male5',
    'node-fail-male6',
    'node-fail-male7',
    'node-fail-male8',
    'node-fail-male9',
    'window-open',
    'window-close',
    'cult-declare-war',
    'cult-paralyzed',
    'cult-gain-stash',
    'artifact-gain',
    'artifact-bind',
    'artifact-find',
  ];
  // sounds to stop on event window close
  static var soundsStopOnClose = [
    'final-ritual-success',
    'final-ritual-success-other',
    'victory',
    'defeat',
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

// stop event sounds on event window close
  public function stopOnClose()
    {
      for (s in soundsStopOnClose)
        ui.sound.stop(s);
    }

// play a sound
  public function play(id: String)
    {
      // ignore duplicate sounds
      var last = lastSoundTS[id];
      if (last != null && Sys.time() - last < 0.10)
        return;
      lastSoundTS[id] = Sys.time();
      SoundManager.play(id, { volume: soundVolume });
    }

// stop a sound
  public function stop(id: String)
    {
      SoundManager.stop(id);
    }

// play a random sound from a group
  public function playRandom(prefix: String)
    {
      var tmp = soundsRandom[prefix];
      if (tmp == null || tmp.length == 0)
        {
          tmp = [];
          for (s in sounds)
            if (StringTools.startsWith(s, prefix))
              tmp.push(s);
          if (tmp.length == 0)
            throw 'No sounds with this prefix: ' + prefix;
          soundsRandom[prefix] = tmp;
        }
      var rnd = tmp[Std.random(tmp.length)];
      tmp.remove(rnd);
      SoundManager.play(rnd, { volume: soundVolume });
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

