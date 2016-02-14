/*	**************************************************
	Overview
	**************************************************

	The new $$$ function expands upon the builtin prototype.js $$ function.
	It adds the ability to prepend the @ symbol to any phrase in the
	selector string to limit the return values to immediaate children
	of the preceeding phrase.  That is: "#foo ul" gets you all <ul> elements
	found under the element with ID foo, but "#foo @ul" will only return
	<ul> elements that are immediate children of the foo element.

	The original Effect.toggle was limited in that it could only toggle
	between two effects if one of those effects resulted in the element
	being invisible.

	metaculous.js aims to fix all those problems.  It provides a
	replacement for Effect.toggle that operates on more effects,
	including those that never render the element invisible.  The
	added effects include:

		- grow/shrink from the base scriptaculous effects.

		- effects from the scriptaculous Effects Treasure Chest,
		  included as treasurechest.js.

		- brand new effects such as SetStyle and AddClassName.

	For a complete list, see Effect.PAIRS_AND_TESTERS in the code.

	And beyond simple toggling we introduce the ToggleSet, an object
	which allows complex relationships between multiple widgets to
	be easily created.  With the ToggleSet these all become easy:

		- tabbers: horizontal or vertical
		- accordions: horizontal or vertical

	See the ToggleSet docs below for complete information.
*/

/*	**************************************************
	New $$$ function
	**************************************************
*/

function $$$() {
	return $A(arguments).map(function(expression) 
	{	return expression.strip().split(/\s+/).inject([null], function(results, expr) 
		{	var isAt = 0;
			if ( expr.substring( 0, 1 ) == '@' )
			{	isAt = 1;
				expr = expr.substring( 1, expr.length )
			}
			var selector = new Selector(expr);
			return results.map( function(r) 
			{	return selector.findElements.bind(selector)(r).findAll( function( el )
				{	//alert( isAt + '|' + r + '|' + el );
					//if ( r ) alert( r.tagName + '|' + r.childNodes.length + '|' + $A( r.childNodes ).indexOf( el ) );
					return ( !isAt || r == null || el.parentNode == r );
				} );
			} ).flatten();
		} );
	} ).flatten();
}

/*	**************************************************
	New Effect.toggle
	**************************************************
*/

// These are like Effect.PAIRS, but provide a function for testing whether
// an element is in its "toggled" state.
Effect.PAIRS_AND_TESTERS = 
	{
	// scriptaculous
    'slide':      ['SlideDown',          'SlideUp',             function(e) { return e.visible() }    ],
    'blind':      ['BlindDown',          'BlindUp',             function(e) { return e.visible() }    ],
    'appear':     ['Appear',             'Fade',                function(e) { return e.visible() }    ],
    'grow':       ['Grow',               'Shrink',              function(e) { return e.visible() }    ],

	// new
    'slideright':   
		['SlideRightIntoView', 'SlideRightOutOfView', function(e, o) { return e.visible() }    ],
    'phase':   
		['PhaseIn',            'PhaseOut',            function(e, o) { return e.visible() }    ],
	'addclassname': 
		['AddClassName',       'RemoveClassName',     function(e, o) { return e.hasClassName(o.className) } ],
	'setstyle': 
		['SetStyle',           'UnsetStyle',          function(e, o) { return e.stylesForUnsetting } ],
	'moveto':       
		['MoveTo',             'ReturnMove',          function(e, o) { return e.isMoved }      ],
	'center':       
		['Center',             'ReturnMove',          function(e, o) { return e.isMoved }      ],
	'dialog':       
		['StartDialog',        'EndDialog',           function(e, o) { return e.isDialogging } ],
	'growto':
		['GrowTo',             'ShrinkBack',          function(e, o) { return e.isGrown } ]
	};

Effect.toggle = function( element, effect, options )
{
    effect = (effect || 'appear').toLowerCase();
    element = $(element);
    options = Object.extend({
      queue: { position:'end', scope:(element.identify() || 'global'), limit: 1 }
    }, options || {});

	if ( Effect.PAIRS_AND_TESTERS[effect][2]( element, options ) )
		new Effect[Effect.PAIRS_AND_TESTERS[effect][1]]( element, options );
	else
		new Effect[Effect.PAIRS_AND_TESTERS[effect][0]]( element, options );
};


