import string, logging, time

import wsgiref.handlers
from django.utils import simplejson
from google.appengine.ext import webapp
from google.appengine.api import users

from IP4ELibs.ModelTypes import SearchModels, AuthorizedModels
from IP4ELibs import models, BaseHandler, IP4DB

class BaseInitializeHandler(BaseHandler.BaseHandler):

    def get(self):
        user = users.get_current_user() or None

        # If we can't find any objects matching the key(s) specified, bail.
        allObjects = \
        [   self.getAuthorizedModelOfClasses(self.VIEW, 
                [ models.Campaign, getattr(models, models.VERSIONED_CHARACTER_CLASS) ],
                useKey=thisKey, returnNone=True) \
            for thisKey in self.request.get('key').split(',') \
        ]
        allObjects = [ ao for ao in allObjects if ao is not None ]
        if not allObjects:
            return self.getAny(user, None)

        for model in allObjects:
            if model.__class__ is models.Campaign:
                self.getCampaign(user, model)
            elif model.__class__ is getattr(models, models.VERSIONED_CHARACTER_CLASS):
                self.getCharacter(user, model)

    def getAny(self, user, model):
        self.response.headers['Content-Type'] = 'text/javascript'

        modelKey = safeKey = ''
        modelDom = None
        if model:
            lettersAndDigits = string.letters + string.digits
            modelKey = model.toDom().get('key') # because the actual model.key() might be different.
            #modelKey = str(model.key())
            safeKey = ''.join([k for k in modelKey if k in lettersAndDigits ])

        retDict = {'key':modelKey, 'safeKey':safeKey, 'dom':modelDom}

        authClass = AuthorizedModels.AuthorizedModel
        for ability, trueClass, falseClass, beforeClass in \
        (   
            (authClass.MEMBER, 'MemberOnly', 'NotMember', 'BeforeMemberKnown'),
            (authClass.PUBLIC, 'PublicOnly', 'PrivateOnly', 'BeforePublicKnown'),
            (authClass.OWNER, 'OwnerOnly', 'NotOwner', 'BeforeOwnerKnown'),

            (authClass.VIEW,    'ViewerOnly',   'NotViewer',    'BeforeViewerKnown'),
            (authClass.MONITOR, 'MonitorOnly',  'NotMonitor',   'BeforeMonitorKnown'),
            (authClass.EDIT,    'EditorOnly',   'NotEditor',    'BeforeEditorKnown'),
            (authClass.DELETE,  'DeletorOnly',  'NotDeletor',   'BeforeDeletorKnown'),
        ):
            (retDict[ability], showClass) = \
                model \
                and (model.authorizeUserAbility(user, ability) and (True, trueClass) or (False, falseClass)) \
                or (False, falseClass)
                
            # Mobile devices 
            for thisClass, thisMethod in ((showClass, 'show'), (beforeClass, 'hide')):
                self.response.out.write(""" $$('.%(safeKey)s%(thisClass)s').invoke('%(thisMethod)s'); """ % locals())

        self.response.out.write("""try { sizeCampaignPanels(); } catch (e) { sizeParentIframeToMyContainer(); }""")

        return retDict

    def sendCharacterStateWithInitDict(self, stateModels, initDict):
        key, safeKey, pulse = initDict['key'], initDict['safeKey'], initDict.get('pulse', 0)
        now = time.time()

        namesToValues = {}
        [ namesToValues.update({cv.name: cv.textOrValue}) for cv in stateModels ]
        namesToValues = simplejson.dumps(namesToValues)
        self.response.out.write( \
        """ 
            //try
            //{   
                CHARACTER%(safeKey)s.setDict($H(%(namesToValues)s), {noSave:1, pulse:%(pulse)d});
                CHARACTER%(safeKey)s.polltime = %(now)f;
                //alert('Set current state');
            //}
            //catch (e)
            //{   
                //alert('Error setting character values');
                //if (console && console.log) console.log(e);
            //}
            //try
            //{   
                CHARACTER%(safeKey)s.loadUnsavedValues();
                //alert('Loaded unsaved values');
            //}
            //catch (e)
            //{   
                //alert('Error loading unsaved values');
                //if (console && console.log) console.log(e);
            //}
        """ % locals())

class PollHandler(BaseInitializeHandler):

    def getCharacter(self, user, model):
        initDict, timestamp = self.getAny(user, model), self.request.get('t', None)
        #logging.error('getCharacter(%(timestamp)s)' % locals())
        if not user and timestamp and initDict[model.MONITOR]:
            return
        try:
            timestamp = float(timestamp)
        except ValueError:
            return

        initDict['pulse'] = 1
        self.sendCharacterStateWithInitDict(model.getState(timestamp=timestamp), initDict)
        #self.sendCharacterStateWithInitDict(model.getState(timestamp=timestamp), initDict)

