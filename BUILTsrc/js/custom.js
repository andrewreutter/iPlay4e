
top$ = function(e) { ret = top.$(e); return ret; };
top$$ = function(e) { return top.$$(e); };

requestIsMobile = function()
{
     if (navigator.userAgent.indexOf('iPhone') != -1) return true;
     if (navigator.userAgent.indexOf('midp') != -1) return true;
     if (navigator.userAgent.indexOf('opera mini') != -1) return true;
     if (navigator.userAgent.indexOf('android') != -1) return true;
     if (navigator.userAgent.indexOf('pre/1.0') != -1) return true;
     return false;
};

requestIsIPad = function()
{   return (navigator.userAgent.indexOf('iPad') != -1);
};

promptIntoFunction = function(options, intoFunction)
{   
    options = Object.extend(
    {   min:-10000, requireInt:0, text:'Please enter a value', error:'', defaultValue:null
    }, options || {});

    if (options.autoValue || options.autoValue == 0) 
    {   return intoFunction(options.autoValue);
    }

    var userVal = prompt(options.error + ' ' + options.text, options.defaultValue);
    if (!userVal) return null;

    if (options.requireInt)
    {   userVal = parseInt(userVal);
        if (isNaN(userVal)) 
        {   options.error = 'Invalid number!';
            return promptIntoFunction(options, intoFunction);
        }
        if (userVal < options.min) 
        {   options.error = 'Please enter at least ' + options.min + '!';
            return promptIntoFunction(options, intoFunction);
        }
    }

    return intoFunction(userVal);
};

activateCompendiumLink = function(linkElement, charKey, powerKey)
{   var notesForm = linkElement.next('.NotesForm');
    var existingIframe = notesForm.next();
    if (existingIframe && existingIframe.src)
    {   existingIframe.remove();
    }
    else
    {   notesForm.insert({after:'<iframe name="iframe' + charKey + powerKey + '" class="NoWeapons" style="padding:0; width:102%; height:340px;"></iframe>'});

        var theUrl = linkElement.href;
        if (IS_NATIVE_APP) {
            theUrl = '/proxywotc/' + theUrl;
            //alert(theUrl);
        }
        notesForm.next().src = theUrl;
    }
};

activatePowerLink = function(charId, powerId, powerUrl, autoLoad)
{
    var thisPowerLink = $('powerlink'+charId+powerId);
    if (!thisPowerLink) alert('WWW: ' + 'powerlink'+charId+powerId);
    thisPowerLink.observe('click', function(e)
    {   //alert('VVV charId: ' + charId + ' powerId: ' + powerId);
        e.stop();
        var targetUrl = thisPowerLink.href;

        var targetFrameId = 'iframe'+charId+powerId;
        var targetFrame = $(targetFrameId);
        var targetHrefId = 'href'+charId+powerId;
        var targetHref = $(targetHrefId);

        if (!targetFrame) 
        {   //alert('no target frame found: ' + targetFrameId);
            if (!targetHref)
            {   alert('no target frame (' + targetFrameId + ') or href (' + targetHrefId + ') found');
                return;
            }
            //alert('XXX' + targetHref);
            targetHref.href = targetUrl;

            if (autoLoad && !targetHref.compActivated)
            {
                var compendiumEntryLinkId = 'href' + charId + powerId;
                activateCompendiumLink(targetHref);
                targetHref.compActivated = 1;
            };

            return;
        }

        if (!targetFrame.loadedIt)
        {
            // The URL may have been updated with Javascript for a power.
            targetUrl = (targetUrl == '#' || !targetUrl) ? powerUrl : targetUrl;
            // And may need redirection through the native app.
            if (IS_NATIVE_APP) {
                targetUrl = '/proxywotc/' + targetUrl;
                //alert(targetUrl);
            }

            targetFrame.src = targetUrl;
            targetFrame.loadedIt = true;
        }
        //$('overlay').scrollTo();
    });
}; 

makeHeatmap = function(rollerSelector, targetSelector)
{
    var allTargets = $$(targetSelector);
    var allRollers = $$(rollerSelector);
    var maxValue = 1.0;
    var minValue = 100000;
    var rollerValues = allRollers.collect(function(ar)
    {   
        var ret = parseInt('' + ar.innerHTML);
        maxValue = 0.0 + Math.max(maxValue, ret);
        minValue = 0.0 + Math.min(minValue, ret);
        return ret;
    });
    for (var i=0;i<allRollers.length;i++)
    {   allTargets[i].setStyle(
        {   
            border: 'none',
            opacity:.50 + (.50 * (rollerValues[i] - minValue) / (maxValue - minValue))
        });
        allRollers[i].addClassName('HeatmapRoller');
    }
};

