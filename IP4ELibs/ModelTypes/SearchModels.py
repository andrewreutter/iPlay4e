from google.appengine.ext import db
from google.appengine.api import users
from google.appengine.ext import deferred

import search, re, logging
import IP4XMLModels
from IP4ELibs import IP4DB

class SearchResult(search.Searchable, db.Model):
    """ One type of entity stores all search results.
    """

    owner = db.UserProperty(required=True)
    viewers = db.ListProperty(users.User)
    viewerIds = db.ListProperty(str)
    isPublic = db.BooleanProperty(required=True, default=True)

    # e.g. Gilpa, half-elf assault swordmage 4 || Kobold High Priest, Medium immortal humanoid (undead) 4
    title = db.StringProperty()      
    subtitle = db.StringProperty()   # e.g. Arcane Controller || Elite Controller (Leader)
    searchtext = db.TextProperty()

    modelType = db.StringProperty() # e.g. Character || Monster
    modelKey = db.StringProperty()  # e.g. ab902345jasdbqewrtk7qqtokh-AHR

    INDEX_ONLY = ['searchtext']
    INDEX_TITLE_FROM_PROP = 'title' 

    @property
    def model(self):
        return IP4DB.get(self.modelKey)

    class SearchRequest:
        LEVEL_RANGE_REGEX = re.compile('[^\d]*([\d]+)-([\d]+)') # match "fighter 1-10"

        def __init__(self):
            self.setUser(None).setString(None).setTypes(None).setCampaign(None)
        def setUser(self, user):
            self.__user = user
            return self
        def setString(self, string):
            self.__string = string
            return self
        def setCampaign(self, campaignKey):
            self.__campaignKey = campaignKey
            return self
        def setTypes(self, typeList):
            self.__typeList = typeList
            return self

        def isViable(self):
            # We must have either owner or a string.
            return (self.__user, self.__string, self.__campaignKey) != (None, None, None)

        def get(self):
            ret = None
            # We have a string or an owner or both.  isViable() said so, right?

            if self.__string:

                # If they didn't enter something like "1-10", we just search for what they typed.
                levelRangeMatch = self.LEVEL_RANGE_REGEX.match(self.__string)
                if not levelRangeMatch:
                    searchStrings = [self.__string]
                else:
                    lowLevel, highLevel = [ int(g) for g in levelRangeMatch.groups() ]
                    baseSearch = self.__string.replace('%d-%d' % (lowLevel, highLevel), '')

                    # But for level-ranged searches, we actually perform multiple searches.
                    lowAndHighLevel = [min(lowLevel, 30), min(highLevel, 30)]
                    lowAndHighLevel.sort() # in case they specified 20-11 (high first)
                    lowLevel, highLevel = lowAndHighLevel
                    searchStrings = [ '%s %d' % (baseSearch, l) for l in range(lowLevel, highLevel+1) ]
                
                #logging.debug('searchStrings: %(searchStrings)r' % locals())
                resultsPerLevel=200/len(searchStrings)
                ret = []
                [   ret.extend([r for r in SearchResult.search(ss, limit=resultsPerLevel) if r.isPublic]) \
                    for ss in searchStrings \
                ]

            if self.__user:
                userId = self.__user.user_id()
                # Limit by owner at either the query or result level
                if ret is not None:
                    ret = [ r for r in ret if userId in (r.viewerIds or ()) or self.__user in r.viewers or self.__user == r.owner ]
                else:
                    # XXX Hopefully, this is temporary code.  It handles the fact that
                    # earlier versions of v31 didn't have the viewers field.
                    badResults = \
                    [   sr for sr in SearchResult.gql('WHERE owner = :1', self.__user) \
                        if self.__user not in sr.viewers \
                    ]
                    db.delete(badResults)
                    [ br.model.putSearchResult() for br in badResults ]

                    ret = {}
                    for propName, matchValue in \
                    (   ('viewers', self.__user),
                        ('viewerIds', userId),
                    ):
                        [   ret.update({str(sr.key()): sr}) \
                            for sr in SearchResult.gql('WHERE %s = :1' % propName, matchValue) \
                        ]
                    ret = ret.values()

                    # We had a bug for a while that caused 2 SearchResult models for each character.
                    # Clean up from that.
                    newRet, dupResults = {}, []
                    for thisResult in ret:
                        firstRec = newRet.get(thisResult.modelKey, None)
                        if firstRec is None:
                            newRet[thisResult.modelKey] = thisResult
                        else:
                            dupResults.append(thisResult)
                    dupResults and db.delete(dupResults)
                    ret = newRet.values()

                    ret.sort(lambda x,y:cmp(x.title, y.title))

            if self.__campaignKey:
                from IP4ELibs import models
                self.__theCampaign = models.Campaign.get(self.__campaignKey)
                characterKeys = [ str(c.key()) for c in self.__theCampaign.characters ]
                ret = characterKeys and SearchResult.gql('WHERE modelKey IN :1 ORDER BY title', characterKeys) or []

            # Either way, we can limit by type
            ret = ret or []
            if self.__typeList is not None:
                ret = [ r for r in ret if r.modelType in self.__typeList ]

            # Finally, make sure the search results refer to models that still exist.
            # We'd like to remove this code eventually; it exists because we weren't
            # always deleting search results when models were deleted.  Now we are.
            from IP4ELibs import models
            rawModelKeysAndTypes = [ (r.modelKey, r.modelType) for r in ret ]
            modelKeysAndTypes = [ (db.Key(IP4DB.hrdKey(r.modelKey)), r.modelType) for r in ret ]

            #raise RuntimeError, 'RAW: %(rawModelKeysAndTypes)r, KEYED: %(modelKeysAndTypes)r' % locals()
            modelExistenceBooleans = \
            [   getattr(models, mType).all(keys_only=True).filter('__key__ =', mKey).count() \
                for mKey, mType in modelKeysAndTypes \
            ]
            db.delete([ r for (r, mBool) in zip(ret, modelExistenceBooleans ) if not mBool ])
            ret = [ r for (r, mBool) in zip(ret, modelExistenceBooleans ) if mBool ]

            return ret

        def getTitle(self):
            if self.__campaignKey:
                return '%s - Characters' % self.__theCampaign.name
            if self.__user:
                if self.__typeList and not self.__string:
                    from IP4ELibs import models
                    displayableTypeList = [ getattr(models, tl).PLURAL for tl in self.__typeList]
                    typeListStr = ', '.join(['%s' % dtl for dtl in displayableTypeList])
                    return 'My %(typeListStr)s' % locals()
            if self.__string:
                return 'Search for: %s' % self.__string
            return ''

