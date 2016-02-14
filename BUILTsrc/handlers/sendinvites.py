from google.appengine.api import users, mail

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def javascriptError(self, message):
        """ We override this because errors should show up near the "add player" interface,
            not at the top of the screen.
        """
        self.response.out.write(\
        """ <html> <head>
                <script type="text/javascript" language="javascript" src="/145541695845/js/combo.js"></script>
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

    GOOGLE_EMAIL_TEMPLATE = \
    """
%(userName)s has added you to a campaign at iPlay4e!

The campaign is called %(campaignName)s and can be viewed at this address:

    http://iplay4e.appspot.com/campaigns/%(campaignKey)s

Replying to this email will send a message to %(userName)s.

Have fun!

- The iPlay4e Minion
http://iplay4e.com
    """

    EXTERNAL_EMAIL_TEMPLATE = \
    """
%(userName)s wants to add you to a campaign at iPlay4e!

The campaign is called %(campaignName)s and can be viewed at this address:

    http://iplay4e.appspot.com/campaigns/%(campaignKey)s

Use the Sign In link to create a Google account or use an existing one.

Then reply to this email to send a message to %(userName)s.
Let them know your account email address so they can add you to the campaign again.

Have fun!

- The iPlay4e Minion
http://iplay4e.com
    """

    def get(self):
        user = users.get_current_user()
        model = self.getAuthorizedModelOfClasses(self.EDIT, [models.Campaign], returnNone=True)
        if not user and model:
            return self.javascriptError('You must be signed in as the campaign owner to send invites!')

        userEmail, userName, campaignName, campaignKey = user.email(), user.nickname(), model.name, model.key()

        for  listId, emailTemplate in \
        (   ('ne',   self.GOOGLE_EMAIL_TEMPLATE),
            ('ue',   self.EXTERNAL_EMAIL_TEMPLATE),
        ):
            idLen = len(listId)
            emailList = [ a[idLen:] for a in self.request.arguments() if not a.find(listId) ]
            if not emailList:
                continue

            for emailTarget in emailList:
                mail.EmailMessage(\
                    sender='iPlay4e Minion <%(userEmail)s>' % locals(),
                    subject='iPlay4e Campaign Invite: %(campaignName)s' % locals(),
                    to=emailTarget,
                    body=emailTemplate % locals()
                    ).send()

        return self.reloadParent()
