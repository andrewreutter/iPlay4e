from google.appengine.ext import db
from google.appengine.api import users
from google.appengine.ext import deferred

import logging, re, cgi

import IP4XML, IP4DB
from ModelTypes import AuthorizedModel, SearchResult, HasSearchResults, HasIP4XML, HasCombatState

class MigratoryModel(db.Model):
    """ Just like db.Model, except translates get() calls to HRD-style keys in case we get pre-HRD keys
    """

    def get(klass, key):

        if type(key) == type([]):
            newKey = [IP4DB.hrdKey(k) for k in key]
        else:
            newKey = IP4DB.hrdKey(key)

        return db.Model.get(newKey)

    get = classmethod(get)

class UserItemNote(MigratoryModel):

    user_id = db.StringProperty(required=True)
    item_key = db.StringProperty(required=True)
    name = db.StringProperty(required=True)
    note = db.TextProperty()

class UserPreferences(MigratoryModel):
    owner = db.UserProperty(required=True)
    handle = db.StringProperty()

    def getPreferencesForUser(thisClass, user, createMissing=True):
        """ Get (or create if necessary) preferences for this user.

            Pass createMissing=False to return None if no prefs are found.
        """

        # Return existing record, if any.
        userPrefs = thisClass.gql('WHERE owner = :1', user)
        if userPrefs.count():
            return userPrefs[0]

        if not createMissing:
            return None

        userPrefs = thisClass(owner=user)
        userPrefs.put()
        deferred.defer(SiteCounters.incrementCounter, 'users')

        return userPrefs
    getPreferencesForUser = classmethod(getPreferencesForUser)

class DonatingUser(MigratoryModel):
    """ We would like to have one of these for each user in the system, keyed by userId.

        We used to store them by userEmail, though, so th
    """

    emailAddress = db.StringProperty(required=True)
    userId = db.StringProperty()
    nextDonationRequest = db.DateProperty(auto_now_add=True)
    nonDonating = db.BooleanProperty(default=False, verbose_name='Non-donating')

    def fromUser(thisClass, googleUser, userEmail=None, userId=userId):
        """ Convert a Google users.get_current_user() to a DonatingUser model (or None if unauthenticated).

            As a side effect, we ensure the presence of
        """

        # If they passed in a user object, user the email and ID.
        if googleUser:
            userEmail, userId = googleUser.email(), googleUser.user_id()
        else:

            # But they may have passed in email and/or ID manually.
            if not (userEmail or userId):
                return None

        # Hopefully, this is a recently created DonatingUser based on userId instead of userEmail.
        donatingUser = userId and thisClass.gql('WHERE userId = :1', userId).get() or None
        if not donatingUser:

            # If user ID fails, try by email as well.  
            # If _that_ works, add the userId to avoid the need for the second query in the future.
            donatingUser = userEmail and thisClass.gql('WHERE emailAddress = :1', userEmail).get() or None
            if donatingUser:
                donatingUser.userId = userId
                donatingUser.put()

            # Neither user ID nor email provided a result.
            # Add a non-donating DonatingUser to avoid the need for the second query in the future.
            else:
                donatingUser = thisClass(emailAddress=userEmail, userId=userId, nonDonating=True)
                donatingUser.put()

        return donatingUser

    fromUser = classmethod(fromUser)

class SiteCounters(MigratoryModel):
    name = db.StringProperty(required=True)
    value = db.IntegerProperty(required=True)

    def incrementCounter(thisClass, name):
        theCounter = thisClass.nameToCounter(name)
        theCounter.value += 1
        theCounter.put()
    incrementCounter = classmethod(incrementCounter)

    def nameToCounter(thisClass, name):
        # Hopefully, the counter already exists.
        ret = thisClass.gql('WHERE name = :1', name)
        if ret.count():
            return ret[0]

        # Nope, initialize and return.
        ret = thisClass(name=name, value=0)
        ret.put()
        return ret
    nameToCounter = classmethod(nameToCounter)

