FADE_DURATION = .3
MODEL_TOGGLES = {};

DRAGGING = 0;

logToggle = function(theLink)
{   EwgCookie.setCookie('logToggleHash', document.location.hash.substring(1));
    return true;
}

initManagement = function()
{   mgmtToggle = new Effect.ToggleSet();
    mgmtToggle.addActivationArray('#managementNav a', null, null);
    mgmtToggle.addDisplayArray('#managementNav a', 'addclassname', {className:'Active'});
    mgmtToggle.addFunctionArray( function(e,i,o) 
    {   new Ajax.Updater('managementBody', '/' + MODEL_CLASS_NAMES[i] + '/list', 
            {   evalScripts:true,
                onComplete: function()
                {   initModelToggle(MODEL_CLASS_NAMES[i], '', 0);
                }
            } );
    }, {} );
    mgmtToggle.toggle(Math.max(0, MODEL_CLASS_NAMES.indexOf(location.hash.substring(1))), null, null);
};

getFirstInput = function(el)
{
    el = $(el);
    el.select('input:not([type~=hidden]), select, textarea, button, a[href]').invoke('addClassName', '_focusable');
    var focusableElements = el.select('._focusable');
    return focusableElements.find(function(e)
    {   return e.tabIndex == 1;
    } ) || focusableElements.first();
};

initModelToggle = function(mcn, parent, togglePage, options)
{   var options = Object.extend(
    {   suppressEffect: false
    }, (options || {}) );
    var thisToggle = new Effect.ToggleSet();
    var displayArray = $$$('#managementPanes' + mcn + parent + ' @div');
    thisToggle.addDisplayArray( displayArray, 'phase', { duration: FADE_DURATION } );

    thisToggle.addFunctionArray( function(e,i,o) 
    {   if (!i) return;
        displayDivId = o.displayDivs[i].id;
        setTimeout( "var fi = getFirstInput('" + displayDivId + "'); if (fi) fi.focus();", ( 1000 * FADE_DURATION) + 100 ); 
    }, {displayDivs:displayArray} );

    if (options.suppressEffect) { displayArray[0].style.display = 'block'; }
    else { thisToggle.toggle(togglePage, null, null); }
    MODEL_TOGGLES['modelToggle' + mcn + parent] = thisToggle;
};

editModel = function(w, mcn, key, parent, parentProp)
{   
    new Effect.Pulsate(w,{duration:10});
    new Ajax.Updater( 'managementEdit' + mcn + parent, 
    '/' + mcn + '/edit?key=' + key + '&parent=' + parent + '&prop=' + parentProp,
    {   evalScripts:true,
        onComplete: function() { MODEL_TOGGLES['modelToggle' + mcn + parent].toggle(2,null,null); }
    } );
};

copyModel = function(w, mcn, key, parent, parentProp)
{   
    new Effect.Pulsate(w,{duration:10});
    new Ajax.Updater( 'managementEdit' + mcn + parent, 
    '/' + mcn + '/edit?key=' + key + '&parent=' + parent + '&prop=' + parentProp + '&copy=1',
    {   evalScripts:true,
        onComplete: function() { MODEL_TOGGLES['modelToggle' + mcn + parent].toggle(2,null,null); }
    } );
};

fetchTablePage = function(modelClassName, propertyName, parent, page)
{   new Ajax.Updater('managementContent' + modelClassName + parent, 
        '/' + modelClassName + '/table?page=' + page + '&prop=' + propertyName + '&parent=' + parent,
        { evalScripts:true
        } );
};

fetchSubModels = function(parent, subModelClass, subModelParentProp )
{   
    var containerDiv = $('managementBody' + parent + subModelClass + subModelParentProp);
    var destinationUrl = '/' + subModelClass + '/list?prop=' + subModelParentProp + '&parent=' + parent;
    new Ajax.Updater(containerDiv, destinationUrl,
        {   evalScripts:true,
            onComplete: function()
            {   initModelToggle(subModelClass, parent, 0, {suppressEffect:1} );
            }
        });
};

customViewModel = function(w, mcn, key, parent, parentProp)
{   
    var containerDiv = $('managementEdit' + mcn + parent);
    var destinationUrl= '/' + mcn + '/view?printLink=1&key=' + key + '&parent=' + parent + '&prop=' + parentProp;

    new Effect.Pulsate(w, {duration:10});
    new Ajax.Updater( containerDiv, destinationUrl,
        {   evalScripts: true,
            onComplete: function() 
            {   MODEL_TOGGLES['modelToggle' + mcn + parent].toggle(2,null,null);
            }
        } );
};

