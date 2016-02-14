import json as simplejson
from google.appengine.api import users, mail

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def getMultipleUrls(self):
        user = users.get_current_user()
        multipleUrls = simplejson.loads(self.request.get('multipleUrls', '[]'))
        targetElements = simplejson.loads(self.request.get('targetElements', '[]'))
        powerLinks = simplejson.loads(self.request.get('powerLinks', '[]'))
        retContents = [ 
            self.getQueryUrl(user=user, getUrlArg=mu.get, targetElement=te, powerLink=pl)
            for (mu, te, pl) in zip(multipleUrls, targetElements, powerLinks) 
        ]
        return simplejson.dumps(retContents)

    def getQueryUrl(self, user=None, getUrlArg=None, targetElement=None, powerLink=None):
        user = user or users.get_current_user()
        getUrlArg = getUrlArg or self.request.get # by default, fetch from CGI data.

        charKey, powerId, powerUrl, powerName, packageUrl, packageName = \
            [ getUrlArg(x) for x in ('c', 'i', 'u', 'n', 'pu', 'pn') ]

        retHtml = []

        # If the URL is on record, provide the (hopefully) fixed URL.
        try:
            reportedUrl = models.ReportedUrl.all().filter('url =', powerUrl)[0]
            fixedUrl = reportedUrl.fixedurl
        except IndexError:
            fixedUrl = None
        if fixedUrl:
            # And if we get here, we have a good URL.  Fix the links.
            retHtml.append("""\
                <script type="text/javascript" language="javascript">
                    var targetLink = $('%(powerLink)s');
                    targetLink.href = '%(fixedUrl)s';
                </script>
            """ % locals())

        # Regardless, allow them to (re-)report it.
        retHtml.append("""\
            <div style="display:inline;">
                <span class="Step">
                    <i><u><a href="#" style="color:#961334;"
                        onclick="
                            $(this).up('.Step').hide();
                            $(this).up('.Step').next('.Step').show();

                            // Open the compendium link if it isn't already.
                            var possibleCompendiumLink = $(this).up('.Step').up('span').previous('a');
                            if (possibleCompendiumLink.innerHTML.indexOf('Compendium') != -1) {
                                if (! $(this).up('.leightbox').down('iframe'))
                                    activateCompendiumLink(possibleCompendiumLink);
                            }

                            compFrame = $(this).up('.leightbox').down('iframe');
                            origCompSrc = compFrame.src;
                            srcPieces = origCompSrc.split('=');
                            origIdStr = srcPieces[srcPieces.length-1];
                            tryingUrl = compFrame.src.substring(0, compFrame.src.length - origIdStr.length) + (parseInt(origIdStr) + 1);

                            return false;
                        ">Report Bad Link</a></u></i>
                </span>
                <span class="Step" style="display:none;">
                    <u><a href="#" style="color:#961334;"
                        onclick="
                            $(this).up('.Step').hide();
                            $(this).up('.Step').previous('.Step').show();
                            return false;
                        ">Cancel</a></u>
                    Does clicking 
                    <u><a href="#" onclick="
                            compFrame.src = tryingUrl;
                            return false;
                        ">here</a></u>
                    solve the problem?
                    <u><a target="reporturl" href="#" onclick="new Ajax.Updater('%(targetElement)s', '/reporturl', {method: 'GET', parameters: { c:'%(charKey)s', url:'%(powerUrl)s', n:'%(powerName)s', pu:'%(packageUrl)s', pn:'%(packageName)s', fu:tryingUrl }});return false;">Yes</a></u>
                    <u><a target="reporturl" href="#" onclick="new Ajax.Updater('%(targetElement)s', '/reporturl', {method: 'GET', parameters: { c:'%(charKey)s', url:'%(powerUrl)s', n:'%(powerName)s', pu:'%(packageUrl)s', pn:'%(packageName)s' }});return false;">No</a></u>
                </span>
            </div>
        """ % locals())

        return ''.join(retHtml)

    def get(self):
        user = users.get_current_user()

        # They might just be asking about many or a single URL.  Let them know.
        if self.request.get('multipleUrls'):
            return self.response.out.write(self.getMultipleUrls())
        if self.request.get('u'): 
            return self.response.out.write(self.getQueryUrl())

        # If anything required is missing, bail - otherwise, thank the user nicely.
        charKey, powerUrl, powerName, packageUrl, packageName, fixedUrl = \
            [ self.request.get(x) for x in ('c', 'url', 'n', 'pu', 'pn', 'fu') ]
        if None in (charKey, powerName, powerUrl):
            return

        # We're not done, but nothing else we do impacts the user.  Thank them contextually.
        if fixedUrl:
            self.response.out.write('Thanks for fixing this link!')
        else:
            self.response.out.write('Thanks for the report! The Link Squad is on task.')

        # If there's an existing model, just update its fixedurl property. Otherwise, build one from scratch.
        existingRU = models.ReportedUrl.all().filter('url = ', powerUrl)
        if existingRU.count():
            newModel = existingRU[0]
            newModel.fixedurl = (fixedUrl or '')
        else:
            newModel = models.ReportedUrl(
                character=charKey,
                url=powerUrl,
                name=powerName,
                packagename=packageName,
                packageurl=packageUrl,
                fixedurl=(fixedUrl or '')
            )

        # Before we save, if we lack a URL we take a guess...
        if not newModel.fixedurl:

            # ...by deriving namenoplus, which handles the following cases...
            #   "Magic Weapon + 1" -> "Magic Weapon"
            #   "Potion of Healing (heroic tier)" -> "Potion of Healing"
            #   "Master's Wand" -> "Masters Wand"
            newModel.namenoplus = powerName.split(' +')[0].split(' (')[0].replace("'", '').strip() # Magic Weapon +5 -> Magic Weapon

            #...and seeing if any earlier fixes had the same namenoplus.
            relatedReport = models.ReportedUrl.all().filter('namenoplus', newModel.namenoplus).filter('fixedurl !=', '').get()
            if relatedReport:
                newModel.urlguess = relatedReport.fixedurl

        newKey = newModel.put()

        # If we were told the URL was bad, send a report to the link squad.
        if not newModel.fixedurl:
            userEmail = user and user.email() or 'andrew.reutter@gmail.com'
            mail.EmailMessage(\
                sender='iPlay4e Robot <%(userEmail)s>' % locals(),
                subject='iPlay4e URL Report',
                to='iPlay4e Link Squad <iplay4elinksquad@googlegroups.com>',
                body="""
Greetings from iPlay4e!

If you recently reported a bad link on an iPlay4e character, you're receiving
this email as a side effect.

If you're on the Link Squad, you know what to do!

Compendium Item:

    name: %(powerName)s
    url: %(powerUrl)s

Character:

    http://iplay4e.appspot.com/view?key=%(charKey)s

Link Squad page:

    http://iplay4e.appspot.com/linksquad#%(newKey)s

                """ % locals()).send()
