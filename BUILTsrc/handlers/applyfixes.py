from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        model = self.getAuthorizedModelOfClasses(self.DELETE, models.getSearchableClasses())
        model.ip4XML = None # This will cause the dnd4e data to get reparsed.
        model.put()
        self.response.out.write(\
        """ <html>
                <script type="text/javascript" language="javascript">
                    replaceDone = function()
                    {
                        window.parent.location.reload();
                    };
                </script>
            </head>
            <body onload="replaceDone();">
            </body>
            </html>
        """ % locals())
