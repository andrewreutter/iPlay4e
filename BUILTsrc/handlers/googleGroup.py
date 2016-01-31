from google.appengine.api import users, urlfetch, urlfetch_stub

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        hostName = self.request.host
        key = self.request.get('key')
        if not key:
            return

        try:
            siteUrl, createUrl = \
            {   'site': (   'http://sites.google.com/site/iplay4e%(key)s' % locals(), 
                            'https://sites.google.com/site/sites/system/app/pages/meta/dashboard/create-new-site'),
            }[self.request.get('type', None)]
        except KeyError:
            return

        # No matter what, we're redirecting somewhere, based on attempt to view the existing page.
        #   Success: Site page
        #   404: Create site
        #   Other errors: Retry
        try:
            redirectUrl = siteUrl
            if urlfetch.fetch(redirectUrl, method=urlfetch.GET, deadline=10).status_code == 404:
                redirectUrl = createUrl
        except urlfetch.Error, errorMessage:
            redirectUrl = self.request.url
        return self.redirect(redirectUrl)
