# INTRODUCTION

This document is intended for developers new to the iPlay4e codebase.
It should be sufficient to get your local copy of iPlay4e up and running,
with enough knowledge of the codebase to fix bugs and implement features.

Please report any missing information or implementation issues to the
author (andrew.reutter@gmail.com) so the document can be updated accordingly,
or better yet, submit document updates via a pull request.

If you don't intend to read the entire document, or are simply curious,
you might skip ahead to the POINTS OF INTEREST.

# WHAT IS IPLAY4E?

iPlay4e is a supplemental web service for subscribers to DND Insider (DDi), 
a suite of online tools for players of 4th edition Dungeons & Dragons.  
Both D&D and DDi are published by Wizards of the Coast (WotC).

iPlay4e's core features:

- Converts character files generated using the DDi Character Builder into interactive, digital character sheets accessible from any device, from your smart phone to your tablet to your desktop.
- Provides an online, searchable, community-generated database of characters.
- Groups user (players) and characters into campaigns, allowing the players and campaign owners to view (and sometimes edit) the other characters in the campaign.
- An open API and lots of third-party tools that integrate directly with iPlay4e.

# HELLO IPLAY4E

- Extract iPlay4e.zip to a location on your system from which you wish to work. Note the location of the iplay4e directory which is created.
- Download, install, and run the Google App Engine SDK for Python.
- In GAE, use "File -> New Application" to add the iplay4e directory as an application named iplay4e.
- Browse to http://localhost:9090 (assuming you accepted the default port when adding the application to GAE).
- It is suggested you have Firebug or equivalent browser-based debugging tools installed.

# CODE TREE REFERENCE

- BUILTsrc: the output of the build process.
- IP4ELibs: libraries in support of the request handlers.
  - BaseHandler.py: defines the base class for all request handlers
  - DDI.py: experimental client to WotC's suite of web-based tools.
  - IP4XML.py: XML parsing and generation classes:
    - Parsing WotC's dnd4e pseudo-XML format into iplay4e character instances.
    - Representing iplay4e character and campaign instances as XML.
  - ModelTypes: mixin classes for GAE's db.model
    - AuthorizedModels.py: mixin class that authorizes operations performed on a model
    - CombatStateModels.py: mixin class that stores transitory state separate from the base model
    - IP4XMLModels.py: mixin class for models with XML representations
    - SearchModels.py: mixin class for searchable models
  - models.py: data model definition that utilizes GAE's storage APIs.
- app.yaml: application definition file for Google App Engine.
- ewgappengine: a suite of libraries to support development under GAE (mostly unused).
- handlecgi.py: maps dynamic URL requests to request handler classes.
- makepc.py: the build script.
- search: third-party keyword search libraries wrapped by IP4ELibs.
- index.yaml: index definition file for GAE; automatically maintained.
- settings.py: settings file for GAE.
- src: all non-library source code for iPlay4e.
  - css: style sheets
  - handlers: web request handler classes
  - html: HTML that is "static" but requires cache invalidation on build
  - images: image files
  - js: javascript files
  - xml: static xml files
  - xsl: xsl files
- yuicompressor-2.4.2.jar: static file minification java application used by the build.

# POINTS OF INTEREST

- Service-based design: iPlay4e is written from the ground up to expose its core functions
  as web services.  The iPlay4e web application can be considered the principal client
  of the iPlay4e API, which is documented at:

      https://sites.google.com/site/iplay4eapi/

  This approach has enabled rapid partnership with other service providers; there are
  now many pieces of software that feature direct integration with iPlay4e.  At the
  same time, the approach encourages minimalist and clean coding.

- Device agnostic: iPlay4e uses XSL appropriate to the client to transform XML
  data representations into HTML.  There are two XSL implementations for each object:

    - A "full screen" interface optimized for tablets and desktop browsers.
    - A "mobile" interface for use on small devices.
  
  In most cases, the client performs the transformations, but for clients without XSL
  support, the xslorcist web service is used to do transformations server-side because
  GAE lacks server-side XSL support.

  The use of XSL in the presentation stack guarantees isolation of those routines
  that retrieve authorized data, eliminates ugly HTML generation code, and
  encapsulates the presentation layers for mobile and full-sized devices.

  See:

  - src/xsl (jPint is for mobile devices)
  - IP4ELibs/BaseHandler.py

