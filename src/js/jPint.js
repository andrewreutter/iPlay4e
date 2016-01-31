/* Copyright (c) 2008 Journyx, Inc.

   Permission is hereby granted, free of charge, to any person obtaining
   a copy of this software and associated documentation files (the
   "Software"), to deal in the Software without restriction, including
   without limitation the rights to use, copy, modify, merge, publish,
   distribute, sublicense, and/or sell copies of the Software, and to
   permit persons to whom the Software is furnished to do so, subject to
   the following conditions:
  
   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.
  
   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
   LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
   OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  
   The software may not be used to develop, enable or integrate with 
   time, expense, or mileage tracking software of any kind,  except when
   such software is provided by Journyx or its designated licensees.
*/

/* PUBLIC Element METHODS */

Element.addMethods(
{

	// If the element has a previous sibling, put it before that sibling.
	// If it does not, put it at the end of the parent.
    movePrevious: function( theElement )
    {
        var parentNode = theElement.up();
        var previousDiv = theElement.previous();

        parentNode.removeChild( theElement );
        if ( previousDiv ) { parentNode.insertBefore( theElement, previousDiv ); }
        else { parentNode.appendChild( theElement ); }
		return theElement;
    },
   
    moveNext: function( theElement )
    {
        var parentNode = theElement.up();
        var nextDiv = theElement.next();

        parentNode.removeChild( theElement );
        if ( nextDiv )
        {   
			var nextNextDiv = nextDiv.next();
            if ( nextNextDiv ) { parentNode.insertBefore( theElement, nextNextDiv ); }
            else { parentNode.appendChild( theElement ); }
        }
        else
        {   parentNode.insertBefore( theElement, $A( parentNode.getElementsByClassName( 'Character' ) ).first() );
        }
		return theElement;
    },

	// Ensure that an element is the only one of its siblings with a given class name.
	ownClassName: function( theElement, className )
	{	theElement.siblings().without( theElement ).invoke( 'removeClassName', className );
		return theElement.addClassName( className );
	},

	getPhonePage: function( theNode ) 
	{	if ( theNode.hasClassName( 'jPintPage' ) ) return theNode;
		return theNode.up( '.jPintPage' ); 
	},

	makeSlidingDoor: function( theButton )
	{	//console.log( 'Element.makeSlidingDoor' );
		jPintLayout.makeSlidingDoor( theButton );
	},

	makeDisabledClone: function( theLink )
	{
		theCopy = theLink.cloneNode( true );
		theLink.up().insertBefore( theCopy, theLink );
		$( theCopy ).disable();

		theLink.addClassName( 'EditModeInvisible' );
		theCopy.addClassName( 'EditModeVisible' );
	},

	makeSortable: function( li )
	{
		// Create and add the double button used for up/down sorting.
		li.doubleButton = $( document.createElement( 'span' ) );
		li.doubleButton.className = 'EditModeVisible DoubleButton SortDouble';
		li.doubleButton.innerHTML = '<span class="ALike"></span>';
		var doubleButtonSpan = li.doubleButton.childElements().first();
		li.insertBefore( li.doubleButton, li.childElements().first() );
		jPintLayout.makeSlidingDoor( doubleButtonSpan, 'DoubleButton' );

		// Make the li move up and down and call the sorthandler if any.
		[ [ '&dArr;', 'moveNext' ], [ '&uArr;', 'movePrevious' ] ].each( function( arrowAndMethod )
		{
			var theButton = $( document.createElement( 'span' ) );
			theButton.innerHTML = arrowAndMethod[0];
			theButton.className = 'NoFont WidePadding';
			doubleButtonSpan.appendChild( theButton );
			theButton.observe( 'click', function( e )
			{	var listItem = Event.findElement( e, 'li' );
				listItem[ arrowAndMethod[1] ]();
				if( listItem.getPhonePage().onSort ) listItem.getPhonePage().onSort( listItem );
				return false;
			} );
		} );
	},

	makeDeletable: function( li )
	{
		// Insert an invisible href over our nifty delete background image,
		// and another one at the right that will only appear while confirming.
		li.deleteLink = $( document.createElement( 'span' ) );
		li.deleteLink.className = 'EditModeVisible DeleteButton';
		li.insertBefore( li.deleteLink, li.childElements().first() );
		li.deleteFunction =
			function( theEvent )
			{	var listItem = Event.findElement( theEvent, 'li' );
				var thePage = listItem.getPhonePage();
				thePage.getElementsBySelector( 'li' ).without( listItem ).invoke( 'removeClassName', 'DeleteConfirm' );
				listItem.toggleClassName( 'DeleteConfirm' );

				// Save the fact that we're deleting an item so we can cancel that if we leave edit mode.
				thePage.deletingListItem = listItem.hasClassName( 'DeleteConfirm' ) ? listItem : null;
				return false;
			};
		li.deleteLink.observe( 'click', li.deleteFunction );

		li.confirmLink = $( document.createElement( 'span' ) );
		li.confirmLink.className = 'EditModeVisible DeleteConfirm';
		li.confirmLink.innerHTML = '<a>Delete</a>';
		li.insertBefore( li.confirmLink, li.childElements().first() );
		var confirmLinkLink = li.confirmLink.childElements().first();
		jPintLayout.makeSlidingDoor( confirmLinkLink, 'DeleteConfirm' );
		li.confirmFunction =
			function( theEvent )
			{	var listItem = Event.findElement( theEvent, 'li' );
				if ( listItem.getPhonePage().onDelete ) listItem.getPhonePage().onDelete( listItem, theEvent );
				return false;
			};
		confirmLinkLink.observe( 'click', li.confirmFunction );
	},

	// Disable/enable a single link.
	disable: function( theLink )
	{	
		theLink.disabled = true; 
		if ( theLink.onclick ) theLink.oldclick = theLink.onclick; 
		theLink.onclick = function() { return false; }; 
		theLink.addClassName( 'Unclickable' );
	},
	enable: function( theLink )
	{
		theLink.disabled = false; 
		theLink.onclick = theLink.oldclick;
		theLink.removeClassName( 'Unclickable' );
	}

} );