// Pass in an array of div elements; we'll make them all the same height.
// If those divs have children with class EqualSection1 or EqualSection2 etc...
// we will make all of _them_ match up as well.
makeDivsEqualHeight = function(allDivs)
{
    // Gotta work from the inside out.
    var keepFindingSubsections = 1;
    var equalSectionIndex = 1;
    while (keepFindingSubsections)
    {   var foundSubsections = [];
        for (var i=0;i<allDivs.length;i++)
        {   thisDivSubsections = allDivs[i].select('.EqualSection' + equalSectionIndex);
            for (var j=0; j<thisDivSubsections.length; j++)
                foundSubsections[foundSubsections.length] = thisDivSubsections[j];
        }
        if (foundSubsections.length)
        {   makeDivsEqualHeight(foundSubsections);
        }
        else
        {   keepFindingSubsections = 0;
        }
        equalSectionIndex++;
    }

    // Start with a clean, self-calculated slate.
    allDivs.invoke('setStyle', {height: 'auto'});
    var maxHeight = 0;

    // Find the tallest.
    var allDivHeights = allDivs.collect(function(cc) { return cc.getHeight(); });
    for (var i=0;i<allDivHeights.length;i++)
    {   maxHeight = Math.max(maxHeight, allDivHeights[i]);
    }

    // Make them all that tall and return that new height.
    allDivs.invoke('setStyle', {height:maxHeight+'px'});
    return maxHeight;
}

// RANDOM NUMBER GENERATOR

function RNG(seed) {
  // LCG using GCC's constants
  this.m = 0x100000000; // 2**32;
  this.a = 1103515245;
  this.c = 12345;

  this.state = seed ? seed : Math.floor(Math.random() * (this.m-1));
}
RNG.prototype.nextInt = function() {
  this.state = (this.a * this.state + this.c) % this.m;
  return this.state;
}
RNG.prototype.nextFloat = function() {
  // returns in range [0,1]
  return this.nextInt() / (this.m - 1);
}
RNG.prototype.nextRange = function(start, end) {
  // returns in range [start, end): including start, excluding end
  // can't modulu nextInt because of weak randomness in lower bits
  var rangeSize = end - start;
  var randomUnder1 = this.nextInt() / this.m;
  return start + Math.floor(randomUnder1 * rangeSize);
}
RNG.prototype.choice = function(array) {
  return array[this.nextRange(0, array.length)];
}

USE_RNG = new RNG();
randomDie = function(dieSize) 
{   return USE_RNG.nextRange(1, dieSize+1);
};

DICE_REGEX = /(\d+)d(\d+)/i;                                // Match 1d20, d212, etc...
DICE_OR_NUM_REGEX = /(\d+)d(\d+)|(\d+)/i;                   // Match 1d20, 0, 4, etc...
PLUS_OR_MINUS_DICE_OR_NUM_REGEX = 
    /(plus|minus)(\d+)d(\d+)|(plus|minus)(\d+)/i;           // Match plus1d20, minus0, 4, etc...
DICE_CLASS_REGEX = /dice(\d+)d(\d+)/i;                      // Match dice1d20Roll, dice1d20plus4Attack, etc...

rollerElementToRollTitle = function(rollerElement) {
    var itemTitle = '';

    // Power?
    var titledContainer = rollerElement.up('.leightbox');
    if (titledContainer) {
        itemTitle = titledContainer.down('h2 span').innerHTML;
    } else {

        // Skill or ability?
        titledContainer = rollerElement.up('tr');
        if (titledContainer) {

            // Skill?
            var itemLink = titledContainer.down('a.CompendiumLink');
            if (itemLink) {
                itemTitle = itemLink.innerHTML;
            } else {

                // Ability
                itemTitle = titledContainer.down('td').innerHTML;
            }
        } else {

            // jPint mobile UI?
            titledContainer = rollerElement.up('.NotesForm');
            if (titledContainer) {
                itemTitle = titledContainer.down('.withHelp').down('.primary span').innerHTML;
            } else {
            }
        }
    }

    return itemTitle;
};

