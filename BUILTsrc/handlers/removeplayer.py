from google.appengine.ext import db
from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        user = users.get_current_user()

        playerId = self.request.get('player', None)
        if playerId is None:
            return

        campaign = self.getAuthorizedModelOfClasses(self.VIEW, [models.Campaign])
        if not campaign:
            return

        try:
            matchingPlayer = [ p for p in campaign.players if p.user_id() == playerId ][0]
        except IndexError:
            return

        # Make sure that I am either the campaign owner or the actual player.
        # Don't let the owner remove himself; he should be deleting the campaign.
        if (not users.is_current_user_admin()) and user not in (campaign.owner, matchingPlayer):
            return
        if matchingPlayer == campaign.owner:
            return

        # Take note of all characters in the campaign before deleting the membership.
        charactersBeforeDelete = campaign.characters
        matchingMembers = campaign.character_memberships.filter('owner =', matchingPlayer)
        matchingMembers = [ mm for mm in matchingMembers ]
        db.delete(matchingMembers)

        # Then update the model, setting ip4XML to re-trigger XML generation with new players and characters.
        campaign.players.remove(matchingPlayer)
        campaign.ip4XML = ''
        campaign.put()

        # Finally, set up character search again (including the deleted one) because viewers have changed.
        [ cm.putSearchResult() for cm in charactersBeforeDelete ]