class Campaign(AuthorizedModel, HasSearchResults, HasIP4XML, HasCombatState, MigratoryModel):
    PLURAL = 'Campaigns'
    XML_VERSION = 9
    xmlVersion = db.IntegerProperty()

    owner = db.UserProperty(required=True)
    isPublic = db.BooleanProperty(default=True, verbose_name='Is public')
    ip4XML = db.BlobProperty()

    name = db.StringProperty(required=True)
    world = db.StringProperty()
    description = db.TextProperty()
    players = db.ListProperty(users.User)
    editrule = db.StringProperty(default='dmonly') # or 'players' or None (if created before this prop was added)...

    wikiUrl = db.StringProperty(default='')
    groupUrl = db.StringProperty(default='')
    blogUrl = db.StringProperty(default='')

    def authorizeUserAbility(self, user, ability):
        if ability == self.MEMBER:
            return user and (user.user_id() in self.playerIds)
        return super(Campaign, self).authorizeUserAbility(user, ability)

    @property
    def playerIds(self):
        return [ p.user_id() for p in self.players ]

    def put(self):
        isNew = not self.is_saved()
        db.Model.put(self)
        self.putSearchResult()
        isNew and deferred.defer(SiteCounters.incrementCounter, 'campaigns')

    def putAndUpdateCharacterSearch(self):
        myCharacters = self.characters
        db.Model.put(self)

        searchResultsToDelete = []
        searchResultsToDelete.extend(self.getSearchResults())
        [ searchResultsToDelete.extend(c.getSearchResults()) for c in myCharacters ]

        searchResultsToPut = [ self.buildSearchResult() ]
        [ searchResultsToPut.append(c.buildSearchResult()) for c in myCharacters ]

        db.delete(searchResultsToDelete)
        db.put(searchResultsToPut)
        [ deferred.defer(searchResult.index) for searchResult in searchResultsToPut ]

    def delete(self):

        # Delete all character memberships in the campaign so that when we
        # rebuild those characters' search results, co-players won't see them anymore.
        # First snag the character list for later use, though.
        myCharacters = self.characters
        db.delete([ cm for cm in self.character_memberships])

        searchResultsToDelete = []
        searchResultsToDelete.extend(self.getSearchResults())
        [ searchResultsToDelete.extend(c.getSearchResults()) for c in myCharacters ]

        searchResultsToPut = []
        [ searchResultsToPut.append(c.buildSearchResult()) for c in myCharacters ]

        db.delete(searchResultsToDelete)
        db.put(searchResultsToPut)
        [ deferred.defer(searchResult.index) for searchResult in searchResultsToPut ]

        db.Model.delete(self)

    @property
    def characters(self):
        retList = [ cm.getCharacterIfExists() for cm in self.character_memberships ]
        retList = [ rl for rl in retList if rl is not None ]
        retList.sort(lambda x,y: cmp(x.name, y.name))
        return retList

    @property
    def playersDMFirst(self):
        players = self.players[:]

        # We had a bug for a minute where you could store an invalid user.  Fix it.
        if None in [ p.user_id() for p in players ]:
            self.players = [ player for player, userId in zip(players, [ p.user_id() for p in players ]) if userId ]
            players = self.players[:]
            db.put(self)

        (self.owner in players) and players.remove(self.owner)
        players.insert(0, self.owner)
        return players

    @property
    def playerNames(self):
        return [ p.nickname().split('@')[0] for p in self.playersDMFirst ]

    @property
    def characterNames(self):
        return [ c.name for c in self.characters ]

    @property
    def viewers(self):
        return self.players

    @property
    def title(self):
        return self.name

    @property
    def subtitle(self):
        return self.world or ''

    @property
    def searchtext(self):
        return ' '.join( \
            ( self.name, self.world or '', self.description or '', 
              ' '.join(self.playerNames), ' '.join(self.characterNames)
            ))

    # METHODS for HasIP4XML

    def buildDom(self):
        return IP4XML.IP4CampaignTree(self)

