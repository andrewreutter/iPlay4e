from google.appengine.api import users

from IP4ELibs import models, BaseHandler
from IP4ELibs.ModelTypes import SearchModels

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        campaign = self.getAuthorizedModelOfClasses(self.MEMBER, [models.Campaign])
        if not campaign:
            return self.redirect(self.request.referrer)

        user = users.get_current_user()
        if not user:
            return

        # Build models for the characters that were selected but don't already belong to the campaign.
        existingKeys = [ str(c.key()) for c in campaign.characters ]
        addedCharacters = []
        for myCharacter in getattr(models, models.VERSIONED_CHARACTER_CLASS).all().filter('owner =', user):
            myKey = str(myCharacter.key())
            if myKey in existingKeys or self.request.get(('add%s' % myKey), None) != 'add':
                continue

            addedCharacters.append(myCharacter)
            models.CampaignCharacter(owner=user, campaign=campaign, character=myCharacter).put()

        # Retrigger XML and search result generation, including for characters because of visibility.
        campaign.ip4XML = ''
        campaign.put()
        [ cm.putSearchResult() for cm in addedCharacters ]
        self.redirect(self.request.referrer)
