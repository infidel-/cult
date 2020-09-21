// music player

extern class SoundManager implements Dynamic
{
  static function stop(id: Dynamic): Void;
  static function play(id: Dynamic, ?p2: Dynamic): Void;
  static function togglePause(id: Dynamic): Void;
  static function createSound(p1: Dynamic): Void;
  static function destroySound(p1: Dynamic): Void;
  static function stopAll(): Void;
  static function setVolume(vol: Int): Void;
}

class Music
{
  var ui: UI;
  public var isInited: Bool;
  var trackID: Int;
  var playlist: Array<Array<String>>;
  var volume: Int;

  public function new(ui: UI)
    {
      this.ui = ui;
      volume = 100;
      var v = ui.config.get('musicVolume');
      if (v != null)
        volume = Std.parseInt(v);
      isInited = false;
      trackID = -1;
      playlist = [
        [
          "Introspective",
          "Occlusion",
          "Fluid Dynamics",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi051a_intro-fluid_dynamics.ogg",
          "http://www.kahvi.org/releases.php?release_number=051",
        ],
        [
          "Introspective",
          "Occlusion",
          "Contain Release",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi051b_intro-contain_release.ogg",
          "http://www.kahvi.org/releases.php?release_number=051",
        ],
        [
          "Introspective",
          "Occlusion",
          "Wave Propagation",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi051c_intro-wave_propagation.ogg",
          "http://www.kahvi.org/releases.php?release_number=051",
        ],

        [
          "Introspective",
          "Analogy",
          "Mail Order Monsters",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi080a_intro-mail_order_monsters.ogg",
          "http://www.kahvi.org/releases.php?release_number=080",
        ],
        [
          "Introspective",
          "Analogy",
          "Cartographer",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi080b_intro-cartographer.ogg",
          "http://www.kahvi.org/releases.php?release_number=080",
        ],
        [
          "Introspective",
          "Analogy",
          "Gone Awry",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi080c_intro-analogy_gone_awry.ogg",
          "http://www.kahvi.org/releases.php?release_number=080",
        ],
        [
          "Introspective",
          "Analogy",
          "Bearing Your Name",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi080d_intro-bearing_your_name.ogg",
          "http://www.kahvi.org/releases.php?release_number=080",
        ],

        [
          "Introspective",
          "Crossing Borders",
          "Crossing Borders",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi094a_introspective-crossing_borders.ogg",
          "http://www.kahvi.org/releases.php?release_number=094",
        ],
        [
          "Introspective",
          "Crossing Borders",
          "Medina Of Tunis",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi094b_introspective-medina_of_tunis.ogg",
          "http://www.kahvi.org/releases.php?release_number=094",
        ],

        [
          "Introspective",
          "Black Mesa Winds",
          "Crepuscular Activity",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi236a_introspective-crepuscular_activity.ogg",
          "http://www.kahvi.org/releases.php?release_number=236",
        ],
        [
          "Introspective",
          "Black Mesa Winds",
          "Vanishing Point",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi236b_introspective-vanishing_point.ogg",
          "http://www.kahvi.org/releases.php?release_number=236",
        ],
        [
          "Introspective",
          "Black Mesa Winds",
          "Black Mesa Winds",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi236c_introspective-black_mesa_winds.ogg",
          "http://www.kahvi.org/releases.php?release_number=236",
        ],
        [
          "Introspective",
          "Black Mesa Winds",
          "Convection",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi236d_introspective-convection.ogg",
          "http://www.kahvi.org/releases.php?release_number=236",
        ],
        [
          "Introspective",
          "Black Mesa Winds",
          "Sky City",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi236e_introspective-sky_city.ogg",
          "http://www.kahvi.org/releases.php?release_number=236",
        ],
        [
          "Introspective",
          "Black Mesa Winds",
          "Predator Distribution",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi236f_introspective-predator_distribution.ogg",
          "http://www.kahvi.org/releases.php?release_number=236",
        ],
        [
          "Introspective",
          "Black Mesa Winds",
          "Fahrenheit",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi236g_introspective-fahrenheit.ogg",
          "http://www.kahvi.org/releases.php?release_number=236",
        ],
        [
          "Introspective",
          "Black Mesa Winds",
          "Riverside",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi236h_introspective-riverside.ogg",
          "http://www.kahvi.org/releases.php?release_number=236",
        ],
        [
          "Introspective",
          "Black Mesa Winds",
          "Xerophytes",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi236i_introspective-xerophytes.ogg",
          "http://www.kahvi.org/releases.php?release_number=236",
        ],
        [
          "Introspective",
          "Black Mesa Winds",
          "Differential Erosion",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi236j_introspective-differential_erosion.ogg",
          "http://www.kahvi.org/releases.php?release_number=236",
        ],
        [
          "Introspective",
          "Black Mesa Winds",
          "Overwhelming Sky",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi236k_introspective-overwhelming_sky.ogg",
          "http://www.kahvi.org/releases.php?release_number=236",
        ],

        [
          "Curious Inversions",
          "Whom",
          "Antibiotic Resistance",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi254a_curious_inversions-antibiotic_resistance.ogg",
          "http://www.kahvi.org/releases.php?release_number=254",
        ],
        [
          "Curious Inversions",
          "Whom",
          "Antiquity",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi254b_curious_inversions-antiquity.ogg",
          "http://www.kahvi.org/releases.php?release_number=254",
        ],
        [
          "Curious Inversions",
          "Whom",
          "Geonosian Advance",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi254c_curious_inversions-geonosian_advance.ogg",
          "http://www.kahvi.org/releases.php?release_number=254",
        ],
        [
          "Curious Inversions",
          "Whom",
          "In The Scholar's Wake",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi254d_curious_inversions-in_the_scholars_wake.ogg",
          "http://www.kahvi.org/releases.php?release_number=254",
        ],
        [
          "Curious Inversions",
          "Whom",
          "Predators",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi254e_curious_inversions-predators.ogg",
          "http://www.kahvi.org/releases.php?release_number=254",
        ],
        [
          "Curious Inversions",
          "Whom",
          "Sissot Eclipse",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi254f_curious_inversions-sissots_eclipse.ogg",
          "http://www.kahvi.org/releases.php?release_number=254",
        ],
        [
          "Curious Inversions",
          "Whom",
          "Voluntary",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi254g_curious_inversions-voluntary.ogg",
          "http://www.kahvi.org/releases.php?release_number=254",
        ],
        [
          "Curious Inversions",
          "Whom",
          "Windslak",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi254h_curious_inversions-windslak.ogg",
          "http://www.kahvi.org/releases.php?release_number=254",
        ],

        [
          "Introspective",
          "Gewesen",
          "Gewesen",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi176a_introspective-gewesen.ogg",
          "http://www.kahvi.org/releases.php?release_number=176",
        ],
        [
          "Introspective",
          "Gewesen",
          "Undocumented",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi176b_introspective-undocumented.ogg",
          "http://www.kahvi.org/releases.php?release_number=176",
        ],
        [
          "Introspective",
          "Gewesen",
          "Gewesen pt2",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi176c_introspective-gewesen_part2.ogg",
          "http://www.kahvi.org/releases.php?release_number=176",
        ],
        [
          "Introspective",
          "Gewesen",
          "Specular Highlights",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi176d_introspective-specular_highlights.ogg",
          "http://www.kahvi.org/releases.php?release_number=176",
        ],
        [
          "Introspective",
          "Gewesen",
          "The Leaves In The Rain",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi176e_introspective-the_leaves_in_the_rain.ogg",
          "http://www.kahvi.org/releases.php?release_number=176",
        ],

        [
          "Curious Inversions",
          "Schoolyard Crows",
          "Unfamiliar Domain",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi353a_curious_inversions-unfamiliar_domain.ogg",
          "http://www.kahvi.org/releases.php?release_number=353",
        ],
        [
          "Curious Inversions",
          "Schoolyard Crows",
          "Restrictions",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi353b_curious_inversions-restrictions.ogg",
          "http://www.kahvi.org/releases.php?release_number=353",
        ],
        [
          "Curious Inversions",
          "Schoolyard Crows",
          "Inefficient Sacrifice",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi353c_curious_inversions-inefficient_sacrifice.ogg",
          "http://www.kahvi.org/releases.php?release_number=353",
        ],
        [
          "Curious Inversions",
          "Schoolyard Crows",
          "Elder Grove",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi353d_curious_inversions-elder_grove.ogg",
          "http://www.kahvi.org/releases.php?release_number=353",
        ],
        [
          "Curious Inversions",
          "Schoolyard Crows",
          "Woven Hand",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi353e_curious_inversions-woven_hand.ogg",
          "http://www.kahvi.org/releases.php?release_number=353",
        ],
        [
          "Curious Inversions",
          "Schoolyard Crows",
          "Eccentric Structures",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi353f_curious_inversions-eccentric_structures.ogg",
          "http://www.kahvi.org/releases.php?release_number=353",
        ],
        [
          "Curious Inversions",
          "Schoolyard Crows",
          "Fetter",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi353g_curious_inversions-fetter.ogg",
          "http://www.kahvi.org/releases.php?release_number=353",
        ],
        [
          "Curious Inversions",
          "Schoolyard Crows",
          "Unit 731",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi353h_curious_inversions-unit_731.ogg",
          "http://www.kahvi.org/releases.php?release_number=353",
        ],
        [
          "Curious Inversions",
          "Schoolyard Crows",
          "Symmetric Immortality",
          "http://ftp.scene.org/pub/music/groups/kahvicollective/kahvi353i_curious_inversions-symmetric_immortality.ogg",
          "http://www.kahvi.org/releases.php?release_number=353",
        ],
      ];

#if electron
      // local music files
      var pl = [];
      for (row in playlist)
        {
          row[3] = StringTools.replace(row[3],
            'http://ftp.scene.org/pub/music/groups/kahvicollective/',
#if demo
            'data/music/demo/');
          if (row[1] == 'Gewesen')
            pl.push(row);
#else
            'data/music/');
#end
          row[3] = StringTools.replace(row[3], '.ogg', '.mp3');
        }
#if demo
      playlist = pl;
#end
#end
    }