VERSIONED_CHARACTER_CLASS = 'CharacterV2'
class CharacterV2(AuthorizedModel, HasSearchResults, HasIP4XML, HasCombatState, MigratoryModel):
    PLURAL = 'Characters'
    XML_VERSION = 52
    xmlVersion = db.IntegerProperty()

    owner = db.UserProperty(required=True)
    isPublic = db.BooleanProperty(default=True, verbose_name='Is public')

    wotcData = db.BlobProperty()
    ip4XML = db.BlobProperty()

    # We need the \\s* to detect the arbitrary number of whitespaces that is
    # sometimes spit out by the character builder.
    TEXTSTRING_MATCHSTRING = '<textstring name="%s"\\s*>.*?</textstring>'

    SAVE_FILE_MATCHER = re.compile(TEXTSTRING_MATCHSTRING % 'Character Save File', re.DOTALL)
    SAVE_FILE_REPLACEMENT = '<textstring name="Character Save File">\n\n   </textstring>'

    def authorizeUserAbility(self, user, ability):

        # We actually have our co-players stored off.
        if ability == self.MEMBER:
            return user and (user.user_id() in self.playerIds)

        # Both the owner and the DM can edit a character.
        if ability == self.EDIT:
            return self.authorizeUserAbility(user, self.OWNER) or (user and self.playerCanEdit(user))

        return super(CharacterV2, self).authorizeUserAbility(user, ability)

    @property
    def playerIds(self):
        return [ p.user_id() for p in self.players ]

    @property
    def players(self):
        ret = []
        [ ret.extend(c.players) for c in self.campaigns ]
        return ret

    @property
    def campaigns(self):
        retList = [ cm.getCampaignIfExists() for cm in self.campaign_memberships ]
        return [ rl for rl in retList if rl is not None ]

    def playerCanEdit(self, user): 
        """ Can a given player edit this character? Used instead of editingPlayers for efficiency.
        """

        # Testing the DM is cheapest, so do it first.
        for campaign in self.campaigns:
            if user == campaign.owner:
                return True

        # We're still avoiding accessing .players as much as possible here...
        for campaign in self.campaigns:
            if campaign.editrule == 'players' and user in campaign.players:
                    return True

        return False

    @property
    def editingPlayers(self): # Who, besides the owner, may edit this Character?
        ret = []
        for campaign in self.campaigns:
            ret.append(campaign.owner)
            if campaign.editrule == 'players':
                ret.extend(c.players)
        return ret

    def put(self):
        isNew = not self.is_saved()
        try:
            super(CharacterV2, self).put()
        except UnicodeDecodeError:
            raise ValueError, 'bad value found in %r' % (self.wotcData)
        self.putSearchResult()
        isNew and deferred.defer(SiteCounters.incrementCounter, 'characters')

    def putAndUpdateCampaigns(self):
        myCampaigns = self.campaigns
        for myCampaign in myCampaigns:
            myCampaign.ip4XML = None

        db.put(self)

        # We have to build the "put"s before the "delete"s because just building
        # it can cause the search result to be saved (circular BS).
        searchResultsToPut = [ self.buildSearchResult() ]
        [ searchResultsToPut.append(c.buildSearchResult()) for c in myCampaigns ]

        searchResultsToDelete = []
        searchResultsToDelete.extend(self.getSearchResults())
        [ searchResultsToDelete.extend(c.getSearchResults()) for c in myCampaigns ]

        db.delete(searchResultsToDelete)
        try:
            db.put(myCampaigns + searchResultsToPut)
        except db.BadValueError:
            logging.debug('searchDict: %(searchDict)r' % locals())
            raise
        [ deferred.defer(searchResult.index) for searchResult in searchResultsToPut ]

    def delete(self):
        self.deleteSearchResult()
        db.Model.delete(self)

    # PROPERTIES for HasSearchResults

    @property
    def viewers(self):
        viewerIdsToViewers = { self.owner.user_id(): self.owner }
        allPlayers = []
        [ allPlayers.extend(campaign.players) for campaign in self.campaigns ]
        [ viewerIdsToViewers.update({player.user_id():player}) for player in allPlayers ]
        return viewerIdsToViewers.values()

    @property
    def name(self):
        dom = self.toDom()
        buildDom = dom.find('Build')

        # Seems some versions of ElementTree have rootNode, some don't...
        return getattr(dom, 'rootNode', dom).get('name')

    @property
    def title(self):
        dom = self.toDom()
        buildDom = dom.find('Build')

        # Seems some versions of ElementTree have rootNode, some don't...
        name = getattr(dom, 'rootNode', dom).get('name')

        build, level = buildDom.get('name'), buildDom.get('level')
        race = buildDom.find('Race').get('name')
        return '%(name)s, %(race)s %(build)s %(level)s' % locals()

    @property
    def subtitle(self):
        buildDom = self.toDom().find('Build')
        powerSource, role = buildDom.get('powersource'), buildDom.get('role')
        return '%(powerSource)s %(role)s' % locals()

    @property
    def searchtext(self):
        dom = self.toDom()
        buildDom = dom.find('Build')

        # Seems some versions of ElementTree have rootNode, some don't...
        name = getattr(dom, 'rootNode', dom).get('name')

        build, level = buildDom.get('name'), buildDom.get('level')
        powerSource, role = buildDom.get('powersource'), buildDom.get('role')
        race = buildDom.find('Race').get('name')

        return '%(name)s %(race)s %(build)s %(level)s %(powerSource)s %(role)s' % locals()

    # METHODS for HasIP4XML

    def buildDom(self, testing=False):
        """ Set testing=True if you just want to be sure the file is parsable before saving.
            This makes sure we don't choke on the absence of a key.
        """
        charKey = (not testing) and str(self.key()) or ''
        try:
            wotcData = self.SAVE_FILE_MATCHER.sub(self.SAVE_FILE_REPLACEMENT, self.wotcData)
            charSource = IP4XML.DND4ECharacterDataSource(charKey, wotcData)
            ret = IP4XML.IP4CharacterTree(charSource)
        except Exception, errorMessage:
            logging.exception('bad .rtf data: %(errorMessage)s: %(wotcData)s' % locals())
            raise ValueError, 'bad data: %(errorMessage)s' % locals()

        if not testing:
            self.readCurrentValuesFromData(overrideCurrent=True)
        return ret

    # OTHER METHODS

    def getStateClass(self):
        return CharacterCurrentValueV2

    def getDataWithState(self):
        """ Get my dnd4e XML, with current state variables substituted in.
        """

        # Start off with raw dnd4e file contents; we'll need to reference our own XML too.
        ret, characterTree = self.wotcData, self.toDom()

        # This is our lame way of figuring out the character's current level by looking for the highest
        # level in a _PER_LEVEL tag.
        currentLevel = 0
        allLevels = range(1,31)
        allLevels.reverse()
        for thisLevel in allLevels:
            textStringName = '_PER_LEVEL_%(thisLevel)s_Carried Money' % locals()
            textStringMatcher = re.compile(self.TEXTSTRING_MATCHSTRING % textStringName, re.DOTALL|re.UNICODE)
            if textStringMatcher.search(ret):
                currentLevel = thisLevel
                break

        # Go through our current state looking for nice simple one-to-one variables.
        subDefinitions, coinsDict, itemsDict = [], {}, {}
        for currentValue in self.getState():
            name, value = currentValue.name, currentValue.textOrValue;

            tagName, textStringName = \
            {   'Experience Points':    ('Experience',  'Experience Points'),
                'CUR_Notes':            ('Notes',       'NOTE_Session and Campaign Notes'),
                'CUR_Appearance':       ('Appearance',  'NOTE_Mannerisms and Appearance'),
                'CUR_Traits':           ('Traits',      'NOTE_Personality Traits'),
                'CUR_Companions':       ('Companions',  'NOTE_Companions And Allies'),
            }.get(name, (None, None))
            if tagName:
                subDefinitions.append((tagName, textStringName, value))

            # But there's a case where several state variables comprise a single dnd4e value.
            elif not (name.find('CUR_carried') and name.find('CUR_stored')):
                coinsDict[name] = value

            # Sometimes they can also be items
            elif name.find('CUR_Item_') == 0:
                itemsDict[name] = value

        # And here is where we put them together.
        lootElement = characterTree.find('Loot')
        for moneyBucket in ('carried', 'stored'):
            moneyString = []
            for coinType in ('ad', 'pp', 'gp', 'sp', 'cp'):
                numCoins = coinsDict.get('CUR_%(moneyBucket)s%(coinType)s' % locals(), None)
                if numCoins is None:
                    numCoins = lootElement.get('%s-%s' % (moneyBucket, coinType), '0')
                numCoins = int(numCoins)
                numCoins and moneyString.append('%(numCoins)d %(coinType)s' % locals())
            moneyString = '; '.join(moneyString)

            capMoneyBucket = moneyBucket.capitalize()
            subDefinitions.append(('%(capMoneyBucket)sMoney' % locals(), '_PER_LEVEL_%(currentLevel)s_%(capMoneyBucket)s Money' % locals(), moneyString))

        # TODO: The below code can be optimized more. Way more.
        itemElement = lootElement.findall('Item')
        for loot in itemElement:
            #print loot, loot.get('display-class', ''), loot.get('count', ''), loot.get('equippedcount', '')
            itemName = loot.get('display-class', '')
            itemCount = itemsDict.get(itemName, loot.get('count', ''))
            #print itemCount

            # Go find the lootTally element
            #lootTallyElement = ret.toDom().find('LootTally')

            # Let's find the ruleselement with our weapon
            #rulesElement = lootTallyElement.findall('RulesElement')
            #for i in rulesElement:
            #    print i

            itemName = cgi.escape(loot.get('name', ''))
            htmlEscapeTable = {'"': "&quot;", "'": "&apos;"}
            itemName = ''.join(htmlEscapeTable.get(c,c) for c in itemName)
            #print itemName
            textStringMatcher = re.compile('<loot count="\d*" equip-count="\d*" ShowPowerCard="\d*"\s*>\s*<RulesElement name="%(itemName)s"' % locals(), re.DOTALL|re.UNICODE)

            equipCount = loot.get('equippedcount', '')
            showPowerCard = 1
            textStringReplacement = u'<loot count="%(itemCount)s" equip-count="%(equipCount)s" ShowPowerCard="%(showPowerCard)s" >  <RulesElement name="%(itemName)s"' % locals()
            textStringReplacement = textStringReplacement.encode('utf8')
            ret = textStringMatcher.sub(textStringReplacement, ret)

        # There are two different ways values may be stored in the XML.  Try both.
        for tagName, textStringName, value in subDefinitions:

            textStringMatcher = re.compile(self.TEXTSTRING_MATCHSTRING % textStringName, re.DOTALL|re.UNICODE)

            textStringReplacement = u'<textstring name="%s">\n      %s\n   </textstring>' % (textStringName,value)
            textStringReplacement = textStringReplacement.encode('utf8')
            ret = textStringMatcher.sub(textStringReplacement, ret)

            textStringMatcher = re.compile('<%s>.*?</%s>' % (tagName, tagName), re.DOTALL|re.UNICODE)
            textStringReplacement = u'<%s> %s </%s>' % (tagName, value, tagName)
            textStringReplacement = textStringReplacement.encode('utf8')
            ret = textStringMatcher.sub(textStringReplacement, ret)

        return ret
        
    TEXTSTRING_READER = '<textstring name="%s">(.*?)</textstring>'

    def readCurrentValuesFromData(self, overrideCurrent=0, knownEmpty=0):

        stateSaveDict = {}
        for ourName, wotcName in \
        (   ('Experience Points',   'Experience Points'),
            ('CUR_Notes',           'NOTE_Session and Campaign Notes'),
            ('CUR_Appearance',      'NOTE_Mannerisms and Appearance'),
            ('CUR_Traits',          'NOTE_Personality Traits'),
            ('CUR_Companions',      'NOTE_Companions And Allies'),
        ):
            readerMatch = re.compile(self.TEXTSTRING_READER % wotcName, re.DOTALL).search(self.wotcData)
            if readerMatch is not None:
                fileValue = readerMatch.groups()[0].strip() 
                stateSaveDict[ourName] = fileValue

        self.saveState(stateSaveDict, overrideCurrent=overrideCurrent, knownEmpty=knownEmpty)