/*	**************************************************
	ToggleSet
	**************************************************

	A ToggleSet is an object that ties together other sets of objects, and
	ties together the state of of those sets so that one element from each
	set is active at any given time.  This is easiest to understand in terms
	of examples.  A tabbed interface consists of the following sets of objects:

		- A set of pages, only one of which is displayed at a time.

		- A set of clickable tabs for changing those pages, with the
		  active one highlighted or otherwise visually differentiated.
		  There are usually the same number of tabs as there are pages.

	This is not limited to tab navigation; an accordion is really a similar
	linking of different sets of elements.  They vary only in the positioning
	of elements and the effects used to transition between them.

	The API is straightforward:

		- Instantiate a ToggleSet

		- XXX
*/

Effect.ToggleSet = Class.create();
Object.extend(Effect.ToggleSet.prototype, {
  initialize: function( options )
  {
	options = Object.extend( 
		{	
			// Arrays of objects.
			displayArrays: [],       // pass in as you like, in batches of 3
			                         // as per the addDisplayArray method
			activationArrays: [],    // pass in as you like, in batches of 3
			                         // as per the addActivationArray method.
			functionArrays: [],      // pass in as you like, in batches of 2
			                         // as per the addFunctionArray method.
			hoverFunctionArrays: [], // pass in as you like, in batches of 2
			                         // as per the addHoverFunctionArray method.
			clickFunctionArrays: [], // pass in as you like, in batches of 2
			                         // as per the addHoverFunctionArray method.
			hideAllArrays: [],

			// Initialization stuff.
			initialToggle: -1,       // initially toggled index.
			beforeInit: null,        // function to call before initializing 
			                         //   (with this instance as the sole argument)
			afterInit: null,         // function to call after initializing
			                         //   (with this instance as the sole argument)

			allowClosed: 0,          // should it be possible to "close" all display elements?
			allowMultiple: 0,        // can multiple display elements be toggle at once?
			persistAs: '',           // if provided, is a unique ID for storing the toggle
			                         // state in user cookies, so it will be "sticky"
			debugMode: 0,            // set to 1 for some debugging alerts.
			toggleEvent: 'onclick'   // set to "onmouseover" to make toggling happen on hover, e.g.
		}, options || {} );
	this.options = options;

	if ( options.debugMode )
		alert( 'Building ToggleSet ' + options.persistAs );

	// Store off config options.
	this.allowClosed = options.allowClosed;
	this.allowMultiple = options.allowMultiple;
	this.persistAs = options.persistAs;

	// Suck in any provided activation and display arrays.
	this.displayArrays = [];
	this.activationArrays = [];
	this.functionArrays = [];
	this.hoverFunctionArrays = [];
	this.clickFunctionArrays = [];
	for ( i=0; i<options.displayArrays.length; i += 3 )
		this.addDisplayArray( 
			options.displayArrays[i], options.displayArrays[i+1], options.displayArrays[i+2] );
	for ( i=0; i<options.hoverFunctionArrays.length; i += 2 )
		this.addHoverFunctionArray( options.hoverFunctionArrays[i], options.hoverFunctionArrays[i+1] )
	for ( i=0; i<options.clickFunctionArrays.length; i += 2 )
		this.addClickFunctionArray( options.clickFunctionArrays[i], options.clickFunctionArrays[i+1] )
	for ( i=0; i<options.activationArrays.length; i += 3 )
		this.addActivationArray( 
			options.activationArrays[i], options.activationArrays[i+1], options.activationArrays[i+2] );
	for ( i=0; i<options.functionArrays.length; i += 2 )
		this.addFunctionArray( options.functionArrays[i], options.functionArrays[i+1] );
	for ( i=0; i<options.hideAllArrays.length; i += 1 )
		this.addHideAllArray( options.hideAllArrays[i] );

	if ( options.beforeInit ) options.beforeInit( this );
	if ( options.initialToggle != -1 || options.persistAs ) 
    {   //alert(options.initialToggle);
		this.toggle( options.initialToggle, 1 );
    }
	if ( options.afterInit ) options.afterInit( this );

	if ( options.debugMode )
		alert( 'Built ToggleSet ' + options.persistAs );
  },

  // Cause a set of elements to be display elements using a given effect.
  //	elements: an array of elements, or a string to pass to $$$ to get one.
  //	effect: an effect key from PAIRS_AND_TESTERS
  //	options: options for the effect.  May also optionally include a "reverseToggle"
  //		key which will cause the behavior to be opposite normal (that is,
  //		one element will be hidden instead of one visible).
  //		May instead be an array of option sets, if the options need to vary
  //		based on which element is being displayed.
  addDisplayArray: function( elements, effect, options )
  {
	if ( !options ) 
	{	alert( 'aborting because no options found in ' + $A(arguments).inspect() );
		return;
	}
	if ( typeof( elements ) == typeof( '' ) ) elements = $$$(elements);
	this.displayArrays[this.displayArrays.length] = 
		[	$A( elements ).collect( function( element ) { return $(element) } ),
			(effect || 'appear').toLowerCase(),
			options
		];
  },

  // Cause a function to get called when our activators are clicked.
  //	theFunction: a function that takes (element,index,options) as arguments.
  //	options: that should be passed to theFunction.
  addFunctionArray: function( theFunction, options )
  {	this.functionArrays[this.functionArrays.length] = [ theFunction, options ];
  },

  // Cause a function to get called when our activators are hovered over.
  //	theFunction: a function that takes (element,index,options) as arguments.
  //	options: that should be passed to theFunction.
  addHoverFunctionArray: function( theFunction, options )
  {	this.hoverFunctionArrays[this.hoverFunctionArrays.length] = [ theFunction, options ];
  },

  // Cause a function to get called when our activators are clicked on.
  // This is only useful if you have set toggleEvent to something besides onlick.
  //	theFunction: a function that takes (element,index,options) as arguments.
  //	options: that should be passed to theFunction.
  addClickFunctionArray: function( theFunction, options )
  {	this.clickFunctionArrays[this.clickFunctionArrays.length] = [ theFunction, options ];
  },

  // Hook a bunch of elements up for hiding all.
  addHideAllArray: function( elements )
  {
	if ( typeof( elements ) == typeof( '' ) ) elements = $$$(elements);
	var exclusiveSet = this;
  	elements.each(
		function( element, index )
		{	
			element.exclusiveSets = element.exclusiveSets || [];
			element.exclusiveSets[element.exclusiveSets.length] = exclusiveSet;
			element.style.cursor = 'pointer';
			element[exclusiveSet.options.toggleEvent] = function() 
			{	
				this.exclusiveSets.each( 
					function( es, i ) { es.toggle( -1 );} 
				);
			};
		}
	);
  },
  // Add another set of elements as togglers of the displayed ones.
  // 	elements: specification string or array of elements
  //	effect: optionally set an effect pair for onMouseOver/onMouseOut
  //	options: for effect, if provided.
  addActivationArray: function( elements, effect, options )
  {
	if ( typeof( elements ) == typeof( '' ) ) 
	{	var realElements = $$$(elements);
		if ( !realElements.length ) 
			alert( 'no activation elements found for "' + elements + '"');
		elements = realElements;
	}
	var exclusiveSet = this;
  	elements.each(
		function( element, index )
		{	
			element.exclusiveIndexes = element.exclusiveIndexes || [];
			element.exclusiveIndexes[element.exclusiveIndexes.length] = index;
			element.exclusiveSets = element.exclusiveSets || [];
			element.exclusiveSets[element.exclusiveSets.length] = exclusiveSet;
			element.onMouseOverEffect = effect;
			element.onMouseOverOptions = options;
			element.style.cursor = 'pointer';
			element[exclusiveSet.options.toggleEvent] = function() 
			{	
				var theseIndexes = this.exclusiveIndexes;
				this.exclusiveSets.each( 
					function( es, i ) { es.toggle( theseIndexes[i], 0, this ); } 
				);
			};
			if ( exclusiveSet.options.toggleEvent != 'onclick' )
			{
				element.onclick = function() 
				{	
					var theseIndexes = this.exclusiveIndexes;
					this.exclusiveSets.each( 
						function( es, i )
						{	es.clickFunctionArrays.each( function( clickFunctionArray, hfai )
							{	//alert( clickFunctionArray, hfai );
								clickFunctionArray[0]( this, theseIndexes[i], clickFunctionArray[1] );
							} );
						}
					);
				};
			};
			if ( exclusiveSet.options.toggleEvent != 'onmouseover' )
			{
				element.onmouseover = function() 
				{	
					if ( this.onMouseOverEffect )
						Effect[Effect.PAIRS_AND_TESTERS[this.onMouseOverEffect][0]]( this, 
							this.onMouseOverOptions );
					var theseIndexes = this.exclusiveIndexes;
					this.exclusiveSets.each( 
						function( es, i )
						{	es.hoverFunctionArrays.each( function( hoverFunctionArray, hfai )
							{	hoverFunctionArray[0]( this, theseIndexes[i], hoverFunctionArray[1] );
							} );
						}
					);
				};
				element.onmouseout = function() 
				{	
					if ( this.onMouseOverEffect )
					Effect[Effect.PAIRS_AND_TESTERS[this.onMouseOverEffect][1]]( this, 
						this.onMouseOverOptions );
				};
			}
		}
	);
  },
  destroy: function()
  { this.isDestroyed = 1;
  },
  // This is called whenever an activation array element is clicked on (such
  // as the tabs on a tabber).  The index is where that element comes in its set.
  toggle: function( index, initializing, element ) 
  {
    if (this.isDestroyed) return;

	// Create a structure carrying the desired state of each index in each array:
	// 		1=on, 0=off, -1=leave, -2=toggle
    // There will be an element in each set that was clicked, the rest
	// will get a default value (0/off, unless "allowMultiple" is on in
	// which case we use -1 for "don't touch").
	defaultValue = ( this.allowMultiple && !initializing ) ? -1 : 0
	var desiredStates = [];
	if ( this.displayArrays.length )
		this.displayArrays[0][0].each( function() 
			{	desiredStates[desiredStates.length] = defaultValue;
			} );

	// Behave specially on initialization.
	if ( initializing )
	{	
		// And extra-specially if we are persistent.
		if ( this.persistAs )
		{
			// See if we can find a cookie by our "persistAs" name.
			var cookieString = '' + document.cookie;
			var index1 = cookieString.indexOf( this.persistAs );
			if ( index1!=-1 )
			{
				// Yep.  Grab its value.
				var index2 = cookieString.indexOf( ';', index1 );
				index2 = ( index2 == -1 ? cookieString.length : index2 );
				var persistedState = 
					cookieString.substring( index1 + this.persistAs.length + 1, index2 );
				persistedState = eval( unescape( persistedState ) );
	
				// If we find an int, it's our index (backwards-compatible).
				// New-style is to store the full toggle state set.
				// If we find a valid (int) value, use it for our index.
				if ( typeof( persistedState ) == typeof( 0 ) )
					desiredStates[index] = persistedState;
				else if ( typeof( persistedState ) == typeof( [] ) )
					$A( persistedState ).each( function( persistValue, persistIndex )
					{	desiredStates[persistIndex] = persistValue;
					} );
				else desiredStates[index] = 1;
			}

			// If the cookie is not found or we're not persistent, just flip it on.
			else desiredStates[index] = 1;
		}
		else desiredStates[index] = 1;
	}

	// If we are not initalizing, then ensure the visibility of the element,
	// unless multiple or closed is allowed, in which case we flip it.
	else desiredStates[index] = ( this.allowMultiple || this.allowClosed ? -2 : 1 )
	
	// Put each display array into the desired set of toggled states
	// and store that new state.
	var newStates = [];
	this.displayArrays.each(
		function( displayArray, arrayIndex )
		{	displayArray[0].each(
				function( oneElement, elementIndex )
				{	
					// Get the desired state, effect pair, and state tester.
					var pairAndTester = Effect.PAIRS_AND_TESTERS[displayArray[1]];
					var onEffect = Effect[pairAndTester[0]];
					var offEffect = Effect[pairAndTester[1]];

					// The options may be the same, or may vary for each element.
					var theseOptions = displayArray[2];
					if ( theseOptions && theseOptions.each )
					{
						theseOptions = theseOptions[elementIndex];
					}
					var isOn = pairAndTester[2]( oneElement, theseOptions );

					// The base desired state might be flipped if the options say so.
					// If desired state is relative, base it on current state.
					try
					{
						var desiredState = desiredStates[elementIndex];
						desiredState = 
							( desiredState >= 0 && theseOptions.reverseToggle ) 
							? ( desiredState ? 0 : 1 ) : desiredState;
						desiredState = ( desiredState == -2 ) ? ( isOn ? 0 : 1 ) : desiredState;
						desiredState = ( desiredState == -1 ) ? isOn : desiredState;
					} catch(e) { alert( e + ' | ' + displayArray.inspect() ); }

					// Put into the desired state if not already.
					if ( desiredState == 1 && !isOn )
							new onEffect( oneElement, Object.extend( {}, theseOptions ) );
					else if ( desiredState == 0 && isOn )
							new offEffect( oneElement, Object.extend( {}, theseOptions ) );

					// When going through the first array, store the new state.
					if ( !arrayIndex )
						newStates[elementIndex] = desiredState;
				}
			);
		}
	);

	// Also execute any functions we are supposed to (except when initializing).
	if ( !initializing )
		this.functionArrays.each( function( functionAndOptions, faIndex )
		{	
			functionAndOptions[0]( element, index, functionAndOptions[1] );
		} );

	// If we are persistent and were clicked, save our new states.
	if ( this.persistAs && !initializing )
	{
		document.cookie = this.persistAs + "=[" + escape( '' + newStates ) + ']'; 
  	}
  }
});


