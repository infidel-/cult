// music player

class Music
{
  public var isInited: Bool;
  var trackID: Int;
  var playlist: Array<Array<String>>;

  public function new()
    {
      isInited = false;
      trackID = -1;
    }


// init player
  public function init()
    {
      isInited = true;
    }


// select random track
  public function random()
    {
    }


  public dynamic function onRandom()
    {
    }


// start playing
  public function play()
    {
    }


// stop playing
  public function stop()
    {
    }


// pause playing
  public function pause()
    {
    }


// get name of played music
 public function getName()
   {
     return "";
   }


// get album page
  public function getPage()
    {
      return "";
    }
}
