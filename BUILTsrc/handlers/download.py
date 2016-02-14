import StringIO, zipfile

from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        try:
            model = self.getAuthorizedModelOfClasses(self.VIEW, models.getSearchableClasses())
        except ValueError:
            return self.jsonError('Missing iplay4e item')

        if model.__class__ is models.Campaign:
            return self.getCampaign(model) 
        else:
            self.getCharacter(model)

    def getCampaign(self, model):
        zipContent = StringIO.StringIO()
        zipFile = zipfile.ZipFile(zipContent, 'w')
        for thisCharacter in model.characters:
            safeName, modelXML = self.getCharacterNameAndXML(thisCharacter)
            zipFile.writestr('%s.dnd4e' % safeName, modelXML)
        zipFile.close()

        safeName = model.name.encode('utf8').replace(' ', '')
        self.response.headers["Content-Type"] = "multipart/x-zip"
        self.response.headers['Content-Disposition'] = "attachment; filename=%s.zip" % safeName
        self.response.out.write(zipContent.getvalue())

    def getCharacter(self, model):
        safeName, modelXML = self.getCharacterNameAndXML(model)

        self.response.headers['Content-Type'] = 'text/dnd4e'
        self.response.headers['Content-Disposition'] = 'attachment; filename=%s.dnd4e' % safeName
        self.response.out.write(modelXML)

    def getCharacterNameAndXML(self, model):
        safeName = model.toDom().get('name').encode('utf8').replace(' ', '')
        modelXML = model.getDataWithState()
        return safeName, modelXML


def main():
    BaseHandler.BaseHandler.main(MainHandler)
if __name__ == '__main__':
    main()
