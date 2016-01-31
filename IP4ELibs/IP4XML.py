import sys, string, re, logging
import xml.dom.minidom
from xml.etree import ElementTree

import models

class CharacterDataSource(object):
    """ Defines the interface for a source of character data.

        Methods will be invoked in the order in which this class defines them, so you may
        safely store an instance attribute in an earlier method for access in a later.
    """

    def _updateHealthDictWithCalculations(self, healthDict, parseStat=None):
        """
        """

        maxHitPoints = healthDict['MaxHitPoints'][0]
        for childName, statName, portionStr, divideBy, floatStr in \
        (   ('BloodiedValue', None, 'Half', 2, '.5'),
            ('SurgeValue', 'Healing Surge Value', 'Quarter', 4, '.25'),
        ):
            childValue = maxHitPoints / divideBy
            retFactors = \
            [   {   'name': '%s Hit Points' % portionStr, 'abbreviation': '1/%d HP' % divideBy, 
                    'modifier': childValue, 'multiplier':floatStr, 'multiplied':maxHitPoints,
                }
            ]

            # The healing surge value can have bonuses found in the StatBlock.
            if None not in (statName, parseStat):
                statBonus, moreFactors = parseStat(statName)
                childValue += statBonus
                retFactors.extend(moreFactors)

            healthDict[childName] = (childValue, retFactors)
        return healthDict

    def getNameAndKey(self):
        """ Return a 2-tuple: (characterName, characterKey)
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getNameAndKey()' % locals()

    def getDescriptionDict(self):
        """ Return a dict of description attributes, containing at least those keys defined
            by IP4CharacterTree.DESCRIPTION_ATTRIBUTES_OPTIONAL and DESCRIPTION_CHILDREN, with the former
            being strings and the latter being strings with newlines.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getDescriptionDict()' % locals()

    def getBuildDict(self):
        """ Return a dict of build attributes, containing at least those keys defined
            by IP4CharacterTree.BUILD_ATTRIBUTES.  If the "name" key is missing or blank,
            the class name will end up getting used.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getBuildDict()' % locals()

    def getRaceDict(self):
        """ Return a dict of race attributes, containing at least those keys defined
            by IP4CharacterTree.BUILD_CHILD_ATTRIBUTES.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getRaceDict()' % locals()

    def getRaceFeatureDicts(self):
        """ Return a list of dicts of race feature attributes, each dict containing at least
            those keys defined by by IP4CharacterTree.FEATURE_ATTRIBUTES.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getRaceFeatureDicts()' % locals()

    def getClassDict(self):
        """ Return a dict of class attributes, containing at least those keys defined
            by IP4CharacterTree.BUILD_CHILD_ATTRIBUTES.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getClassDict()' % locals()

    def getClassFeatureDicts(self):
        """ Return a list of dicts of class feature attributes, each dict containing at least
            those keys defined by by IP4CharacterTree.FEATURE_ATTRIBUTES.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getClassFeatureDicts()' % locals()

    def getParagonPathDict(self):
        """ Return a dict of paragon path attributes, containing at least those keys defined
            by IP4CharacterTree.BUILD_CHILD_ATTRIBUTES.

            May instead return None if no paragon path has been chosen.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getParagonPathDict()' % locals()

    def getParagonPathFeatureDicts(self):
        """ Return a list of dicts of paragon path feature attributes, each dict containing at least
            those keys defined by by IP4CharacterTree.FEATURE_ATTRIBUTES.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getParagonPathFeatureDicts()' % locals()

    def getEpicDestinyDict(self):
        """ Return a dict of epic destiny attributes, containing at least those keys defined
            by IP4CharacterTree.BUILD_CHILD_ATTRIBUTES.

            May instead return None if no epic destiny has been chosen.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getEpicDestinyDict()' % locals()

    def getEpicDestinyFeatureDicts(self):
        """ Return a list of dicts of epic destiny feature attributes, each dict containing at least
            those keys defined by by IP4CharacterTree.FEATURE_ATTRIBUTES.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getEpicDestinyFeatureDicts()' % locals()

    def getHealthDict(self):
        """ Return a dictionary with keys defined by IP4CharacterTree.HEALTH_CHILD_NODES.
            Values are 2-tuples:

                - childValue: integer value for the node
                - factorDicts: a list of dictionaries of contributing factors, where each dictionary
                  must have a key for IP4CharacterTree.FACTOR_ATTRIBUTES, and may optionally have a key
                  for IP4CharacterTree.FACTOR_ATTRIBUTES_OPTIONAL.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getHealthDict()' % locals()

    def getMovementDict(self):
        """ Return a dictionary with keys defined by IP4CharacterTree.MOVEMENT_CHILD_NODES.
            Values are 2-tuples as per getHealthDict().
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getMovementDict()' % locals()

    def getPassiveSkillsDict(self):
        """ Return a dictionary with keys defined by IP4CharacterTree.PASSIVE_SKILLS_CHILD_NODES.
            Values are 2-tuples as per getHealthDict().
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getPassiveSkillsDict()' % locals()

    def getSkillsDict(self):
        """ Return a dictionary with keys defined by IP4CharacterTree.SKILLS_CHILD_NODES.
            Values are 3-tuples:
                - childValue: integer value for the node
                - factorDicts: a list of dictionaries of contributing factors, where each dictionary
                  must have a key for IP4CharacterTree.FACTOR_ATTRIBUTES, and may optionally have a key
                  for IP4CharacterTree.FACTOR_ATTRIBUTES_OPTIONAL.
                - childDict: a dict of attributes for the node with keys defined by IP4CharacterTree.SKILL_ATTRIBUTES.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getSkillsDict()' % locals()

    def getAbilityScoresDict(self):
        """ Return a dictionary with keys defined by IP4CharacterTree.DEFENSES_CHILD_NODES.
            Values are 2-tuples as per getHealthDict().
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getAbilityScoresDict()' % locals()

    def getPowersList(self):
        """ Return a list of 4-tuples, each tuple representing a power and containing:

                - powerDict: a dictionary with keys defined by IP4CharacterTree.POWER_ATTRIBUTES.
                - conditionFactors: potentially empty list of conditions affecting the power regardless of weapon.
                - weaponList: a list of tuples, each tuple representing a weapon that can be used
                  with the power and containing:

                    - weaponDict: a dictionary with keys defined by IP4CharacterTree.POWER_WEAPON_ATTRIBUTES,
                      and optional keys defined by IP4CharacterTree.POWER_WEAPON_ATTRIBUTES_OPTIONAL.
                    - attackFactorDicts: a list of dictionaries of contributing attack factors, where each dictionary
                      must have a key for IP4CharacterTree.FACTOR_ATTRIBUTES, and may optionally have a key
                      for IP4CharacterTree.FACTOR_ATTRIBUTES_OPTIONAL.
                    - damageFactorDicts: a list of dictionaries of contributing damage factors, where each dictionary
                      must have a key for IP4CharacterTree.FACTOR_ATTRIBUTES, and may optionally have a key
                      for IP4CharacterTree.FACTOR_ATTRIBUTES_OPTIONAL.
                    - conditionFactors: potentially empty list of factor dicts for this weapon, where each dictionary
                      must have a key for IP4CharacterTree.FACTOR_ATTRIBUTES, and may optionally have a key
                      for IP4CharacterTree.FACTOR_ATTRIBUTES_OPTIONAL.
                - powerCardItems: potentially empty list of tuples, where each tuple represents a 
                  row of a power card block.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getPowersList()' % locals()

    def getFeatsList(self):
        """ Return a list of dictionaries, each having keys defined by IP4CharacterTree.FEAT_ATTRIBUTES.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getFeatsList()' % locals()

    def getLootDict(self):
        """ Return a dict of loot attributes, containing at least those keys defined
            by IP4CharacterTree.LOOT_ATTRIBUTES.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getLootDict()' % locals()

    def getItemList(self):
        """ Return a list of 2-tuples, each representing an item of loot:

                - itemDict: dictionary with keys defined by IP4CharacterTree.ITEM_ATTRIBUTES.
                - enhancementDict: dictionary with keys defined by IP4CharacterTree.ENHANCEMENT_ATTRIBUTES.
                  May be None to indicate the lack of enhancement.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getItemList()' % locals()

    def getLanguageNames(self):
        """ Return a list of the names of languages known.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getLanguageNames()' % locals()

    def getWeaponProficienciesAndGroups(self):
        """ Return a 2-tuple:
        
                - proficienciesDict: list of dictionaries with keys defined by IP4CharacterTree.PROFICIENCY_ATTRIBUTES.
                - groupsList: a list of 2-tuples:

                    - groupDict: dictionary with keys defined by IP4CharacterTree.PROFICIENCY_GROUP_ATTRIBUTES.
                    - groupProfsDict: list of dictionaries with keys defined by IP4CharacterTree.PROFICIENCY_ATTRIBUTES.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getWeaponProficienciesAndGroups()' % locals()

    def getArmorProficiencyDicts(self):
        """ Return a list of dictionaries with keys defined by IP4CharacterTree.PROFICIENCY_ATTRIBUTES.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getArmorProficiencyDicts()' % locals()

    def getShieldProficiencyDicts(self):
        """ Return a list of dictionaries with keys defined by IP4CharacterTree.PROFICIENCY_ATTRIBUTES.
        """

        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement getShieldProficiencyDicts()' % locals()

class DND4ECharacterDataSource(CharacterDataSource):
    """ Implements the CharacterDataSource interface in terms of dnd4e XML of version 0.7a or later
        that is stored in the iplay4e data store.
    """

    class OLD_VERSION_ERROR(Exception):
        pass

    def __init__(self, characterKey, characterXML):
        """ Raises OLD_VERSION_ERROR if characterXML is down-level.
            Saves instance variables: characterKey, d20CharNode, charSheetNode, rulesNodes, levelNodes
        """

        # The D20CampaignSetting element has some non-standard XML in it.
        characterXML = characterXML.strip()
        if characterXML.find('<D20CampaignSetting') != -1:
            characterXML = characterXML.split('<D20CampaignSetting')[0] + characterXML.split('/D20CampaignSetting>')[-1]

        # This branch allows for a couple different versions of the XML libraries...
        xmlObject = xml.etree.ElementTree.fromstring(characterXML)
        try:
            self.d20CharNode = xmlObject.getroot()
        except AttributeError:
            self.d20CharNode = xmlObject

        # dnd4e files of version 0.07a and later have a CharacterSheet node containing the most useful data.
        self.charSheetNode = self.d20CharNode.find('CharacterSheet')
        if self.charSheetNode is None:
            raise self.OLD_VERSION_ERROR

        # Rules nodes are found in RulesElementTally, and sometimes in LootTally for equipped gear.
        # They contain <specific> tags sometimes with a name and some content.
        self.rulesNodes = self.charSheetNode.findall('RulesElementTally/RulesElement')
        for lootNode in self.charSheetNode.findall('LootTally/loot'):
            if int(lootNode.get('equip-count', 0)):
                [ self.rulesNodes.append(rel) for rel in lootNode.findall('RulesElement') ]
        [ setattr(rn, 'specificAttributes', {}) for rn in self.rulesNodes ]
        [   [   rn.specificAttributes.update({specificNode.get('name'):(specificNode.text or '').strip()}) \
                for specificNode in rn.findall('specific') \
            ] \
            for rn in self.rulesNodes \
        ]

        # Parse all of the stat nodes.  At one point at least, WotC dropped the "name"
        # attribute from their skill stat nodes, so we're stuck looking at the aliases as well.
        self.statNodes = self.charSheetNode.findall('StatBlock/Stat')
        [ setattr(sn, 'aliasNames', []) for sn in self.statNodes ]
        [   [ sn.aliasNames.append(aliasNode.get('name')) for aliasNode in sn.findall('alias') ] \
            for sn in self.statNodes \
        ]

        self.textstringNodes = self.d20CharNode.findall('textstring')
        self.levelNodes = self.d20CharNode.findall('Level/RulesElement')
        self.levelNodes = [ le for le in self.levelNodes if le.get('type', None) == 'Level']
        self.characterKey = characterKey

    def __getRulesNodes(self, **attrMatchers):
        """ Return a list of all RulesElement Nodes that match the specification.
        """

        retNodes = self.rulesNodes
        for attrName, attrValue in attrMatchers.items():
            retNodes = [ retE for retE in retNodes if retE.get(attrName, None) == attrValue ]
        return retNodes

    def __getRulesNode(self, **attrMatchers):
        """ Return the first matching element, or None if there are no matches.
        """

        matchingNodes = self.__getRulesNodes(**attrMatchers)
        if matchingNodes:
            return matchingNodes[0]
        return None

    def getNameAndKey(self):
        """ Return a 2-tuple: (characterName, characterKey)
        """

        charName = self.charSheetNode.findtext('Details/name').strip()
        return charName, self.characterKey

    def getDescriptionDict(self):
        """ Return a dict of description attributes, containing at least those keys defined
            by IP4CharacterTree.DESCRIPTION_ATTRIBUTES_OPTIONAL and DESCRIPTION_CHILDREN, with the former
            being strings and the latter being strings with newlines.
        """

        # The attributes are lowercase in our output format, but are capitalized nodes in dnd4e XML.
        descDict = {}
        [   descDict.update({descAttr: self.charSheetNode.findtext('Details/%s' % descAttr.capitalize()).strip()}) \
            for descAttr in IP4CharacterTree.DESCRIPTION_ATTRIBUTES_OPTIONAL + IP4CharacterTree.DESCRIPTION_CHILDREN \
        ]

        if len(descDict['height']) < 2:
            descDict['height'] = str(self.__parseStat('Average Height'))

        if len(descDict['weight']) < 2:
            descDict['weight'] = str(self.__parseStat('Average Weight'))

        return descDict

    def getBuildDict(self):
        """ Return a dict of build attributes, containing at least those keys defined
            by IP4CharacterTree.BUILD_ATTRIBUTES.  If the "name" key is missing or blank,
            the class name will end up getting used.
        """

        # Start with blank values for all required attributes.
        buildDict = {}
        [ buildDict.update({buildAttr:''}) for buildAttr in IP4CharacterTree.BUILD_ATTRIBUTES ]

        # Most items are found in RulesElement nodes, and with few exceptions under capitalized labels.
        # I've structured the code like this so that adding to BUILD_ATTRIBUTES is all that's needed.
        doManually = ('level', 'experience', 'ExperienceNeeded')
        for buildAttr in [ ba for ba in IP4CharacterTree.BUILD_ATTRIBUTES if ba not in doManually ]:
            rulesType = \
            {   'powersource': 'Power Source',
            }.get(buildAttr, buildAttr.capitalize())

            # And some, like Tier, show up multiple times, and we use the last one.
            inNodes = self.__getRulesNodes(type=rulesType)
            if inNodes:
                buildDict[buildAttr] = inNodes[-1].get('name')

        # While others are in the <Details> block or <textstring> elements.
        buildDict['level'] = self.charSheetNode.findtext('Details/Level').strip()
        buildDict['experience'] = '0'
        for textstringNode in self.textstringNodes:
            if textstringNode.get('name', None) == 'Experience Points':
                buildDict['experience'] = textstringNode.text.strip()

        # Parse the 'XP Needed' stat to get the XP needed for the next level.
        buildDict['ExperienceNeeded'] = str(self.__parseStat('XP Needed')[0])

        return buildDict

    def __getBuildChildDict(self, rulesElementType):
        """ Return a dict of race, class, paragon path, or epic destiny attributes,
            containing at least those keys defined by IP4CharacterTree.BUILD_CHILD_ATTRIBUTES.
        """

        buildChildDict = {}

        # Some items, like Paragon Path, may not be defined.
        buildChildNode = self.__getRulesNode(type=rulesElementType)
        if buildChildNode is None:
            return None

        [   buildChildDict.update({buildChildAttr:buildChildNode.get(buildChildAttr, '')}) \
            for buildChildAttr in IP4CharacterTree.BUILD_CHILD_ATTRIBUTES \
        ]
        [   buildChildDict.update({'description':(shortDescChild.text or '').strip()}) \
            for shortDescChild in buildChildNode.findall('specific') \
            if shortDescChild.get('name', '') == 'Short Description' \
        ]

        # Backgrounds don't properly include URLs, but they can be derived.
        if rulesElementType == 'Background':
            buildChildDict['url'] = 'http://www.wizards.com/dndinsider/compendium/background.aspx?id=%s' \
                % buildChildNode.get('internal-id', '').split('_')[-1]

        if rulesElementType == 'Theme':
            buildChildDict['url'] = 'http://www.wizards.com/dndinsider/compendium/theme.aspx?id=%s' \
                % buildChildNode.get('internal-id', '').split('_')[-1]

        return buildChildDict

    def __getBuildChildFeatureDicts(self, rulesElementType, fromLevel=None):
        """ Return a list of dicts of race, class, paragon path, or epic destiny feature attributes,
            each dict containing at least those keys defined by by IP4CharacterTree.FEATURE_ATTRIBUTES.

            The optional fromLevel argument specifies that we should, instead of looking for matching
            RulesElementTally/RulesElement nodes, look beneath the Level block in the appropriate level.
            Then we can corellate back to our Tally subnodes (which contain the descriptive info)
        """

        featureDicts = []
        featureNodes = self.__getRulesNodes(type=rulesElementType)

        if fromLevel is not None:
            levelNode = self.levelNodes[fromLevel - 1]
            levelFeatureNodes = levelNode.findall('RulesElement//RulesElement')
            levelFeatureNodes = [ lfn for lfn in levelFeatureNodes if lfn.get('type', None) == rulesElementType ]
            levelFeatureNames = [ lfn.get('name') for lfn in levelFeatureNodes ]
            featureNodes = [ fn for fn in featureNodes if fn.get('name') in levelFeatureNames ]

        for featureNode in featureNodes:
            featureDict = {'name': featureNode.get('name', ''), 'description': ''}
            featureDicts.append(featureDict)

            specificNode = featureNode.find('specific')
            if specificNode is not None and specificNode.get('name', None) == 'Short Description':
                featureDict['description'] = (specificNode.text or '').strip()

        return featureDicts

    def getRaceDict(self):
        retDict = self.__getBuildChildDict('Race')
        self.__raceName = retDict['name']
        return retDict
    def getRaceFeatureDicts(self):
        return self.__getBuildChildFeatureDicts('Racial Trait')
    def getBackgroundDict(self):
        return self.__getBuildChildDict('Background')
    def getBackgroundFeatureDicts(self):
        return self.__getBuildChildFeatureDicts('Background Choice')
    def getThemeDict(self):
        return self.__getBuildChildDict('Theme')
    def getThemeFeatureDicts(self):
        return self.__getBuildChildFeatureDicts('Theme Features') # I don't actually know what the key is
    def getClassDict(self):
        retDict = self.__getBuildChildDict('Class')
        self.__className = retDict['name']
        return retDict
    def getClassFeatureDicts(self):
        return self.__getBuildChildFeatureDicts('Class Feature', fromLevel=1)
    def getParagonPathDict(self):
        return self.__getBuildChildDict('Paragon Path')
    def getParagonPathFeatureDicts(self):
        return self.__getBuildChildFeatureDicts('Class Feature', fromLevel=11)
    def getEpicDestinyDict(self):
        return self.__getBuildChildDict('Epic Destiny')
    def getEpicDestinyFeatureDicts(self):
        return self.__getBuildChildFeatureDicts('Class Feature', fromLevel=21)

    def __massageFactorDictNames(self, factorDict):
        newName, factorAbbrev = None, None
        factorName = factorDict['name']
        if factorName == '_LEVEL-ONE-HPS':
            newName = 'Level 1 %s' % self.__className
            factorAbbrev = '%s 1' % self.__className
        elif factorName in ('HALF-LEVEL', 'half your level'):
            newName = 'Half Level'
            factorAbbrev = '1/2 Level'
        elif factorName in ('1', 'SkillRules'):
            newName = 'Constant' # Because everyone has Level 1 and SkillRules
        elif factorName in IP4CharacterTree.ABILITY_SCORE_NAMES:
            factorAbbrev = factorName[:3]
        else:
            try:
                nameInt = int(factorName)
                newName = 'Level %d' % nameInt
            except ValueError:
                pass

        if newName is not None:
            factorDict['name'] = newName
        if factorAbbrev is not None:
            factorDict['abbreviation'] = factorAbbrev

    def __parseStat(self, statName, valueOnly=0, conditionList=None):
        """ Returns a 2-tuple: (statValue, factorDicts).

            Pass valueOnly=1 to just get the value and save some factor processing.
            Pass in a list to fill with conditions we find in the stat.
        """

        # Find the stat.  If we fail, still return something useful.
        statNode = None
        for statElement in self.statNodes:
            if statElement.get('name') == statName or statName in statElement.aliasNames:
                statNode = statElement
                break
        if statNode is None:
            if valueOnly:
                return 0
            else:
                return (0, [])

        # We can now get the value, which possibly means we're done.
        statValue, factorDicts = int(statNode.get('value', 0)), []
        if valueOnly:
            return statValue

        # Look for statadd nodes, which become our factor nodes, for the most part.
        # Some, though, such as hit points per level, we have to accumulate.
        stataddNodes = statNode.findall('statadd')
        perLevelHPNodes = [ san for san in stataddNodes if san.get('statlink') == '_PER-LEVEL-HPS' ]
        abilityModNodes = [ san for san in stataddNodes if san.get('abilmod') == 'true']
        [ stataddNodes.remove(p) for p in abilityModNodes ]

        # These nodes are the ones that increment the power points per level.
        powerPointPerLevelNodes = [ san for san in stataddNodes if san.get('charelem') == '18' ]
        if statName != "Power Points":
            powerPointPerLevelNodes = None # Something happened, and we got charelem=18 on a non-powerpoint-per-level node.

        for stataddNode in stataddNodes:
            if conditionList is None:
                factorConditions = []
            else:
                factorConditions = conditionList

            # There are some that we just grab the String attribute and finish
            if (statName == "Average Height"):
                return stataddNode.get('String', None)

            if statName == "Average Weight":
                return stataddNode.get('String', None)

            # There are also some that we skip because we don't understand them.
            if stataddNode.get('wearing', None) == 'DEFENSIVE:':
                continue
            self.__stataddNodeToConditions(stataddNode, factorConditions)

            # And some we skip because we don't meet requirements.
            nodeRequirement = stataddNode.get('requires', None)
            if nodeRequirement is not None:
                isNot = nodeRequirement[0] == '!'
                if isNot:
                    nodeRequirement = nodeRequirement[1:]
                    rulesNode = self.__getRulesNode(name=nodeRequirement)
                    if rulesNode is not None:
                        continue
                else:
                    rulesNode = self.__getRulesNode(name=nodeRequirement)
                    if rulesNode is None:
                        continue

            factorDict = {}
            factorDicts.append(factorDict)

            linkedStatName, charElement = stataddNode.get('statlink', None), stataddNode.get('charelem', None)

            if linkedStatName is not None:

                # This handles things like statlink="initiative misc", where we want to copy
                # the factors from that stat into ours.
                if linkedStatName.split()[-1] == 'misc':
                    factorDicts = factorDicts[:-1] # Pull out the one we just added.
                    [ factorDicts.append(miscFactor) for miscFactor in self.__parseStat(linkedStatName)[1] ]
                    continue

                else:
                    factorDict['name'] = linkedStatName
                    factorDict['modifier'], garbageFactors = self.__parseStat(linkedStatName, conditionList=factorConditions)

            elif charElement is not None:
                factorDict['modifier'] = stataddNode.get('value', '0')

                charElementNode = self.__getRulesNode(charelem=charElement)
                if charElementNode is None:
                    factorDict['name'] = 'UNKNOWN'
                else:
                    charElementType = charElementNode.get('type', '')
                    if charElementType[:16] == 'Ability Increase':
                        factorName = charElementType[18:-1] # parse "Ability Increase (Level 18)" to just "Level 18"
                    elif charElementType[:18] == 'Race Ability Bonus':
                        factorName = self.__raceName
                    else:
                        factorName = charElementNode.get('name', 'UNKNOWN')
                    factorDict['name'] = factorName

            else: # This is a really clean node, only found in starting ability scores.
                factorDict['name'] = 'Starting'
                factorDict['modifier'] = stataddNode.get('value', '0')

            # We know alternate names and abbreviations for some names.
            self.__massageFactorDictNames(factorDict)

            # Last check for conditions.  # XXX and for die rollers within them!
            factorCondition = stataddNode.get('conditional', None)
            if factorCondition is not None:
                factorConditions.append(factorCondition)
            if factorConditions:
                factorDict['condition'] = ', '.join(factorConditions)


        # If there were special statadd nodes that didn't get the normal treatment, use them.
        if perLevelHPNodes:
            numNodes = len(perLevelHPNodes)
            perLevelHP = self.__parseStat('_PER-LEVEL-HPS', valueOnly=1)
            factorDicts.append(\
            {
                'name': 'Level %d %s' % (numNodes+1, self.__className),
                'abbreviation': '%s %d' % (self.__className, numNodes+1),
                'modifier': numNodes * perLevelHP,
                'multiplier': numNodes,
                'multiplied': perLevelHP,
            })

        # Nodes with abilmod="true" are specially treated, because you only use the highest.
        if abilityModNodes:
            abilityModNames = [ amn.get('statlink') for amn in abilityModNodes ]
            abilityModValues = [ self.__parseStat(amn, valueOnly=1) for amn in abilityModNames ]
            abilityModValuesAndNamesAndNodes = zip(abilityModValues, abilityModNames, abilityModNodes)
            abilityModValuesAndNamesAndNodes.sort()
            linkedStatValue, linkedStatName, highestNode = abilityModValuesAndNamesAndNodes[-1]

            factorDicts.append(\
            {
                'name': '%s modifier' % linkedStatName,
                'abbreviation': '%s mod' % linkedStatName[:3],
                'modifier': ( linkedStatValue - 10 ) / 2,
            })

            # Where there conditions on this stat?
            factorConditions = []
            self.__stataddNodeToConditions(highestNode, factorConditions)
            if factorConditions:
                factorDicts[-1]['condition'] = ', '.join(factorConditions)

        if powerPointPerLevelNodes:
            for san in powerPointPerLevelNodes:
                requirement = san.get('requires', 'invalid level')

                # Check to see if it's a level requirement
                p = re.compile(r"(\d+) level")
                matches = p.match(requirement)
                if matches: # If we got a match
                    requiredLevel = int(matches.group(1))

                    # Check to see if we match the requirements
                    currentLevel = int(self.charSheetNode.findtext('Details/Level').strip())
                    if requiredLevel > currentLevel:
                        continue # We aren't a high-enough level :(
                else:
                    continue

                # Add the powerpoints to the statValue
                statValue += int(san.get('value', '0'))

            pass

        return statValue, factorDicts

    def __stataddNodeToConditions(self, stataddNode, factorConditions):
        for attrName, displayTemplate in ( ('wearing', 'with %s'), ('not-wearing', 'without %s') ):
            attrVal = stataddNode.get(attrName, None)
            if attrVal:
                factorConditions.append(displayTemplate % attrVal.replace(':', ': '))

    def getHealthDict(self):
        """ Return a dictionary with keys defined by IP4CharacterTree.HEALTH_CHILD_NODES.
            Values are 2-tuples as per getHealthDict().
        """

        healthDict = {}
        [   healthDict.update({childName: self.__parseStat(localName)}) \
            for childName, localName in ( ( 'MaxHitPoints', 'Hit Points'), ( 'MaxSurges', 'Healing Surges'), ('PowerPoints', 'Power Points') ) \
        ]

        return self._updateHealthDictWithCalculations(healthDict, self.__parseStat)

    def getMovementDict(self):
        """ Return a dictionary with keys defined by IP4CharacterTree.MOVEMENT_CHILD_NODES.
            Values are 2-tuples as per getHealthDict().
        """

        self.movementDict = {'Speed':(0,[]), 'Initiative':(0,[])}
        for childName, localName in \
        (   ('Speed', 'Speed'),
            ('Speed', 'speed'),
            ('Initiative', 'Initiative'),
            ('Initiative', 'initiative'),
        ):
            theValue, theFactors = self.__parseStat(localName)
            if theValue:
                self.movementDict[childName] = (theValue, theFactors)
        return self.movementDict

    def getDefensesDictAndConditions(self):
        """ Returns a 2-tuple:
                
                - defensesDict: a dictionary with keys defined by IP4CharacterTree.DEFENSES_CHILD_NODES.
                  Values are 2-tuples as per getHealthDict().
                - Defenseconditions: conditions that apply to all defenses.
        """

        defensesDict = {}
        [   defensesDict.update({childName: self.__parseStat(localName)}) \
            for childName, localName in ( ( 'Armor Class', 'AC'), ( 'Reflex', 'Reflex Defense'), ('Fortitude', 'Fortitude Defense'), ('Will', 'Will Defense')) \
        ]

        conditionLists = \
            [   factorList for defense, (val, factorList) in defensesDict.items() \
            ]
        defenseConditions = self.__pluckGlobalConditions(conditionLists)

        return defensesDict, defenseConditions

    def getResistancesDict(self):
        resistDict = {}

        # Go through every stat node, finding all that start with 'Resist:'
        statNode = None
        for statElement in self.statNodes:
            if 'Resist:' in statElement.aliasNames[0] or 'resist:' in statElement.aliasNames[0]:
                statNode = statElement

                # Do some processing: Pull out primary, secondary resistances.
                # e.g.: 'Resist:cold and resist 5 fire' means:
                # Cold is Stat.@value and fire is 5.
                # However, the second part ('and resist 5 fire') doesn't always appear,
                # but we still need a match.
                if 'and' in statElement.aliasNames[0]:
                    match = re.match(r"[rR]esist:(\w*) and [rR]esist (\d*) (\w*)", statElement.aliasNames[0])
                else:
                    match = re.match(r"[rR]esist:(\w*)", statElement.aliasNames[0])
                primaryResistance = match.group(1).lower()
                resistDict[primaryResistance] = resistDict.get(primaryResistance, 0) + int(statElement.get('value', 0))
                if match.lastindex > 1:
                    secondResistance = match.group(3).lower()
                    secondResistanceVal = int(match.group(2))
                    resistDict[secondResistance] = resistDict.get(secondResistance, 0) + secondResistanceVal

        # Convert resistDict to ints
        for resistanceName in resistDict:
            resistDict[resistanceName] = str(resistDict[resistanceName])

        return resistDict

    def getPassiveSkillsDict(self):
        """ Return a dictionary with keys defined by IP4CharacterTree.PASSIVE_SKILLS_CHILD_NODES.
            Values are 2-tuples as per getHealthDict().
        """

        childDict = {'Perception': (0, []), 'Insight': (0, [])}
        for childName, localName in \
        (   ('Perception', 'Passive Perception'),
            ('Insight', 'Passive Insight'),
            ('Perception', 'passive Perception'),
            ('Insight', 'passive Insight'),
        ):
            theValue, theFactors = self.__parseStat(localName)
            if theValue:
                childDict[childName] = (theValue, theFactors)
        return childDict

    def getSkillsDict(self):
        """ Return a dictionary with keys defined by IP4CharacterTree.SKILLS_CHILD_NODES.
            Values are 3-tuples.
        """

        childDict = {}
        [   childDict.update({childName: self.__parseStat(childName)}) \
            for childName in IP4CharacterTree.SKILLS_CHILD_NODES \
        ]

        newDict = {}
        for childName, (childValue, childFactors) in childDict.items():
            childNodeDict = {}
            newDict[childName] = (childValue, childFactors, childNodeDict)

            trainedFactors = [ cf for cf in childFactors if cf.get('name') == '%s Trained' % childName ]
            isTrained = int(trainedFactors[-1]['modifier'])
            childNodeDict['trained'] = isTrained and 'true' or 'false'
            if isTrained:
                [ tf.update({'name': 'Trained'}) for tf in trainedFactors ]
            else:
                [ childFactors.remove(tf) for tf in trainedFactors ]

            armorPenaltyFactors = [ cf for cf in childFactors if cf.get('name') == 'Armor Penalty' ]
            childNodeDict['armorpenaltyapplies'] = armorPenaltyFactors and 'true' or 'false'
            isPenalized = armorPenaltyFactors and int(armorPenaltyFactors[-1]['modifier'])
            if not isPenalized:
                [ childFactors.remove(tf) for tf in armorPenaltyFactors ]

            childNodeDict['url'] = self.__getRulesNode(type='Skill', name=childName).get('url', '') or '/characters/missingCompendium'

        childDict = newDict
        return childDict

    def getAbilityScoresDict(self):
        """ Return a dictionary with keys defined by IP4CharacterTree.ABILITY_SCORES_CHILD_NODES.
            Values are 2-tuples as per getHealthDict().
        """

        childDict = {}
        [   childDict.update({childName: self.__parseStat(childName)}) \
            for childName in IP4CharacterTree.ABILITY_SCORES_CHILD_NODES \
        ]

        return childDict

    def getPowersList(self):

        # Powers derived from class/race features need to use class/race URLs because those provided are broken.
        featureNamesToUrlsAndNames = {}
        for getPackageDict, getPackageFeatureDicts in \
        (
            (self.getRaceDict, self.getRaceFeatureDicts),
            (self.getClassDict, self.getClassFeatureDicts),
            (self.getParagonPathDict, self.getParagonPathFeatureDicts),
            (self.getEpicDestinyDict, self.getEpicDestinyFeatureDicts),
        ):
            packageDict = getPackageDict()
            if not packageDict:
                continue
            packageUrl = packageDict.get('url', None)
            if packageUrl is None:
                continue
            packageName = packageDict.get('name', None)
            if packageName is None:
                continue
            [ featureNamesToUrlsAndNames.update({pfd['name']:(packageUrl, packageName)}) for pfd in getPackageFeatureDicts() ]

        powerList = []
        powerNodes = self.charSheetNode.findall('PowerStats/Power')
        for powerNode in powerNodes:
            powerDict, powerConditionFactors, weaponList, powerCardItems = \
                {'powerusage': 'UNKNOWN', 'actiontype': 'UNKNOWN'}, [], [], []
            powerList.append((powerDict, powerConditionFactors, weaponList, powerCardItems))

            powerName = powerDict['name'] = powerNode.get('name', 'UNKNOWN')
            specificNodes = powerNode.findall('specific')
            for specificNode in specificNodes:
                specificName = specificNode.get('name')
                localName = \
                {   'Power Usage': 'powerusage',
                    'Power Type': 'powertype',
                    'Action Type': 'actiontype',
                    'Attack Type': 'attacktype',
                    'Level': 'level',
                    'Flavor': 'flavor',
                    'Display': 'source',
                    'Keywords': 'keywords',
                }.get(specificName, None)
                specificText = (specificNode.text or '').strip()
                if localName is not None:
                    specificText = specificText.replace(' action', ' Action')
                    powerDict[localName] = specificText
                elif specificName != 'Class' and specificName[0] != '_': # exclude anything with the _underscore
                    if specificText:
                        powerCardItems.append((specificName, specificText))

            powerDict['packageurl'], powerDict['packagename'] = featureNamesToUrlsAndNames.get(powerName, ('', ''))
            lowerPower = powerName.lower()
            if lowerPower in ('melee basic attack', 'ranged basic attack'):
                powerDict['url'] = 'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=426'
            else:
                powerDict['url'] = self.__getRulesNode(type='Power', name=powerName).get('url', '') or '/characters/missingCompendium'

            weaponNodes = powerNode.findall('Weapon')
            for weaponNode in weaponNodes:
                weaponDict, attackFactorDicts, damageFactorDicts, conditionFactors = \
                    {'weaponurl': ''}, [], [], []
                weaponList.append((weaponDict, attackFactorDicts, damageFactorDicts, conditionFactors))

                weaponDict['name'] = weaponNode.get('name', '')
                weaponDict['attackstat'] = weaponNode.find('AttackStat').text.strip()
                weaponDict['attackbonus'] = weaponNode.find('AttackBonus').text.strip()
                weaponDict['defense'] = weaponNode.find('Defense').text.strip()
                weaponDict['damage'] = weaponNode.find('Damage').text.strip()
                damageTypeNode = weaponNode.find('DamageType')
                if damageTypeNode is not None:
                    weaponDict['damagetype'] = damageTypeNode.text.strip()

                # Magic weapons get represented by two RulesElement nodes - a Weapon and a Magic Item.
                # Some others show up as simply Gear.
                for weaponRuleElement in weaponNode.findall('RulesElement'):
                    ruleType = weaponRuleElement.get('type')
                    if ruleType == 'Magic Item':
                        weaponDict['enhancementurl'] = weaponRuleElement.get('url', '') or '/characters/missingCompendium'
                    else:
                        weaponDict['weaponurl'] = weaponRuleElement.get('url', '') or '/characters/missingCompendium'
                # Some show up as _just_ a magic item, in which case we promote enhancementurl to weaponurl.
                if weaponDict.get('enhancementurl') and not weaponDict.get('weaponurl'):
                    weaponDict['weaponurl'] = weaponDict.get('enhancementurl')
                    del weaponDict['enhancementurl']

                for componentsName, targetFactorDicts in \
                (   ( 'HitComponents', attackFactorDicts ),
                    ( 'DamageComponents', damageFactorDicts ),
                ):
                    # We came across ' \n ' in a file, thus the list comp.
                    for thisComponent in [ s for s in weaponNode.find(componentsName).text.strip().split('\n') if s.strip() ]:
                        # Parse "+1 half your level." into "+1" and "half your level"
                        componentWords = thisComponent.strip().rstrip('.').split()
                        factorDict = {'modifier': componentWords[0], 'name': ' '.join(componentWords[1:])}
                        self.__massageFactorDictNames(factorDict)
                        targetFactorDicts.append(factorDict)

                conditionNode = weaponNode.find('Conditions')
                if conditionNode is not None:
                    for thisCondition in conditionNode.text.strip().split('\n'):
                        conditionWords = thisCondition.rstrip('.').split()
                        conditionModifier, conditionName = conditionWords[0], ' '.join(conditionWords[1:])
                        factorDict = {'modifier': conditionWords[0], 'name': conditionName, 'condition': conditionName }
                        self.__massageFactorDictNames(factorDict)
                        conditionFactors.append(factorDict)

            # If a condition shows up in each weapon, promote it to the power.
            if weaponList:
                for globalCondition in self.__pluckGlobalConditions([ wl[3] for wl in weaponList ]):
                    powerConditionFactors.append(globalCondition)

        # Before returning, we need to troll for Monks powers like "Dancing Cobra [Movement Technique]"
        # which are always paired with "Dancing Cobra".  The latter has the correct URL, and the two
        # are the same power as far as usage (encounter/daily) is concerned.
        powerNamesToDicts = {}
        [ powerNamesToDicts.update({powerDict['name']: powerDict}) for powerDict, conditionFactors, weaponList, powerCardItems in powerList ]
        for powerName, powerDict in powerNamesToDicts.items():
            moveTechIndex = powerName.find(' [Movement Technique]')
            if moveTechIndex == -1:
                continue
            basePowerDict = powerNamesToDicts.get(powerName[:moveTechIndex], None)
            if basePowerDict is None:
                continue
            powerDict['name'], powerDict['url'] = basePowerDict['name'], basePowerDict['url']

        # Add fake powers like Action Points and Second Wind (which is a minor action for some characters)
        secondWindActionType = 'Standard Action'
        for rulesNode in self.rulesNodes:
            if rulesNode.specificAttributes.get('Short Description', None) == 'Second wind is minor action.':
                secondWindActionType = 'Minor Action'
                break
        mySpeed = self.movementDict['Speed'][0]

        # The isMore argument means these powers may be lumped together in an expandable widget.
        powerList.extend(\
            [
                (   {   'name':'Second Wind', 'powerusage':'Encounter', 'actiontype':secondWindActionType,
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=334', 
                    }, [], [], []
                ),
                (   {   'name':'Opportunity Attack', 'powerusage':'At-Will', 'actiontype':'Opportunity Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=331', 
                    }, [], [], []
                ),
                (   {   'name':'Opportunity Action', 'powerusage':'At-Will', 'actiontype':'Opportunity Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=119', 
                    }, [], [], []
                ),
                (   {   'name':'Readied action', 'powerusage':'At-Will', 'actiontype':'Immediate Reaction', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=332', 
                    }, [], [], []
                ),
                (   {   'name':'Action Point', 'powerusage':'Encounter', 'actiontype':'Free Action',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=177', 
                    }, [], [], []
                ),
                (   {   'name':'Delay', 'powerusage':'At-Will', 'actiontype':'Free Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=327', 
                    }, [], [], []
                ),
                (   {   'name':'End a grab', 'powerusage':'At-Will', 'actiontype':'Free Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=329', 
                    }, [], [], []
                ),
                (   {   'name':'Drop prone', 'powerusage':'At-Will', 'actiontype':'Minor Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=141', 
                    }, [], [], []
                ),
                (   {   'name':'Aid Another', 'powerusage':'At-Will', 'actiontype':'Standard Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=322', 
                    }, [], [], []
                ),
                (   {   'name':'Bull Rush', 'powerusage':'At-Will', 'actiontype':'Standard Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=323', 
                    }, [], [], []
                ),
                (   {   'name':'Charge', 'powerusage':'At-Will', 'actiontype':'Standard Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=324', 
                    }, [], [], []
                ),
                (   {   'name':'Coup de grace', 'powerusage':'At-Will', 'actiontype':'Standard Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=325', 
                    }, [], [], []
                ),
                (   {   'name':'Grab', 'powerusage':'At-Will', 'actiontype':'Standard Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=329', 
                    }, [], [], []
                ),
                (   {   'name':'Sustain a Grab', 'powerusage':'At-Will', 'actiontype':'Minor Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=329', 
                    }, [], [], []
                ),
                (   {   'name':'Ready an action', 'powerusage':'At-Will', 'actiontype':'Standard Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=332', 
                    }, [], [], []
                ),
                (   {   'name':'Total defense', 'powerusage':'At-Will', 'actiontype':'Standard Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=338', 
                    }, [], [], []
                ),
                (   {   'name':'Walk %d squares' % mySpeed, 'powerusage':'At-Will', 'actiontype':'Move Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=339', 
                    }, [], [], []
                ),
                (   {   'name':'Run %d squares' % (mySpeed + 2), 'powerusage':'At-Will', 'actiontype':'Move Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=333', 
                    }, [], [], []
                ),
                (   {   'name':'Shift 1 square', 'powerusage':'At-Will', 'actiontype':'Move Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=335', 
                    }, [], [], []
                ),
                (   {   'name':'Crawl %d squares' % (mySpeed / 2), 'powerusage':'At-Will', 'actiontype':'Move Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=326', 
                    }, [], [], []
                ),
                (   {   'name':'Squeeze %d squares' % (mySpeed / 2), 'powerusage':'At-Will', 'actiontype':'Move Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=336', 
                    }, [], [], []
                ),
                (   {   'name':'Stand up', 'powerusage':'At-Will', 'actiontype':'Move Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=337', 
                    }, [], [], []
                ),
                (   {   'name':'Escape a Grab', 'powerusage':'At-Will', 'actiontype':'Move Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=328', 
                    }, [], [], []
                ),
                (   {   'name':'Any Move Action', 'powerusage':'At-Will', 'actiontype':'Standard Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=116',
                    }, [], [], []
                ),
                (   {   'name':'Any Minor Action', 'powerusage':'At-Will', 'actiontype':'Standard Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=117',
                    }, [], [], []
                ),
                (   {   'name':'Any Minor Action', 'powerusage':'At-Will', 'actiontype':'Move Action', 'isMore': 'true',
                        'url':'http://www.wizards.com/dndinsider/compendium/glossary.aspx?id=117',
                    }, [], [], []
                ),
            ])
        
        return powerList

    def __pluckGlobalConditions(self, conditionLists):
        """ Pass a list of lists of condition dictionaries, 
            such as the list of conditions for a group of weapons or defenses.

            Any condition that is an all of the lists will be pulled out,
            and returned in a list of such "global" conditions.

            We're even nice if you screw up and pass in factors that aren't conditions.  We'll leave them be.
        """

        # Find the globals.
        globalConditions = []
        for conditionFromFirstList in conditionLists[0]:
            if conditionFromFirstList.get('condition', None) is None:
                continue # Make good on the "be nice" statement in the comment.

            isGlobal = 1
            for thisConditionList in conditionLists[1:]:
                isHere = 0
                for thisCondition in thisConditionList:
                    if thisCondition == conditionFromFirstList:
                        isHere = 1
                        break
                if not isHere:
                    isGlobal = 0
                    break
            if isGlobal:
                globalConditions.append(conditionFromFirstList)

        # Remove them from the original lists.
        for globalCondition in globalConditions:
            for thisConditionList in conditionLists:
                matchingFactors = [ tw for tw in thisConditionList if tw == globalCondition ]
                [ thisConditionList.remove(mf) for mf in matchingFactors ]

        return globalConditions

    def getFeatsList(self):
        """ Return a list of dictionaries, each having keys defined by IP4CharacterTree.FEAT_ATTRIBUTES.
        """

        featsList = []
        for featNode in self.__getRulesNodes(type='Feat'):
            featDict = {'description': ''}
            featsList.append(featDict)

            [ featDict.update({attrName: featNode.get(attrName, '')}) for attrName in ('name', 'url') ]
            if not featDict['url']:
                lowerFeat = featDict['name'].lower()

                # We weren't provided a URL.  Go through a list of known deficiencies, falling back on our own explanatory URL.
                if not lowerFeat.find('weapon expertise ('):
                    featDict['url'] = 'http://www.wizards.com/dndinsider/compendium/feat.aspx?id=1032'
                elif not lowerFeat.find('weapon focus ('):
                    featDict['url'] = 'http://www.wizards.com/dndinsider/compendium/feat.aspx?id=233'
                elif not lowerFeat.find('implement expertise ('):
                    featDict['url'] = 'http://www.wizards.com/dndinsider/compendium/feat.aspx?id=734'
                elif not lowerFeat.find('versatile expertise ('):
                    featDict['url'] = 'http://www.wizards.com/dndinsider/compendium/feat.aspx?id=2785'
                elif not lowerFeat.find('superior implement training ('):
                    featDict['url'] = 'http://www.wizards.com/dndinsider/compendium/feat.aspx?id=2624'
                else:
                    featDict['url'] = '/characters/missingCompendium'

            specificNode = featNode.find('specific')
            if specificNode is not None and specificNode.get('name', None) == 'Short Description':
                featDict['description'] = specificNode.text.strip()

        return featsList

    def getLootDict(self):
        """ Return a dict of loot attributes, containing at least those keys defined
            by IP4CharacterTree.LOOT_ATTRIBUTES.
        """
        lootDict = {}

        for thisPrefix, lootName in (('carried', 'CarriedMoney'), ('stored', 'StoredMoney')):
            lootDisplay = self.charSheetNode.find('Details/%s' % lootName).text.strip()

            # Parse out: "20 ad; 30 pp; 40 gp" into individual coin type counts.
            displayPieces = [ ld.strip() for ld in lootDisplay.split(';') ]
            coinAmountsAndTypes  = [ dp.split() for dp in displayPieces if dp ]
            coinTypesToAmounts = {}

            # Just in case...
            for coinAmount, coinType in coinAmountsAndTypes:
                try:
                    coinTypesToAmounts[coinType] = int(coinAmount)
                except ValueError:
                    coinTypesToAmounts[coinType] = 0

            for coinType in ('ad', 'pp', 'gp', 'sp', 'cp'):
                lootDict['%(thisPrefix)s-%(coinType)s' % locals()] = str(coinTypesToAmounts.get(coinType, 0))

        # The 'Weight' stat is actually the amount of weight we're carrying.
        lootDict['weightCarried'] = str(self.__parseStat('Weight')[0])

        return lootDict

    def getItemList(self):
        """ Return a list of 2-tuples, each representing an item of loot:

                - itemDict: dictionary with keys defined by IP4CharacterTree.ITEM_ATTRIBUTES.
                - enhancementDict: dictionary with keys defined by IP4CharacterTree.ENHANCEMENT_ATTRIBUTES.
                  May be None to indicate the lack of enhancement.
        """

        itemList = []
        for lootNode in self.charSheetNode.findall('LootTally/loot'):
            itemDict = {}
            [   itemDict.update({attrName: lootNode.get(localName, '')}) for attrName, localName in \
                (   ('count', 'count'),
                    ('equippedcount', 'equip-count'),
                ) \
            ]

            # Skip equipment you don't have anymore.
            if (itemDict['count'], itemDict['equippedcount']) == ('0','0'):
                continue

            # If there are multiple RulesElements, and one is a Magic Item type, it is an enhancement.
            enhancementDict = None
            itemRules = lootNode.findall('RulesElement')
            numRules = len(itemRules)
            for itemRule in itemRules:
                ruleType = itemRule.get('type', None)
                if ruleType == 'Magic Item' and numRules > 1:
                    enhancementDict = {}
                    [ enhancementDict.update({attrName: itemRule.get(attrName, '')}) for attrName in ('name', 'url') ]
                    enhancementDict['url'] = enhancementDict['url'] or '/characters/missingCompendium'
                    if enhancementDict['url'].count('item.aspx'):
                        enhancementDict['url'] = '%s&page=item' % enhancementDict['url'].replace('item.aspx', 'display.aspx')
                else:
                    [ itemDict.update({attrName: itemRule.get(attrName, '')}) for attrName in ('name', 'url', 'type') ]
                    itemDict['url'] = itemDict['url'] or '/characters/missingCompendium'
                    if itemDict['url'].count('item.aspx'):
                        itemDict['url'] = '%s&page=item' % itemDict['url'].replace('item.aspx', 'display.aspx')

            itemList.append((itemDict, enhancementDict))

        return itemList

    def getLanguageNames(self):
        """ Return a list of the names of languages known.
        """

        languageList = [ languageNode.get('name', '') for languageNode in self.__getRulesNodes(type='Language') ]
        languageList = [ ll for ll in languageList if ll ] # trim blank names.
        return languageList

    def getWeaponProficienciesAndGroups(self):
        """ Return a 2-tuple:
        
                - proficiencyDicts: list of dictionaries with keys defined by IP4CharacterTree.PROFICIENCY_ATTRIBUTES.
                - groupsList: a list of 2-tuples:

                    - groupDict: dictionary with keys defined by IP4CharacterTree.PROFICIENCY_GROUP_ATTRIBUTES.
                    - groupProfsDict: list of dictionaries with keys defined by IP4CharacterTree.PROFICIENCY_ATTRIBUTES.
        """

        return self.__getProficiencyDicts('Weapon')

    def getArmorProficiencyDicts(self):
        """ Return a list of dictionaries with keys defined by IP4CharacterTree.PROFICIENCY_ATTRIBUTES.
        """

        return self.__getProficiencyDicts('Armor')

    def getShieldProficiencyDicts(self):
        """ Return a list of dictionaries with keys defined by IP4CharacterTree.PROFICIENCY_ATTRIBUTES.
        """

        return self.__getProficiencyDicts('Shield')

    def __getProficiencyDicts(self, profType):
        profDicts = []
        doneNames = {}
        groupNamesToTuples = {}

        # The first thing we look for is Proficiency nodes with Proficiency children, because they represent groups.
        levelRuleNodes = self.d20CharNode.findall('Level//RulesElement')
        if profType == 'Weapon':

            profGroupNodes = \
                [   lrn for lrn in levelRuleNodes if lrn.get('type', None) == 'Proficiency' \
                    and lrn.get('name', '').split()[0] not in ('Weapon', 'Armor', 'Shield') \
                ]
            for profGroupNode in profGroupNodes:
                groupName = profGroupNode.get('name', '')

                if not groupName.find('Implement Proficiency'):
                    profDict = {'name':groupName.split(')')[0].split('(')[-1], 'source':self.__className}
                    implementGroupDict, implementGroupProfDicts = groupNamesToTuples.setdefault('Implement Proficiency',
                        ({'name':'Implement Proficiency', 'source':self.__className}, []))
                    implementGroupProfDicts.append(profDict)
                    continue

                # We don't want to note the same group twice, simply extend the included items.
                groupDict, groupProfDicts = groupNamesToTuples.setdefault(groupName, 
                    ({'name':groupName, 'source':self.__className}, []))

                profNames = \
                    [   rel.get('name', '').split('(')[1][:-1].capitalize().split(' (')[0] \
                        for rel in profGroupNode.findall('RulesElement') \
                    ]
                profNames = [ pn for pn in profNames if doneNames.get(pn, None) is None ]
                [ doneNames.update({pn:1}) for pn in profNames ]

                for profName in profNames:
                    profDict = {'name':profName, 'source':self.__className}

                    if not profName.find('Implement Proficiency'):
                        implementGroupDict, implementGroupProfDicts = groupNamesToTuples.setdefault('Implement Proficiency',
                            ({'name':'Implement Proficiency', 'source':self.__className}, []))
                        implementGroupProfDicts.append(profDict)
                    else:
                        groupProfDicts.append(profDict)

        # Look for nodes from most to least specific.
        for ruleType in ('Racial Trait', 'Feat', 'Grants'):
            theseRules = [ lrn for lrn in levelRuleNodes if lrn.get('type', None) == ruleType ]

            for thisRule in theseRules:

                sourceName = thisRule.get('name', '')
                profNames = \
                    [   rel.get('name', '').split('(')[1][:-1].capitalize().split(' (')[0] \
                        for rel in thisRule.findall('.//RulesElement') \
                        if rel.get('type', None) == 'Proficiency' and rel.get('name', '').split()[0] == profType \
                    ]

                # Skip ones we already did, do the rest, then mark the ones we did for later skipping.
                profNames = [ pn for pn in profNames if doneNames.get(pn, None) is None ]
                [ doneNames.update({pn:1}) for pn in profNames ]

                for profName in profNames:
                    profDict = {'name':profName, 'source':sourceName}

                    if profType == 'Weapon' and not profName.find('Implement Proficiency'):
                        groupDict, groupProfDicts = groupNamesToTuples.setdefault('Implement Proficiency',
                            ({'name':'Implement Proficiency', 'source':sourceName}, []))
                        groupProfDicts.append(profDict)
                    else:
                        profDicts.append(profDict)

        if profType == 'Weapon':
            return profDicts, sorted(groupNamesToTuples.values())
        return profDicts

class IP4CharacterTree(ElementTree.ElementTree):
    """ A subclass of ElementTree that uses a CharacterDataSource instance
        to build a tree of IP4XML nodes.
    """

    DESCRIPTION_ATTRIBUTES_OPTIONAL = ('gender', 'height', 'weight', 'age')
    DESCRIPTION_CHILDREN = ('Notes', 'Appearance', 'Traits', 'Companions')
    BUILD_ATTRIBUTES = ('name', 'level', 'tier', 'experience', 'powersource', 'role', 'alignment', 'vision', 'size', 'gender', 'deity', 'ExperienceNeeded')
    BUILD_CHILD_ATTRIBUTES = ('name', 'url', 'description') # Race, Background, Class, ParagonPath, EpicDestiny attributes
    HEALTH_CHILD_NODES = ('MaxHitPoints', 'BloodiedValue', 'MaxSurges', 'SurgeValue', 'PowerPoints')
    MOVEMENT_CHILD_NODES = ('Speed', 'Initiative')
    DEFENSES_CHILD_NODES = ('Armor Class', 'Fortitude', 'Reflex', 'Will')
    DEFENSES_CHILD_ABBREVIATIONS = ('AC', 'Fort', 'Ref', 'Will')
    PASSIVE_SKILLS_CHILD_NODES = ('Perception', 'Insight')
    SKILLS_CHILD_NODES = (  'Acrobatics', 'Arcana', 'Athletics', 'Bluff', 'Diplomacy', 
                            'Dungeoneering', 'Endurance', 'Heal', 'History', 'Insight', 'Intimidate', 
                            'Nature', 'Perception', 'Religion', 'Stealth', 'Streetwise', 'Thievery',
                         )
    SKILL_ATTRIBUTES = ( 'trained', 'armorpenaltyapplies', 'url' )
    ABILITY_SCORES_CHILD_NODES = ('Strength', 'Constitution', 'Dexterity', 'Intelligence', 'Wisdom', 'Charisma')
    ABILITY_SCORES_CHILD_ABBREVIATIONS = ('Str', 'Con', 'Dex', 'Int', 'Wis', 'Cha')
    POWER_ATTRIBUTES = ('name', 'url', 'powerusage', 'actiontype', 'packageurl', 'packagename', 'isMore')
    POWER_ATTRIBUTES_OPTIONAL = ('powertype', 'attacktype', 'target', 'level', 'flavor', 'source', 'keywords')
    POWER_WEAPON_ATTRIBUTES = ('name', 'weaponurl', 'attackstat', 'defense', 'attackbonus', 'damage')
    POWER_WEAPON_ATTRIBUTES_OPTIONAL = ('damagetype', 'enhancementurl')
    FEAT_ATTRIBUTES = ('name', 'url', 'description')
    LOOT_ATTRIBUTES = ('carried-ad', 'carried-pp', 'carried-gp', 'carried-sp', 'carried-cp', 'stored-ad', 'stored-pp', 'stored-gp', 'stored-sp', 'stored-cp', 'weightCarried')
    ITEM_ATTRIBUTES = ('name', 'type', 'url', 'count', 'equippedcount')
    ENHANCEMENT_ATTRIBUTES = ('name', 'url')
    PROFICIENCY_ATTRIBUTES = ('name', 'source')
    PROFICIENCY_GROUP_ATTRIBUTES = ('name', 'source')

    FEATURE_ATTRIBUTES = ('name', 'description')
    FACTOR_ATTRIBUTES = ('name', 'modifier')
    FACTOR_ATTRIBUTES_OPTIONAL = ('abbreviation', 'condition', 'multiplier', 'multiplied')
    # NOTE: the presence of 'condition' makes a Factor element into a Condition element

    ABILITY_SCORE_NAMES = ('Strength', 'Constitution', 'Dexterity', 'Intelligence', 'Wisdom', 'Charisma')
    ABILITY_SCORE_MODIFIER_NAMES = tuple([ '%s modifier' % asn for asn in ABILITY_SCORE_NAMES ])

    CHARACTER_COMMENT = """\