class MainHandler(BaseInitializeHandler):

    def getCampaign(self, user, model):
        initDict = self.getAny(user, model)
        if not user:
            return

        campaignCharacters = model.characters
        campaignCharacterKeys = [ str(cc.key()) for cc in campaignCharacters ]

        mySearch = SearchModels.SearchResult.SearchRequest().setUser(user).setTypes([models.VERSIONED_CHARACTER_CLASS])
        myCharacters = [ mc for mc in mySearch.get() if mc.owner == user ]
        myCampaignCharacters = [ mc for mc in myCharacters if (mc.modelKey) in campaignCharacterKeys ]
        myOtherCharacters = [ mc for mc in myCharacters if str(mc.modelKey) not in campaignCharacterKeys ]
        myCampaignCharacters, myOtherCharacters = \
            [   [   {'key': str(char.modelKey), 'title': char.title, 'subtitle': char.subtitle} \
                    for char in charList \
                ] \
                for charList in myCampaignCharacters, myOtherCharacters \
            ]

        myCampaignCharacters, myOtherCharacters = \
            simplejson.dumps(myCampaignCharacters), simplejson.dumps(myOtherCharacters)

        userId = user.user_id()
        self.response.out.write(""" setMyCampaignUser(%(userId)r); """ % locals())
        self.response.out.write(""" setMyCampaignCharacters($A(%(myCampaignCharacters)s), $A(%(myOtherCharacters)s)); """ % locals())

    def getCharacter(self, user, model):
        initDict = self.getAny(user, model)
        if not user:
            return
        userId = user.user_id()

        isEditor = initDict[model.EDIT]
        key, safeKey = initDict['key'], initDict['safeKey']

        # If the user has made any notes on this character, provide them.
        for note in models.UserItemNote.gql('WHERE user_id = :1 and item_key = :2', userId, key):
            name, noteText = note.name, (note.note or '')
            name, noteText = simplejson.dumps(name), simplejson.dumps(noteText)

            # Mobile devices only display notes
            if self.requestIsMobile():
                self.response.out.write(\
                """ 
                    var possibleInputs = $$("#%(safeKey)s form.NotesForm input[name='name']");
                    var charElement = possibleInputs.find(function(e)
                    {   return e.value == %(name)s;
                    });
                    if (charElement) 
                    {
                        charElement = charElement.up('li');
                        charElement.down('pre').update(%(noteText)s);
                        charElement.show();
                    }
                    else alert('Notes element for "' + %(name)s + '" not found');
                """ % locals())
        
            # Find the element that has this name as its label.
            else:
                self.response.out.write(\
                """ 
                    var possibleInputs = $$('.' + charKey + "Multiple form.NotesForm input[name='name']");
                    var charElement = possibleInputs.find(function(e)
                    {   return e.value == %(name)s;
                    });
                    if (charElement) 
                    {   // Also make the Notes tab the active one.
                        var noteText = %(noteText)s;
                        charElement.up().down('textarea').value = noteText;
                        charElement.up().previous().innerHTML = noteText.replace('\\n', '<br/>');
                    }
                """ % locals())

        # Pull pieces we need from the character tree for control purposes.
        characterTree = initDict['dom']
        buildElement = characterTree.find('Build')
        currentExperience = buildElement.get('experience', '')

        healthElement = characterTree.find('Health')
        shortRestClass = healthElement.get('short-rest-class')
        extendedRestClass = healthElement.get('extended-rest-class')
        tempHPDisplayClass = healthElement.get('tempHP-display-class', '')
        tempHPPromptClass = healthElement.get('tempHP-prompt-class', '')
        tempHPBarClass = healthElement.get('tempHP-bar-class', '')
        deathSavesDisplayClass = healthElement.get('death-saves-display-class', '')
        conditionsDisplayClass = healthElement.get('conditions-display-class', '')
        powerPointsDisplayClass = healthElement.get('power-points-display-class', '')

        hitPointsElement = healthElement.find('MaxHitPoints')
        maxHitPoints = hitPointsElement.get('value', '')
        minHitPoints = '-%s' % characterTree.find('Health/BloodiedValue').get('value', '')

        surgesElement = characterTree.find('Health/MaxSurges')
        maxSurges = surgesElement.get('value', '')

        surgeValueElement = characterTree.find('Health/SurgeValue')
        surgeValue = surgeValueElement.get('value', '')

        lootElement = characterTree.find('Loot')
        dailyUseDisplayClass = lootElement.get('daily-use-display-class', '')
        dailyUses = { 'Heroic': 1, 'Paragon': 2, 'Epic': 3 }.get(buildElement.get('tier', None), 0);

        powerPointsElement = healthElement.find('PowerPoints')
        powerPoints = 3 # unused
        if not powerPointsElement:
            maxPowerPoints = 0
        else:
            maxPowerPoints = powerPointsElement.get('value', '')
        minPowerPoints = 0 # Unused

        self.response.out.write( \
        """ 
            CHARACTER%(safeKey)s.isEditor = %(isEditor)d;
            CHARACTER%(safeKey)s.addVariable('Experience Points', 'ExperiencePoints', %(currentExperience)s,
            {   requireInt:1, min:0
            });
            CHARACTER%(safeKey)s.addVariable('CUR_HitPoints', 'CUR_HitPoints', %(maxHitPoints)s,
            {   requireInt:1, max:%(maxHitPoints)s, min:%(minHitPoints)s,
                barClass: 'CUR_HitPointsBar', barOptions: {threshold:.5},
                onChange: function(newVal)
                {   $$('#%(key)s .CUR_HitPointsDying').invoke( (newVal < 1) ? 'show' : 'hide' );
                    $$('.%(key)sMultiple .CUR_HitPointsDying').invoke( (newVal < 1) ? 'show' : 'hide' );

                    var deathSavesVar = CHARACTER%(safeKey)s.namesToVariables['CUR_Death Saves'];
                    if (deathSavesVar) { // Defeat initialization race condition
                        deathSavesVar.set(deathSavesVar.get(), {isCascade:true}); // To update Death Saves visibility, which respects HP value.
                    }
                }
            });
            CHARACTER%(safeKey)s.addVariable('CUR_PowerPoints', '%(powerPointsDisplayClass)s', %(maxPowerPoints)s,
            {   requireInt:1, min:0, max:%(maxPowerPoints)s,
                onChange: function(newVal)
                {
                    if (%(maxPowerPoints)s == 0) {
                       $$('#%(key)s .CUR_PowerPoints').invoke('hide');
                       $$('.%(key)sMultiple .CUR_PowerPoints').invoke('hide');
                    } else {
                       $$('#%(key)s .CUR_PowerPoints').invoke('show');
                       $$('.%(key)sMultiple .CUR_PowerPoints').invoke('show');
                    }
                }
            });
            CHARACTER%(safeKey)s.addVariable('MAX_Surges', 'MAX_Surges', %(maxSurges)s, 
            {   requireInt: 1
            });
            // The +3 is for vampires.
            CHARACTER%(safeKey)s.addVariable('CUR_Surges', 'CUR_Surges', %(maxSurges)s,
            {   requireInt:1, max:%(maxSurges)s+3, min:0,
                barClass: 'CUR_SurgesBar', 
                barOptions: {threshold:2/%(maxSurges)s, goodColor:'yellow', badColor:'orange'}
            });
            CHARACTER%(safeKey)s.addVariable('CUR_TempHP', '%(tempHPDisplayClass)s', 0,
            {   requireInt:1, min:0, max:%(maxHitPoints)s, barClass: '%(tempHPBarClass)s'
            });
            CHARACTER%(safeKey)s.addVariable('CUR_Action Points', 'CUR_ActionPoints', 1,
            {   requireInt:1, min:0
            });
            CHARACTER%(safeKey)s.addVariable('CUR_Death Saves', '%(deathSavesDisplayClass)s', 3,
            {   requireInt:1, min:0, max:3,
                onChange: function(newDeathSaves)
                {
                    // Handle death saves change directly, and hit point change indirectly.
                    // Check both hit points and death saves, and if either is too low, show death saves.
                    var hitPoints = CHARACTER%(safeKey)s.namesToVariables['CUR_HitPoints'].get();
                    var hideOrShow = (hitPoints < 1 || newDeathSaves < 3) ? 'show' : 'hide';
                    $$('#%(key)s .CUR_HitPointsDyingOrFailedSaves').invoke(hideOrShow);
                    $$('.%(key)sMultiple .CUR_HitPointsDyingOrFailedSaves').invoke(hideOrShow);
                }
            });
            CHARACTER%(safeKey)s.addVariable('CUR_Conditions', '%(conditionsDisplayClass)s', [],
            {   listItemClass: 'CUR_ConditionsDelete'
            });
            CHARACTER%(safeKey)s.addVariable('CUR_DailyUses', '%(dailyUseDisplayClass)s', %(dailyUses)s,
            {   requireInt:1, min:0, reset:'Daily'
            });
        """ % locals())

        for moneyBucket in ('carried', 'stored'):
            for coinType in ('ad', 'pp', 'gp', 'sp', 'cp'):
                numCoins = lootElement.get('%s-%s' % (moneyBucket, coinType), '0')
                self.response.out.write(\
                """
                    CHARACTER%(safeKey)s.addVariable('CUR_%(moneyBucket)s%(coinType)s', 'CUR_%(moneyBucket)s%(coinType)s', %(numCoins)s,
                    {   requireInt:1, min:0
                    });
                """ % locals())

        #print "Gone item looping..."
        for thisItem in lootElement.findall("Item"):
            #print thisItem.get('name', '')
            unsafeItemName = thisItem.get('name', '')
            lettersAndDigits = string.letters + string.digits
            safeItemName = ''.join([k for k in unsafeItemName if k in lettersAndDigits ])
            itemCount = thisItem.get('count', '')
            itemDisplayClass = thisItem.get('display-class', '')
            self.response.out.write(\
            """
                CHARACTER%(safeKey)s.addVariable('CUR_Item_%(safeItemName)s', '%(itemDisplayClass)s', %(itemCount)s,
                {   requireInt:1, min:0,
onChange: function(newCount)
{
}
                });
            """ % locals())

        for thisDesc in characterTree.findall('Description/*'):
            nodeName = thisDesc.tag
            safeNodeValue = (thisDesc.text or '').replace("'", r"\'").replace('\n', r'\n')
            self.response.out.write(\
            """ CHARACTER%(safeKey)s.addVariable('CUR_%(nodeName)s', 'CUR_%(nodeName)s', '%(safeNodeValue)s',
            {   
            });
            """ % locals())

        for thisPower in characterTree.findall('Powers/Power'):
            powerName = thisPower.get('name', '')
            safeName = powerName
            for badChar in (""" ',+()"""):
                safeName = safeName.replace(badChar, '')
            powerUsage = (thisPower.get('powerusage', '').split() or [''])[0]
            powerDisplayClass = thisPower.get('display-class')

            if powerName == 'Second Wind':
                self.response.out.write(\
                """ 
                    CHARACTER%(safeKey)s.addVariable('USAGE_%(safeName)s', '%(powerDisplayClass)s', false, 
                    {   isBoolean:1, reset:'%(powerUsage)s',
                        useRequires: function() { return CHARACTER%(safeKey)s.namesToVariables['CUR_Surges'].get() > 0; },
                        onChange: function(newVal, options)
                        {   if (newVal && !options.noSave)
                            {   
                                CHARACTER%(safeKey)s.namesToVariables['CUR_HitPoints'].getIntoFunction(function(currentHP) { CHARACTER%(safeKey)s.namesToVariables['CUR_HitPoints'].set(Math.max(0,currentHP) + %(surgeValue)s, {isCascade:true}); });
                                CHARACTER%(safeKey)s.namesToVariables['CUR_Surges'].getIntoFunction(function(curSurges) { CHARACTER%(safeKey)s.namesToVariables['CUR_Surges'].set(curSurges - 1, {isCascade:true}); });
                            }
                        }
                    });
                """ % locals())
            elif powerName == 'Action Point':
                self.response.out.write(\
                """ 
                    CHARACTER%(safeKey)s.addVariable('USAGE_%(safeName)s', '%(powerDisplayClass)s', false, 
                    {   isBoolean:1, reset:'%(powerUsage)s',
                        useRequires: function() { return CHARACTER%(safeKey)s.namesToVariables['CUR_Action Points'].get() > 0; },
                        onChange: function(newVal, options)
                        {   if (newVal && !options.noSave)
                            {   
                                CHARACTER%(safeKey)s.namesToVariables['CUR_Action Points'].getIntoFunction(function(currentAP) 
                                {   CHARACTER%(safeKey)s.namesToVariables['CUR_Action Points'].set(currentAP - 1, {isCascade:true}); 
                                });
                            }
                        }
                    });
                """ % locals())
            else:
                self.response.out.write(\
                """ 
                    CHARACTER%(safeKey)s.addVariable('USAGE_%(safeName)s', '%(powerDisplayClass)s', false, 
                    {   isBoolean:1, reset:'%(powerUsage)s' 
                    });
                """ % locals())

        if initDict[model.EDIT]:
            self.response.out.write(\
            """
                try
                {   CHARACTER%(safeKey)s.enableSaving();
                    //alert('Enabled saving');
                }
                catch (e)
                {   alert('Error enabling character saving.');
                }
                //alert('You are the owner');
            """ % locals())

        # This block comes after the EDIT block because sendCharacterStateWithInitDict depends on enableSaving().
        if initDict[model.MONITOR]:
            self.sendCharacterStateWithInitDict(model.getState(), initDict)
            self.response.out.write(\
            """
                try
                {   CHARACTER%(safeKey)s.enablePolling();
                    //alert('Enabled saving');
                }
                catch (e)
                {   alert('Error enabling character polling.');
                }
                //alert('You are the owner');
            """ % locals())
