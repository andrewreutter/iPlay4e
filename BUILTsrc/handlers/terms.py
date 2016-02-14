from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        self.sendXMLWithCachedFullAndMobileStylesheets(open('BUILTsrc/xml/terms.xml').read(), 145541695845,
            'plainFull.xsl', 'plainMobile.xsl')
