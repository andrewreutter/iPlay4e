from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        user = users.get_current_user()
        if not user:
            return self.javascriptError('Please sign in to create your own campaign.')

        name = self.request.get('name')
        if not name:
            return self.javascriptError('Please enter a name for your campaign.')

        modelDict = \
        {   'owner': user,
            'isPublic': self.request.get('isPublic') and True or False,
            'players': [ user ],
            'name': name,
            'world': self.request.get('world', ''),
            'description': self.request.get('description', '')
        }
        model = models.Campaign(**modelDict)
        model.put()

        self.redirectTop('/campaigns/%s' % model.key())
