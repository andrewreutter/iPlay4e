from google.appengine.api import users
from django.utils import simplejson

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        # We need a user, key and name for sure (e.g. andrew, 234824572, Diplomacy)
        user = users.get_current_user() or None
        key, name = self.request.get('key', None), self.request.get('name', None)
        if None in (user, key, name):
            return

        # Delete any existing matches.
        userId = user.user_id()
        [ note.delete() for note in models.UserItemNote.gql('WHERE user_id = :1 and item_key = :2 and name = :3', userId, key, name) ]

        # Create a new one if there was some text.
        note = self.request.get('note')
        if note:
            models.UserItemNote(user_id=userId, item_key=key, name=name, note=note).put()
