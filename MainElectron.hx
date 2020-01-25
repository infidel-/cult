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
            width: 1058,
            height: 695,
            webPreferences: {
              nodeIntegration: true
            }
          });
          win.on( closed, function() {
              win = null;
          });
          win.loadFile('app.html');
//          win.webContents.openDevTools();
        });

      App.on(window_all_closed, function(e) {
          if (Node.process.platform != 'darwin')
            electron.main.App.quit();
      });
    }
}
