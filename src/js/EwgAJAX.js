/*	Provides a very high level AJAX interface.

	Always be sure to have:    <script src="prototype.js"></script>
	in your HTML file before:  <script src="EwgAJAX.js"></script>
*/

// Turn this on or off for a bunch of annoying alert progress statements.
EWG_AJAX_DEBUG_ALERT = 0;
function debugAlert( someThing )
{
	if ( EWG_AJAX_DEBUG_ALERT ) alert( someThing );
}

// This is a useful default error handler.
function alertErrorHandler( errorMessage, nameSpace )
{	alert( errorMessage );
}

var loadedSpinner = new Image;
loadedSpinner.src = '/images/DivLoadingSpinner.gif';
function showProgressInDiv( divId )
{
	var theDiv = $( divId );
	if (!theDiv)
		alert( 'Invalid divId "' + divId + '"' );
	else
		theDiv.innerHTML = '<img src="/images/DivLoadingSpinner.gif">';
}
function useUpdater( divId, theUrl, methodsToCall, method, parameters, options)
{
    //alert('UU');
	// This keeps us from blinking while hovering over sub-spans.
	//if ( ( !($( divId )) || $( divId ).lastUrl == theUrl ) && (!options.refreshUrl) ) return;
	//$( divId ).lastUrl = theUrl;

	options = Object.extend( {}, options );
	//if ( !options.noProgress ) showProgressInDiv( divId );

	if ( !options.cacheUrl )
	{
		if ( theUrl.split('?').length > 1 )
			var uncachableUrl = theUrl + '&time=' + (new Date()).getTime();
		else
			var uncachableUrl = theUrl + '?time=' + (new Date()).getTime();
	}
	else
		var uncachableUrl = theUrl;

	var methodsToCall = methodsToCall;
	return new Ajax.Updater( divId, uncachableUrl,
		{	method: method,
			evalScripts: true,
			parameters: parameters,
			onComplete: function( theResponse )
			{	if ( methodsToCall )
					for ( var i=0; i<methodsToCall.length; i++ )
						methodsToCall[i]( theResponse, divId );
			}
		} );
}

// This is a useful routine for loading a URL into a div.
function submitFormIntoDiv( formId, divId, methodsToCall, options)
{	
    var serialForm = Form.serialize($(formId));
    //alert(serialForm);
    useUpdater( divId, $( formId ).action, methodsToCall, $( formId ).method, serialForm, options);
}

// This is a useful routine for loading an URL into a div.
function getUrlIntoDiv( theUrl, divId, methodsToCall, options )
{	useUpdater( divId, theUrl, methodsToCall, 'get', null, options );
}

function getUrlIntoFunction( theUrl, theFunction )
{
	new Ajax.Request( theUrl, 
		{	method: 'get',
			onComplete: function( r )
			{	theFunction( r.responseText );
			}
		} );
}

Ajax.mungeOptionsForProgress = function( options )
{   options = options || {};
    var originalOnComplete = options.onComplete;
    options.onComplete = function(r)
    {   if (originalOnComplete) originalOnComplete(r);
        Modalbox.hide();
    };
    return options;
};
Ajax.showModalboxForProgress = function(progressMessage)
{
    Modalbox.show( '<span>' + progressMessage + '</span>',
    {   title: '', width:400, height: 50, overlayClose:false, autoFocusing:false,
        slideDownDuration:.25, slideUpDuration:.25
    } );
    Modalbox.deactivate()
};
Ajax.ProgressUpdater = function( progressMessage, theDiv, theUrl, options )
{   options = Ajax.mungeOptionsForProgress(options);
    Ajax.showModalboxForProgress(progressMessage);
    new Ajax.Updater( theDiv, theUrl, options);
};
Ajax.ProgressRequest = function( progressMessage, theUrl, options )
{   options = Ajax.mungeOptionsForProgress(options);
    Ajax.showModalboxForProgress(progressMessage);
    new Ajax.Request(theUrl, options);
};
Ajax.InlineProgressUpdater = function( progressMessage, theDiv, theUrl, options )
{   
    var loadingNode = options.loadingNode || $(document.createElement('span')).update('Loading');
    theDiv.insert({after: loadingNode});

    var originalOC = options.onComplete;
    options.onComplete = function(r) { loadingNode.remove(); if (originalOC) originalOC(r) };
    new Ajax.Updater( theDiv, theUrl, options);
};

callInProgress = function (xmlhttp) 
{
    switch (xmlhttp.readyState) 
    {
        case 1: case 2: case 3:
            return true;
            break;
        // Case 4 and 0
        default:
            return false;
            break;
        }
};
showFailureMessage = function() 
{   //alert('It looks like the network is down. Try again shortly');
    Modalbox.hide();
};

// Register global responders that will occur on all AJAX requests
Ajax.Responders.register(
{   onCreate: function(request) 
    {
        request['timeoutId'] = window.setTimeout( function() 
        {
            // If we have hit the timeout and the AJAX request is active, abort it and let the user know
            if (callInProgress(request.transport)) 
            {
                request.transport.abort();
                showFailureMessage(request);
                // Run the onFailure method if we set one up when creating the AJAX object
                if (request.options['onFailure']) 
                {   request.options['onFailure'](request.transport, request.json);
                }
            }
        }, 9000 ); // 8 seconds is just under Google's 9 second threshold anyway; add a couple for traffic.
    },
    onComplete: function(request) 
    {
        // Clear the timeout, the request completed ok
        window.clearTimeout(request['timeoutId']);
    }
} );