// select random track
  public function random()
    {
      SoundManager.destroySound('music');

      while (true)
        {
          var t = Std.int(Math.random() * (playlist.length - 1));
          if (t != trackID)
            {
              trackID = t;
              break;
            }
        }
/*
      trackID++;
      if (trackID >= playlist.length)
        trackID = 0;
      trace(playlist[trackID][3]);
*/

      SoundManager.createSound({
        id: 'music',
        url: playlist[trackID][3],
        volume: volume,
      });

      SoundManager.play('music', { onfinish: random });
      onRandom();
    }


  public dynamic function onRandom()
    {
    }


// first start - checks for config variable
  public function start()
    {
      var val = ui.config.get('music');
      if (val == null || val == '0')
        return;

      play();
    }


// increase volume
  public function increaseVolume()
    {
      var v = volume;
      v += 10;
      if (v > 100) 
        v = 100;
      if (v == volume)
        return;
      volume = v;
      ui.config.set('musicVolume', '' + volume);
      SoundManager.setVolume(volume);
    }


// decrease volume
  public function decreaseVolume()
    {
      var v = volume;
      v -= 10;
      if (v < 0)
        v = 0;
      if (v == volume)
        return;
      volume = v;
      ui.config.set('musicVolume', '' + volume);
      SoundManager.setVolume(volume);
    }


// start playing
  public function play()
    {
      SoundManager.stopAll();
      if (trackID == -1)
        random();
      else SoundManager.play('music', { onfinish: random });
      ui.config.set('music', '1');
    }


// stop playing
  public function stop()
    {
      SoundManager.stopAll();
      ui.config.set('music', '0');
    }


// pause playing
  public function pause()
    {
      SoundManager.togglePause('music');
    }


// get name of played music
  public function getName()
    {
      var a = playlist[trackID];
      return "<span style='color: #080'>Track:</span> " + a[2] +
       "<br><span style='color: #080'>Album:</span> " + a[1] +
       "<br><span style='color: #080'>Artist:</span> " + a[0];
    }


// get album page
  public function getPage()
    {
      return playlist[trackID][4];
    }
}