class CharacterCurrentValueV2(MigratoryModel):
    """ Represent a single current value for a character.
    """
    character = db.Reference(CharacterV2, required=True)
    name = db.StringProperty(required=True)
    value = db.StringProperty()
    text = db.TextProperty()
    modified = db.DateTimeProperty(auto_now=True)

    @property
    def textOrValue(self):
        return self.text or self.value

class CampaignCharacter(MigratoryModel):
    owner = db.UserProperty(required=True)
    campaign = db.ReferenceProperty(Campaign, collection_name='character_memberships')
    character = db.ReferenceProperty(CharacterV2, collection_name='campaign_memberships')

    def getCharacterIfExists(self):
        try:
            ret = self.character
        except db.Error:
            return None

        try:
            ret.toDom() # To make sure the character hasn't gone bad somehow (too large, etc.).
        except HasIP4XML.DomTooLargeError:
            ret.delete()

        return ret

    def getCampaignIfExists(self):
        try:
            return self.campaign
        except db.Error:
            return None

class CampaignCustomTab(MigratoryModel):

    campaign = db.ReferenceProperty(Campaign, collection_name='campaign_custom_tabs')
    name = db.StringProperty(required=True)
    url = db.StringProperty(required=True)
    height = db.IntegerProperty(required=True, default=600)

