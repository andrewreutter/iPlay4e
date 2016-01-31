from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        model = self.getAuthorizedModelOfClasses(self.DELETE, models.getSearchableClasses())
        model.isPublic = False
        model.put()
        self.redirect(self.request.referrer)