class HasSearchResults:
    """ Mixed into Character, Monster, etc...to encapsulate relationship with the SearchResult class.
        Those classes should:

            - Define owner, viewers, isPublic, title, subtitle, and searchtext fields or properties.
            - Call putSearchResult() when put() is called.
            - Call deleteSearchResult() when delete() is called.
    """

    def putSearchResult(self):
        """ Create the SearchResult entity that points at me, with relevant searchable goodness.
            Does the indexing offline for perfomance's sake.
        """

        # We have to call buildSearchResult() before deleteSearchResult().  Why, you ask?  Because:
        #   - buildSearchResult() accesses character.title
        #   - character.title calls character.buildDom()
        #   - character.buildDom() calls character.put() if ip4xml isn't already built.
        #   - character.put() calls character.putSearchResult()
        #   - and we're back here.  
        # Therefore the call to deleteSearchResult() clears out the first one so we don't get dups.
        searchResult = self.buildSearchResult()
        self.deleteSearchResult()
        searchResult.put()
        deferred.defer(searchResult.index)

    def getSearchResults(self):
        return SearchResult.all().filter('modelKey = ', str(self.key()))

    def deleteSearchResult(self):
        db.delete([ sr for sr in self.getSearchResults() ])

    def buildSearchResult(self):
        """ Create the SearchResult entity that points at me, with relevant searchable goodness.
            Does the indexing offline for perfomance's sake.
        """

        viewers = self.viewers
        viewerIds = [ v.user_id() for v in viewers ]
        viewerIds = [ vi for vi in viewerIds if vi is not None ] # when a user has changed email address...
        searchDict = \
        {   'owner': self.owner,
            'viewers': viewers,
            'viewerIds': viewerIds,
            'isPublic': self.isPublic,
            'title': self.title,
            'subtitle': self.subtitle,
            'searchtext': self.searchtext,
            'modelType': self.__class__.__name__,
            'modelKey': str(self.key()),
        }
        try:
            return SearchResult(**searchDict)
        except db.BadValueError:
            logging.debug('searchDict: %(searchDict)r' % locals())
            raise