class Character(MigratoryModel):
    """ Exists only to provide a migration path from old versions.
    """

    # Pieces from the .dnd4e file worth indexing.
    name = db.StringProperty(required=True, default='New Character')
    race = db.StringProperty(required=True, default='Human')
    characterClass = db.StringProperty(required=True, default='Fighter')
    build = db.StringProperty(default='Guardian Fighter')
    level = db.IntegerProperty(required=True, default=1)
    powerSource = db.StringProperty(required=True, default='Martial')
    role = db.StringProperty(required=True, default='Defender')

    # Administrative stuff
    dnd4eData = db.BlobProperty()
    owner = db.UserProperty(required=True)
    isPublic = db.BooleanProperty(default=True, verbose_name='Is public')

    # This lets us track migration to searchable characters.
    isMigrated = db.BooleanProperty(required=True, default=False)
    hadBadDataDuringMigration = db.BooleanProperty(required=True, default=False)
    newCharacter = db.Reference(CharacterV2)

    def getUnmigratedCharactersForUser(thisClass, user):
        unmigratedCharacters = []
        for oldCharacter in Character.gql('WHERE owner = :1', user):
            try:
                if oldCharacter.hadBadDataDuringMigration or oldCharacter.newCharacter:
                    continue 
                unmigratedCharacters.append(oldCharacter)
            except db.Error: # the new character has been deleted, but that's okay.
                continue
        return unmigratedCharacters
    getUnmigratedCharactersForUser = classmethod(getUnmigratedCharactersForUser)

    def migrate(self):
        """ Try to update to the latest schema and return that model.
            Returns None on failure.
        """

        modelDict = \
        {   'wotcData': self.dnd4eData, 
            'owner': self.owner,
            'isPublic': self.isPublic,
        }
        model = globals()[VERSIONED_CHARACTER_CLASS](**modelDict)

        # Finalize the model to see if the provided file was any good.
        try:
            model.buildDom(testing=True)
        except (ValueError, RuntimeError), errorMessage:
            self.hadBadDataDuringMigration = True
            self.put()
            return None
        model.put()

        self.isMigrated = True
        self.newCharacter = model
        self.put()

        NewCurrentValueClass = model.getStateClass()
        newStateObjects = []
        for thisValue in CharacterCurrentValue.gql('WHERE character = :1', self):
            thisDict = \
            {   'character': model,
                'name': thisValue.name,
                'value': thisValue.value,
            }
            newStateObjects.append(NewCurrentValueClass(**thisDict))
        db.put(newStateObjects)

        return model

