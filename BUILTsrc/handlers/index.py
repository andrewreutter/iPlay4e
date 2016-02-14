from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):

        # You have to be on _one_ of our main pages...
        if self.request.path in ('', '/'):
            return self.redirect('/characters')

        # Mobile devices get redirected to the page that a web browser would load into the main iframe body.
        if self.requestIsMobile():
            requestPath, queryString = self.request.path, self.request.query_string
            requestPath = requestPath[-1] == '/' and requestPath or '%s/' % requestPath
            return self.redirect('%(requestPath)smain?%(queryString)s' % locals())

        return self.response.out.write(open('BUILTsrc/html/index.html').read())
