from google.appengine.api import users

from IP4ELibs import BaseHandler, models, IP4XML

class BaseViewHandler(BaseHandler.BaseHandler):

    def sendXML(self, theXML, isMigrated):

        # Which XSL are we going to use?  If none, just send XML and be done with it.
        xslFile = self.request.get('xsl', 'fullold')
        if isMigrated: # the old "fullpage" xsl is now our tablet view; our default is "fullold"
            xslFile = {'fullpage':'fullold'}.get(xslFile, xslFile)
        if not xslFile:
            self.response.headers['Content-Type'] = 'text/xml'
            self.response.out.write('<?xml version="1.0" encoding="ISO-8859-1"?>')        
            self.response.out.write('\n')
            self.response.out.write(theXML)
            return

        # Otherwise, let our libraries do the work.  Specify the same XSL for both mobile
        # and full views, because it was provided to us as a GET argument.  The reason
        # we still call this method is to leverage xslorcist for Android platforms.
        xslFile = '%(xslFile)s.xsl' % locals()
        self.sendXMLWithCachedFullAndMobileStylesheets(theXML, '145541695845', xslFile, xslFile)

class MainHandler(BaseViewHandler):

    def get(self):
        #isExternalEmbed = self.request.referrer.find(self.request.host_url)

        user = users.get_current_user()
        try:
            model, isMigrated = self.getAuthorizedModelOfClasses(self.VIEW, models.getSearchableClasses(), returnMigrated=True)
        except ValueError:
            return self.response.out.write(\
            """ <html>
                <head>
                    <link rel="stylesheet" href="/145541695845/css/combo.css" type="text/css" media="screen, projection" />
                    <link rel="stylesheet" href="/145541695845/css/blueprint/print.css" type="text/css" media="print" />
                    <!--[if lt IE 8]><link rel="stylesheet" href="/145541695845/css/blueprint/ie.css" type="text/css" media="screen, projection" /><![endif]-->
                    <script type="text/javascript" language="javascript" src="/145541695845/js/combo.js"></script>
                    <script>
                        Event.observe(document, 'dom:loaded', function()
                        {   sizeParentIframeToMyContainer(20);
                            pageAuth();
                            initializeEnvironmentalElements();
                        });
                    </script>
                </head>
                <body class="Page">
                    <div class="container">
                        <div id="searchBar" class="span-24 last">
                            <div class="span-12">
                                <span class="FirstLeft">
                                    Invisible iPlay4e!
                                </span>
                            </div>
                            <div class="span-12 last" style="text-align:right;">
                                <span class="ForeignOnly" style="display:none;margin-right: 8px;">
                                    <b id="nicknameDisplay"></b>
                                    <script type="text/javascript" language="javascript">
                                        registerAuthHandler(function(json)
                                        {   var nameDisplay = null;
                                            if (json.nickname) nameDisplay = json.nickname;
                                            if (json.prefs && json.prefs.handle)
                                                nameDisplay = json.prefs.handle;
                                            if (nameDisplay) $('nicknameDisplay').update(nameDisplay + ' | ');
                                        });
                                    </script>
                                    <u><a class="SignInOut list" style="text-decoration:none;" href="#"><img src="/145541695845/images/DivLoadingSpinner.gif"/></a></u>
                                </span>
                            </div>
                        </div>
                        <div class="span-24 last">
                            <div class="FirstLeft" style="padding-top:20px;">
                                Sorry, but this iPlay4e item doesn't exist, or you aren't authorized to view it.
                            </div>
                        </div>
                        <div id="paginationBar" class="span-24 last">
                    </div>
                </body>
            """)
        
        return self.sendXML(model.toXML(), isMigrated)

class MultipleHandler(BaseViewHandler):

    def get(self):
        searchableClasses = models.getSearchableClasses()

        # They may have sent a single comma-delimited "keys" arg or a sequence of "key" args.
        keys = self.request.get('keys')
        if keys:
            keys = keys.split(',')
        else:
            keys = self.request.get_all('key')

        allObjects = \
        [   self.getAuthorizedModelOfClasses(self.VIEW, searchableClasses, useKey=thisKey, returnNone=True) \
            for thisKey in keys
        ]
        allObjects = [ ao for ao in allObjects if ao is not None ]

        # Sometimes we got a campaign key, but really want characters.
        if self.request.get('usecharacters'):
            characterObjects = []
            [ characterObjects.extend(ao.characters) for ao in allObjects ]
            allObjects.extend(characterObjects)
        objectsXML = ''.join([ ao.toXML() for ao in allObjects ])

        return self.sendXML('<MultipleKeys>%(objectsXML)s</MultipleKeys>' % locals(), False)

def main():
    BaseHandler.BaseHandler.main(MainHandler)
if __name__ == '__main__':
    main()
