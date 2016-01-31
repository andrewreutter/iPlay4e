from django.utils import simplejson
from google.appengine.api import users, datastore_errors

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        charIdsToNamesToValues = simplejson.loads(self.request.get('toBeSaved', '{}'))

        numSet = 0
        for characterKey, namesToValues in charIdsToNamesToValues.items():
            try:
                model = getattr(models, models.VERSIONED_CHARACTER_CLASS).get(characterKey)
            except datastore_errors.BadKeyError:
                continue
            if not model.authorizeUserAbility(users.get_current_user(), model.EDIT):
                continue

            # Because in the list we have u'asdf' and that's not valid JSON.
            if namesToValues.has_key('CUR_Conditions'):
                namesToValues['CUR_Conditions'] = [ str(cc) for cc in namesToValues['CUR_Conditions']]

            model.saveState(namesToValues)
            numSet += len(namesToValues.keys())

        self.response.out.write(simplejson.dumps(numSet))