/*
**************************************************
	3rd Party Effects and other Addons
**************************************************
*/

// Transitions
Effect.Transitions.exponential = function(pos) {  
  return 1-Math.pow(1-pos,2);
}
Effect.Transitions.slowstop = function(pos) {
	return 1-Math.pow(0.5,20*pos);
}

// firstElementChild() method is safe than firstChild attribute.
Element.addMethods(
  {
    firstElementalChild : function(element) 
     {
       element = $(element);
       for(var x=0; x < element.childNodes.length; x++)
         {
           if(element.childNodes[x].nodeType == Node.ELEMENT_NODE)
             {
               return element.childNodes[x];
             }
         }

       return;
     }
  }  
);  // end addMethods

// Phase is an implementation of smooth appearing elements
Effect.PhaseIn = function(element) {
  element = $(element);
  new Effect.BlindDown(element, arguments[1] || {});
  new Effect.Appear(element, arguments[2] || arguments[1] || {});
}
Effect.PhaseOut = function(element) {
  element = $(element);
  new Effect.Fade(element, arguments[1] || {});
  new Effect.BlindUp(element, arguments[2] || arguments[1] || {});
}
Effect.Phase = function(element) {
  element = $(element);
  if (element.style.display == 'none')
    new Effect.PhaseIn(element, arguments[1] || {}, arguments[2] || arguments[1] || {});
  else new Effect.PhaseOut(element, arguments[1] || {}, arguments[2] || arguments[1] || {});
}