/*	This object knows about the pages in the document and how to move between them,
	including observing the page address for # links.
*/
var jPintNav = 
{
	// Config variables.  Edit at will.
	animateX: -20,
	animateInterval: 24,

	// State variables.  Leave them alone.
	currentHash: null,
	hashPrefix: "#",
	currentPage: 0,
	pageHistory: [],
	pagesAreBeingChecked: 0,

    // Don't use animation.
    useAnimation: 0,

	// Display the first jPintPage in the document, and set up URL hash observation
	// if other pages are included.  
	//
	// Also makes all the back buttons into jPint history nav items.
	//
	// Safe to call multiple times, e.g. if you have loaded more dynamic content.
	initNav: function()
	{
		// Cause page 1 to appear and set up URL monitoring if there is only one page,
		// because others might be dynamically loaded...
		if (! jPintNav.pagesAreBeingChecked )
		{
			var jPintPages = jPintNav.getPages();
            if (!jPintPages.length) return;
			jPintNav.checkPage();

            var allHashRefs = $$('a').findAll(function(a) {return a.href.indexOf('#') != -1}).each(function(a)
            {   
                var oldHref = a.href;

                // Opera Mini couldn't seem to get the dynamic loading right.
                // So instead, we just link to the page directly for the @url convention.
                // We do this for all browsers to keep it simple.
			    var atIndex = a.href.indexOf( '@' );
			    if ( atIndex != -1 )
                {
				    var loadUrl = a.href.substr( atIndex + 1 );
                    a.href = loadUrl.replace('asPhoneDiv', 'asPhonePage');
                    return;
                }
                if (oldHref.substr(0, 10) != 'javascript')
                {
                    // Opera gets treated differently that this simple approach.
                    if (navigator.userAgent.indexOf('Opera') == -1) 
                    {   a.href = "javascript:jPintNav.checkPage('" + oldHref + "');";
                    }
                    else
                    {
                        var clickFunction = function()
                        {   
                            jPintNav.checkPage(oldHref);
                            return false;
                        };
    
                        a.href = "#";
                        a.observe('click', clickFunction);
                    }
                }

            });
		}

		jPintNav.hideURLBar();

		// Convert all CancelButton links into history nav items
		$A( document.getElementsByClassName( 'BackButton' ) ).invoke( 'writeAttribute', 'href', 'javascript:jPintNav.back();' );
	},

	back: function()
	{	
        //alert(jPintNav.pageHistory.length);
        var newLocation = '#' + jPintNav.pageHistory[jPintNav.pageHistory.length - 2];
        document.location = newLocation;
        jPintNav.checkPage();
	},

    // If newLocation is not provided, we parse it from document.location.
    // In an iFrame in IE in XSL, we aren't able to set document.location for some reason, so we allow this.
	checkPage: function(newLocation)
	{
        var newHash;
        if (newLocation)
        {
            newHash = '#' + newLocation.split( '#' ).last().split("'").first()
        }
        /* This was causing unwanted scrolling on pages embedding mobile character
        else if (navigator.userAgent.indexOf('Opera') == -1) 
        {
		    if ( location.hash == '' )
		    {	
                document.location = location + '#' + jPintNav.getPages()[0].id;
		    }
		    else if ( location.hash == '#' )
		    {	
                document.location = location + jPintNav.getPages()[0].id;
		    }
            newHash = location.hash;
        }
        */
        else // Don't set document.location on Opera mini because it does strange things.
        {
            newHash = '#' + jPintNav.getPages()[0].id;
        }

	    if ( newHash != jPintNav.currentHash )
	    {   jPintNav.currentHash = newHash;

            // Find the links that activated this location and make them show a spinner.
            var hashNoMark = jPintNav.currentHash.substr( 1 );
            activeLinks = $$( 'a' ).findAll( function(l) 
            {	return l.href.split( '#' ).last().split("'").first() == hashNoMark;
            } );
            activeLinks.invoke( 'addClassName', 'Loading' );

			// Are they using the #tag@url convention to dynamically load?
			var atIndex = jPintNav.currentHash.indexOf( '@' );
			if ( atIndex != -1 )
			{	var pageId = jPintNav.currentHash.substr( jPintNav.hashPrefix.length, atIndex - 1 );
				var loadUrl = jPintNav.currentHash.substr( atIndex + 1 );

				new Ajax.Request( loadUrl,
				{	method: 'get',
					onSuccess: function( theResponse )
					{	//alert( theResponse.responseText );

						// Make a temporary div just so we can use it to "eval" the HTML.
						var tempDiv = $( document.createElement( 'div' ) );
						tempDiv.update(theResponse.responseText);
						var childDivs = tempDiv.childElements();
						var newDiv = childDivs.first();
						newDiv.id = pageId;

						// Add the new div(s) then update the location so that checkPage()
						// will move us to it.
                        var pageSet = jPintNav.getPageSet();
                        for (var i=0; i<childDivs.length; i++)
                        {   pageSet.appendChild(childDivs[i]);
                        }

						jPintLayout.initLayout();
						jPintNav.initNav();
						jPintEdit.initEdit();
						location.replace( location.pathname + '#' + pageId );

                        activeLinks.invoke( 'removeClassName', 'Loading' );
                        jPintNav.checkPage();

						// Also, make the links no longer be loading, and change their
						// URLs so that they point to the new div.
						activeLinks.invoke( 'writeAttribute', 'href', '#' + pageId );
					}
				} );
			}

			// If not, we can show the page immediately.
			else
			{
				// Is there a page by that id?  If not, use page 1 and its id.
	        	var pageId = jPintNav.currentHash.substr(jPintNav.hashPrefix.length) || jPintNav.getPages()[0].id;
	        	var page = $(pageId) || jPintNav.getPages()[0];
				var pageId = page.id;
			
                // Display the new page, and give it time to do so before clearing out Loading states.
				jPintNav.showPage( page );
                setTimeout( function() { activeLinks.invoke( 'removeClassName', 'Loading' ); }, 1000);
			}

	    }
	},
	// Get a list of all the divs with class jPintPage.  These act as pages.
	getPages: function() { return document.getElementsByClassName( 'jPintPage' ); },
	getPageSet: function() { return document.getElementsByClassName( 'jPintPageSet' )[0]; },
	getActivePage: function() { return document.getElementsByClassName( 'jPintPageActive' )[0]; },

	// Display a certain jPintPage, animating our way to it if necessary.
	showPage: function( pageDiv )
	{	
		// Figure out the from->to pages, and store off the new page.
		var toPage = $( pageDiv );

		var fromPage = jPintNav.currentPage;
		jPintNav.currentPage = toPage;

		// Make the "to" page the only visible one, and animate to it if there's a "from" page.
		if ( fromPage ) 
		{
            jPintNav.fromPage = fromPage;
            jPintNav.toPage = toPage;
            if (jPintNav.useAnimation)
            {   setTimeout( jPintNav.swipePage, 0 );
            }
            else
            {   
                jPintNav.updateHistory(fromPage, toPage);
                fromPage.hide();
                toPage.show();
			    toPage.style.left = '0%'; // WTF???
            }
		}
		else
		{
            toPage.show();
			toPage.style.left = '0%';
		}
	},

	swipePage: function()
	{   //alert('SWIPE');
		var fromPage = jPintNav.fromPage;
		var toPage = jPintNav.toPage;
        backwards = jPintNav.updateHistory(fromPage, toPage);

		toPage.style.position = fromPage.style.position = 'absolute';

    	toPage.style.left = ( backwards ? "-100%" : "100%");
		//fromPage.up().up().scrollTop = 1;

		fromPage.style.display = 'block';
		toPage.style.display = 'block';
    	
    	var percent = 100;
    	var timer = setInterval(function()
    	{
        	percent += jPintNav.animateX;
        	if (percent <= 0)
        	{
            	percent = 0;
            	clearInterval(timer);
				jPintNav.hideURLBar();
				fromPage.style.display = 'none';
				toPage.style.position = fromPage.style.position = 'relative';
        	}
	
        	fromPage.style.left = (backwards ? (100-percent) : (percent-100)) + "%"; 
        	toPage.style.left = (backwards ? -percent : percent) + "%"; 
    	}, jPintNav.animateInterval );
	},

    updateHistory: function(fromPage, toPage)
    {
		// Figure out backwards by seeing if the div we're headed to has a
		// link into this one.
		var backwards = 
			toPage.getElementsBySelector( 'a' ).findAll( function( a ) 
			{	//alert( a.href.split( '#' ).last() );
				return ( a.href.split( '#' ).last().split("'").first() == fromPage.id );
                // The above parses "javascript:document.location = '#xxx'" into xxx
			} ).length;

		// We can update our page history now that we know which way we're going.
		if ( backwards ) 
		{
			var index = jPintNav.pageHistory.indexOf( toPage.id );
			jPintNav.pageHistory.splice(index, jPintNav.pageHistory.length);
		}
		jPintNav.pageHistory.push( toPage.id );

        return backwards;
    },

	// Hide the URL bar if we're on iPhone.
	hideURLBar: function() 
	{
		if (navigator.userAgent.indexOf('iPhone') != -1) 
		{	setTimeout( function() { window.scrollTo( 0, 1 ); }, 0); 
		}
	}

};

