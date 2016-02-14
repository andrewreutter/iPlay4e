AUTH_SUCCESS_HANDLERS = [];
AUTH_ERROR_HANDLERS = [];

registerAuthHandler = function(successHandler, errorHandler)
{   if (successHandler) AUTH_SUCCESS_HANDLERS[AUTH_SUCCESS_HANDLERS.length] = successHandler;
    if (errorHandler) AUTH_ERROR_HANDLERS[AUTH_ERROR_HANDLERS.length] = errorHandler;
};

AUTH_DATA = null;

pageAuth = function()
{   
    if ( (''+location.search).indexOf('native=') != -1)
        $$('.NotNative').invoke('hide');

    // If a parent window has already done this, don't bother.
    var authData = null;
    try { authData = top.AUTH_DATA } catch (e) {}
    if (!authData) try { authData = parent.AUTH_DATA } catch (e) {}
    if (authData)
    {   //alert('found AUTH_DATA up');
        AUTH_DATA = authData;
        AUTH_SUCCESS_HANDLERS.each(function(h) 
        {   try { h(AUTH_DATA); } catch(e) {}
        });
        return;
    }
    // We have to use the 'get' method because post, on Android 1.5, provokes an HTTP 411 failure response.
    new Ajax.Request('/auth', 
    {   method: 'get',
        onSuccess: function(r)
        {   
            //alert('Got it!');
            AUTH_DATA = r.responseText.evalJSON();
            AUTH_SUCCESS_HANDLERS.each(function(h) 
            {   try { h(AUTH_DATA); } catch(e) {}
            });
        },
        onFailure: function(r)
        {   
            //alert('Failed it with response status ' + r.status + '(' + r.statusText + ') with headers ' + r.getAllHeaders());
            //alert(r.responseText);
            AUTH_ERROR_HANDLERS.each(function(h) 
            {   try { h(); } catch(e) {}
            });
        }
    });
};
registerAuthHandler(function(json)
{
    $$(json.id ? '.AuthOnly' : '.NoAuthOnly').invoke('show');
    $$('.SignInOut').each(function(sio) 
    {   sio.href = json.url;
        sio.update(json.id ? '<u>Sign out</u>' : '<u>Sign in</u>');
    });
    $$(json.isAdmin ? '.AdminOnly' : '.NoAdminOnly').invoke('show');
});

REPORT_URLS = [];

// targetElement: where it asks if it's good or bad
// urlGetDict: c, i, etc...all the info for a reportedurl
// powerLink: optionally override the link whose URL will get "fixed"
registerReportUrl = function(targetElement, urlGetDict, powerLink) {   
    var powerLink = powerLink || 'powerlink' + urlGetDict.c + urlGetDict.i;
    REPORT_URLS.push([targetElement, urlGetDict, powerLink]);
};
processReportUrls = function()
{   //alert('PRU');
    if (!REPORT_URLS.length) return;
    //alert('PRU2');

    //alert('XXXxxx' + $A(REPORT_URLS).collect(function(ru) {return ru[1];}).toJSON()),
    new Ajax.Request('/reporturl', 
    {   method: 'post',
        parameters: {
            targetElements: $A(REPORT_URLS).collect(function(ru) {return ru[0];}).toJSON(),
            multipleUrls: $A(REPORT_URLS).collect(function(ru) {return ru[1];}).toJSON(),
            powerLinks: $A(REPORT_URLS).collect(function(ru) {return ru[2];}).toJSON()
        },
        onSuccess: function(r) {   
            var retContents = r.responseText.evalJSON();
            $A(REPORT_URLS).zip(retContents).each(function(reportUrlTupleAndContent)
            {   
                //alert(reportUrlTupleAndContent[0][0] + ' | ' + reportUrlTupleAndContent[0][1] + ' | ' + reportUrlTupleAndContent[1]);
                $(reportUrlTupleAndContent[0][0]).update(reportUrlTupleAndContent[1]);
            });
        },
        onFailure: function(r) {   
            //alert('Failed it with response status ' + r.status + '(' + r.statusText + ') with headers ' + r.getAllHeaders());
            //alert(r.responseText);
        }
    });
};

