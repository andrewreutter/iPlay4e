import time, logging, datetime, types
from google.appengine.ext import db

class HasCombatState:
    """ When you mix this into a Model class, you must override the getStateClass() method.
    """

    def getStateClass(self):
        return None

    def getState(self, timestamp=None):
        #logging.error('getState(%(timestamp)s)' % locals())

        retValues = self.getStateClass().all()
        retValues.filter('character =', self)
        if timestamp:
            inDatetime = apply(datetime.datetime, time.gmtime(timestamp)[:-2])
            retValues.filter('modified >', inDatetime)
        #retValues.count() and logging.error('modified: %r' % retValues[0].modified.__class__)
        return retValues

    def saveState(self, namesToValues, overrideCurrent=1, knownEmpty=0):

        # Add the new ones while considering the old (unless we known there are no old).
        if knownEmpty:
            oldNamesAndCVs = []
        else:
            oldNamesAndCVs = [ (mcv.name, mcv) for mcv in self.getState() ]

        modelsToDelete, modelsToPut = [], []
        for reqName, reqValue in namesToValues.items():
            oldCVs = [onac[1] for onac in oldNamesAndCVs if onac[0] == reqName ]

            # If set to override, delete whatever already existed for those names.
            # If not set to override, and there are values, quit now.
            if overrideCurrent:
                modelsToDelete.extend(oldCVs)
            elif oldCVs:
                continue

            # Convert numeric values to strings, and strings to unicode utf-8
            # If the value is just "false", which is a default, don't bother.
            if not hasattr(reqValue, 'replace'):
                reqValue = str(reqValue)
            if type(reqValue) is not types.UnicodeType:
                reqValue = reqValue.decode('utf-8')
            if reqValue == u'false':
                continue

            isLongValue = (reqValue.find('\n') != -1) or len(reqValue) > 500
            newValue = self.getStateClass()(\
                **{ 'character': self, 'name': reqName, 
                    'text': isLongValue and reqValue or '',
                    'value': (not isLongValue) and reqValue or '',
                  })
            modelsToPut.append(newValue)

        db.delete(modelsToDelete)
        db.put(modelsToPut)