- Aggressive caching: iPlay4e uses caching strategically to maximize performance
  while minimizing consumption of scarcer resources.  In GAE, disk is cheap but
  processor is expensive.  Lengthy operations are cancelled by the execution
  environment, which (fortunately) forces the developer to design for execution speed.

  Specific caching strategies in use in iPlay4e include:

  - Caching in storage of the XML representation of each object.  The XML cache
    for a given object is invalidated only when the source data is updated; this
    ensures the expensive source parsing routines are executed only at need.  The
    XML cache for all models of a given class can be invalidated by incrementing
    the class' XML_VERSION variable; this allows changes to the XML parsing or
    generation code to interact seamlessly with the XML caching strategy.  See:

    - IP4ELibs/ModelTypes/IP4XMLModels.py
    - IP4ELibs/models.py

  - Indefinite browser caching of static files.  Almost all content that is static
    from model to model (e.g. css, js, xsl) is cached indefinitely by the client.
    However, references to these objects are specially encoded in the source code
    such that every time the build script is executed, fresh URIs are generated.
    This ensures that the browser will cache as aggressively as possible, but that
    changes to the files are pulled down at need, without the need to check for
    changes to the files while processing the request.  See:

    - makepc.py
    - app.yaml
    - files in the src directory containing the string "TIME_TOKEN"

# BUILD ENVIRONMENT

Building iPlay4e is only necessary if you make changes to the contents of
app.yaml, the src directory, or the ewgappengine directory.  

To build iPlay4e, execute the makepc.py script in the iplay4e directory.

The BUILTsrc directory is overwritten every time iPlay4e is built by
applying translations to the contents of the src directory and app.yaml.  
Most prominently, the TIME_TOKEN string is replaced with a timestamp,
which ensures that "static" files (those the browser has been instructed
to retain indefinitely, such as js and xsl) are now referred to by fresh URIs.
This maximizes browser caching while minimizing maintenance.

The build system also performs source file combining and minification routines.
While debugging (especially javascript), it is sometimes useful to disable the 
minification routines, which can be accomplished by executing "makepc.py 0".

# EXECUTION STACK

A typical request made of iPlay4e running under GAE runs as follows:

- GAE uses app.yaml to map the URL to a handler.  For most "static" files, 
  this is a direct mapping to a file in the BUILTsrc directory which is
  served up immediately, thus completing the request.

- Requests requiring dynamic responses ("CGI" requests) are passed through
  to handlecgi.py, which maps the URL to a handler class.

- Handler classes are defined in the src/handlers directory; each python
  file contains one or more handler classes.  The appropriate handler class'
  get() method is invoked.

- Handler get() methods utilize the libraries found in the IP4ELibs directory; 
  in fact, each handler class is a subclass of IP4ELibs.BaseHandler.BaseHandler,
  which contributes by:
      
  - Regularizing the GET/POST API to allow subclasses to implement a
    single get() method that processes all requests.

  - Providing or abstracting information about the request that is not 
    available in GAE's base webapp.RequestHandler.request object, such
    as mobile device and XSL support detection.

  - Defining additional operations useful when a handler composes its
    reponse, such as:
          
    - Retrieval of data appropriate to the user's authorization.
    - Streaming XML with or without XSL appropriate to the user's device.
    - Targeted redirection and reload within the browser's frame stack.
    - Success/error routines for various formats like JS and JSON.

- The handler's get() method writes to self.response.out, or utilizes one
  of the utility methods defined by IP4ELibs.BaseHandler.BaseHandler.

- The browser processes the response.  The most common yet complex response
  stack contains:
      
  - XML as generated by the handler (src/handlers) or static file (src/xml).
  - XSL (src/xsl) as referenced by the XML.
  - XHTML produced by the browser's XSL transformation engine, referencing:
    - CSS (src/css)
    - JavaScript (src/js)
    - GIF and PNG images (src/images)

  Other response types include javascript, JSON, and static html.
