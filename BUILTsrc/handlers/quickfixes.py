from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        if not models.DonatingUser.gql('where emailAddress = :1', 'andrew.reutter@gmail.com').count():
            models.DonatingUser(emailAddress='andrew.reutter@gmail.com').put()
