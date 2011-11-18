// music player

extern class SoundManager implements Dynamic
{
  static function stop(id: Dynamic): Void;
  static function play(id: Dynamic, ?p2: Dynamic): Void;
  static function togglePause(id: Dynamic): Void;
  static function createSound(p1: Dynamic): Void;
  static function destroySound(p1: Dynamic): Void;
}

class Music
{
  public var isInited: Bool;
  var trackID: Int;
  var playlist: Array<Array<String>>;

  public function new()
    {
      isInited = false;
      trackID = -1;
      playlist = [
        ["Introspective", "Occlusion", "Fluid Dynamics",
         "http://kahvi.micksam7.com/mp3/kahvi051a_intro-fluid_dynamics.mp3",
         "http://www.kahvi.org/releases.php?release_number=051"],
        ["Introspective", "Occlusion", "Contain Release",
         "http://kahvi.micksam7.com/mp3/kahvi051b_intro-contain_release.mp3",
         "http://www.kahvi.org/releases.php?release_number=051"],
        ["Introspective", "Occlusion", "Wave Propagation",
         "http://kahvi.micksam7.com/mp3/kahvi051c_intro-wave_propagation.mp3",
         "http://www.kahvi.org/releases.php?release_number=051"],
        ["Introspective", "Analogy", "Mail Order Monsters",
         "http://kahvi.micksam7.com/mp3/kahvi080a_intro-mail_order_monsters.mp3",
         "http://www.kahvi.org/releases.php?release_number=080"],
        ["Introspective", "Analogy", "Cartographer",
         "http://kahvi.micksam7.com/mp3/kahvi080b_intro-cartographer.mp3",
         "http://www.kahvi.org/releases.php?release_number=080"],
        ["Introspective", "Analogy", "Gone Awry",
         "http://kahvi.micksam7.com/mp3/kahvi080c_intro-analogy_gone_awry.mp3",
         "http://www.kahvi.org/releases.php?release_number=080"],
        ["Introspective", "Analogy", "Bearing Your Name",
         "http://kahvi.micksam7.com/mp3/kahvi080d_intro-bearing_your_name.mp3",
         "http://www.kahvi.org/releases.php?release_number=080"],
        ["Introspective", "Crossing Borders", "Crossing Borders",
         "http://kahvi.micksam7.com/mp3/kahvi094a_introspective-crossing_borders.mp3",
         "http://www.kahvi.org/releases.php?release_number=094"],
        ["Introspective", "Crossing Borders", "Medina Of Tunis",
         "http://kahvi.micksam7.com/mp3/kahvi094b_introspective-medina_of_tunis.mp3",
         "http://www.kahvi.org/releases.php?release_number=094"],

        ["Introspective", "Black Mesa Winds", "Crepuscular Activity",
         "http://kahvi.micksam7.com/mp3/kahvi236a_introspective-crepuscular_activity.mp3",
         "http://www.kahvi.org/releases.php?release_number=236"],
        ["Introspective", "Black Mesa Winds", "Vanishing Point",
         "http://kahvi.micksam7.com/mp3/kahvi236b_introspective-vanishing_point.mp3",
         "http://www.kahvi.org/releases.php?release_number=236"],
        ["Introspective", "Black Mesa Winds", "Black Mesa Winds",
         "http://kahvi.micksam7.com/mp3/kahvi236c_introspective-black_mesa_winds.mp3",
         "http://www.kahvi.org/releases.php?release_number=236"],
        ["Introspective", "Black Mesa Winds", "Convection",
         "http://kahvi.micksam7.com/mp3/kahvi236d_introspective-convection.mp3",
         "http://www.kahvi.org/releases.php?release_number=236"],
        ["Introspective", "Black Mesa Winds", "Sky City",
         "http://kahvi.micksam7.com/mp3/kahvi236e_introspective-sky_city.mp3",
         "http://www.kahvi.org/releases.php?release_number=236"],
        ["Introspective", "Black Mesa Winds", "Predator Distribution",
         "http://kahvi.micksam7.com/mp3/kahvi236f_introspective-predator_distribution.mp3",
         "http://www.kahvi.org/releases.php?release_number=236"],
        ["Introspective", "Black Mesa Winds", "Fahrenheit",
         "http://kahvi.micksam7.com/mp3/kahvi236g_introspective-fahrenheit.mp3",
         "http://www.kahvi.org/releases.php?release_number=236"],
        ["Introspective", "Black Mesa Winds", "Riverside",
         "http://kahvi.micksam7.com/mp3/kahvi236h_introspective-riverside.mp3",
         "http://www.kahvi.org/releases.php?release_number=236"],
        ["Introspective", "Black Mesa Winds", "Xerophytes",
         "http://kahvi.micksam7.com/mp3/kahvi236i_introspective-xerophytes.mp3",
         "http://www.kahvi.org/releases.php?release_number=236"],
        ["Introspective", "Black Mesa Winds", "Differential Erosion",
         "http://kahvi.micksam7.com/mp3/kahvi236j_introspective-differential_erosion.mp3",
         "http://www.kahvi.org/releases.php?release_number=236"],
        ["Introspective", "Black Mesa Winds", "Overwhelming Sky",
         "http://kahvi.micksam7.com/mp3/kahvi236k_introspective-overwhelming_sky.mp3",
         "http://www.kahvi.org/releases.php?release_number=236"],


        ["Curious Inversions", "Whom", "Antibiotic Resistance",
         "http://kahvi.micksam7.com/mp3/kahvi254a_curious_inversions-antibiotic_resistance.mp3",
         "http://www.kahvi.org/releases.php?release_number=254"],
        ["Curious Inversions", "Whom", "Antiquity",
         "http://kahvi.micksam7.com/mp3/kahvi254b_curious_inversions-antiquity.mp3",
         "http://www.kahvi.org/releases.php?release_number=254"],
        ["Curious Inversions", "Whom", "Geonosian Advance",
         "http://kahvi.micksam7.com/mp3/kahvi254c_curious_inversions-geonosian_advance.mp3",
         "http://www.kahvi.org/releases.php?release_number=254"],
        ["Curious Inversions", "Whom", "In The Scholar's Wake",
         "http://kahvi.micksam7.com/mp3/kahvi254d_curious_inversions-in_the_scholars_wake.mp3",
         "http://www.kahvi.org/releases.php?release_number=254"],
        ["Curious Inversions", "Whom", "Predators",
         "http://kahvi.micksam7.com/mp3/kahvi254e_curious_inversions-predators.mp3",
         "http://www.kahvi.org/releases.php?release_number=254"],
        ["Curious Inversions", "Whom", "Sissot Eclipse",
         "http://kahvi.micksam7.com/mp3/kahvi254f_curious_inversions-sissot_eclipse.mp3",
         "http://www.kahvi.org/releases.php?release_number=254"],
        ["Curious Inversions", "Whom", "Voluntary",
         "http://kahvi.micksam7.com/mp3/kahvi254g_curious_inversions-voluntary.mp3",
         "http://www.kahvi.org/releases.php?release_number=254"],
        ["Curious Inversions", "Whom", "Windslak",
         "http://kahvi.micksam7.com/mp3/kahvi254h_curious_inversions-windslak.mp3",
         "http://www.kahvi.org/releases.php?release_number=254"],

        ["Introspective", "Gewesen", "Gewesen",
         "http://kahvi.micksam7.com/mp3/kahvi176a_introspective-gewesen.mp3",
         "http://www.kahvi.org/releases.php?release_number=176"], 
        ["Introspective", "Gewesen", "Undocumented",
         "http://kahvi.micksam7.com/mp3/kahvi176b_introspective-undocumented.mp3",
         "http://www.kahvi.org/releases.php?release_number=176"],
        ["Introspective", "Gewesen", "Gewesen pt2",
         "http://kahvi.micksam7.com/mp3/kahvi176c_introspective-gewesen_part2.mp3",
         "http://www.kahvi.org/releases.php?release_number=176"],
        ["Introspective", "Gewesen", "Specular Highlights",
         "http://kahvi.micksam7.com/mp3/kahvi176d_introspective-specular_highlights.mp3",
         "http://www.kahvi.org/releases.php?release_number=176"],
        ["Introspective", "Gewesen", "The Leaves In The Rain",
         "http://kahvi.micksam7.com/mp3/kahvi176e_introspective-the_leaves_in_the_rain.mp3",
         "http://www.kahvi.org/releases.php?release_number=176"]
      ];
    }


// init player
  public function init()
    {
      isInited = true;
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
//      trace(playlist[trackID][3]);
      
      SoundManager.createSound({
        id: 'music',
        url: playlist[trackID][3],
        volume: 100,
      });

      SoundManager.play('music', { onfinish: random });
      onRandom();
    }


  public dynamic function onRandom()
    {
    }


// start playing
  public function play()
    {
      if (trackID == -1)
        random();
      else SoundManager.play('music', { onfinish: random });
    }


// stop playing
  public function stop()
    {
      SoundManager.stop('music');
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