/* Knows how to fix display discrepancies and fancy things up */
var jPintLayout =
{
	// This will initialize the page layout.  It is safe to call multiple times,
	// for instance you may call it again after dynamically loading more content.
	initLayout: function()
	{	
		// Round off the icons in our IconMenu pages.
		jPintLayout.roundIconMenus();

		// Make our calendars work.
		jPintLayout.activateCalendars();

		// Make all our button hrefs use sliding doors.
		jPintLayout.makeSlidingDoors();
	},

	makeSlidingDoors: function()
	{	//console.log( 'makeSlidingDoors' );
		var allButtons = [ $A( document.getElementsByClassName( 'LeftButton' ) ), $A( document.getElementsByClassName( 'RightButton' ) ), $A( document.getElementsByClassName( 'BackButton' ) ) ].flatten();
		allButtons.findAll( function(tb)
		{	return (! tb.hasClassName( 'SlidingDoored' ) );
		} ).invoke( 'makeSlidingDoor' );
		//console.log( 'madeSlidingDoors' );
	},

	makeSlidingDoor: function( thisButton, doorClass )
	{	//console.log( 'makeSlidingDoor' );

		doorClass = doorClass ? doorClass : thisButton.readAttribute( 'class' ).split()[0];

		// Remove the button from its parent but hold onto it.
		//console.log( thisButton );
		var buttonHolder = $(thisButton.parentNode);
		buttonHolder.removeChild( thisButton );

		// Build elements of a wrapper hierarchy.
		var slidingBackSpan = $( document.createElement( 'span' ) );
		slidingBackSpan.className = 'SlidingBackWrapper SlidingDoored ' + doorClass;
		var slidingBackDiv = $( document.createElement( 'div' ) );
		slidingBackDiv.className = doorClass + ' SlidingDoored';
        slidingBackDiv.setStyle({width:'50px'});
        if (doorClass == 'RightButton')
            slidingBackDiv.setStyle({right:'30px'});

		// Attach our button class, and possibly the addon classes, to each of the divs in the hierarchy.
		if ( thisButton.hasClassName( 'ActiveButton' ) )
		{	
			slidingBackSpan.className = slidingBackSpan.className + ' ActiveButton';
			slidingBackDiv.className = slidingBackSpan.className + ' ActiveButton';
		}

		slidingBackSpan.appendChild( thisButton );
		slidingBackDiv.appendChild( slidingBackSpan );
		//buttonHolder.appendChild( slidingBackDiv );
        buttonHolder.insert( {top:slidingBackDiv} );

		thisButton.addClassName( 'SlidingDoored' );
	},

	activateCalendars: function()
	{
		var allCalendars = $A( document.getElementsByClassName( 'iPhoneCal' ) );
		if (! allCalendars.length ) return;

		var newCalendars = allCalendars.findAll( function(ipc) { return (! ipc.isCalendared); } );
		if (! newCalendars.length ) return;

		newCalendars.each( function( thisCalDiv )
		{
			theCalendar = new scal( thisCalDiv.id, 'showDate', { dayheadlength: 3 } );
			theCalendar.showCalendar();
			thisCalDiv.isCalendared = 1;
		} );
	},

	roundIconMenus: function()
	{
		$A( document.getElementsByClassName( 'IconMenu' ) ).findAll( function(im) { return (! im.isRounded) } ).each( function( thisMenu )
		{
			thisMenu.getElementsBySelector( 'ul li a img' ).each( function( thisImage )
			{	
				var imageRounder = $( document.createElement( 'div' ) );
				imageRounder.className = 'ImageRounder';
				var imageLabel = $(document.createElement( 'div' ) );
				imageLabel.className = 'IconItemText';
				imageLabel.appendChild( document.createTextNode( thisImage.title ) );
	
				thisImage.parentNode.appendChild( imageRounder );
				thisImage.parentNode.appendChild( imageLabel );
			} );
			thisMenu.isRounded = 1;
		} );
	}

};