Character Element: always present
    Required attributes: name, key
    Control attributes:
        safe-key: a variation of the key that is safe for use in javascript variable names.
            You will probably only use this when calling initializeCharacter (see jPint.xsl for an example).
        IP4Login: assign to each HTML element that can be clicked to log in.
            You should also set style="display:none;" on such elements; they will be made visible if not logged in.
        IP4Logout: assign to each HTML element that can be clicked to log out.
            You should also set style="display:none;" on such elements; they will be made visible if logged in.
        IP4SyncPrompt: assign to each HTML element that should allow clicking to force a character state sync.
        IP4Sync: assign to each HTML element that should dynamically indicate sync status.
        IP4Syncing: style because it will be assigned to the IP4Sync elements during sync operations.
        IP4SyncError: style because it will be assigned to the IP4Sync elements for sync failures.
        IP4Manage: assign to each HTML element that can be clicked to perform actions on the character (download, etc...)
        Roller: assign to each HTML element that can be clicked to do a die roll.  
            Should always be used in conjunction with the dice-class attribute of another element (e.g. Movement/Initiative).
        CUR_ActionPoints: assign to at least one HTML element that should dynamically display current action points.
        action-points-add-script: javascript to execute to add an action point.
        action-points-subtract-script: javascript to execute to subtract an action point.
        milestone-script: javascript to execute when the character gains a milestone."""

    BUILD_COMMENT = """\