// itemTitle: optional
rollRoller = function(rollerElement)
{   
    var rollerElement = (rollerElement && rollerElement.up) ? rollerElement : $(this);
    var itemTitle = rollerElementToRollTitle(rollerElement);

    // Find the class name that's something like 2d8plus5 or 1d20plus0Arcana
    var classMatches = [];
    var theseClassNames = $w(rollerElement.className);
    for (var i=0; i<theseClassNames.length; i++)
    {   var thisClassName = theseClassNames[i];
        var tryMatch = thisClassName.match(DICE_CLASS_REGEX);
        if (tryMatch) classMatches[classMatches.length] = thisClassName;
    }
    if (!classMatches.length)
    {   alert('No roller-related class name found in ' + rollerElement.className + '!');
        return;
    }

    alertStrs = [];
    classMatches.each(function(classMatch)
    {
        var workingClass = classMatch.substring(4); // Chop off 'dice' from beginning.
        var resultStr = '';
        var resultTotal = 0;
    
        var firstDiceOrNum = workingClass.match(DICE_OR_NUM_REGEX);
        if (!firstDiceOrNum)
        {   alert('Invalid dice class ' + classMatch + '!');
            return;
        }
        var strAndNum = processDiceOrNumStr(firstDiceOrNum[0]);
        resultStr = resultStr + strAndNum['str'];
        resultTotal += strAndNum['num'];
        var firstRoll = resultTotal;
        workingClass = workingClass.substr(firstDiceOrNum[0].length);
    
        var plusOrMinusDiceOrNum = workingClass.match(PLUS_OR_MINUS_DICE_OR_NUM_REGEX);
        while (plusOrMinusDiceOrNum)
        {
            var isMinus = workingClass.substr(0,5) == 'minus';
            var strAndNum = processDiceOrNumStr(plusOrMinusDiceOrNum[0].substr(isMinus?5:4));
    
            resultStr = resultStr + (isMinus ? ' - ' : ' + ') + strAndNum['str'];
            resultTotal += (isMinus ? -strAndNum['num'] : strAndNum['num']);
    
            workingClass = workingClass.substr(plusOrMinusDiceOrNum[0].length);
            plusOrMinusDiceOrNum = workingClass.match(PLUS_OR_MINUS_DICE_OR_NUM_REGEX);
        }
    
        resultStr = workingClass + ': ' + resultStr + ' = ' + resultTotal;
        if ((!workingClass.indexOf('Attack')) && firstRoll == 20) resultStr = resultStr + ' NATURAL 20!';
        alertStrs[alertStrs.length] = resultStr;

        if (!itemTitle)
            itemTitle = workingClass;
    });

    var alertStr = alertStrs.join('\n');


    var charKey = null;
    var titledContainer = rollerElement.up('.container');
    if (titledContainer) {
        charKey = titledContainer.up('div').id;
    } else {
        charKey = rollerElement.up('.jPintPageSet').up('span').id;
    }
    logCharacterEvent({
        name: itemTitle,
        description: alertStr,
        rollStrings: alertStrs,
        character: charKey
    });
};

/* a characterEvent has:
    name: a title, such as a power name, skill, or manual description
    description: 
*/
logCharacterEvent = function(characterEvent) {
    var theChar = window['CHARACTER' + characterEvent.character];
    var diceHistoryContainers = $$('.DiceHistoryContainer' + theChar.safeKey);

    var rollName = null, rollStrings = null;
    if (characterEvent.rollStrings.length == 1) {
        rollName = characterEvent.rollStrings[0].split(':')[0];
        rollStrings = characterEvent.rollStrings[0].split(':')[1];
    } else {
        rollName = characterEvent.name;
        rollStrings = characterEvent.rollStrings.join('\n');
    }
    alert(rollName + '\n\n' + rollStrings);
};

processDiceOrNumStr = function(diceOrNumStr)
{   var diceMatch = diceOrNumStr.match(DICE_REGEX);
    if (diceMatch)
    {   //alert(diceMatch.toJSON());
        var retStr = '';
        var retNum = 0;
        var dieSize = parseInt(diceMatch[2]);
        for (var i=0;i<parseInt(diceMatch[1]);i++)
        {   var thisDieRoll = randomDie(dieSize);
            retNum += thisDieRoll;
            if (i) retStr = retStr + ', ';
            retStr = retStr + thisDieRoll;
        }
        retStr = diceOrNumStr + ' (' + retStr + ')';
        return {'str':retStr, 'num':retNum};
    }
    else
    {   return {'str':diceOrNumStr, 'num':parseInt(diceOrNumStr)};
    }
};

