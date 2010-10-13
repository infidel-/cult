# save/load functions

from google.appengine.ext import webapp
from google.appengine.ext import db
from django.utils import simplejson as json
import logging

class Save(webapp.RequestHandler):
    MaxSaves = 5 # max number of saves per user
    MaxSize = 15000 # max size of save file

    # get query
    def get(self):
        if (self.request.path == '/save.load'):
          self.load()
        elif (self.request.path == '/save.list'):
          self.list()
        elif (self.request.path == '/save.delete'):
          self.delete()

    # post query
    def post(self):
        if (self.request.path == '/save.save'):
          self.save()


    # list user saves
    def list(self):
#        logging.info('list')
        owner = self.request.get('owner')
        if (owner == ''):
          return

        q = db.GqlQuery("SELECT * FROM SaveModel WHERE owner = :o ORDER BY date DESC",
          o = owner)
        saves = q.fetch(self.MaxSaves)

        # dump save list to json
        obj = list()
        for s in saves:
          sv = {
            'id': s.key().id(),
            'version': s.version,
            'name': s.name,
            'date': str(s.date) }
          obj.append(sv)
        s = json.dumps(obj)

        self.response.out.write(s);


    # load user save
    def load(self):
        owner = self.request.get('owner')
        id = int(self.request.get('id'))

        save = SaveModel.get_by_id(id)
        if (save == None):
          self.response.out.write('NoSuchSave')
          return
        if (save.owner != owner):
          return

        self.response.out.write(save.content)


    # delete user save
    def delete(self):
        owner = self.request.get('owner')
        id = int(self.request.get('id'))
        if (owner == ''):
          return

        save = SaveModel.get_by_id(id)
        if (save == None):
          return
        if (save.owner != owner):
          return
        
        save.delete()


    # save user save
    def save(self):
        owner = self.request.get('owner')
        if (owner == ''):
          return

        # check for saves limit
        q = db.GqlQuery("SELECT * FROM SaveModel WHERE owner = :o",
          o = owner)
        if (q.count() >= self.MaxSaves):
          self.response.out.write("TooManySaves")
          return

        # check for existing save
        idstr = self.request.get('id')
        if (idstr != ''):
          id = int(idstr)
        else: id = 0
        if (id > 0):
          data = SaveModel.get_by_id(id)
          if (data != None):
            data.delete()
        
        # too big to be save
        if (len(self.request.body) > self.MaxSize):
          logging.error("Length:" + str(len(self.request.body)))
          self.response.out.write("TooBig")
          return

#        logging.info("body:" + self.request.body)
        logging.info("body length:" + str(len(self.request.body)))

        data = SaveModel()
        data.name = self.request.get('name')
        if (data.name == ''):
          data.name = 'Unnamed'
        data.owner = self.request.get('owner')
        data.version = self.request.get('version')
        data.content = self.request.body
        data.put()

        self.response.out.write("OK")


# save file model
class SaveModel(db.Model):
    name = db.StringProperty() # save name
    owner = db.StringProperty() # owner key
    version = db.StringProperty() # game version
    content = db.TextProperty() # save file contents
    date = db.DateTimeProperty(auto_now_add=True) # creation date
