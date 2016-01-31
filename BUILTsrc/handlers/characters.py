from google.appengine.api import users
from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        user = users.get_current_user()
        if not user:
            return self.sendCachedMainPage(143371090575)

        owner = self.request.get('owner', None)
        owner = owner and ('&owner=%s' % owner) or ''

        userId, page = user.user_id(), self.request.get('p', '1')
        self.redirect('/search/main?xsl=search&type=Character&user=%(userId)s&p=%(page)s%(owner)s' % locals())

class MigrateHandler(BaseHandler.BaseHandler):

    def get(self):

        user = users.get_current_user()
        if not user:
            return self.redirect('/characters')

        unmigratedCharacters = models.Character.getUnmigratedCharactersForUser(user)
        if not unmigratedCharacters:
            return self.redirectTop('/characters')

        unmigratedCharacters.pop().migrate()
        if not unmigratedCharacters:
            return self.redirectTop('/characters')

        return self.response.out.write(open('BUILTsrc/html/migrate.html').read())
