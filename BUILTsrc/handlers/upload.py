from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        newData, currentUser = self.request.get('dnd4eData', ''), users.get_current_user()
        if not newData:
            return self.javascriptError('First choose a file from Character Builder (.dnd4e) or Monster Builder (.rtf)')
        if not currentUser:
            return self.javascriptError('Please sign in to upload files')

        modelDict = \
        {   'wotcData': newData, 
            'owner':currentUser,
            'isPublic': self.request.get('isPublic') and True or False,
        }
        model = getattr(models, models.VERSIONED_CHARACTER_CLASS)(**modelDict)

        # Finalize the model to see if the provided file was any good.
        try:
            model.buildDom(testing=True)
        except (ValueError, RuntimeError), errorMessage:
            return self.javascriptError('Invalid file - are your Builders up to date?')

        model.ip4XML = None
        model.put()
        self.redirectTop('/characters/%s' % model.key())
