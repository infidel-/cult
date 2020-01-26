// main electron entry-point

import js.Node;
import js.Node.__dirname;
import electron.main.App;
import electron.main.BrowserWindow;

class MainElectron
{
  static function main()
    {
      App.on(ready, function(e)
        {
          var win = new BrowserWindow({
            icon: __dirname + '/favicon.png',
            width: 1056,
            height: 685,
            webPreferences: {
              nodeIntegration: true
            }
          });
#if !mydebug
          win.setMenu(null);
#end
          win.on( closed, function() {
              win = null;
          });
          win.loadFile('app.html');
/*
#if mydebug
          win.webContents.openDevTools();
#end
*/
        });

      App.on(window_all_closed, function(e) {
          if (Node.process.platform != 'darwin')
            App.quit();
      });
    }
}
