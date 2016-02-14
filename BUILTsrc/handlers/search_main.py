import xml.dom.minidom
from xml.etree import ElementTree
import StringIO, string

import wsgiref.handlers
from google.appengine.ext import webapp
from google.appengine.api import users
from django.core.paginator import ObjectPaginator

from IP4ELibs import BaseHandler, models
from IP4ELibs.ModelTypes import SearchModels

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        user, searchRequest = users.get_current_user(), SearchModels.SearchResult.SearchRequest()

        # First possibility is a search by user, who better be me (My Characters, My Monsters).
        if self.request.get('user'):
            if not user:
                return self.sendCachedMainPage(145541695845)
            searchRequest.setUser(user)

        # Although if I'm an admin, I can add "owner=foo@bar.com" to the URL for debugging.
        if users.is_current_user_admin():
            owner = self.request.get('owner')
            if owner:
                try:
                    searchRequest.setUser(users.User(owner))
                except users.UserNotFoundError:
                    raise RuntimeError, 'invalid owner %(owner)r' % locals()

        # Next is search by string/campaign.  SearchRequest will take None for an answer.
        searchRequest.setString(self.request.get('q', None))
        searchRequest.setCampaign(self.request.get('campaign', None))

        # Finally, we can limit by type.
        searchType = \
        {   'Character':models.VERSIONED_CHARACTER_CLASS,
            'Campaign':'Campaign',
        }.get(self.request.get('type', None), None)
        searchType and searchRequest.setTypes([searchType])

        return self.show(user, searchRequest)

    def show(self, user, searchRequest):

        # If the request isn't viable, show empty results.  Let XSL deal with that.
        searchResults = searchRequest.isViable() and searchRequest.get() or []

        # iPhone isn't wide enough to show "Search Results for: asdfasdfasdfasdf"
        if self.requestIsMobile() and not self.request.get('user'):
            searchTitle = 'Search Results'
        else:
            searchTitle = searchRequest.getTitle()
        elementTree = SearchResultsElementTree(searchResults, self, searchTitle, user)

        xmlString = StringIO.StringIO()
        elementTree.write(xmlString)

        self.sendXMLWithCachedFullAndMobileStylesheets(xmlString.getvalue(), 145541695845,
            'searchFull.xsl', 'searchMobile.xsl')

class SearchResultsElementTree(ElementTree.ElementTree):
    HITS_PER_PAGE = 10
    ORPHANS_PER_PAGE = 3

    def getPagelessUrlFromHandler(self, handler):
        baseUrl = handler.requestIsMobile() and handler.request.url or handler.request.referrer
        urlPieces = baseUrl.split('?')
        if len(urlPieces) == 2:
            path, queryString = urlPieces
        else:
            path, queryString = urlPieces[0], ''
        path = path.rstrip('\/')

        queryElements = [ qs for qs in queryString.split('&') if qs and qs[:2] != 'p=' ]
        campaign = self.handler.request.get('campaign', None)
        (campaign is not None) and queryElements.append('campaign=%s' % campaign)
        queryElements.append('p=')

        queryString = '&'.join(queryElements)
        return '%(path)s?%(queryString)s' % locals()

    def __init__(self, searchResults, handler, title, user):
        self.user, self.handler = user, handler
        self.rootNode = rootNode = ElementTree.Element('SearchResults')
        ElementTree.ElementTree.__init__(self, rootNode)

        rootNode.set('title', title)
        rootNode.set('pagelessUrl', self.getPagelessUrlFromHandler(handler))

        # Don't limit the number of results if viewing the characters in a campaign.
        hitsPerPage = handler.request.get('campaign', None) and 100 or self.HITS_PER_PAGE
        paginator = ObjectPaginator(searchResults, hitsPerPage, orphans=self.ORPHANS_PER_PAGE)

        pageNumber = int(handler.request.get('p', '1'))
        numPages = paginator.pages
        pageNumber = min(numPages, pageNumber)
        pageNumber0 = pageNumber - 1

        firstOnPage, lastOnPage, numResults = \
            paginator.first_on_page(pageNumber0), paginator.last_on_page(pageNumber0), paginator.hits
        firstOnPage = lastOnPage and firstOnPage or 0 # so firstOnPage isn't 1 when there are 0 results

        localVars = locals()
        for thisVar in ('numResults', 'numPages', 'pageNumber', 'firstOnPage', 'lastOnPage'):
            rootNode.set(thisVar, str(localVars[thisVar]))

        try:
            [ self.addResult(thisResult, user) for thisResult in paginator.get_page(pageNumber0) ]
        except AttributeError:
            raise
            raise RuntimeError, 'expecting searchResults, got %(searchResults)r' % locals()

    def addResult(self, resultModel, user):
        modelType = \
        {   models.VERSIONED_CHARACTER_CLASS: 'Character',
        }.get(resultModel.modelType, resultModel.modelType)

        lettersAndDigits = string.letters + string.digits

        retElement = ElementTree.SubElement(self.rootNode, modelType)
        retElement.set('key', resultModel.modelKey)
        retElement.set('safe-key', ''.join([k for k in resultModel.modelKey if k in lettersAndDigits ]))
        retElement.set('isOwner', (resultModel.owner == self.user) and 'True' or 'False')
        retElement.set('isViewer', (self.user in resultModel.viewers) and 'True' or 'False')
        retElement.set('isPublic', str(resultModel.isPublic))
        [ retElement.set(thisVar, getattr(resultModel, thisVar)) for thisVar in ('title', 'subtitle') ]

        viewers = resultModel.viewers
        if user in viewers:
            viewers.remove(user)
            viewers.insert(0, user)
        for viewer in viewers:
            viewerElement = ElementTree.SubElement(retElement, 'Viewer')
            viewerElement.set('nickname', viewer.nickname().split('@')[0])
            viewerElement.set('id', viewer.user_id())

        return retElement

def main():
    application = webapp.WSGIApplication(
    [   ('.*/main', MainHandler),
    ], debug=False)
    wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
  main()
