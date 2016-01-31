from google.appengine.api import users
from django.utils import simplejson

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        user = users.get_current_user()
        if not user:
            return self.javascriptError('Please sign in to save your settings')

        # First check that the handle, if provided, is valid.
        handleValue = self.request.get('handle', '')
        if handleValue:
            if models.UserPreferences.gql('WHERE handle = :1 and owner != :2', handleValue, user).count():
                return self.javascriptError('Handle is already in use.  Please try another.')

        userPrefs = models.UserPreferences.getPreferencesForUser(user)
        [ setattr(userPrefs, k, self.request.get(k, '')) for k in userPrefs.properties().keys() if k != 'owner' ]
        userPrefs.put()

        handleJS = simplejson.dumps(handleValue or user.nickname())
        self.response.out.write(\
        """ <html> <head>
                <script type="text/javascript" language="javascript">
                top.$('nicknameDisplay').update(%(handleJS)s);
                top.$('settingsHolder').removeClassName('IconHolderHover');
                </script>
            </head> <body> </body> </html>
        """ % locals())