pleaseBeOwner = function()
{   alert('Only the owner of this character can do this.  If you are the owner, please log in.');
};

/* VARIABLE DEFINITION

    Called by the server response from initializeCharacter to activate all user variables.
*/

OwnedCharacter = Class.create();
Object.extend(OwnedCharacter.prototype, 
{   initialize: function(isEditor, charKey, safeKey)
    {   this.isEditor = isEditor;
        this.charKey = charKey;
        this.safeKey = safeKey;

        this.characterElements = $$('.' + charKey + 'Multiple');
        this.characterElement = $(charKey);
        if (this.characterElement)
            this.characterElements[this.characterElements.length] = this.characterElement;
        this.characterElements = this.characterElements.uniq(); // In case we already had characterElement in there.

        this.variableList = $A([]);
        this.namesToVariables = $H({});
        this.toBeSaved = $H({});
        this.isSaving = 0;
    },
    getMyElementsByClassName: function(className)
    {   var retElements = [];
        this.characterElements.each(function(tce)
        {   $A(tce.getElementsByClassName(className)).each(function(e)
            {   retElements[retElements.length] = e;
            });
        });
        return retElements;
    },
    addVariable: function(varName, displayClass, startValue, varOptions)
    {   
        var newVar = new OwnedCharacterVariable(this, varName, displayClass, startValue, varOptions);
        this.variableList[this.variableList.length] = newVar;
        this.namesToVariables[varName] = newVar;
        return newVar;
    },
    triggerVariable: function(varName, options)
    {   var theVar = this.namesToVariables[varName];
        if (!theVar) 
        {   alert('Please wait for the character '+varName+' to finish loading');
            return;
        }
        this.namesToVariables[varName].triggerTrigger(options);
    },
    getVariablesWithOption: function(optionName)
    {   return this.variableList.select(function(v) { return v.options[optionName]; } );
    },
    addRollerClass: function(rollerClass)
    {   // Don't use addTrigger because it changes "this", which rollRoller needs.
        this.characterElements.collect(function(tce)
        {   return $A(tce.getElementsByClassName(rollerClass));
        }).flatten().uniq().invoke('observe', 'click', rollRoller);
    },
    addTrigger: function(triggerClass, triggerFunction)
    {   this.characterElements.each(function(tce)
        {   $A(tce.getElementsByClassName(triggerClass)).invoke('observe', 'click', triggerFunction.bindAsEventListener(this));
        });
    },
    resetUsage: function(usageType, options)
    {   options = Object.extend({}, options || {});
    
        varsOfType = this.variableList.select(function(v) { return v.options.reset == usageType; });
        varsOfType.each( function(thisVar) { thisVar.set(thisVar.startValue, options); } );
        if (!options.isCascade) this.save();
    },
    get: function(varName)
    {   
        var thisVar = this.namesToVariables[varName];
        return thisVar ? thisVar.currentValue : false;
    },
    set: function(varName, varValue, options)
    {   
        var thisVar = this.namesToVariables[varName];
        if (thisVar) thisVar.set(varValue, options);
    },
    setDict: function(theDict, options)
    {   //alert(theDict.toJSON());
        //console.log(theDict.toJSON());
        var namesToVariables = this.namesToVariables;
        options = Object.extend({isCascade:1, pulse:0}, options || {});
        theDict.each(function(keyAndValue) 
        {   var thisVar = namesToVariables[keyAndValue.key];
            if (thisVar) thisVar.set(keyAndValue.value, options);
        });
    },
    enablePolling: function()
    {   this.pollEnabled = 1;
        // turn on for polling XXX new PeriodicalExecuter(this.poll.bindAsEventListener(this), 6);
    },
    enableSaving: function()
    {   this.saveEnabled = 1;
        // Period didn't work on Opera Mini, so now we do things immediately,
        // using the isCascade option to allow batch processing.
        // new PeriodicalExecuter(this.save.bindAsEventListener(this), 6);
    },
    disableSaving: function()
    {   this.saveEnabled = 0;
    },
    poll: function()
    {   if (!this.pollEnabled) return;

        new Ajax.Request('/poll',
        {   method: 'post', parameters: {t: this.polltime, key:this.charKey },
            onSuccess: function(response)
            {   if (response.responseText) 
                {   response.responseText.evalScripts();
                }
            }.bindAsEventListener(this),
            onException: function(request, e)
            {   syncDisplays.invoke('addClassName', 'IP4SyncError');
            }.bindAsEventListener(this),
            onFailure: function(request, e)
            {   syncDisplays.invoke('addClassName', 'IP4SyncError');
            }.bindAsEventListener(this)
        });
    },
    save: function() {
        if (!this.saveEnabled) return;

        // If we are already saving, or there's nothing to save, forget it.
        if (this.isSaving) return;
        var saveKeys = this.toBeSaved.keys();
        if (!saveKeys.length) return;
        this.isSaving = 1;

        // Construct JSON to send to the server, and cookify it in case we fail so we can recover.
        var saveJSON = $H({}); saveJSON.set(this.charKey, this.toBeSaved); saveJSON = saveJSON.toJSON();
        EwgCookie.setCookie('saving' + this.charKey, this.toBeSaved.toJSON(), 1000);

        // Update the displays to show that we are syncing and not errored.
        var syncDisplays = $$('#' + this.charKey + ' .IP4Sync');
        syncDisplays.invoke('removeClassName', 'IP4SyncError');
        syncDisplays.invoke('addClassName', 'IP4Syncing');

        var handleError = function(response) {
            var saveIt = this.save.bindAsEventListener(this);
            setTimeout(function() { saveIt(); }, 6000);
            syncDisplays.invoke('addClassName', 'IP4SyncError');
        }.bindAsEventListener(this);

        new Ajax.Request('/characters/savestate',
        {   method: 'post', parameters: {toBeSaved: saveJSON},
            onComplete: function(response) {
                syncDisplays.invoke('removeClassName', 'IP4Syncing');
                this.isSaving = 0;
            }.bindAsEventListener(this),
            onSuccess: function(response) {
                if (!response.responseText) {
                    handleError();
                } else {
                    this.toBeSaved = $H({});
                    EwgCookie.setCookie('saving' + this.charKey, $H({}).toJSON(), 1000);
                }
            }.bindAsEventListener(this),
            onException: handleError,
            onFailure: handleError
        });
    },
    loadUnsavedValues: function()
    {
        var unsavedValues = EwgCookie.getCookie('saving' + this.charKey);
        try
        {   unsavedValues = unsavedValues ? $H((''+unsavedValues).evalJSON()) : $H();
        }
        catch (e)
        {   alert('Bad Cookie: ' + unsavedValues);
            unsavedValues = $H();
        }
        EwgCookie.setCookie('saving' + this.charKey, $H({}).toJSON(), 1000);
        this.setDict(unsavedValues, {isCascade:1});
        this.save();
    },
    fetch: function(charKey)
    {
        new Ajax.Request('/characters/getValues?key='+this.charKey,
        {   method: 'get',
            onSuccess: function(response)
            {   var serverValues = (''+response.responseText).evalJSON(true);
                if (serverValues) this.setDict($H(serverValues), {noSave:1});
            }.bindAsEventListener(this)
        });
    },
    damagePrompt: function()
    {   var namesToVariables = this.namesToVariables;
        this.triggerVariable('CUR_HitPoints',
        {   requireInt:1, min:1, text:'How many points of damage?',
            calculateChange: function(oldVal, newVal) 
            {   
                var newVal = newVal;
                return namesToVariables['CUR_TempHP'].getIntoFunction( function(currentTempHP)
                {
                    tempDamage = Math.min(currentTempHP, newVal);
                    if (tempDamage)
                    {
                        namesToVariables['CUR_TempHP'].set(currentTempHP-tempDamage, {isCascade:1});
                        newVal -= tempDamage;
                    }
                    return oldVal - newVal; 
                }, {requireInt:1});
            }
        });
    },
    surgeValueToHitPoints: function(surgeValue)
    {   var namesToVariables = this.namesToVariables;
        namesToVariables['CUR_HitPoints'].getIntoFunction(function(currentHP) 
        {   namesToVariables['CUR_HitPoints'].set(Math.max(0,currentHP) + surgeValue); 
        });
    },
    milestone: function()
    {
        if (!confirm('Reach a milestone?')) return;

        var newActionPoints = this.namesToVariables['CUR_Action Points'].get() + 1;
        this.namesToVariables['CUR_Action Points'].set(newActionPoints, {isCascade:1});
        var newDailyUses = this.namesToVariables['CUR_DailyUses'].get() + 1;
        this.namesToVariables['CUR_DailyUses'].set(newDailyUses, {isCascade:1});
        this.save();
    },
    shortRest: function()
    {
        if (!confirm('Take a short rest?')) return;
        this.resetUsage('Encounter', {isCascade:1});

        this.namesToVariables['CUR_TempHP'].set(0, {isCascade:1});
        this.namesToVariables['CUR_Death Saves'].set(3, {isCascade:1});

        // This is here just for the Vampire class, which I don't like.
        // Vampires can get extra surges exceeding their max.
        var curSurges = this.namesToVariables['CUR_Surges'].get();
        var maxSurges = this.namesToVariables['MAX_Surges'].get();
        var newSurges = Math.min(curSurges, maxSurges);
        this.namesToVariables['CUR_Surges'].set(newSurges, {isCascade:1});

        // Also for vampires: BLOOD IS LIFE
        // ... If you end a short rest with more healing surges than your usual
        // number of healing surges for the day, you lose any healing surges
        // beyond that number but regain all your hit points.
        if (newSurges < curSurges)
        {   this.namesToVariables['CUR_HitPoints'].set(10000, {isCascade:1});
        }

        this.save();
    },
    extendedRest: function()
    {
        if (!confirm('Take an extended rest?')) return;
        this.resetUsage('Encounter', {isCascade:1});
        this.resetUsage('Daily', {isCascade:1});

        this.namesToVariables['CUR_TempHP'].set(0, {isCascade:1});
        this.namesToVariables['CUR_Death Saves'].set(3, {isCascade:1});
        this.namesToVariables['CUR_HitPoints'].set(10000, {isCascade:1});
        this.namesToVariables['CUR_Surges'].set(this.namesToVariables['MAX_Surges'].get(), {isCascade:1});
        this.namesToVariables['CUR_Action Points'].set(1, {isCascade:1});
        this.save();
    }
});

