from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        self.sendXMLWithCachedFullAndMobileStylesheets(open('BUILTsrc/xml/help.xml').read(), 143371090575,
            'plainFull.xsl', 'plainMobile.xsl')