// Slide right into view, then back out left
Effect.SlideRightIntoView = function(element) {
  element = $(element);
  var originalWidth = element.getDimensions().width;
  element.style.width = '0px';
  element.style.overflow = 'hidden';
  if ( element.firstElementalChild() ) 
  	element.firstElementalChild().style.position = 'relative';
  Element.show(element);
  new Effect.Scale(element, 100,
    Object.extend(arguments[1] || {}, {
      scaleContent: false,
      scaleY: false,
      scaleMode: 'contents',
      //scaleMode: { originalWidth: originalWidth, originalHeight: 100 },
      scaleFrom: 0,
      afterUpdate: function(effect){}
    })
  );
}
Effect.SlideRightOutOfView = function(element) {
  element = $(element);
  element.style.overflow = 'hidden';
  if ( element.firstElementalChild() ) 
  	element.firstElementalChild().style.position = 'relative';
  Element.show(element);
  onComplete = ( (arguments[1] && arguments[1].afterFinish) ? arguments[1].afterFinish : function() {return;} );
  new Effect.Scale(element, 0,
    Object.extend(arguments[1] || {}, {
      scaleContent: false,
      scaleY: false,
      afterUpdate: function(effect){},
      afterFinish: function(effect)
        { Element.hide(effect.element);onComplete(); }
    })
  );
}