printCustomModel = function(mcn,key)
{   var w = window.open('/' + mcn + '/view?print=1&key=' + key);
};

removeListItem = function(w)
{   // Grab what we need for putting the option back into the select before removing the list item.
    var li = $($(w).up('li'));
    var option = $(document.createElement('option'));
    option.value = li.down('input').value;
    option.text = li.down('span').innerHTML;
    var sel = li.up('td').down('select');
    li.remove();
    try { sel.add(option,null); } catch(e) { sel.add(option); }
}

addListItem = function(theIndex,w,n)
{   
    w = $(w);
    if (theIndex==-1) theIndex = w.selectedIndex;
    if (theIndex<1) return;

    // Which select item was chosen?
    var sel = w.options[theIndex];
    var selVal = sel.value;
    var selLabel = sel.innerHTML;

    // Build a new list item on crack and add it to the list.
    var li = $(document.createElement('li'));
    li.innerHTML = '<label><input type="hidden" name="' + n + '" value="' + selVal + '"><a href="" onclick="removeListItem(this);return false;"><img src="/images/minus.png"></a> <span>' + selLabel + '</span></label>'
    w.up().select('ul').last().appendChild(li);

    w.remove(theIndex);
    w.selectedIndex = 0;

}

EditableView = Class.create();
Object.extend(EditableView.prototype, 
{   initialize: function(modelKind, modelKey, modelName)
    {   this.modelKind = modelKind;
        this.modelKey = modelKey;
        this.modelName = modelName;

        // The model kind and key can get us to the overall container if they did their HTML right.
        var divId = 'editableView' + this.modelKind + this.modelKey;
        this.editableViewDiv = $(divId);
        if (!this.editableViewDiv)
        {
            divId = 'editableView' + this.modelKind + '_' + this.modelKey;
            this.editableViewDiv = $(divId);
            if (!this.editableViewDiv)
            {
                alert('EditableView could not find required div ' + divId);
                return;
            }
        }
        this.editableViewDiv.addClassName('EditableView');
        this.editableViewDiv.editableView = this;

        this.saveUrl = '/' + this.modelKind + '/editprop?_key=' + this.modelKey;
        this.viewUrl = '/' + this.modelKind + '/viewprop?_key=' + this.modelKey;
        this.deleteUrl = '/' + this.modelKind + '/delete?noview=1&key=' + this.modelKey;
        this.copyUrl = '/' + this.modelKind + '/edit?customview=1&copy=1&key=' + this.modelKey;

        this.onClickAddListener = this.clickAddLink.bindAsEventListener(this);
	    this.onClickDeleteListener = this.clickDeleteLink.bindAsEventListener(this);
	    this.onClickCopyListener = this.clickCopyLink.bindAsEventListener(this);

        // Structures we append to as calls are made to our methods that activate things.
        this.addClasses = [];
        this.editableElements = [];
    },

    // Find all elements of a specified class and turn them into links for
    // creating new child models of a given kind (that refer to us via a property).
    // propHash is a set of default values to use while creating the object.
    activateClassForModelAdd: function(className, modelKind, propName, propHash, options)
    {   
        var addLinks = this.getAddLinksForClass(className);
        var ocal = this.onClickAddListener;
        addLinks.each( function(al)
        {   
            al.observe('click', ocal );
            al.modelKind = modelKind;
            al.propName = propName;
            al.propHash = propHash || {};

            al.setStyle({cursor:'pointer'});
            al.addClassName('AddElement');
            al.options = Object.extend(al.options||{}, options||{});
        } );
        this.addClasses.push(className);
    },
    getAddLinksForClass: function(className)
    {   var myDivId = this.editableViewDiv.id;
        var allAddLinks = this.editableViewDiv.select('.'+className).select( function(adl)
        {   return adl.up('.EditableView').id == myDivId;
        } );
        return allAddLinks;
    },
    clickAddLink: function(evt)
    {   
        // Stop the event and also temporarily redirect the observation so they can't 
        // accidentally double-click
        evt.stop();
        var el = $(evt.element());
        el = ( el.hasClassName('AddElement') ? el : el.up('.AddElement') );
        el.stopObserving('click')
        var ocal = this.onClickAddListener
        el.observe('click', function() {return false;} );

        var propHash = Object.extend(
        {   parent: this.modelKey,
            prop: el.propName,
            customview: 1
        }, el.propHash );

        var options = el.options;
        Ajax.InlineProgressUpdater( 'Adding...', el, '/' + el.modelKind + '/save',
        {   evalScripts: true,
            insertion: 'after',
            parameters: propHash,
            loadingNode: options.loadingNode,
            onComplete: function(r)
            {   if (options.onComplete) options.onComplete();
                var addedElement = el.next();
                setTimeout( function() 
                {   
                    addedElement.down('.EditableElement').editableElement.clickEditableElement(null, 
                    {   onCancel: function()
                        {   addedElement.down('.EditableElement').editableElement.editableView.clickDeleteLink(null,
                            {   noConfirm: true
                            } );
                        }
                    });
                    el.observe('click', ocal);
                }, 100 );
            }
        } );

    },

    // Find all <a class="CopyLink"> objects in our div and turn them into
    // links for copying this model.  Whenever we muck about with our content,
    // we deactivate, load the content, then reactivate again, to ensure that
    // our observers remain active and prevent memory leaks.
    activateCopyLinks: function(options)
    {   this.copyOptions = options || {};
        this.getCopyLinks().invoke('observe', 'click', this.onClickCopyListener);
    },
    deactivateCopyLinks: function()
    {   this.getCopyLinks().invoke('stopObserving', 'click', this.onClickCopyListener);
    },
    getCopyLinks: function()
    {   var myDivId = this.editableViewDiv.id;
        var allCopyLinks = this.editableViewDiv.select('.CopyLink').select( function(adl)
        {   return adl.up('.EditableView').id == myDivId;
        } );
        $$( '.' + this.modelKey + 'CopyLink' ).each( function(cl)
        {   allCopyLinks[allCopyLinks.length] = cl;
        } );
        return allCopyLinks;
    },
    clickCopyLink: function(evt)
    {   
        evt.stop();
        var myDiv = this.editableViewDiv;
        var optionOnComplete = this.copyOptions.onComplete;
        if (this.copyOptions.onClick) this.copyOptions.onClick();
        Ajax.ProgressUpdater( 'Copying...', myDiv, this.copyUrl,
        {   evalScripts: true,
            insertion: 'before',
            onComplete: function()
            {
                new Effect.Pulsate(myDiv.previous(),{pulses:2, duration:2});
                if (optionOnComplete) optionOnComplete();
            }
        } );
    },

    // Find all <a class="DeleteLink"> objects in our div and turn them into
    // links for deleting this model.  Whenever we muck about with our content,
    // we deactivate, load the content, then reactivate again, to ensure that
    // our observers remain active and prevent memory leaks.
    activateDeleteLinks: function(options)
    {   this.deleteOptions = Object.extend(this.deleteOptions||{removeEditableView:true}, options||{});
        this.getDeleteLinks().invoke('observe', 'click', this.onClickDeleteListener);
    },
    deactivateDeleteLinks: function()
    {   this.getDeleteLinks().invoke('stopObserving', 'click', this.onClickDeleteListener);
    },
    getDeleteLinks: function()
    {   var myDivId = this.editableViewDiv.id;
        var allDeleteLinks = this.editableViewDiv.select('.DeleteLink').select( function(adl)
        {   return adl.up('.EditableView').id == myDivId;
        } );
        $$( '.' + this.modelKey + 'DeleteLink' ).each( function(cl)
        {   allDeleteLinks[allDeleteLinks.length] = cl;
        } );
        return allDeleteLinks;
    },
    clickDeleteLink: function(evt, options)
    {   
        if (evt) evt.stop();
        options = Object.extend( { noConfirm:false }, options || {} );
        if ( !options.noConfirm && !confirm('Are you sure you want to delete this ' + this.modelKind + '?')) return;
        this.deactivateDeleteLinks();
        this.deactivateCopyLinks();
        this.deactivateAllElements();

        var myDiv = this.editableViewDiv
        if (this.deleteOptions.removeEditableView) myDiv.remove();
        var delOp = this.deleteOptions;
        new Ajax.Request( this.deleteUrl,
        {   onComplete: function()
            {   if (delOp.onComplete) delOp.onComplete();
            }
        } );
    },

    // Add an element to this EditableView that, when clicked, loads a form.
    makeEditableElement: function(showPropName, options)
    {   this.editableElements.push(new EditableElement(this, showPropName, options));
    },
    // Also, a method for deactivating them all temporarily
    deactivateAllElements: function()
    {   this.editableElements.invoke('deactivateElement');
    }

});


