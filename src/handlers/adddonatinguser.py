from google.appengine.api import users

from IP4ELibs import models, BaseHandler

from datetime import *

class MainHandler(BaseHandler.BaseHandler):

    FORM_CONTENT = \
    """ Enter the email address of a new donating user:
        <form method="GET" action="adddonatinguser">
            <input name="email" id="email" />
            <input type="submit" value="Add Donating User" />
        </form>
        <script>
            document.getElementById('email').focus();
        </script>
    """

    def get(self):
        if not users.is_current_user_admin():
            loginUrl = users.create_login_url(self.request.url)
            return self.response.out.write(\
            """ You must be an admin to add donating users.  <a href="%(loginUrl)s">Sign in</a>
            """ % locals())

        userEmail = self.request.get('email', None)
        if not userEmail:
            return self.response.out.write(self.FORM_CONTENT)

        # If we find a matching user, use their ID and canonical email address.
        try:
            matchingUser = models.EmailToUser.emailsToGoodUsers([userEmail])[0]
            userId, userEmail = matchingUser.user_id(), matchingUser.email()
        except IndexError:
            # Otherwise, use the provided email address and no ID.
            userId = None

        # Has the user donated before?  Start by assuming so.
        actionMessage = 'Donating user already existed'
        donatingUser = models.DonatingUser.fromUser(None, userEmail=userEmail, userId=userId)
        if donatingUser.nonDonating:

            # The user has not donated.  Change that fact and our message.
            donatingUser.nonDonating = False
            actionMessage = 'Created donating user:'
            donatingUser.nextDonationRequest = date.today() + timedelta(90)
            donatingUser.put()

        formContent = self.FORM_CONTENT
        return self.response.out.write(\
        """ %(actionMessage)s
            <div style="margin-left:20px;">
                emailAddress: %(userEmail)s
                <br/>
                userId: %(userId)s
            </div>
            <p>
                %(formContent)s
            </p>
        """ % locals())
