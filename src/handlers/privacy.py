from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        self.sendXMLWithCachedFullAndMobileStylesheets(open('BUILTsrc/xml/privacy.xml').read(), TIME_TOKEN,
            'plainFull.xsl', 'plainMobile.xsl')