EditableElement = Class.create();
Object.extend(EditableElement.prototype, 
{   initialize: function(editableView, showPropName, options)
    {   this.editableView = editableView;
        this.showPropName = showPropName;

        this.options = Object.extend(
            {   propNames: [showPropName],
                dependentProps: [],
                externalProps: []
            }, (options || {}) );
        this.dependentProps = this.options.dependentProps;
        this.externalProps = this.options.externalProps;
        this.onComplete = this.options.onComplete;
        this.options.showPropName = showPropName;
        this.options.targetUrl = editableView.saveUrl + '&showProp=' + showPropName;
        for (var i=0;i<this.options.propNames.length;i++)
            this.options.targetUrl = this.options.targetUrl + '&prop=' + options.propNames[i];

        // Find the div whose contents we edit and the trigger that activates editing.
        this.label = $(this.editableView.modelKey + showPropName);
        if (!this.label)
            alert('Could not find element: ' + this.editableView.modelKey + showPropName);
        this.trigger = $(this.editableView.modelKey + showPropName + 'Trigger') || this.label;

        // Give them both references back to us
        this.label.editableElement = this;
        this.trigger.editableElement = this;

        // Listeners for our events.
	    this.onClickEditableListener = this.clickEditableElement.bindAsEventListener(this);
	    this.onFormLoadedListener = this.formLoaded.bindAsEventListener(this);
        this.modalBoxHiddenListener = this.modalBoxHidden.bindAsEventListener(this);
	    this.onSubmitListener = this.submitEditableForm.bindAsEventListener(this);
	    this.onCancelListener = this.cancelElement.bindAsEventListener(this);
	    this.onSubmitCompleteListener = this.submitComplete.bindAsEventListener(this);

        // Activate the element and set it up so it can be found later.
        this.label.addClassName('EditableElement');
        this.activateElement();
    },

    // Activate/deactivate a clickable element.  Activation happens upon creation,
    // deactivation when the form gets loaded, and reactivation on submit or cancel.
    activateElement: function(el)
    {   //console.log('Now observing:' + el.innerHTML);
        Event.observe(this.trigger, 'click', this.onClickEditableListener);
        this.trigger.style.cursor = 'pointer';
    },
    deactivateElement: function(el)
    {   //console.log('No longer observing:' + el.innerHTML);
        Event.stopObserving(this.trigger, 'click');
        this.trigger.style.cursor = 'default';
    },

    // Triggered when you click an element to load up the form.
    // Temporarily halts onclick observation of the element,
    // but starts up observation of the cancellation/submission of the form.
    clickEditableElement: function(evt, options)
    {   if (DRAGGING) return;
        if (evt) evt.stop();

        options = Object.extend( {'onCancel':null}, options || {} );
        Modalbox.show( this.options.targetUrl,
        {   title:this.editableView.modelName, width:400, overlayClose:false, autoFocusing:false,
            slideDownDuration:.25, slideUpDuration:.25,
            afterLoad: this.onFormLoadedListener, beforeHide: this.modalBoxHiddenListener
        } );
        Modalbox.editableOptions = options;
    },

    formLoaded: function()
    {   
        this.editableView.deactivateDeleteLinks();
        this.editableView.deactivateCopyLinks();
        Modalbox.editableView = this.editableView;

        this.resizeDialog = Modalbox.resizeToContent.bindAsEventListener(Modalbox);
        
        var thisForm = Modalbox.thisForm = $('MB_content').down('form');
        thisForm.observe( 'submit', this.onSubmitListener );
        thisForm.down('.Cancel').observe( 'click', this.onCancelListener );
        thisForm.observe('DOMNodeInserted', this.resizeDialog );
    },
    modalBoxHidden: function()
    {
        if (Modalbox.thisForm)
        {
            Modalbox.thisForm.stopObserving( 'submit' );
            Modalbox.thisForm.stopObserving('DOMNodeInserted', this.resizeDialog );
            if (Modalbox.thisForm.down('.Cancel'))
            {   Modalbox.thisForm.down('.Cancel').stopObserving( 'click' );
            }
        }
        // Do a timeout here to make it work in Firefox for some reason...
        setTimeout( function()
        {   Modalbox.editableView.activateDeleteLinks();
            Modalbox.editableView.activateCopyLinks();
        }, 500 );
    },

    // Once the form is loaded, they must either cancel or submit.
    // Either way, we stop observing the form and its button,
    // and start observing the click of the element again.
    cancelElement: function(evt)
    {   
        Modalbox.hide();
        if (Modalbox.editableOptions.onCancel) Modalbox.editableOptions.onCancel();
    },
    submitEditableForm: function(evt)
    {   evt.stop();

        // Create a hidden iframe.  We have to take this approach to allow file upload.
        var hiddenIframe = $(document.createElement('iframe')).setStyle(
        {   display:'none'
        } ).writeAttribute(
        {   src: 'about:blank', id: 'hiddenIframe', name: 'hiddenIframe'
        } ).observe( 'load', this.onSubmitCompleteListener );
        document.body.appendChild(hiddenIframe);

        // Make the form just not submit any more, at any cost, while the dialog is deactivated.
        var theForm = evt.element();
        theForm.stopObserving('submit')
        theForm.observe('submit', function(evt) {evt.stop();return false;} )
        Modalbox.deactivate();

        // Submit the form into the hidden iframe.
        theForm.writeAttribute({target: 'hiddenIframe'});
        theForm.submit();

        /*  This is what we did before we started using the iframe.
        new Ajax.Updater( 'MB_content', theForm.action,
        {   evalScripts: true,
            parameters: Form.serialize(theForm),
            onComplete: this.onSubmitCompleteListener
        } );
        */

    },
    submitComplete: function(evt)
    {   
        // Have a look in our hidden iframe; we may have gotten called early so bail if so.
        var hiddenIframe = $('hiddenIframe');
        if (hiddenIframe.contentDocument) { var d = hiddenIframe.contentDocument; } 
        else if (hiddenIframe.contentWindow) { var d = hiddenIframe.contentWindow.document; } 
        else { var d = window.frames['hiddenIframe'].document; }
        if (d.location.href == "about:blank") { return; }

        // Otherwise, copy the content into our modalbox so we can proceed how we
        // did before this iframe file upload debacle.
        iframeContent = d.body.innerHTML;
        $('MB_content').innerHTML = iframeContent;

        // For whatever reason, doing this immediately makes firefox think it's still
        // loading the response, so its native spinner never goes away.
        // The timeout gets around that.
        setTimeout( function() { hiddenIframe.remove(); }, 100 );
    
        // If we get a form back, it's because there were errors in the user input.
        var thisForm = $('MB_content').down('form');
        if (thisForm)
        {   this.onFormLoadedListener();
            Modalbox.activate();
            return;
        }

        // Otherwise, we were successful and can update our label div.
        var modelKey = Modalbox.editableView.modelKey;
        var viewUrl = Modalbox.editableView.viewUrl;
        updatableElements = this.dependentProps.collect( function(dep)
        {   var targetEl = $(modelKey+dep);
            if (targetEl) { targetEl.depName = dep; }
            else { alert('Bad prop: ' + dep); }
            return targetEl;
        } ).compact();
        this.externalProps.each( function(dep)
        {   var externalEls = $$( '.' + modelKey + dep );
            externalEls.each( function(eel)
            {   eel.depName = dep;
                updatableElements[updatableElements.length] = eel;
            } );
        } );
        updatableElements.each( function(targetEl)
        {   
            var oldHTML = targetEl.innerHTML;
            var depName = targetEl.depName;
            new Ajax.Updater( targetEl, viewUrl + '&showProp=' + depName,
            {   evalScripts: true,
                onComplete: function() 
                {   // Strangely enough, IE crashes if you Pulsate the tacticsTitle...Defect 119.
                    if ( targetEl.innerHTML != oldHTML && depName != 'tacticsTitle')
                        new Effect.Pulsate(targetEl, {pulses:2, duration:2}); 
                }
            } );
        } );
        if (this.onComplete) this.onComplete();

        Modalbox.hide();
        $(this.label).innerHTML = $('MB_content').down('.Response').innerHTML;
        new Effect.Pulsate(this.label, {pulses:2, duration:2});
    }
} );