/*	**************************************************
	New Effects
	**************************************************

	These effects include new pairs:

		- MoveTo/ReturnMove
		- Center/ReturnMove
		- AddClassName/RemoveClassName
		- SetStyle/UnsetStyle
		- StartDialog/EndDialog
		- GrowTo/ShrinkBack
*/

// Pass x and y in with the options.
Effect.MoveTo = function( elementId, options )
{
	$(elementId).isMoved = 1;
	reallyMove( elementId, options )
}

// Put an element back after a MoveTo, Center, or other Move operation.
Effect.ReturnMove = function( elementId, options )
{
	var theElement = $(elementId);
	theElement.isMoved = 0;
	reallyMove( theElement, 
		Object.extend( options, 
			{ x: theElement.moveEffect.originalLeft,
			  y: theElement.moveEffect.originalTop } ) )
}

Effect.Center = function( elementId, options ) 
{
	// Use the WindowUtilities to figure out where it should go and do it.
	var windowScroll = WindowUtilities.getWindowScroll();    
	var pageSize = WindowUtilities.getPageSize();    
	top = ( pageSize.windowHeight - Element.getDimensions( elementId ).height ) / 2 + windowScroll.top;
	left = ( pageSize.windowWidth - Element.getDimensions( elementId ).width ) / 2 + windowScroll.left;
	Effect.MoveTo( elementId,
    	Object.extend( options || {}, { x: left, y: top } ) );
}

