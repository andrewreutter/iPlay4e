from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):

        owner = self.request.get('owner', None)
        if not owner:
            return self.javascriptError('You must supply a new email address to change the owner')
        try:
            newOwner = models.EmailToUser.emailsToGoodUsers([owner])[0]
        except IndexError:
            return self.javascriptError('Invalid email address %(email)s provided' % locals())

        model = self.getAuthorizedModelOfClasses(self.ADMIN, models.getSearchableClasses(), returnNone=True)
        if model is None:
            key = self.request.get('key', None)
            return self.javascriptError('Invalid object key %(key)s provided' % locals())

        model.owner = newOwner
        model.putAndUpdateCampaigns()
        return self.reloadTop()
