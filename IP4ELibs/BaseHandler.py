#!/usr/bin/env python

import StringIO, urllib

import json as simplejson
import wsgiref.handlers
from google.appengine.ext import webapp, db
from google.appengine.api import users, datastore_errors, urlfetch, urlfetch_stub
import urllib, logging

from ModelTypes import AuthorizedModel
import IP4XML, IP4DB

class BaseHandler(webapp.RequestHandler):

    OWNER  = AuthorizedModel.OWNER
    MEMBER = AuthorizedModel.MEMBER
    PUBLIC = AuthorizedModel.PUBLIC
    ADMIN  = AuthorizedModel.ADMIN

    VIEW    = AuthorizedModel.VIEW
    MONITOR = AuthorizedModel.MONITOR
    DELETE  = AuthorizedModel.DELETE
    EDIT    = AuthorizedModel.EDIT

    def main(thisClass, debug=False):
        wsgiref.handlers.CGIHandler().run(webapp.WSGIApplication([('.*', thisClass)], debug=debug))
    main = staticmethod(main)
    
    def post(self):
        return self.get()

    def requestIsMobile(self):
        lowerAgent = self.request.user_agent.lower()
        for mobileStr in ('iphone', 'midp', 'opera mini', 'android', 'pre/1.0'):
            if lowerAgent.find(mobileStr) != -1:
                return True
        return self.request.get('mobile') and True or False

    def requestClientLacksXsl(self):
        """ Some platforms (e.g. Android, Konqueror, and Linux Chrome) lack XSL support.
            Does the current client?
        """

        lowerAgent = self.request.user_agent.lower()
        if lowerAgent.find('android') != -1 \
        or ((lowerAgent.find('chrome') != -1) and (lowerAgent.find('linux') != -1)) \
        or ((lowerAgent.find('safari') != -1) and (self.request.headers.get('Accept', '').find('xml') == -1)) \
        or lowerAgent.find('konqueror') != -1:
            return True

    def sendCachedMainPage(self, timeToken):
        self.sendXMLWithCachedFullAndMobileStylesheets(open('BUILTsrc/xml/main.xml').read(), timeToken,
            'main.xsl', 'mainmobile.xsl')

    RELOAD_PAGE = \
    """ <html>
            <head>
                <title>iPlay4e on Android</title>
                <meta http-equiv="refresh" content="0;url=%(reloadUrl)s" />
            </head>
            <body>
                <p>
                    Please wait while we load iPlay4e for your device.  If this page
                    doesn't update in 10 seconds please 
                    <a href="%(reloadUrl)s">click here to try again</a>.
                </p>
                <p style="text-align:center">
                    <img src="/%(timeToken)s/images/DivLoadingSpinner.gif" />
                </p>
            </body>
        </html>
    """

    XSLORCIST_URL = 'http://xslorcist.appspot.com/xslorcist' # 3.latest will always be beta according to Brindy.
    XSLORCIST_API_KEY = '26c4d3bb-48b7-429b-b97e-7860acf35e60'

    def sendXMLWithCachedFullAndMobileStylesheets(self, xmlContent, timeToken, fullStyleFile, mobileStyleFile):
        # The stylesheet we used is based on whether the client is mobile.
        isMobile = self.requestIsMobile()
        styleSheet = isMobile and mobileStyleFile or fullStyleFile

        # Prepend the XSL directives to the XML we were provided.
        xmlEncoding = 'ISO-8859-1'
        outXml = """<?xml version="1.0" encoding="%(xmlEncoding)s"?><?xml-stylesheet type="text/xsl" href="/%(timeToken)s/xsl/%(styleSheet)s"?>%(xmlContent)s""" % locals()

        # Use the xslorcist if the client needs us to or directs us to.
        # Unless we are, let the client handle XSL processing so we're all done.
        if not self.request.get('xslorcist', self.requestClientLacksXsl()):
            self.response.headers['Content-Type'] = 'text/xml'
            return self.response.out.write(outXml)

        # But on Android and some devices, we have it processed externally and stream the resulting HTML.
        hostName = self.request.host
        postParams = urllib.urlencode(\
            {   'xml': outXml, 
                'base': 'http://%(hostName)s' % locals(), 
                'enc': xmlEncoding, 
                'apikey': self.XSLORCIST_API_KEY,
            })
        try:
            postResult = urlfetch.fetch(self.XSLORCIST_URL, postParams, method=urlfetch.POST, deadline=10)
        except urlfetch.Error, errorMessage:
            numChars = len(postParams)
            logging.debug(\
                'POSTed %(numChars)d characters and got %(errorMessage)s %(postParams)r' % locals())
            reloadUrl = self.request.url
            return self.response.out.write(self.RELOAD_PAGE % locals())

        return self.response.out.write(postResult.content)

    def getAuthorizedModelOfClasses(self, ability, modelClasses, 
        user=None, useKey=None, requestKey='key', returnNone=False, returnMigrated=False):
        """ Usually raises ValueError if no model found.  If returnNone is True, returns None instead.
            If returnMigrated is set True, we return a 2-tuple (model, isMigrated), 
                where isMigrated indicates whether we forwarded an old character to a new.
        """
        import models
        if not modelClasses:
            raise RuntimeError, 'no modelClasses specified'

        # They may have manually provided the key.
        key = useKey
        if key is None:

            # Usually, the key is a GET parameter.  But sometimes it's in the URL in
            # the format /characters/KEY/main
            key = self.request.get(requestKey, None)
            if key is None:
                urlPieces = self.request.url.split('/')
                if urlPieces[-1] == 'main':
                    key = urlPieces[-2]
            if key is None:
                if returnNone: 
                    return returnMigrated and (None, False) or None
                raise ValueError

        try:
            model = IP4DB.get(key)
            assert model is not None
        except (datastore_errors.BadKeyError, AssertionError):
            if returnNone: return None
            raise ValueError

        # Auto-forward old characters to new.
        isMigrated = False
        if model.__class__ == models.Character and getattr(models, models.VERSIONED_CHARACTER_CLASS) in modelClasses:
            try:
                newCharacter = model.newCharacter
            except db.Error:
                newCharacter = None
            model, isMigrated = (newCharacter or model.migrate()), True

        if not (model.__class__ in modelClasses \
                and model.authorizeUserAbility(user or users.get_current_user(), ability)):
            if returnNone:
                return returnMigrated and (None, False) or None
            raise ValueError

        return returnMigrated and (model, isMigrated) or model

    def htmlError(self, message):
        self.response.out.write(message)

    def htmlSuccess(self, message):
        self.response.out.write(message)

    def jsonError(self, message):
        self.response.out.write({'error': message})

    def jsonSuccess(self, message):
        self.response.out.write({'success': message})

    def javascriptError(self, message):
        return self.__javascriptMessage(message, 'showError')

    def javascriptSuccess(self, message):
        return self.__javascriptMessage(message, 'showSuccess')

    def redirectParent(self, url):
        return self.__redirectWindowToUrl('parent', url)

    def redirectTop(self, url):
        return self.__redirectWindowToUrl('window.top', url)

    def reloadParent(self):
        return self.__reloadWindow('parent')

    def reloadTop(self):
        return self.__reloadWindow('window.top')

    def __reloadWindow(self, windowName):
        self.response.out.write(\
        """ <html> <head>
                <script type="text/javascript" language="javascript">
                gotoTop = function()
                {   %(windowName)s.location = %(windowName)s.location;
                };
                </script>
            </head> <body onload="gotoTop();"> </body> </html>
        """ % locals())

    def __redirectWindowToUrl(self, windowName, url):
        self.response.out.write(\
        """ <html> <head>
                <script type="text/javascript" language="javascript">
                gotoTop = function()
                {   %(windowName)s.location = '%(url)s';
                };
                </script>
            </head> <body onload="gotoTop();"> </body> </html>
        """ % locals())

    def __javascriptMessage(self, message, topFunction):
        message = simplejson.dumps(message)
        self.response.out.write(\
        """ <html> <head>
                <script type="text/javascript" language="javascript">
                showit = function()
                {   window.top.%(topFunction)s(%(message)s);
                };
                </script>
            </head> <body onload="showit();"> </body> </html>
        """ % locals())