Build element: always present
    Required attributes: alignment, experience, level, name, powersource, role, size, tier, vision, deity, gender
        The name attribute is the build name if one was selected in the Character Builder, or the class name otherwise.
        Attribute may be blank.
    Control attributes:
        ExperiencePoints: assign to at least one HTML element that should dynamically display current XP.
        experience-prompt-script: javascript to execute to prompt the user for XP to add.
    Children:
        Race element: always present
            Required attributes: name, url, description
            Children:
                Feature elements: one per race feature
                    Required attributes: name, description
        Background element: sometimes present
            Required attributes: name, url, description
            Children: as Race element
        Class element: always present
            Required attributes: name, url, description
            Children: as Race element
        ParagonPath element: present if of sufficient level
            Required attributes: name, url, description
            Children: as Race element
        EpicDestiny element: present if of sufficient level
            Required attributes: name, url, description
            Children: as Race element"""

    RESISTANCES_COMMENT = """\
Resistances element: Always present
    Optional Attributes: Fire, Cold, etc. (all allowed resistances)
"""

    DESCRIPTION_COMMENT = """\
Description element: may be absent if all attributes and children are absent from the dnd4e file.
    Optional attributes: gender, height, weight, age
    Children:
        Notes element: always present
            Content: multi-line text
        Appearance element: always present
            Content: multi-line text
        Traits element: always present
            Content: multi-line text
        Companions element: always present
            Content: multi-line text"""

    HEALTH_COMMENT = """\
