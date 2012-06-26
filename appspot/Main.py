import os
import cgi
from google.appengine.api import channel
from google.appengine.api import users
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template
from google.appengine.ext.webapp.util import run_wsgi_app

from Save import *


class MainPage(webapp.RequestHandler):
    def get(self):
        path = os.path.join(os.path.dirname(__file__), 'index.html')
        self.response.out.write(template.render(path, {}))


class SiteMap(webapp.RequestHandler):
    def get(self):
        path = os.path.join(os.path.dirname(__file__), 'sitemap.xml')
        self.response.out.write(template.render(path, {}))


class Multiplayer(webapp.RequestHandler):
    def get(self):
        if (self.request.path == '/mp.create'):
#        user = users.get_current_user()
          game_key = '123'
          token = channel.create_channel(game_key + '.0')
          self.response.out.write(game_key + ',' + token)

        elif (self.request.path == '/mp.join'):
          game_key = self.request.get('k')
#        user = users.get_current_user()
          token = channel.create_channel(game_key + '.1')
          self.response.out.write(token)

        elif (self.request.path == '/mp.joined'):
          game_key = self.request.get('k')
          channel.send_message(game_key + '.0', 'hallo-hallo! i joined!')


application = webapp.WSGIApplication(
  [
    ('/', MainPage),
    ('/sitemap.xml', SiteMap),
    ('/save.list', Save),
    ('/save.delete', Save),
    ('/save.load', Save),
    ('/save.save', Save),
    ('/mp.create', Multiplayer),
    ('/mp.join', Multiplayer),
    ('/mp.joined', Multiplayer)
  ], debug = True)

def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()