OwnedCharacterVariable = Class.create();
Object.extend(OwnedCharacterVariable.prototype, 
{   initialize: function(ownedCharacter, varName, displayClass, startValue, options)
    {   
        this.ownedCharacter = ownedCharacter;
        this.varName = varName;
        this.displayClass = displayClass;
        this.options = options;
        this.startValue = startValue;
        
        this.displayElements = $A(this.ownedCharacter.getMyElementsByClassName(displayClass));
        if (this.options.barClass) 
            this.barElements = $A(this.ownedCharacter.getMyElementsByClassName(this.options.barClass));

        this.set(startValue, {noSave:1});
    },

    get: function()
    {   return this.currentValue;
    },
    getIntoFunction: function(intoFunction, options)
    {   return intoFunction(this.get(), options||{});
    },

    addTrigger: function(triggerClass, options)
    {   options = Object.extend({calculateChange: function(oldVal, newVal) { return newVal; }}, options || {});
        this.ownedCharacter.characterElements.each(function(tce)
        {   $A(tce.getElementsByClassName(triggerClass)).invoke(
                'observe', 'click', this.triggerTrigger.bindAsEventListener(this, options));
        });
    },
    triggerTrigger: function(e)
    {
        if (!this.ownedCharacter.isEditor) return pleaseBeOwner();

        var options = { calculateChange: function(oldVal, newVal) { return newVal; } };
        if (e.autoValue || e.autoValue == 0) options.autoValue = e.autoValue;
        options = Object.extend(options, $A(arguments).last());

        if (options.useRequires)
        {   if (!options.useRequires()) return alert('This may not be used right now.');
        }

        if (options.isBoolean)
        {   this.getIntoFunction( function(currentValue) 
            {   options.autoValue = !currentValue; 
                //console.log('currentValue:'+currentValue);
            } );
        }

        var charVar = this;
	if (options.askLastText)
	{   if (charVar.get() == 1) {
		var r = confirm(options.askLastText);
		if (r == true)
		{
		    charVar.set(0);
		    //$$(options.displayClass).invoke('hide');
		}
	    }
	    else
	    {   charVar.set(charVar.get()-1);
	    }
	    return;
	}

        this.getIntoFunction( function(currentValue)
        {   promptIntoFunction(options, function(newValue)
            {   
                //console.log('newValue:'+newValue);
                var finalValue = options.calculateChange(currentValue, newValue);
                if (charVar.options.listItemClass)
                {   var valueList = charVar.get();
                    valueList[valueList.length] = finalValue;
                    finalValue = valueList;
                }
                //console.log('finalValue:'+finalValue);
                charVar.set(finalValue);
            });
        }, charVar.options);
    },
    set: function(newVal, options)
    {   options = options || {};

        // Enforce both bounds and massage whacky values from the server.
        if (this.options.max) newVal = Math.min(newVal, this.options.max);
        if (this.options.min || this.options.min == 0) newVal = Math.max(newVal, this.options.min);
        if (this.options.isBoolean && newVal == 'False') newVal = false;
        if (this.options.listItemClass && newVal.split) newVal = (''+newVal).evalJSON();
        this.currentValue = newVal;

        this.updateDisplay(options);
        this.ownedCharacter.getVariablesWithOption('useRequires').without(this).invoke('updateDisplay');

        if (this.options.onChange) this.getIntoFunction(this.options.onChange, options);
        if (!options.noSave)
        {   this.ownedCharacter.toBeSaved.set(this.varName, newVal);
            if (!options.isCascade)
            {   this.ownedCharacter.save();
            }
        }
    },
    updateDisplay: function(options)
    {   options = options || {};

        if (this.options.isBoolean)
        {   
            var useAllowed = ( this.options.useRequires ? this.options.useRequires() : 1 );
            this.displayElements.invoke(this.currentValue || (!useAllowed) ? 'addClassName' : 'removeClassName', 'Used');
        }
        else if (this.options.listItemClass)
        {   
            var listItemClass = this.options.listItemClass;
            htmlValue = '';
            this.currentValue.each(function(thisCondition)
            {   htmlValue += '<div class="' + listItemClass + '">' + thisCondition.escapeHTML() + '</div>';
            });
            this.displayElements.invoke('update', htmlValue);

            if (this.ownedCharacter.isEditor)
            {
                var currentValue = this.currentValue;
                var listItemClass = this.options.listItemClass;
                var displayClass = this.displayClass;
                var thisVariable = this;
                this.ownedCharacter.characterElements.each(function(tce)
                {
                    var listItemSelector = '.' + displayClass + ' .' + listItemClass;
                    var listItemElements = tce.select(listItemSelector);
                    for (var i=0; i<listItemElements.length; i++)
                    {   
                        var thisValue = currentValue[i];
                        listItemElements[i].thisValue = thisValue;
                        listItemElements[i].observe('click', function(e)
                        {   thisVariable.set(currentValue.without(e.element().thisValue));
                            e.stop();
                        }.bindAsEventListener(thisVariable));
                    }
                });
            }
            try { sizeParentIframeToMyContainer(); } catch (e) {}
        }
        else
        {   
            //console.log(this.displayElements.length + ' elements for ' + '#' + this.ownedCharacter.charKey + ' .' + this.displayClass);
            var currentValue = this.currentValue;
            this.displayElements.each(function(de)
            {   
                if (de.tagName == 'TEXTAREA') { de.value = currentValue; }
                else if (currentValue.replace) de.update(currentValue.replace(/\n/g, '<br/>'));
                else de.update(currentValue);
            });
            //this.displayElements.invoke('update', this.currentValue);
            if (options.pulse)
            {
                this.displayElements.each(function(de)
                {   new Effect.Pulsate(de);
                });
            }
        }
        if (this.options.barClass) this.updateBars(options);
    },
    updateBars: function(options)
    {   barOptions = Object.extend({goodColor:'green', badColor:'#E3170D', threshold:-1}, this.options.barOptions||{});

        var aliveRatio = this.currentValue / this.options.max;
        this.barElements.each( function(e)
        {   
            var styleDict = 
            {   
                backgroundColor: (aliveRatio <= barOptions.threshold) ? barOptions.badColor : barOptions.goodColor,
                opacity: .15 + (.85 * (1.0 - aliveRatio))
            };
            styleDict[e.hasClassName('Vertical') ? 'height' : 'width'] = Math.max(1, aliveRatio * 100) + '%';
            e.setStyle(styleDict);
            if (options.pulse) Effect.Pulsate(e);
        });
    }
});

