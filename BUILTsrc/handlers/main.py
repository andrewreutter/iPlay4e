from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        user = users.get_current_user()
        if user:
            return self.redirect('/characters')
        self.sendCachedMainPage(145541695845)
