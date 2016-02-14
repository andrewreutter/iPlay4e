from google.appengine.api import users
import json as simplejson

from IP4ELibs.ModelTypes import SearchModels
from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        retDict = {}

        user, url = users.get_current_user(), self.request.get('url', self.request.referrer)
        if not user:
            retDict['url'] = users.create_login_url(url)
            return self.response.out.write(simplejson.dumps(retDict))

        # Most of our return keys come from the Google user proper.
        retDict.update({
            'url': users.create_logout_url(url),
            'id': user.user_id(),
            'email': user.email(),
            'nickname': user.nickname(),
            'isAdmin': users.is_current_user_admin() and 1 or 0,
        })

        # Return donation-related values from the DonatingUser model.
        donatingUserObj = models.DonatingUser.fromUser(user)
        retDict.update({
            'reminderDate': str(donatingUserObj.nextDonationRequest or 0),
            'hasDonated': (not donatingUserObj.nonDonating) and 1 or 0,
        })

        # Retrieve the characters and campaigns for this user (XXX should probably be at-need for optimization...)
        retDict['characters'], retDict['campaigns'] = [], []
        mySearch = SearchModels.SearchResult.SearchRequest().setUser(user)
        [   {   'Campaign': retDict['campaigns'],
                models.VERSIONED_CHARACTER_CLASS: retDict['characters'],
            }[o.modelType].append(\
                {   'title':o.title, 'subtitle':o.subtitle, 'key':o.modelKey, 
                    'isOwner':(o.owner==user and 1 or 0),
                }) \
            for o in mySearch.setTypes([ c.__name__ for c in models.getSearchableClasses()]).get() \
        ]


        userPrefs = models.UserPreferences.getPreferencesForUser(user)
        retDict['prefs'] = dict([ (k,(getattr(userPrefs, k) or '')) for k in userPrefs.properties().keys() if k != 'owner' ])

        self.response.out.write(simplejson.dumps(retDict))