changeWeapon = function(powerId)
{   
    var weaponSelect = $('weapons'+powerId);
    if (!weaponSelect) alert('no weaponSelect! ' + powerId);
    var weaponIndex = weaponSelect.selectedIndex;
    var weaponContents = $$('#power'+powerId+' .WeaponContent');
    if (!weaponContents.length) alert('no WeaponContents! ' + powerId);
    weaponContents.invoke('hide');
    weaponContents[weaponIndex].show();
};

initializeCompendiumBrowser = function()
{
    var powerContents = $$('.PowerContent');

    $$('.HelpLink').invoke('observe', 'click', function(e)
    {   powerContents.invoke('hide');
        powerContents[0].show();
    });

    return;
}

/* CHARACTER INITIALIZATION

    Call initializeCharacter with the character key as its only argument.
    The system will make that character as interactive as the current user's authority allows.

*/

initializeEnvironmentalElements = function()
{
    // Be careful accessing top and parent because of security restrictions...
    var topDoc = null;
    try { topDoc = top.document; } catch (e) { topDoc = null; }
    var parentDoc = null;
    try { parentDoc = parent.document; } catch (e) { parentDoc = null; }

    var hasIplay4eTop = (topDoc && topDoc.location);
    var hasIplay4eParent = (parentDoc && parentDoc.location);
    //var isTopDoc = ( !topDoc || !topDoc.location || document.location == topDoc.location );

    if ( (topDoc && document.location == topDoc.location) || (!hasIplay4eTop && !hasIplay4eParent))
    {
        $$('.ForeignOnly').invoke('show'); 
        $$('.NotForeign').invoke('hide'); 
    }

    // If the hostname is the same, we're on iplay4e.com not some embedded site.
    // But campaigns should be treated as an embedding site.
    var isInCampaign = (parentDoc && (''+parentDoc.location).indexOf('campaigns') != -1);
    if ( !hasIplay4eParent || !(document.location+'').indexOf(parentDoc.location+'') || isInCampaign )
    {   
            $$('.EmbedOnly').invoke('show'); 
            $$('.NotEmbed').invoke('hide'); 
    }
};