Health element: always present
    Control attributes:
        short-rest-script: javascript to execute when the user wants to take a short rest.
        extended-rest-script: javascript to execute when the user wants to take an extended rest.
        tempHP-display-class: assign to at least one HTML element that should dynamically display temp HP.
        tempHP-prompt-script: javascript to execute to prompt the user for a new temp HP value.
        tempHP-bar-class: assign to all HTML elements that should have width set in proportion to current tempHP/max HP.
        death-saves-display-class: assign to at least one HTML element that should dynamically display current HP.
        death-saves-add-script: javascript to execute to add a death save.
        death-saves-subtract-script: javascript to execute to subtract a death save.
        power-points-display-class: assign to at least one HTML element that should dynamically display current power points.
        power-points-add-script: javascript to execute to add a power point.
        power-points-subtract-script: javascript to execute to subtract a power point.
        conditions-display-class: assign to at least on HTML element that should dynamically contain a div per condition.
        conditions-prompt-script: javascript to execute to prompt the user to enter a new condition.
        CUR_ConditionsDelete: will be dynamically assigned to each condition div in conditions-display-class elements.
            Not necessary to assign to any elements, but should probably be styled with css in your XSL.
    Child elements:
        MaxHitPoints: always present
            Required attributes: value
            Control attributes:
                CUR_HitPoints: assign to at least one HTML element that should dynamically display current HP.
                CUR_HitPointsBar: assign to all HTML elements that should have width set in proportion to current/max HP.
                CUR_HitPointsDying: assign to all HTML elements that should only be displayed if the character is dying.
                damage-prompt-script: javascript to execute to prompt the user for hit points of damage taken.
                heal-prompt-script: javascript to execute to prompt the user for hit points healed.
            Children:
                Factor elements: one for each factor contributing to the value.
                    Required attributes: name, modifier
                    Optional attributes: abbreviation, multiplier, multiplied
                        The "multiplier" and "multiplied" are only present if math was performed to get the modifier.
        BloodiedValue: always present
            Required attributes: value
            Children: as MaxHitPoints
        MaxSurges: always present
            Required attributes: value
            Control attributes:
                CUR_Surges: assign to at least one HTML element that should dynamically display current surges.
                CUR_SurgesBar: assign to all HTML elements that should have width set in proportion to current/max surges.
                add-script: javascript to execute to add a surge.
                subtract-script: javascript to execute to subtract a surge.
            Children: as MaxHitPoints
        SurgeValue: always present
            Required attributes: value
            Control attributes:
                toHitPoints-script: javascript to execute when the surge value should be added to hit points.
            Children: as MaxHitPoints"""

    MOVEMENT_COMMENT = """\
