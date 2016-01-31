import re
from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    EMAIL_REGEX = re.compile('[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}', re.IGNORECASE)

    def javascriptError(self, message):
        """ We override this because errors should show up near the "add player" interface,
            not at the top of the screen.
        """
        self.response.out.write(\
        """ <html> <head>
                <script type="text/javascript" language="javascript" src="/TIME_TOKEN/js/combo.js"></script>
                <script type="text/javascript" language="javascript">
                showit = function()
                {   window.frameElement.style.display = 'block';
                    sizeParentIframeToMyContainer(10);
                    parent.sizeCampaignPanels();
                };
                </script>
                <style>
                    body { margin:0; padding:0; font-size:11px; font-family: Arial, sans-serif; }
                </style>
            </head>
            <body onload="showit();">
                <div class="container" style="padding-top:4px;">
                    %(message)s
                </div>
            </body> </html>
        """ % locals())

    def get(self):
        user = users.get_current_user()

        model = self.getAuthorizedModelOfClasses(self.EDIT, [models.Campaign], returnNone=True)
        if not model:
            return self.javascriptError('You must be signed in to add players')

        players = self.request.get('players', []) or []
        badEmails = []
        if players:
            players = [ p for p in [ p.strip() for p in players.split('\n') ] if p ]

            # Try to do lookups by handle.
            for player, playerIndex in zip(players, range(len(players))):
                try:
                    players[playerIndex] = \
                        models.UserPreferences.gql('WHERE handle = :1 and owner != :2', player, user)[0].owner.email()
                except IndexError:
                    pass

            badEmails = [ p for p in players if not self.EMAIL_REGEX.match(p) ]
            players = [ p for p in players if p not in badEmails ]

        # Before we start stickin' the old folks back in...
        newPlayers = players[:]

        # The player list should always contain the owner.
        userEmail = user.email() 
        (userEmail not in players) and players.insert(0, userEmail)

        # So should everyone that was already in there...
        oldPlayers = [ p.email() for p in model.players ]
        [ players.append(op) for op in oldPlayers if op not in players ]

        # Make sure all those email addresses are good.
        model.players, unknownEmails = models.EmailToUser.emailsToGoodUsers(players, returnBad=True)
        newEmails = [ e for e in [ p.email() for p in model.players ] if e not in oldPlayers ]

        model.ip4XML = '' # to re-trigger XML generation, because it includes the players.
        model.putAndUpdateCharacterSearch()
        modelKey = model.key()

        continueContent = \
        """ <form action="/sendinvites">
                <input type="hidden" name="key" value="%(modelKey)s" />
        """ % locals()

        badEmailNote = 'After completing  email notifications, you may try again.'
        unknownEmailNote = 'You may still send email invitations to those addresses.'
        for emailList,      listId, listStyle,      listAction,     listNote in \
        (   
            (badEmails,     '',     'color:red;',   'Invalid',      badEmailNote),
            (unknownEmails, 'ue',   'color:blue;',  'Unknown',      unknownEmailNote),
            (newEmails,     'ne',   '',             'Added these',  ''),
        ):
            if not emailList:
                continue
            if not listId:
                checkBoxes = ''.join(['<br/>- %s' % el for el in emailList ])
            else:
                checkBoxes = ''.join(\
                    [   """ <br/>
                            <label for="%(listId)s%(i)d">
                                <input id="%(listId)s%(i)d" checked="true" name="%(listId)s%(be)s" type="checkbox">
                                %(be)s
                            </label>
                        """ % locals() \
                        for (be, i) in zip(emailList, range(len(emailList))) \
                    ])
            listNote = listNote and ('<br/><br/>%s<br/><br/>' % listNote) or ''
            continueContent += \
                """ <div style="padding-bottom:4px;%(listStyle)s">
                        <div>
                            %(listAction)s Google accounts or handles:
                        </div>
                        %(checkBoxes)s
                        %(listNote)s
                    </div>
                """ % locals()

        continueContent += \
        """     
                <br/>
                <i>Note: all emails will be sent from your Google account.</i>
                <br/>
                <input type="submit" value="Send email invites to checked"/>
                <input type="button" value="No thanks!" onclick="parent.document.location.reload();"/>
            </form>
        """
        return self.javascriptError(continueContent)