// Pass new x and y in with options.
reallyMove = function( elementId, options )
{
	//alert( 'reallyMove ' + elementId + ' ' + options.x + ' ' + options.y );
	// If x and y are in the options, pull them out.
	newOptions = {}
	$H(options).each(
		function(o)
		{	if ( o.key != 'x' && o.key != 'y' )
				newOptions[o.key] = o.value;
		} );

	// Move it to that location by comparing to current location.
	var theElement = $(elementId);
	theElement.moveEffect = 
		new Effect.MoveBy( elementId, 
			( options.y || 0 ) - parseFloat(theElement.getStyle('top')  || '0'),
			( options.x || 0 ) - parseFloat(theElement.getStyle('left') || '0'),
			newOptions );
};

// Add or remove a class from an element.  Pass className in the options.
Effect.AddClassName = function( element, options )
{
	$(element).addClassName( options.className );
};
Effect.RemoveClassName = function( element, options )
{
	$(element).removeClassName( options.className );
};

// Change a style attribute and put it back.
// The options are in the same format as Element.setStyle()
Effect.SetStyle = function( element, options )
{
	element = $(element);
	element.stylesForUnsetting = {}
	$H(options).each(
		function(o) { element.stylesForUnsetting[o.key] = element.getStyle( o.key ); } );
	element.setStyle( options );
};
Effect.UnsetStyle = function( element, options )
{
	element = $(element);
	element.setStyle( element.stylesForUnsetting || {} );
	element.stylesForUnsetting = null;
};

// Given a div ID, gray out the rest of the screen.
Effect.StartDialog = function( elementId, options )
{
	WindowUtilities.disableScreen( 'alphacube', 'overlay_modal', null, options );
	Element.setStyle( elementId, {zIndex: Windows.maxZIndex + 10} );
	$(elementId).isDialogging = 1;

	// This for some strange reason makes the element pop out above the overlay.
	// XXX It might not work in all browsers...
	new Effect.MoveBy( elementId, 0, 0 );
}
Effect.EndDialog = function( elementId, options )
{	WindowUtilities.enableScreen();
	$(elementId).isDialogging = 0;
}

