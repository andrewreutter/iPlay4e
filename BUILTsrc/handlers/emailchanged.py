""" Fix up a user whose Google email address changed.
"""

from google.appengine.api import users

from IP4ELibs import models, BaseHandler
from IP4ELibs.ModelTypes import SearchModels

class MainHandler(BaseHandler.BaseHandler):

    FORM_CONTENT = \
    """ 
        <div style="margin-left:20px;color:red;">
            %(errorMessages)s
        </div>
        <div style="margin-left:20px;">
            %(statusMessages)s
        </div>

        Enter the old and new email addresses of a user who changed their Google account:
        <form method="GET" action="emailchanged">
            <input name="oldEmail" id="oldEmail" value="%(oldEmail)s" />
            <input name="newEmail" id="newEmail" value="%(newEmail)s" />
            <input type="submit" value="Fix User" />
        </form>
        <script>
            document.getElementById('oldEmail').focus();
        </script>
    """

    def get(self):
        errorMessages, statusMessages = '', ''

        if not users.is_current_user_admin():
            loginUrl = users.create_login_url(self.request.url)
            return self.response.out.write(\
            """ You must be an admin to change user emails.  <a href="%(loginUrl)s">Sign in</a>
            """ % locals())

        # If both weren't provided, ask for the rest.
        oldEmail, newEmail = self.request.get('oldEmail', ''), self.request.get('newEmail', '')
        if not (oldEmail and newEmail):
            return self.response.out.write(self.FORM_CONTENT % locals())

        # Both also need to have been good.
        goodOwners, badEmails = models.EmailToUser.emailsToGoodUsers([oldEmail, newEmail], returnBad=True)
        if badEmails:
            errorMessages = 'Bad email address(es):<ul><li>%s</li></ul>' % '</li><li>'.join(badEmails)
            return self.response.out.write(self.FORM_CONTENT % locals())
        oldOwner, newOwner = users.User(oldEmail), users.User(newEmail)

        # First, see if there's a UserPreferences object that needs updating.
        statusMessages = []
        oldPrefs = models.UserPreferences.getPreferencesForUser(oldOwner, createMissing=False)
        if oldPrefs is None:
            statusMessages.append('No preferences for %(oldEmail)s were found' % locals())
        else:
            oldPrefs.owner = newOwner
            oldPrefs.put()
            statusMessages.append('Updated preferences (handle: %s)' % oldPrefs.handle)

        # Loop through the first five objects they own.
        searchRequest = SearchModels.SearchResult.SearchRequest()
        searchRequest.setUser(oldOwner)
        ownedModels = []
        for objectClass in (models.CharacterV2, models.Campaign):
            ownedModels.extend([m for m in objectClass.gql('WHERE owner = :1', oldOwner)])
        #ownedModels = [ thisResult.model for thisResult in searchRequest.get() ]
        modelsToProcess = ownedModels[:5]

        # The way we save varies for characters and campaigns.
        # While we're at it, find ones we didn't know what to do with.
        noUpdateKeys = []
        for thisModel in modelsToProcess:
            thisKey = thisModel.key()
            thisModel.owner = newOwner

            foundUpdateMethod = False
            for updateMethodName in ('putAndUpdateCharacterSearch', 'putAndUpdateCampaigns'):
                updateMethod = getattr(thisModel, updateMethodName, None)
                if updateMethod is not None:
                    foundUpdateMethod = True
                    updateMethod()
                    statusMessages.append('Called %(updateMethodName)s for model key %(thisKey)s' % locals())

            if not foundUpdateMethod:
                noUpdateKeys.append(thisModel)

        if noUpdateKeys:
            errorMessages = 'No update methods for models:<ul><li>%s</li></ul>' \
                % '</li><li>'.join([ str(m) for m in noUpdateKeys ])

        numObjects, numProcessed = len(ownedModels), len(modelsToProcess)
        statusMessages.append('Updated %(numProcessed)d of %(numObjects)d models (submit again to update more)' % locals())

        statusMessages = 'The following actions were taken:<ul><li>%s</li></ul>' % '</li><li>'.join(statusMessages)
        return self.response.out.write(self.FORM_CONTENT % locals())