/* Knows how to magically make list items sortable, deletable, etc... */
var jPintEdit = 
{	
	// This is safe to call multiple times, for instance if you've dynamically loaded more content.
	initEdit: function()
	{	
		// Make a copy of each link, disable the copy, then set it up so that they
		// swap visibility in/out of edit mode.
		$A( document.getElementsByClassName( 'EditModeOff' ) ).findAll( function(a) 
		{	return (! a.isDisabledCloned ); 
		} ).each( function( thisPage )
		{	thisPage.getElementsBySelector( 'li a' ).invoke( 'makeDisabledClone' );
			thisPage.isDisabledCloned = 1;
		} );

		// Dolly up our sortable list items with extra elements.
		$A( document.getElementsByClassName( 'SortableItems' ) ).findAll( function(si)
		{	return (! si.isSortabled );
		} ).each( function( sortableList )
		{	sortableList.getElementsBySelector( 'li' ).invoke( 'makeSortable' );
			sortableList.isSortabled = 1;
		} );

		// Similarly for deletables.
		$A( document.getElementsByClassName( 'DeletableItems' ) ).findAll( function(si)
		{	return (! si.isDeletabled );
		} ).each( function( deletableList )
		{	deletableList.getElementsBySelector( 'li' ).invoke( 'makeDeletable' );
			deletableList.isDeletabled = 1;
		} );

	},

	toggleEditMode: function( theNode, options )
	{	var thePage = theNode.getPhonePage();

		// Assign onSort and onDelete to the page.
		options = Object.extend( { onSort: null, onDelete: null }, options );
		Object.extend( thePage, options )

		// If the user was in the middle of confirming an item deletion, bail that out.
		if ( thePage.deletingListItem ) thePage.deletingListItem.removeClassName( 'DeleteConfirm' );
		thePage.toggleClassName( 'EditModeOn' ).toggleClassName( 'EditModeOff' );

		return jPintEdit;
	}
};

var jPint = 
{	
	init: function()
	{
		//console.profile();
		jPintLayout.initLayout();
		jPintNav.initNav();
		jPintEdit.initEdit();
		//console.profileEnd();
	}
};


/* INITIALIZATION */

Event.observe( document, 'dom:loaded', function()
{	jPint.init();
} );