populatePagebarMenu = function(menuDivId, objectList, urlPath, emptyMessage)
{
    // Always put the message up, even if we have no objects to deal with.
    var menuDiv = $(menuDivId);
    if (!objectList) 
    {   menuDiv.update('<div class="FAQAnswer" style="padding-left:6px;"><i>' + emptyMessage + '</i></div>');
        return;
    }
    menuDiv.update(
        '<div class="FAQQuestion" style="margin-top:6px;">' +
            '<a href="/' + urlPath + '"><u>View all</u></a>' + 
        '</div>'
    );

    // Split up the objects into those I own and those I do not, with separate labels.
    [   ['My',      function(o) { return o.isOwner == 1; }],
        ['Shared',  function(o) { return o.isOwner == 0; }],
    ].each(function(labelAndFilter)
    {   var thisList = objectList.findAll(labelAndFilter[1]);
        if (!thisList.length) return;

        menuDiv.update(menuDiv.innerHTML + 
            '<div style="font-weight:bold;margin-left:10px;">' + labelAndFilter[0] + ' ' + urlPath + '</div>');
        thisList.each(function(c)
        {   menuDiv.update(menuDiv.innerHTML + 
            '<div class="FAQQuestion">' + 
                '<a href="/' + urlPath + '/' + c.key + '">' + 
                    c.title + 
                    ( c.subtitle ? ' (' + c.subtitle + ')' : '') +
                '</a>' +
            '</div>'
            );
        });
    });
};

var MENUS_PROTECTED = 0;
protectMenusFromIE = function()
{   
    if (MENUS_PROTECTED) return;
    MENUS_PROTECTED = 1;

    setTimeout(function()
    {   // Put an iframe before the content of each menu.
        $$('.IconHolder .CombatantContent').each(function(iconContent)
        {   iconContent.insert({before: '<iframe class="MenuProtector" frameborder="0"></iframe>'});
        });

        // Resize the iframe to match the menu content, and set it up to resize when the content does.
        $$('iframe.MenuProtector').each(function(iframeElement) 
        {   useIframeToProtectMenu(iframeElement);
            iframeElement.next().select('.FAQQuestion').invoke('observe', 'click', function()
            {   setTimeout(function()
                {   useIframeToProtectMenu(iframeElement);
                }, 250); // Give time for the menu options to expand.
            });

            var rightAligned = (iframeElement.up().up().getStyle('text-align') == 'right');
            iframeElement.style.right = (rightAligned ? '0' : '');
            iframeElement.style.left = (rightAligned ? '' : '0');
        });

        // Make the menus clickable.
        $$('.IconHolder .IconLink').invoke('observe', 'click', function(evt)
        {   evt.stop();

            var iconHolder = evt.element().up('.IconHolder');
            var isVisible = iconHolder.hasClassName('IconHolderHover');

            //alert('foobar');
            hideMenus();
            if (isVisible) return;

            showMenu(iconHolder);
        });
        $$('.IconHolder .IconLink').invoke('observe', 'mouseover', function(evt)
        {   if (! $$('.IconHolderHover').first()) return;
            hideMenus();
            showMenu(evt.element().up('.IconHolder'));
        });

        $(document.body).observe('click', function(evt)
        {   if (evt.element().up('.IconHolder')) return;
            hideMenus();
        });
        $(document.body).observe('keyup', function(evt)
        {   var whichKey = evt.which || evt.keyCode;
            //alert(whichKey);
            if (whichKey && whichKey == 27)
                hideMenus();
        });
    }, 250); // This gives times for the menus to be populated before we retrieve their dimensions.
};
START_Z_INDEX = 1001;
showMenu = function(iconHolder)
{   START_Z_INDEX += 1;
    iconHolder.setStyle({'zIndex':''+START_Z_INDEX});
    iconHolder.addClassName('IconHolderHover');
};
hideMenus = function()
{   $$('.IconHolder').invoke('removeClassName', 'IconHolderHover');
    if (frameElement) parent.hideMenus(); // Up the frame stack.
};

// Puts an iframe under a menu so it doesn't disappear under iframes in IE.
useIframeToProtectMenu = function(iframeElement)
{   var menuContent = iframeElement.next('.CombatantContent');
    menuContent.style.display = 'block';
    iframeElement.clonePosition(menuContent, {setLeft:false});
    iframeElement.setStyle({height:menuContent.getHeight()+'px', width:menuContent.getWidth()+'px'});
    iframeElement.style.top = menuContent.style.top || menuContent.getStyle('top');
    menuContent.style.display = ''; // clonePosition() doesn't work on hidden elements.
};

sizeIframeToContentWithYPadding = function(theIframe, contentElement, yPadding, minHeight)
{   
    // Firefox returns 0 for contentElement.getHeight() when the containing iframe is hidden.
    theIframe.style.display = 'block';

    var newHeight = contentElement.getHeight();
    newHeight = Math.max(newHeight, minHeight || 0);

    if (!newHeight) return $(theIframe).getHeight();
    // if (!newHeight) alert ('Bad contentElement height: ' + contentElement.id + ' ' + contentElement.style.display);
    // if (!newHeight) alert ('Bad iframe height: ' + theIframe.id + ' ' + theIframe.src + contentElement.style.height);

    newHeight = newHeight + yPadding;
    theIframe.style.height = newHeight + 'px';
    return newHeight;
};

sizeTopToMyContainer = function()
{   
    //sizeIframeToContentWithYPadding(top.$('pageBody'), $$('body').first().down('.container'), 40);
};