// Pass in width and/or height in the options.  
// Only works on elements with fixed width, either percent or px.
Effect.GrowTo = Class.create();
Object.extend( Object.extend( Effect.GrowTo.prototype, Effect.Base.prototype ), {
  initialize: function(element) 
  { this.element = $(element);
    var options = Object.extend( {}, arguments[1] || {} );
    this.start( options );
  },
  setup: function() 
  { 
	this.element.isGrown = 1;
	if ( this.options.width != null )
	{	var originalWidth = this.element.getStyle('width');
    	this.element.originalWidth = parseFloat( originalWidth );
		this.element.widthUnits = 
			originalWidth.substring( originalWidth.length - 2, originalWidth.length ) == 'px'
				? 'px' :
				( originalWidth.substring( originalWidth.length - 1, originalWidth.length ) == '%'
				  ? '%' : '' );
	}
	if ( this.options.height != null )
	{	var originalHeight = this.element.getStyle('height');
	    this.element.originalHeight  = parseFloat( originalHeight );
		this.element.heightUnits = 
			originalHeight.substring( originalHeight.length - 2, originalHeight.length ) == 'px'
				? 'px' :
				( originalHeight.substring( originalHeight.length - 1, originalHeight.length ) == '%'
				  ? '%' : '' );
  	}
  },
  update: function(position) {
  	if ( this.options.width != null )
		this.element.setStyle(
		{	width: this.element.originalWidth 
			       + ( position * ( this.options.width - this.element.originalWidth ) ) 
			       + this.element.widthUnits
		} );
  	if ( this.options.height != null )
		this.element.setStyle(
		{	height: this.element.originalHeight 
			       + ( position * ( this.options.height - this.element.originalHeight ) ) 
			       + this.element.heightUnits
		} );
  }
});

// The inverse of GrowTo.
// width/height are mostly ignored; instead, the original values are used.
// They are used only to determine whether to grow in each dimension.
Effect.ShrinkBack = Class.create();
Object.extend( Object.extend( Effect.ShrinkBack.prototype, Effect.Base.prototype ), {
  initialize: function(element) 
  { this.element = $(element);
    var options = Object.extend( {}, arguments[1] || {} );
    this.start( options );
  },
  setup: function() 
  { this.element.isGrown = 0;
	if ( this.options.width != null )
		this.changedWidth = parseFloat( this.element.getStyle('width') );
	if ( this.options.height != null )
		this.changedHeight = parseFloat( this.element.getStyle('height') );
  },
  update: function(position) 
  {
  	if ( this.options.width != null )
		this.element.setStyle(
		{	width: this.changedWidth 
			       + ( position * ( this.element.originalWidth - this.changedWidth ) ) 
			       + this.element.widthUnits
		} );
  	if ( this.options.height != null )
		this.element.setStyle(
		{	height: this.changedHeight 
			       + ( position * ( this.element.originalHeight - this.changedHeight ) ) 
			       + this.element.heightUnits
		} );
  }
});

/*	**************************************************
	Sample ToggleSets
	**************************************************

	These wrap calls to ToggleSet in order to implement common widgets:

		- Accordion
		- Tabber
*/

Effect.Accordion = function( elementId, titleMatcher, bodyMatcher, options )
{
	options = Object.extend(
		{	activeTabClass: '',
			activeBodyClass: '',
			blindOptions: {},
			initialToggle: -1,
			displayArrays:
				[	'#' + elementId + ' ' + bodyMatcher,  'blind',        
						options.blindOptions || {},
					'#' + elementId + ' ' + titleMatcher, 'addclassname', 
							{className:options.activeTabClass},
					'#' + elementId + ' ' + bodyMatcher,  'addclassname', 
							{className:options.activeBodyClass},
				],
			activationArrays: [ '#' + elementId + ' ' + titleMatcher ]
		}, options || {} );
	new Effect.ToggleSet( options );
};
