from google.appengine.ext import db
from google.appengine.api import users

from IP4ELibs import models, BaseHandler, IP4DB
from IP4ELibs.ModelTypes import SearchModels

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        user = users.get_current_user()

        fixkey = self.request.get('fixkey', None)
        if fixkey is not None:
            fixModel = IP4DB.get(fixkey)
            if fixModel is not None:
                fixModel.deleteSearchResult()
                fixModel.putSearchResult()
            return self.redirect(self.request.referrer)

        # Show me everything I own.
        myResults = user and [ sr for sr in SearchModels.SearchResult.SearchRequest().setUser(user).get() ] or []
        myTitles = [ mr.title for mr in myResults ]
        myModels = [ mr.model for mr in myResults ]
        myKeys = [ str(mm.key()) for mm in myModels ]
        myViewablesOrNones = [ ((user in mm.viewers) and mm or None) for mm in myModels ]

        modelHtml = []
        for thisResult, thisTitle, thisModel, thisKey, thisViewableOrNone \
        in zip(myResults, myTitles, myModels, myKeys, myViewablesOrNones):

            notViewableLink = ''
            if thisViewableOrNone is None:
                notViewableLink = '(Should not be viewable.  <a href="fixme?fixkey=%(thisKey)s">Fix this</a>)' % locals()

            modelHtml.append(\
            """ %(thisTitle)s %(notViewableLink)s
            """ % locals())

        modelHtml = '<br/>'.join(modelHtml)
        self.response.out.write(\
        """ <html>
                <body>
                    %(modelHtml)s
                </body>
            </html> 
        """ % locals())
