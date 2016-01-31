from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        email = self.request.get('email', None)
        self.response.out.write('Provided email: %(email)s<br/>' % locals())
        if not email:
            return self.response.out.write('You must supply an email address to view a user id')

        if not users.is_current_user_admin():
            return self.response.out.write('You must be an admin to view user ids')

        try:
            matchingUser = models.EmailToUser.emailsToGoodUsers([email])[0]
        except IndexError:
            return self.response.out.write('Invalid email address %(email)r provided' % locals())

        userId, userEmail = matchingUser.user_id(), matchingUser.email()
        self.response.out.write('Matching user ID: %(userId)s<br/>' % locals())
        self.response.out.write('Canonical email: %(userEmail)s<br/>' % locals())