var CAMPAIGN_SAFE_KEY = null;
initializeCampaign = function(campKey, safeKey)
{   initializeEnvironmentalElements();
    sizeParentIframeToMyContainer();
    new Ajax.Request('/campaigns/initialize?key='+campKey, { method: 'get' });
    CAMPAIGN_SAFE_KEY = safeKey;
};
setMyCampaignUser = function(userId)
{
    var myPlayerDiv = $(userId);
    if (!myPlayerDiv) return;

    var ownerLink = myPlayerDiv.up('.' + CAMPAIGN_SAFE_KEY + 'OwnerOnly');
    var notOwnerLink = ownerLink.previous('.' + CAMPAIGN_SAFE_KEY + 'NotOwner');
    ownerLink.show(); notOwnerLink.hide();
};
setMyCampaignCharacters = function(myCampaignCharacters, myOtherCharacters)
{   
    var addCharactersDiv = $('addCharactersDiv');
    $A(myOtherCharacters).each(function(c) 
    {   addCharactersDiv.update(addCharactersDiv.innerHTML +
        '<div>' +
        '<input type="checkbox" value="add" name="add' + c.key + '"  /> ' + c.title +
        '</div>'
        );
    });
    if (!$A(myOtherCharacters).length)
        addCharactersDiv.update('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;You have no characters that are not in this campaign!');

    $A(myCampaignCharacters).each(function(c) {
        var removeCharacterLink = $(c.key);
        var ownerLink = removeCharacterLink.up('.OwnerOnly');
        var notOwnerLink = ownerLink.previous('.NotOwner');
        ownerLink.show(); notOwnerLink.hide();
    });
};

initializeCharacter = function(charKey, safeKey, options)
{   options = Object.extend({noServer:false}, options || {});

    initializeEnvironmentalElements();
    sizeParentIframeToMyContainer();

    window['CHARACTER'+charKey] = window['CHARACTER'+safeKey] = new OwnedCharacter(0, charKey, safeKey);
    window['CHARACTER'+safeKey].addRollerClass('Roller');


    // This URL returns some Javascript that automatically gets executed.
    // That Javascript makes the character sheet as interactive as the user's privileges allow.
    if (!options.noServer)
        {
            console.log('Initializing single character ' + charKey);
            new Ajax.Request('/characters/initialize?key='+charKey, 
            {   method: 'get', evalJS: 'force'
            });
        }
    processReportUrls();
};

// If you are initializing multiple characters, call initializeCharacter in a loop with the noServer option.
// Then, upon completion, call initalizeCharacters with a comma delimited string of character keys.
initializeCharacters = function(keyListStr)
{   
    console.log('Initializing multiple characters ' + keyListStr);
    new Ajax.Request('/characters/initialize?key='+keyListStr, 
    {   method: 'get', evalJS: 'force'
    });
    protectMenusFromIE();
};
