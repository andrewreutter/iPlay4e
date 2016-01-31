from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        self.response.headers['Content-Type'] = 'text/javascript'

        user = users.get_current_user()
        if not user:
            return self.response.out.write('alert("You must be signed in to remove characters from campaigns!");')

        campaign = self.getAuthorizedModelOfClasses(self.MEMBER, [models.Campaign], returnNone=True)
        character = self.getAuthorizedModelOfClasses(self.VIEW, 
            [getattr(models, models.VERSIONED_CHARACTER_CLASS)], 
            requestKey='character', returnNone=True)

        if not (campaign and character and user):
            return self.response.out.write('alert("You are not authorized to remove this character!");')

        # Find and delete this campaign/character combo, if it belongs to me.
        [   cm.delete() for cm in models.CampaignCharacter.gql(\
                'WHERE campaign = :1 AND character = :2', campaign, character) \
            if campaign.owner == user or cm.character.owner == user
        ]

        # Re-trigger XML generation and search results for the campaign,
        # and also for the character because the viewers have changed.
        campaign.ip4XML = ''
        campaign.put()
        character.putSearchResult()

        return self.response.out.write('location.reload();')
