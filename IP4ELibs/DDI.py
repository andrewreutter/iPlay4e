from google.appengine.api import urlfetch

import xml.dom.minidom
from xml.etree import ElementTree

import urllib

class DDIException(Exception):
    pass

class DDIClient:

    def fetch(self, postUrl, postData):

        try:
            headers={'Cookie':self.__cookieStr, 'Content-Type': 'application/soap+xml; charset=utf-8'}
        except AttributeError: # self.__cookieStr hasn't been set yet
            headers = {}

        try:
            postResponse = urlfetch.fetch(postUrl, payload=postData, 
                method=urlfetch.POST, follow_redirects=False, deadline=10, headers=headers)
            if postResponse.status_code != 200:
                raise urlfetch.Error
        except urlfetch.Error:
            raise DDIException, 'Error communicating with DDI servers.  Please try again later.'

        return postResponse

    def login(self, userEmail, passWord):

        postResponse = self.fetch('http://vecna.wizards.com',
            urllib.urlencode(\
            {   'LoginButton': 'Login', 'Name': userEmail, 'Password': passWord,
                '__EVENTVALIDATION': '/wEWBALv1beCAgKbufQdAtLF4JEPAv6M0J8PSCftPBYXR+kZNPQzvVeGL7cZhW8=',
                '__VIEWSTATE': '/wEPDwUKMTY0MjY2MTM0NGRkwg5wek29x+iGnuQS8ECM6xUjhSw=',
            }))

        responseCookie = postResponse.headers.get('set-cookie', '')
        if responseCookie.find('AuthPlanetPro=') == -1:
            raise DDIException, 'Invalid username/password for DDI: %r' % postResponse.headers
        else:
            self.__cookieStr = '; '.join([ c.split(';', 1)[0] for c in responseCookie.split(',') ])

        return self

    def getCharacterList(self):

        postResponse = self.fetch('http://ioun.wizards.com/ContentVault.svc', DDIXML.CHARACTER_LIST_REQUEST_XML)
        return DDIXML.parseCharacterList(postResponse.content)

    def getCharacterData(self, oid):

        postResponse = self.fetch('http://vecna.wizards.com/D20WorkspaceService.svc',
            DDIXML.CHARACTER_DATA_REQUEST_XML % locals())
        return postResponse.content

class DDIXML:

    CHARACTER_LIST_REQUEST_XML = """<s:Envelope xmlns:a="http://www.w3.org/2005/08/addressing" xmlns:s="http://www.w3.org/2003/05/soap-envelope"><s:Header><a:Action s:mustUnderstand="1">http://tempuri.org/IContentVaultService/GetAvailableContent</a:Action><a:MessageID>urn:uuid:0f96eb2a-91e5-299b-12c1-4968980169c2</a:MessageID><a:ReplyTo><a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address></a:ReplyTo><a:To s:mustUnderstand="1">http://ioun.wizards.com/ContentVault.svc</a:To></s:Header><s:Body><GetAvailableContent xmlns="http://tempuri.org/"><contentType>0</contentType></GetAvailableContent></s:Body></s:Envelope>"""

    CHARACTER_DATA_REQUEST_XML = """<s:Envelope xmlns:a="http://www.w3.org/2005/08/addressing" xmlns:s="http://www.w3.org/2003/05/soap-envelope"><s:Header><a:Action s:mustUnderstand="1">urn:ID20WorkspaceService/Apply</a:Action><a:MessageID>urn:uuid:d90fe7be-52d0-a22d-4f3e-07dfb0249145</a:MessageID><a:ReplyTo><a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address></a:ReplyTo><a:To s:mustUnderstand="1">http://vecna.wizards.com/D20WorkspaceService.svc</a:To></s:Header><s:Body><Apply><characterID xmlns:d4p1="http://schemas.datacontract.org/2004/07/WotC.ContentVault" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><d4p1:ContentID>%(oid)s</d4p1:ContentID><d4p1:Official>false</d4p1:Official><d4p1:OfficialTypeID i:nil="true" /><d4p1:ScratchID i:nil="true" /><d4p1:TypeID>0</d4p1:TypeID></characterID><updates xmlns:d4p1="http://schemas.datacontract.org/2004/07/WotC.CharBuilder.Web" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><d4p1:RulesEngineUpdate i:type="d4p1:ReloadAll" /></updates></Apply></s:Body></s:Envelope>"""

    @staticmethod
    def parseCharacterList(characterListXML):

        # We get some weirdness from DDi.
        characterListXML = characterListXML.replace('b:ContentInfo', 'ContentInfo')

        xmlObject = xml.etree.ElementTree.fromstring(characterListXML)
        try:
            xmlObject = xmlObject.getroot()
        except AttributeError:
            pass

        characterList = []
        for contentInfoNode in xmlObject.findall('{http://www.w3.org/2003/05/soap-envelope}Body/{http://tempuri.org/}GetAvailableContentResponse/{http://tempuri.org/}GetAvailableContentResult/{http://tempuri.org/}ContentInfo/{http://schemas.datacontract.org/2004/07/WotC.ContentVault}CommittedContent'):
            #raise RuntimeError, xml.etree.ElementTree.tostring(contentInfoNode)

            characterName = 'Unknown Character'
            characterDetails = []
            characterOid = contentInfoNode.find('{http://schemas.datacontract.org/2004/07/WotC.ContentVault}Identifier/{http://schemas.datacontract.org/2004/07/WotC.ContentVault}ContentID').text.strip()
            characterImageUrl = contentInfoNode.find('{http://schemas.datacontract.org/2004/07/WotC.ContentVault}Portrait/{http://schemas.datacontract.org/2004/07/WotC.ContentVault}ContentUri').text.strip()

            # The details node contains escaped XML that must be reparsed.
            detailsNode = contentInfoNode.find('{http://schemas.datacontract.org/2004/07/WotC.ContentVault}Details')
            for detailsItem in xml.etree.ElementTree.fromstring(detailsNode.text.strip()):
                detailsTag, detailsText = detailsItem.tag, detailsItem.text.strip()
                if detailsTag == 'Name':
                    characterName = detailsText
                else:
                    characterDetails.append((detailsTag, detailsText))

            characterList.append(DDICharacter(characterOid, characterName, characterDetails, characterImageUrl))

        return characterList

class DDICharacter:

    def __init__(self, oid, name, details, imageUrl):
        self.oid, self.name, self.details, self.imageUrl = oid, name, details, imageUrl

def test():
    DDIXML.parseCharacterList(open('/tmp/ddidata.xml').read())

if __name__ == '__main__':
    test()