getTop = function()
{
    var topDoc = null;
    try { topDoc = top.document; } catch (e) { topDoc = null; }
    return topDoc;
};

sizeParentIframeToMyContainer = function(extraPadding, minHeight)
{   
    var topDoc = getTop();
    if (topDoc) // True unless embedded.
    {   
        // Get rid of the page loading spinner, if any.
        if (top.$('loadingPageBodyImage')) top.$('loadingPageBodyImage').hide();

        // If we're not surrounded by the standard iPlay4e nav, we need to make the body scrollable.
        var topPageBody = top.$('pageBody');
        if (!topPageBody) 
        {   top.$$('body').first().setStyle({overflow:'auto'});
        }
    }

    var containerDiv = $$('body').first().down('.container');
    if (!containerDiv) return;

    var containerHeightWithPadding = containerDiv.getHeight() + 40;
    if (window.parent.postMessage) window.parent.postMessage(''+containerHeightWithPadding, '*')

    // Change both the iframe (if we're in one) and its container.
    var hasParentFrame = false;
    try { hasParentFrame = (frameElement && frameElement.parentNode); } catch (e) { hasParentFrame = false; }
    if (!hasParentFrame) return;
    var newHeight = sizeIframeToContentWithYPadding(frameElement, containerDiv, 5 + (extraPadding || 0), minHeight);
    if (newHeight) frameElement.parentNode.style.height = newHeight + 'px';

    // Cascade up.
    var parentFrame = parent.frameElement;
    if (parentFrame) 
    {   parent.sizeParentIframeToMyContainer(20); // Things getting cut off without the 20...
    }
    else
    {   if (parent.parent.postMessage) 
            parent.parent.postMessage(''+(parent.$$('body').first().down('.container').getHeight()+20), '*');
    }

};

sizeTopToMyContainerOnLoad = function()
{   Event.observe(document, 'dom:loaded', function()
    {   
        sizeParentIframeToMyContainer(35);
        var topDoc = getTop();
        if (top.$('loadingPageBodyImage')) top.$('loadingPageBodyImage').hide();
    });
}

showAnswer = function(evt) {   
    var faqAnswer = evt.element().next('.FAQAnswer');
    if (faqAnswer)
        Effect.toggle(faqAnswer, 'blind', {duration:.2} );
};

connectQuestionsToAnswers = function()
{
    Event.observe(document, 'dom:loaded', function()
    {   $$('.FAQQuestion').invoke('observe', 'click', showAnswer);
    } );
}

showMessage = function(message, elementId)
{   var theElement = $(elementId);
    if (!theElement) return alert(message);
    new Effect.BlindDown( theElement.update(message), {duration:.2});
    setTimeout(function()
    {   new Effect.Fade( theElement, {duration:1});
    }, 4000);
};

showError = function(message)
{   return showMessage(message, 'pageError');
};

showSuccess = function(message)
{   return showMessage(message, 'pageSuccess');
};

pageLoad = function()
{   
    pageAuth();

    // Choose a nav item to CSS-activate by finding the one whose URL relates to our own.
    var locationTabname = document.location.pathname.substring(1).split('/')[0];
    var firstMatchingLink = 
        $$('#pagesBar a.TabLink').findAll(function(a) 
        {   return a.href.indexOf(locationTabname) != -1; 
        }).first();
    firstMatchingLink.addClassName('Active').show(); // make sure even "search" and other invisible nav items appear.

    // The body content of our page lives in an iframe controlled by that active nav item.
    // Load it using our own CGI arguments, and stretch the iframe to fit.
    var slashlessPathname = document.location.pathname + '';
    while (slashlessPathname[slashlessPathname.length-1] == '/') 
        slashlessPathname = slashlessPathname.substring(0, slashlessPathname.length-1);
    var bodyPathname = slashlessPathname + '/main' + location.search;
    $('pageBody').src = bodyPathname;
};

uploadSubmit = function(e)
{   var theForm = e.element();

    var fileInput = theForm.down('#dnd4eData');
    if (!fileInput.value)
    {   alert('First choose a file from Character Builder (.dnd4e)');
        fileInput.focus();
        return e.stop();
    }
    var termsCheckbox = theForm.down('#acceptTerms');
    if (!termsCheckbox.checked)
    {   alert('Please read and accept the iPlay4e Terms of Use');
        return e.stop();
    }
};

campaignCreateSubmit = function(e)
{   var theForm = e.element();

    var nameInput = theForm.down('#campaignNameInput');
    if (!nameInput.value)
    {   alert('Please enter a name.');
        nameInput.focus();
        return e.stop();
    }

    var termsCheckbox = theForm.down('#acceptTermsCampaign');
    if (!termsCheckbox.checked)
    {   alert('Please read and accept the iPlay4e Terms of Use');
        return e.stop();
    }
};

var IS_NATIVE_APP = false;
iPlay4eLiveInit = function() {
    IS_NATIVE_APP = true;
};
