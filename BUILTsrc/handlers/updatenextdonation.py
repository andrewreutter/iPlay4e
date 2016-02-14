from google.appengine.api import users

from IP4ELibs import models, BaseHandler

import datetime

class MainHandler(BaseHandler.BaseHandler):

    def get(self):

        # Can't give credit if you're not authenticated...
        user = users.get_current_user()
        if not user:
            return self.reloadTop()

        nextTime = models.DonatingUser.fromUser(user)
        nextTime.nextDonationRequest = datetime.date.today() + datetime.timedelta(int(self.request.get('tm')) * 30)
        nextTime.put()

        return self.reloadTop()
