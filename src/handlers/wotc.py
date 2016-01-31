import urllib
from google.appengine.api import users

from IP4ELibs import models, BaseHandler, DDI

class CompendiumHandler(BaseHandler.BaseHandler):

    def get(self):
        return self.redirect('http://www.wizards.com/dndinsider/compendium/database.aspx')

class ProxyHandler(BaseHandler.BaseHandler):

    def get(self):
        return self.redirect(urllib.unquote_plus(self.request.uri.split('proxywotc/')[-1]))

class TestHandler(BaseHandler.BaseHandler):

    FORM_CONTENT = \
    """ Enter your DDI username (email) and password:
        <form method="POST" action="dditest" id="ddiForm">
            <input type="text" name="username" id="username" value="%(userName)s" />
            <input type="password" name="password" value="%(passWord)s" />
            <input type="submit" value="Fetch Character List" />
        </form>
        <form method="POST" action="dditest" id="detailsForm" style="display:none;" target="ddiDetails">
            <input type="text" name="username" value="%(userName)s" />
            <input type="password" name="password" value="%(passWord)s" />
            <input type="hidden" name="oid" id="oid" value="" />
        </form>
        <iframe name="ddiDetails" style="display:none; width:100%%; height:200px;" id="ddiDetails">
        </iframe>
        <script>
            document.getElementById('username').focus();
            loadCharacter = function(oid)
            {   
                document.getElementById('oid').value = oid;
                document.getElementById('detailsForm').submit();
                document.getElementById('ddiDetails').style.display = 'block';
            };
        </script>
    """

    def get(self):
        ddiClient = DDI.DDIClient()

        userName, passWord, oid = self.request.get('username', ''), self.request.get('password', ''), self.request.get('oid', None)
        formContent = self.FORM_CONTENT % locals()
        if not (userName and passWord):
            return self.response.out.write(formContent)

        # If asked for character details, stream them to the iframe and return.
        if oid:
            try:
                characterDetails = ddiClient.login(userName, passWord).getCharacterData(oid)
            except DDI.DDIException, e:
                characterDetails = str(e)
            return self.response.out.write(characterDetails)

        try:
            characterList = ddiClient.login(userName, passWord).getCharacterList()
        except DDI.DDIException, e:
            characterList = None

        if characterList is None:
            characterListStr = '<span style="color:red;">%(e)s</span>' % locals()
        elif not characterList:
            characterListStr = 'You have no characters on the DDI Character Builder'
        else:
            characterListStr = '\n'.join([self.__characterToHtml(cl) for cl in characterList])

        # Add the model, brag, and prompt for another.
        return self.response.out.write(\
        """ 
            <p>%(formContent)s</p>
            <p>%(characterListStr)s</p>
        """ % locals())

    def __characterToHtml(self, character):
        oid, name, imageUrl = character.oid, character.name, character.imageUrl
        detailsStr = '<br/>'.join(['<span style="white-space:nowrap;">%s: %s</span>' % d for d in character.details])
        return \
        """ 
            <div style="clear:both;cursor:pointer;" onclick="loadCharacter('%(oid)s');">
                <img height="131" width="145" src="%(imageUrl)s" style="float:left;margin-right:8px;margin-bottom:8px;" />
                <p>
                    <span style="font-weight:bold;">%(name)s</span>
                    <br/>
                    %(detailsStr)s
                </p>
            </div>
        """ % locals()