class CharacterCurrentValue(MigratoryModel):
    """ Exists for migration from old values.
    """
    character = db.Reference(Character, required=True)
    name = db.StringProperty(required=True)
    value = db.StringProperty()
    modified = db.DateTimeProperty(auto_now=True)

class EmailToUser(MigratoryModel):
    user = db.UserProperty(required=True)

    def emailsToGoodUsers(thisClass, emailAddresses, returnBad=False):
        """ Provided a list of email addresses, return a list of users.User objects for valid addresses.
            This is a workaround for the fact that users.User('valid.email@gmail.com').user_id() returns None.

            If returnBad is True, we return a 2-tuple: (userObjects, badEmailAddresses)
        """

        newKeys = [ thisClass(user=users.User(ea)).put() for ea in emailAddresses ]
        emailToUsers = IP4DB.get(newKeys)
        db.delete(emailToUsers)

        retUsers = [ eto.user for eto in emailToUsers if eto.user.user_id() ]
        if not returnBad:
            return retUsers
        badAddresses = [ eto.user.email() for eto in emailToUsers if eto.user.user_id() is None ]
        return (retUsers, badAddresses)
    emailsToGoodUsers = classmethod(emailsToGoodUsers)

class ReportedUrl(MigratoryModel):
    
    character = db.StringProperty(required=True)
    url = db.StringProperty(required=True)
    urlguess = db.StringProperty(default='')
    name = db.StringProperty(required=True)
    namenoplus = db.StringProperty(default='')
    packagename = db.StringProperty(default='')
    packageurl = db.StringProperty(default='')
    fixedurl = db.StringProperty(default='')
    modified = db.DateTimeProperty(auto_now=True)

def getSearchableClasses():
    return [ m for m in globals().values() if m is not HasSearchResults and getattr(m, 'putSearchResult', None) ]

