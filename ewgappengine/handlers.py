import os, types

from google.appengine.ext import webapp, db
from google.appengine.api import users
from google.appengine.ext.webapp import template

class EWGRequestHandler(webapp.RequestHandler):
    pass

class AuthenticatingHandler(EWGRequestHandler):

    def get(self):
        return self.__authenticatedCall('get')

    def post(self):
        return self.__authenticatedCall('post')

    def getUnauthenticated(self, loginUrl):
        self.redirect(loginUrl)

    def postUnauthenticated(self, loginUrl):
        self.redirect(loginUrl)

    def __authenticatedCall(self, callName):
        userObject = users.get_current_user()
        logoutUrl = users.create_logout_url(self.request.uri)
        if userObject:
            return getattr( self, '%sAuthenticated' % callName )(userObject,logoutUrl)
        else:
            loginUrl = users.create_login_url(self.request.uri)
            return getattr( self, '%sUnauthenticated' % callName )(loginUrl)