Movement element: always present
    Children:
        Speed element: always present
            Required attributes: value
            Children:
                Factor elements: one for each factor contributing to the value.
                    Required attributes: name, modifier
                    Optional attributes: abbreviation, multiplier, multiplied
                        The "multiplier" and "multiplied" are only present if math was performed to get the modifier.
        Initiative element: always present
            Required attributes: 
                value: number to display
                dice-class: use in conjunction with "Roller" to make an initiative roller element.
            Children:
                Factor elements: one for each factor contributing to the value.
                    Required attributes: name, modifier
                    Optional attributes: abbreviation, multiplier, multiplied
                        The "multiplier" and "multiplied" are only present if math was performed to get the modifier."""

    DEFENSES_COMMENT = """\
Defenses element: always present
    Children:
        Condition elements: present if one or more conditions affect all defenses
            Required attributes: name
        Defense elements: four Defense elements are always present.
            Required attributes: value, abbreviation, name (name is "ArmorClass", "Fortitude", "Reflex" or "Will")
            Children:
                Factor elements: one for each factor contributing to the value.
                    Required attributes: name, modifier
                    Optional attributes: abbreviation, multiplier, multiplied
                        The "multiplier" and "multiplied" are only present if math was performed to get the modifier.
                Condition elements: present if one or more conditions affect this defense
                    Required attributes: name"""

    PASSIVE_SKILLS_COMMENT = """\
