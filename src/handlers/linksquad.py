from google.appengine.ext import db
from google.appengine.api import users

from IP4ELibs import models, BaseHandler, IP4DB
from IP4ELibs.ModelTypes import SearchModels

DEFAULT_URL = 'http://www.wizards.com/dndinsider/compendium/'
LINK_SQUAD = """\
edward.avent@gmail.com
greyhawk.chad@gmail.com
briankgold@gmail.com
andrew.reutter@gmail.com # Moi
nazimkaraca@gmail.com 105210683699495787684 # Nazim Karaca
praus1980@gmail.com 117386762099036021047 # David Reddy
hvg3akaek@gmail.com # hvg3
"""

class MainHandler(BaseHandler.BaseHandler):

    def kickOutUser(self, user):
        loginUrl = users.create_login_url(self.request.url)
        return self.response.out.write(\
        """ You must be a member of the iPlay4e Link Squad to edit Reported URLs.  <a href="%(loginUrl)s">Sign in</a>
        """ % locals())

    def get(self):
        user = users.get_current_user()
        if not (user and (users.is_current_user_admin() or LINK_SQUAD.find(user.email()) != -1 or LINK_SQUAD.find(user.user_id()) != -1)):
            return self.kickOutUser(user)
        userEmail, userId = user.email(), user.user_id()

        fixkey = self.request.get('fixkey', None)
        if fixkey is not None:
            fixModel = IP4DB.get(fixkey)
            if fixModel is not None:
                fixModel.fixedurl = self.request.get('fixurl');
                fixModel.put()

        allModels = models.ReportedUrl.all().filter('fixedurl', '')
        allModels.filter('url !=', '/characters/missingCompendium')
        # Put back when above line removed! XXX allModels.order('-modified')

        reportedUrlModels = [ rum for rum in allModels ]
        reportedCharKeys = [ ru.character for ru in reportedUrlModels ]
        reportedKeys = [ ru.key() for ru in reportedUrlModels ]
        reportedNames = [ ru.name for ru in reportedUrlModels ]
        reportedNameNoPluses = [ ru.namenoplus for ru in reportedUrlModels ]
        reportedUrls = [ ru.url for ru in reportedUrlModels ]
        reportedUrlGuesses = [ ru.urlguess or '' for ru in reportedUrlModels ]
        reportedFixedUrls = [ ru.fixedurl for ru in reportedUrlModels ]

        modelHtml, scriptHtml = [], []
        for modelIndex, model, charKey, key, name, reportedNameNoPlus, url, urlGuess, fixedUrl \
        in zip(range(len(reportedUrls)), reportedUrlModels, reportedCharKeys, reportedKeys, reportedNames, reportedNameNoPluses, reportedUrls, reportedUrlGuesses, reportedFixedUrls):
            defaultedFixedUrl = fixedUrl or DEFAULT_URL

            scriptHtml.append("""\
                    $('fixedlink' + %(modelIndex)d).href = $('fixedUrl' + %(modelIndex)d).value;
            """ % locals())

            modelHtml.append("""\
                <tr>
                    <td style="padding-right:24px;">
                        <a target="character" id="charlink%(modelIndex)d" href="/view?key=%(charKey)s">Open</a>
                    </td>
                    <td style="padding-right:24px;">
                        <a name="%(key)s" target="linksquad" id="link%(modelIndex)d" href="%(url)s">%(name)s</a>
                    </td>
                    <td style="padding-right:24px;">
                        <input target="linksquad" value="%(reportedNameNoPlus)s" 
                            onclick="this.focus();this.select();"
                        />
                    </td>
                    <td style="padding-right:24px;">
                        <input style="width:400px;" id="fixedUrl%(modelIndex)d" value="%(urlGuess)s"
                            onkeyup="
                                $('fixedlink' + %(modelIndex)d).href = $('fixedUrl' + %(modelIndex)d).value;
                            "
                        />
                    </td>
                    <td style="padding-right:24px;">
                        <a target="linksquad" id="fixedlink%(modelIndex)d" href="%(defaultedFixedUrl)s"
                            onclick="
                                $('savebutton' + %(modelIndex)d).style.display = 'inline';
                            "
                        >%(name)s</a>
                        <input type="button" id="savebutton%(modelIndex)s" value="Save URL"
                         style="display:none;"
                         onclick="
                            $('fixkey').value = '%(key)s';
                            $('fixurl').value = $('fixedUrl%(modelIndex)d').value;
                            $(this).up('form').submit();
                         "
                    </td>
                </tr>
            """ % locals())

        modelHtml = ''.join(modelHtml)
        scriptHtml = ''.join(scriptHtml)
        self.response.out.write(\
        """ <html>
                <head>
                    <title>
                        iPlay4e Link Squad, Attack!
                    </title>
                    <script type="text/javascript" language="javascript" src="/TIME_TOKEN/js/combo.js"></script>
                </head>
                <body>
                    <h2>
                        Greetings, iPlay4e Link Squad!
                    </h2>
                    <h2>
                        Instructions
                    </h2>
                    <p>
                        The items below have been reported but not yet fixed.  To fix an item, please:
                        <ol>
                            <li>
                                <a href="http://www.wizards.com/dndinsider/compendium/" target="compendium">Open the Compendium</a>
                            </li>
                            <li>
                                Search the Compendium for the item in question, or a related entry that includes it.
                            </li>
                            <li>
                                While viewing the entry, right-click the power/item card and click
                                "Open frame in new tab" (or your browser's equivalent)
                            </li>
                            <li>
                                Copy the address from the compendium entry's browser tab.
                            </li>
                            <li>
                                Paste the address into the Fixed URL box for the item below.
                            </li>
                            <li>
                                Click the Fixed Link next to the Fixed URL box to make sure it works.
                            </li>
                            <li>
                                Click the "Save URL" button next to the Fixed Link.
                            </li>
                        </ol>
                    </p>
                    <form action="/linksquad" method="POST">
                        <input type="hidden" id="fixkey" name="fixkey" value=""/>
                        <input type="hidden" id="fixurl" name="fixurl" value=""/>
                        <table>
                            <tr>
                                <th style="text-align:left;">Character</th>
                                <th style="text-align:left;">Original Link</th>
                                <th style="text-align:left;">Base Name</th>
                                <th style="text-align:left;">Fixed URL</th>
                                <th style="text-align:left;">Fixed Link</th>
                            </tr>
                            %(modelHtml)s
                        </table>
                    </form>
                    <script>
                        %(scriptHtml)s
                    </script>
                </body>
            </html> 
        """ % locals())
