from google.appengine.api import users
from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        user = users.get_current_user()
        if not user:
            return self.sendCachedMainPage(143371090575)

        userId, page = user.user_id(), self.request.get('p', '1')
        self.redirect('/search/main?xsl=search&type=Campaign&user=%(userId)s&p=%(page)s' % locals())

class SaveHandler(BaseHandler.BaseHandler):

    def get(self):
        campaign = self.getAuthorizedModelOfClasses(self.EDIT, [models.Campaign])
        if not campaign:
            return self.redirect(self.request.referrer)

        oldName, oldWorld = campaign.name, campaign.world

        campaign.description = self.request.get('description', campaign.description or '')
        campaign.name = self.request.get('name', campaign.name or '')
        campaign.world = self.request.get('world', campaign.world or '')
        campaign.editrule = self.request.get('editrule', campaign.editrule or '')

        campaign.wikiUrl = self.request.get('wikiUrl', campaign.wikiUrl or '')
        campaign.blogUrl = self.request.get('blogUrl', campaign.blogUrl or '')
        campaign.groupUrl = self.request.get('groupUrl', campaign.groupUrl or '')

        campaign.ip4XML = ''
        campaign.put()

        if (campaign.name != oldName) or (campaign.world != oldWorld):
            return self.reloadTop() # because the "campaigns" menus is affected.
        self.redirect(self.request.referrer)