PassiveSkills element: always present
    Children:
        PassiveSkill elements: two PassiveSkill elements are always present
            Required attributes: value, name (name is "Perception" or "Insight")
            Children:
                Factor elements: one for each factor contributing to the value.
                    Required attributes: name, modifier
                    Optional attributes: abbreviation, multiplier, multiplied
                        The "multiplier" and "multiplied" are only present if math was performed to get the modifier."""

    SKILLS_COMMENT = """\
Skills element: always present
    Children:
        Skill elements: one for each skill defined by the Character Builder
            Required attributes: 
                name: name of the skill
                value: numeric display value
                dice-class: Use in conjunction with "Roller" to create a skill roller element.
                url: Compendium URL for the skill
                trained: "true" or "false"
                armorpenaltyapplies: "true" or "false"
            Children:
                Factor elements: one for each factor contributing to the value.
                    Required attributes: name, modifier
                    Optional attributes: abbreviation, multiplier, multiplied
                        The "multiplier" and "multiplied" are only present if math was performed to get the modifier."""

    ABILITY_SCORES_COMMENT = """\
AbilityScores element: always present
    Children:
        AbilityScore elements: six AbilityScore elements are always present.
            Required attributes: value, abbreviation, name ("Strength", etc...)
            Children:
                AbilityModifier element: always present
                    Required attributes: 
                        modifier: base modifier
                        rollmodifier: (includes 1/2 level)
                        dice-class: use in conjunction with "Roller" to build an ability check roller element.
                Factor elements: one for each factor contributing to the value.
                    Required attributes: name, modifier
                    Optional attributes: abbreviation, multiplier, multiplied
                        The "multiplier" and "multiplied" are only present if math was performed to get the modifier."""

    POWERS_COMMENT = """\
Powers element: always present
    Child elements:
        Power elements: one per power
            Required attributes: name, url, powerusage, actiontype
            Optional attributes: powertype, attacktype, target, level, flavor, source, keywords
            Control attributes: only present for Encounter and Daily powers.
                display-class: assign to all HTML elements that should have classname "Used" added 
                    when the power is used, and classname "Used" removed when the power is un-used.
                use-script: javascript to execute when the user marks a power used or unused.
            Child Elements:
                Condition elements: one per condition that affects all weapons.
                    Required attributes: name
                Weapon elements: one per weapon that is legal for use with the power.
                    Required attributes: name, url, attackstat, defense
                    Child elements:
                        Condition elements: one per condition that affects all weapons.
                            Required attributes: name
                            Optional attributes: dice-class; if present, this condition should be presented as a "Roller".
                        AttackBonus element: always present
                            Required attributes: 
                                value: value to display
                                dice-class: use in conjunction with "Roller" to make an attack roller element.
                            Child elements:
                                Factor elements: one per factor contributing to the value
                                    Required attributes: name, modifier
                                    Optional attributes: abbreviation, multiplier, multiplied
                                        The "multiplier" and "multiplied" are only present if math was performed to get the modifier.
                        Damage element: always present
                            Required attributes: 
                                value: value to display
                                dice-class: use in conjunction with "Roller" to make a damage roller element.
                            Optional attributes: type (e.g. lightning)
                            Child elements:
                                Factor elements: one per factor contributing to the value
                                    Required attributes: name, modifier
                                    Optional attributes: abbreviation, multiplier, multiplied
                                        The "multiplier" and "multiplied" are only present if math was performed to get the modifier."""

    FEATS_COMMENT = """\
Feats element: always present
    Children:
        Feat elements: one for each Feat the character has.
            Required attributes: name, url, description"""

    LOOT_COMMENT = """\
Loot element: always present
    Required attributes: 
        carried-ad, carried-pp, carried-gp, carried-sp, carried-cp: number of each type of coin carried.
        stored-ad, stored-pp, stored-gp, stored-sp, stored-cp: number of each type of coin stored.
        carried-ad-display-class, carried-pp-display-class, carried-gp-display-class, carried-sp-display-class, carried-cp-display-class:
            assign to at least one HTML element each to dynamically display number of each coin type carried.
        stored-ad-display-class, stored-pp-display-class, stored-gp-display-class, stored-sp-display-class, stored-cp-display-class:
            assign to at least one HTML element each to dynamically display number of each coin type stored.
    Control attributes:
        daily-use-display-class: assign to at least one HTML element that should dynamically display remaining daily magic item uses.
        daily-use-add-script: javascript to execute when the user triggers a daily item power.
        daily-use-subtract-script: javascript to execute when the user regains a daily item power.
        carried-ad-add-script, carried-pp-add-script, carried-gp-add-script, carried-sp-add-script, carried-cp-add-script:
            javascript to execute to ask the user how many coins of a given type to add to those carried.
        carried-ad-subtract-script, carried-pp-subtract-script, carried-gp-subtract-script, carried-sp-subtract-script, carried-cp-subtract-script:
            javascript to execute to ask the user how many coins of a given type to subtract from those carried.
        stored-ad-add-script, stored-pp-add-script, stored-gp-add-script, stored-sp-add-script, stored-cp-add-script:
            javascript to execute to ask the user how many coins of a given type to add to those stored.
        stored-ad-subtract-script, stored-pp-subtract-script, stored-gp-subtract-script, stored-sp-subtract-script, stored-cp-subtract-script:
            javascript to execute to ask the user how many coins of a given type to subtract from those stored.
    Child elements:
        Item elements: one for each item.
            Required attributes: count, equippedcount, name, type, url
                Do not have expectations about values in the type attribute (e.g. Weapon, Armor) or you will miss something.
            Child elements:
                Enhancement element: only present if the parent element has an enhancement.
                    Require attributes: name, url"""

    LANGUAGES_COMMENT = """\
Languages element: always present 
    Children:
        Language elements: one for each language
            Required attributes: name"""

    PROFICIENCIES_COMMENT = """\
Proficiencies element: always present
    Children:
        ArmorProficiencies element: may be absent if the character has no armor proficiences.
            Children:
                Proficiency elements: one for each armor proficiency
                    Required attributes: name, source
        ShieldProficiencies element: may be absent if the character has no shield proficiences.
            Children:
                Proficiency elements: one for each shield proficiency
                    Required attributes: name, source
        WeaponProficiencies element: may be absent if the character has no weapon proficiences.
            Children:
                Proficiency elements: one for each weapon proficiency that isn't in a group.
                    Required attributes: name, source
                ProficiencyGroup elements: one for each group of weapon proficiencie (e.g. "simple melee")
                    Required attributes: name, source
                    Children:
                        Proficiency elements: one for each weapon proficiency in the group
                            Required attributes: name, source"""

    def setStyleUrl(self, styleUrl):
        self.styleUrl = styleUrl
        return self

    def __init__(self, characterDataSource):

        self.rootNode = rootNode = ElementTree.Element('Character')
        ElementTree.ElementTree.__init__(self, rootNode)
        self.setStyleUrl('')

        charName, charKey = characterDataSource.getNameAndKey()
        lettersAndDigits = string.letters + string.digits
        safeKey = ''.join([k for k in charKey if k in lettersAndDigits ])

        rootNode.set('name', charName)
        rootNode.set('key', charKey)
        rootNode.set('safe-key', safeKey)
        rootNode.set('action-points-add-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_Action Points', {autoValue:1, calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())
        rootNode.set('action-points-subtract-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_Action Points', {autoValue:-1, calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())
        rootNode.set('milestone-script', 'CHARACTER%(safeKey)s.milestone();' % locals())

        descDict = characterDataSource.getDescriptionDict()
        attrNamesAndValues = [ ( dao, descDict[dao] ) for dao in self.DESCRIPTION_ATTRIBUTES_OPTIONAL if descDict.get(dao, None) ]
        childNamesAndTexts = [ ( dc, descDict.get(dc, '') ) for dc in self.DESCRIPTION_CHILDREN ]
        if attrNamesAndValues or childNamesAndTexts:
            descNode = ElementTree.SubElement(rootNode, 'Description')
            [ descNode.set(attrName, value) for attrName, value in attrNamesAndValues ]

            for childName, childText in childNamesAndTexts:
                descChild = ElementTree.SubElement(descNode, childName)
                descChild.text = childText

        rootNode.append(ElementTree.Comment(self.BUILD_COMMENT))
        buildNode = ElementTree.SubElement(rootNode, 'Build')
        buildDict = characterDataSource.getBuildDict()
        [ buildNode.set(attrName, buildDict.get(attrName, '')) for attrName in self.BUILD_ATTRIBUTES ]
        buildNode.set('experience-prompt-script', """CHARACTER%(safeKey)s.triggerVariable('Experience Points', {requireInt:1, text:'How many XP should be added?', calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())

        rootNode.append(ElementTree.Comment(self.RESISTANCES_COMMENT))
        resistNode = ElementTree.SubElement(rootNode, 'Resistances')
        resistDict = characterDataSource.getResistancesDict()
        [ resistNode.set(k, v) for k, v in resistDict.items() ]

        # Race, Class, ParagonPath, EpicDestiny, and Build all behavior similarly
        for nodeName, getDictMethod, getFeatureDictsMethod in \
        (   ('Race',        characterDataSource.getRaceDict,        characterDataSource.getRaceFeatureDicts),
            ('Theme',       characterDataSource.getThemeDict,       characterDataSource.getThemeFeatureDicts),
            ('Background',  characterDataSource.getBackgroundDict,  characterDataSource.getBackgroundFeatureDicts),
            ('Class',       characterDataSource.getClassDict,       characterDataSource.getClassFeatureDicts),
            ('ParagonPath', characterDataSource.getParagonPathDict, characterDataSource.getParagonPathFeatureDicts),
            ('EpicDestiny', characterDataSource.getEpicDestinyDict, characterDataSource.getEpicDestinyFeatureDicts),
        ):

            # Some methods, like getParagonPathDict, return None to indicate the lack of a selection.
            buildChildDict = getDictMethod()
            if buildChildDict is None:
                continue

            buildChildNode = ElementTree.SubElement(buildNode, nodeName)
            [ buildChildNode.set(attrName, buildChildDict.get(attrName, '')) for attrName in self.BUILD_CHILD_ATTRIBUTES ]
            for featureDict in getFeatureDictsMethod():
                featureNode = ElementTree.SubElement(buildChildNode, 'Feature')
                [ featureNode.set(attrName, featureDict.get(attrName, '')) for attrName in self.FEATURE_ATTRIBUTES ]

        # Use the class name as the build name if it's currently blank.
        if not buildDict.get('name', ''):
            className = rootNode.find('Build/Class').get('name')
            buildNode.set('name', className)

        # These process "stats", which are numeric values with potential factors.
        for parentNodeName, getDictMethod, statComment, hasGlobalConditions, \
            childNodeNames, childClassOverride, childAbbreviations, childAttributes in \
        (   ('Health', characterDataSource.getHealthDict, self.HEALTH_COMMENT, None,
                self.HEALTH_CHILD_NODES, None, None, None),
            ('Movement', characterDataSource.getMovementDict, self.MOVEMENT_COMMENT, None,
                self.MOVEMENT_CHILD_NODES, None, None, None),
            ('Defenses', characterDataSource.getDefensesDictAndConditions, self.DEFENSES_COMMENT, 1,
                self.DEFENSES_CHILD_NODES, 'Defense', self.DEFENSES_CHILD_ABBREVIATIONS, None),
            ('PassiveSkills', characterDataSource.getPassiveSkillsDict, self.PASSIVE_SKILLS_COMMENT, None,
                self.PASSIVE_SKILLS_CHILD_NODES, 'PassiveSkill', None, None),
            ('Skills', characterDataSource.getSkillsDict, self.SKILLS_COMMENT, None,
                self.SKILLS_CHILD_NODES, 'Skill', None, self.SKILL_ATTRIBUTES),
            ('AbilityScores', characterDataSource.getAbilityScoresDict, self.ABILITY_SCORES_COMMENT, None,
                self.ABILITY_SCORES_CHILD_NODES, 'AbilityScore', self.ABILITY_SCORES_CHILD_ABBREVIATIONS, None),
        ):
            rootNode.append(ElementTree.Comment(statComment))
            parentNode = ElementTree.SubElement(rootNode, parentNodeName)

            if parentNodeName == 'Health':
                parentNode.set('short-rest-script', 'CHARACTER%(safeKey)s.shortRest();' % locals())
                parentNode.set('extended-rest-script', 'CHARACTER%(safeKey)s.extendedRest();' % locals())
                parentNode.set('tempHP-display-class', 'CUR_TempHP')
                parentNode.set('tempHP-prompt-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_TempHP', {requireInt:1, min:0, text:'Set to how many temporary HP?' });""" % locals())
                parentNode.set('tempHP-bar-class', 'CUR_TempHPBar')
                parentNode.set('death-saves-display-class', 'CUR_DeathSaves')
                parentNode.set('death-saves-add-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_Death Saves', {autoValue:1, calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())
                parentNode.set('death-saves-subtract-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_Death Saves', {autoValue:-1, calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())
                parentNode.set('conditions-display-class', 'CUR_Conditions')
                parentNode.set('conditions-prompt-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_Conditions', {text:'Enter text for the condition'});""" % locals())

                parentNode.set('power-points-display-class', 'CUR_PowerPoints')
                parentNode.set('power-points-add-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_PowerPoints', {autoValue:1, calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())
                parentNode.set('power-points-subtract-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_PowerPoints', {autoValue:-1, calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())

            # Most of our "getter" methods return a dictionary, but some a dict and a list of conditions.
            parentDict = getDictMethod()
            if hasGlobalConditions:
                parentDict, globalConditions = parentDict
                for globalCondition in globalConditions:
                    self.__processFactorDictIntoParent(globalCondition, parentNode)

            childNodes = []
            for childName in childNodeNames:

                childData = parentDict[childName]
                if childAttributes is None:
                    childValue, childFactors = parentDict[childName]
                    childAttrDict = {}
                else:
                    childValue, childFactors, childAttrDict = parentDict[childName]
    
                childNode = ElementTree.SubElement(parentNode, childClassOverride or childName)
                childNodes.append(childNode)
                childNode.set('value', str(childValue))
                if childAttributes is not None:
                    [ childNode.set(childAttr, childAttrDict.get(childAttr,  '')) for childAttr in childAttributes ]
                if childClassOverride is not None:
                    childNode.set('name', childName)

                if parentNodeName == 'Skills':
                    childNode.set('dice-class', self.__numberToDiceClass(int(childValue), childName))
                elif childName == 'MaxHitPoints':
                    childNode.set('damage-prompt-script', """CHARACTER%(safeKey)s.damagePrompt();""" % locals())
                    childNode.set('heal-prompt-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_HitPoints', {requireInt:1, min:1, text:'How many HP should be added?', calculateChange: function(oldVal, newVal) { return Math.max(0,oldVal) + newVal; } });""" % locals())
                elif childName == 'MaxSurges':
                    childNode.set('add-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_Surges', {autoValue:1, calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())
                    childNode.set('subtract-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_Surges', {autoValue:-1, calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())
                elif childName == 'SurgeValue':
                    childNode.set('toHitPoints-script', """CHARACTER%(safeKey)s.surgeValueToHitPoints(%(childValue)s);""" % locals())
                elif childName == 'Initiative':
                    childNode.set('dice-class', self.__numberToDiceClass(int(childValue), 'Initiative'))

                # Sorting the factors this way makes conditions float to the bottom all pretty.
                childFactors.sort(lambda x,y: cmp(x.get('condition'), y.get('condition')))
                [ self.__processFactorDictIntoParent(factorDict, childNode) for factorDict in childFactors ]

            if childAbbreviations:
                [ childNode.set('abbreviation', childAbbrev) for childNode, childAbbrev in zip(childNodes, childAbbreviations) ]
            if parentNodeName == 'AbilityScores':
                for childNode in childNodes:

                    # Calculate stat/roll modifiers and make sure they're both visible signed.
                    abilityModifier = ( int(childNode.get('value')) - 10 ) / 2
                    rollModifier = abilityModifier + (int(buildDict['level']) / 2)
                    abilityModifier, rollModifier = \
                        [ (mod >= 0) and ('+%d' % mod) or (str(mod)) for mod in abilityModifier, rollModifier ]

                    modifierNode = ElementTree.SubElement(childNode, 'AbilityModifier')
                    modifierNode.set('modifier', abilityModifier)
                    modifierNode.set('rollmodifier', rollModifier)
                    modifierNode.set('dice-class', self.__numberToDiceClass(int(rollModifier), childNode.get('name')))

        # Sort the powers provided by our parser by usage.
        usageDict = {'At-Will': 0, 'Encounter': 1, 'Daily': 2 }
        powersList = characterDataSource.getPowersList()
        powersList.sort(lambda x,y,ud=usageDict: \
            cmp(ud.get(x[0].get('powerusage', None), 3), ud.get(y[0].get('powerusage', None), 3)))
        #logging.error(powersList)

        rootNode.append(ElementTree.Comment(self.POWERS_COMMENT))
        powersNode = ElementTree.SubElement(rootNode, 'Powers')
        for powerDict, powerConditionFactors, weaponList, powerCardItems in powersList:
            powerNode = ElementTree.SubElement(powersNode, 'Power')
            [ powerNode.set(powerAttr, powerDict.get(powerAttr, '')) for powerAttr in self.POWER_ATTRIBUTES ]
            [   powerNode.set(powerAttr, powerDict.get(powerAttr, '')) for powerAttr in self.POWER_ATTRIBUTES_OPTIONAL \
                if powerDict.get(powerAttr, '') \
            ]
            [ self.__processFactorDictIntoParent(factorDict, powerNode) for factorDict in powerConditionFactors ]

            safeName = powerNode.get('name', '')
            for badChar in (""" ',+()"""):
                safeName = safeName.replace(badChar, '')
            powerUsage = powerDict.get('powerusage', None)
            if (not powerUsage.find('Encounter')) or (not powerUsage.find('Daily')):
                powerNode.set('display-class', 'USAGE_%s' % safeName)
                if safeName == 'SecondWind':
                    powerNode.set('use-script', """CHARACTER%(safeKey)s.triggerVariable('USAGE_%(safeName)s', { isBoolean:1, useRequires: function() { return CHARACTER%(safeKey)s.namesToVariables['CUR_Surges'].get() > 0; }, noUseMessage: 'Second Wind requires a healing surge, and you have none.' });""" % locals())
                else:
                    powerNode.set('use-script', """CHARACTER%(safeKey)s.triggerVariable('USAGE_%(safeName)s', {isBoolean:1});""" % locals())

            for cardItemTitle, cardItemText in powerCardItems:
                cardItemNode = ElementTree.SubElement(powerNode, 'PowerCardItem')
                nameNode = ElementTree.SubElement(cardItemNode, 'Name')
                nameNode.text = cardItemTitle
                descriptionNode = ElementTree.SubElement(cardItemNode, 'Description')
                descriptionNode.text = cardItemText

            for weaponDict, attackFactors, damageFactors, weaponConditionFactors in weaponList:
                weaponNode = ElementTree.SubElement(powerNode, 'Weapon')

                # Skip attackbonus, damage and damagetype because they end up in subnodes.
                [   weaponNode.set(weaponAttr, weaponDict.get(weaponAttr, '')) \
                    for weaponAttr in self.POWER_WEAPON_ATTRIBUTES \
                    if weaponAttr not in ('attackbonus', 'damage')
                ]
                for weaponAttr in self.POWER_WEAPON_ATTRIBUTES_OPTIONAL:
                    if weaponAttr == 'damagetype':
                        continue
                    attrValue = weaponDict.get(weaponAttr, '')
                    if attrValue:
                        weaponNode.set(weaponAttr, attrValue)

                [ self.__processFactorDictIntoParent(factorDict, weaponNode) for factorDict in weaponConditionFactors ]

                attackNode = ElementTree.SubElement(weaponNode, 'AttackBonus')
                weaponAttack = weaponDict.get('attackbonus', '0')
                attackNode.set('value', weaponAttack)
                attackNode.set('dice-class', 'dice1d20plus%sAttack' % weaponAttack.replace('+', 'plus').replace('-', 'minus'))
                [ self.__processFactorDictIntoParent(factorDict, attackNode) for factorDict in attackFactors ]

                damageNode = ElementTree.SubElement(weaponNode, 'Damage')
                weaponDamage = weaponDict.get('damage', '0')
                damageNode.set('value', weaponDamage)
                damageNode.set('dice-class', 'dice%sDamage' % weaponDamage.replace('+', 'plus').replace('-', 'minus'))
                damageType = weaponDict.get('damagetype', None)
                if damageType:
                    damageNode.set('type', damageType)
                [ self.__processFactorDictIntoParent(factorDict, damageNode) for factorDict in damageFactors ]

        rootNode.append(ElementTree.Comment(self.FEATS_COMMENT))
        featsNode = ElementTree.SubElement(rootNode, 'Feats')
        for featDict in characterDataSource.getFeatsList():
            featNode = ElementTree.SubElement(featsNode, 'Feat')
            [ featNode.set(attrName, featDict.get(attrName, '')) for attrName in self.FEAT_ATTRIBUTES ]

        rootNode.append(ElementTree.Comment(self.LOOT_COMMENT))
        lootNode = ElementTree.SubElement(rootNode, 'Loot')
        lootDict = characterDataSource.getLootDict()
        [ lootNode.set(attrName, lootDict.get(attrName, '')) for attrName in self.LOOT_ATTRIBUTES ]
        lootNode.set('daily-use-display-class', 'CUR_DailyUses')
        lootNode.set('daily-use-add-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_DailyUses', {autoValue:1, calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())
        lootNode.set('daily-use-subtract-script', """CHARACTER%(safeKey)s.triggerVariable('CUR_DailyUses', {autoValue:-1, calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())
        for moneyType in ('carried', 'stored'):
            for coinType, coinDescription in \
            (   ('ad', 'Astral Diamonds'),
                ('pp', 'Platinum Pieces'),
                ('gp', 'Gold Pieces'),
                ('sp', 'Silver Pieces'),
                ('cp', 'Copper Pieces'),
            ):
                lootNode.set('%(moneyType)s-%(coinType)s-display-class' % locals(), 'CUR_%(moneyType)s%(coinType)s' % locals())
                lootNode.set(\
                    '%(moneyType)s-%(coinType)s-add-script' % locals(), 
                    """CHARACTER%(safeKey)s.triggerVariable('CUR_%(moneyType)s%(coinType)s', {min:1, requireInt:1, text:'How many %(coinDescription)s should be added?', calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())
                lootNode.set(\
                    '%(moneyType)s-%(coinType)s-subtract-script' % locals(), 
                    """CHARACTER%(safeKey)s.triggerVariable('CUR_%(moneyType)s%(coinType)s', {min:1, requireInt:1, text:'How many %(coinType)s should be subtracted?', calculateChange: function(oldVal, newVal) { return oldVal - newVal; } });""" % locals())

        itemAndEnhancementDicts = characterDataSource.getItemList()
        itemAndEnhancementDicts.sort(lambda x,y:cmp(x[0].get('equippedcount'), y[0].get('equippedcount')))
        itemAndEnhancementDicts.reverse()
        for itemDict, enhancementDict in itemAndEnhancementDicts:
            itemNode = ElementTree.SubElement(lootNode, 'Item')
            [ itemNode.set(attrName, itemDict.get(attrName, '')) for attrName in self.ITEM_ATTRIBUTES ]
            unsafeItemName = itemDict.get('name', '')
            lettersAndDigits = string.letters + string.digits
            safeItemName = ''.join([k for k in unsafeItemName if k in lettersAndDigits ])
            itemNode.set('display-class', 'CUR_Item_%(safeItemName)s' % locals())
            itemNode.set('subtract-script' % locals(), """CHARACTER%(safeKey)s.triggerVariable('CUR_Item_%(safeItemName)s', {min:1, requireInt:1, askLastText:'Are you sure you want to discard your last %(safeItemName)s?', displayClass:'CUR_Item_%(safeItemName)s', text:'How many %(safeItemName)s should be subtracted?', calculateChange: function(oldVal, newVal) { return oldVal - newVal; } });""" % locals())
            itemNode.set('add-script' % locals(), """CHARACTER%(safeKey)s.triggerVariable('CUR_Item_%(safeItemName)s', {autoValue:1, calculateChange: function(oldVal, newVal) { return oldVal + newVal; } });""" % locals())

            if enhancementDict is not None:
                enhancementNode = ElementTree.SubElement(itemNode, 'Enhancement')
                [ enhancementNode.set(attrName, enhancementDict.get(attrName, '')) for attrName in self.ENHANCEMENT_ATTRIBUTES ]

        rootNode.append(ElementTree.Comment(self.LANGUAGES_COMMENT))
        languagesNode = ElementTree.SubElement(rootNode, 'Languages')
        for languageName in characterDataSource.getLanguageNames():
            languageNode = ElementTree.SubElement(languagesNode, 'Language')
            languageNode.set('name', languageName)

        rootNode.append(ElementTree.Comment(self.PROFICIENCIES_COMMENT))
        proficienciesNode = ElementTree.SubElement(rootNode, 'Proficiencies')
        for profTypeName, getProfsMethod, hasGroups in \
        (   ( 'WeaponProficiencies', characterDataSource.getWeaponProficienciesAndGroups, 1),
            ( 'ArmorProficiencies', characterDataSource.getArmorProficiencyDicts, 0),
            ( 'ShieldProficiencies', characterDataSource.getShieldProficiencyDicts, 0),
        ):
            profTypeNode = ElementTree.SubElement(proficienciesNode, profTypeName)

            # Most fetchers just return a list of proficiency dicts.  Those with groups, though,
            # return a 2-tuple: profDictList, profGroupTuples.
            profDicts, profGroups = getProfsMethod(), []
            if hasGroups:
                profDicts, profGroups = profDicts

            # When they do have groups, each is itself a 2-tuple.
            for groupDict, groupProfDicts in profGroups:
                groupNode = ElementTree.SubElement(profTypeNode, 'ProficiencyGroup')
                [ groupNode.set(attrName, groupDict.get(attrName, '')) for attrName in self.PROFICIENCY_GROUP_ATTRIBUTES ]

                for profDict in groupProfDicts:
                    profNode = ElementTree.SubElement(groupNode, 'Proficiency')
                    [ profNode.set(attrName, profDict.get(attrName, '')) for attrName in self.PROFICIENCY_ATTRIBUTES ]

            for profDict in profDicts:
                profNode = ElementTree.SubElement(profTypeNode, 'Proficiency')
                [ profNode.set(attrName, profDict.get(attrName, '')) for attrName in self.PROFICIENCY_ATTRIBUTES ]

    def __processFactorDictIntoParent(self, factorDict, parentNode):
        factorName = factorDict.get('name', '')

        # Factor modifiers should always be signed.
        factorModifier = str(factorDict.get('modifier', ''))
        if factorModifier[0] not in ('+', '-'):
            factorModifier = '+%s' % factorModifier

        # Treat factor dicts with "condition" attribute specially; they become Condition nodes.
        factorCondition = factorDict.get('condition', None)
        if factorCondition is not None:
            conditionNode = ElementTree.SubElement(parentNode, 'Condition')
            conditionNode.set('name', '%s %s' % (factorModifier, factorName))
            if factorModifier.find('d') != -1:
                conditionNode.set('dice-class', 'dice%sCondition' % factorModifier[1:]) # strips the +/-

        else:
            factorNode = ElementTree.SubElement(parentNode, 'Factor')
            factorNode.set('name', factorName)
            factorNode.set('modifier', factorModifier)

            # Optional values is optional.
            [   factorNode.set(attrName, str(factorDict.get(attrName))) \
                for attrName in self.FACTOR_ATTRIBUTES_OPTIONAL \
                if factorDict.get(attrName, '') \
            ]

    def __numberToDiceClass(self, intValue, rollLabel):
        if intValue < 0:
            return 'dice1d20minus%d%s' % (-intValue, rollLabel)
        elif intValue == 0:
            return 'dice1d20%s' % rollLabel
        else:
            return 'dice1d20plus%d%s' % (intValue, rollLabel)

class IP4CampaignTree(ElementTree.ElementTree):
    """ A subclass of ElementTree that uses a models.Campaign instance
        to build a tree of IP4XML nodes.
    """

    def setStyleUrl(self, styleUrl):
        self.styleUrl = styleUrl
        return self

    def __init__(self, campaign):

        self.rootNode = rootNode = ElementTree.Element('Campaign')
        ElementTree.ElementTree.__init__(self, rootNode)
        self.setStyleUrl('')

        lettersAndDigits = string.letters + string.digits
        key = str(campaign.key())
        safeKey = ''.join([k for k in key if k in lettersAndDigits ])

        rootNode.set('name', campaign.name)
        rootNode.set('owner', campaign.owner.nickname().split('@')[0])
        rootNode.set('key', key)
        rootNode.set('safe-key', safeKey)
        rootNode.set('world', campaign.world or '')
        rootNode.set('editrule', campaign.editrule or '')
        rootNode.set('wikiUrl', campaign.wikiUrl or '')
        rootNode.set('groupUrl', campaign.groupUrl or '')
        rootNode.set('blogUrl', campaign.blogUrl or '')

        descNode = ElementTree.SubElement(rootNode, 'Description')
        descNode.text = campaign.description

        playersNode = ElementTree.SubElement(rootNode, 'Players')
        for player in campaign.playersDMFirst:
            playerNode = ElementTree.SubElement(playersNode, 'Player')
            playerNode.set('handle', models.UserPreferences.getPreferencesForUser(player).handle or '')
            playerNode.set('nickname', player.nickname().split('@')[0])
            playerNode.set('id', player.user_id())

        charactersNode = ElementTree.SubElement(rootNode, 'Characters')
        for character in campaign.characters:
            charKey = str(character.key())
            safeKey = ''.join([k for k in charKey if k in lettersAndDigits ])
            characterNode = ElementTree.SubElement(charactersNode, 'Character')
            characterNode.set('title', character.title)
            characterNode.set('subtitle', character.subtitle)
            characterNode.set('key', charKey)
            characterNode.set('safe-key', safeKey)
            characterNode.set('ownerid', str(character.owner.user_id()))

def test():
    charFile = sys.argv[1]
    charSource = MonsterRTFDataSource('asdf71234asdf', open(charFile).read())
    outCharTree = IP4CharacterTree(charSource).setStyleUrl('iPlay4eSomethingAwfulFixedWidthAndrew.xsl')
    outCharTree.write(sys.stdout)

if __name__ == '__main__':
    test()
