from google.appengine.ext import webapp
import wsgiref.handlers

from BUILTsrc import handlers

def main():
    application = webapp.WSGIApplication(
    [   
        ('/view/?',                    handlers.view.MainHandler),
        ('/views/?',                   handlers.view.MultipleHandler),
        ('/.+/viewSheet/?',            handlers.view.MainHandler),

        ('/',                          handlers.index.MainHandler),
        ('/search/?',                  handlers.index.MainHandler),
        ('/forums/?',                  handlers.index.MainHandler),

        ('/migrate/?',                 handlers.index.MainHandler),
        ('/migrate/main',              handlers.characters.MigrateHandler),

        ('/poll/?',                    handlers.initialize.PollHandler),

        ('/sendinvites',               handlers.sendinvites.MainHandler),
        ('/savenotes',                 handlers.savenotes.MainHandler),

        ('/characters/?',              handlers.index.MainHandler),
        ('/characters/main',           handlers.characters.MainHandler),
        ('/characters/initialize',     handlers.initialize.MainHandler),
        ('/characters/savestate',      handlers.savestate.MainHandler),
        ('/characters/.*/main',        handlers.view.MainHandler),
        ('/characters/.*',             handlers.index.MainHandler),

        ('/campaigns/?',               handlers.index.MainHandler),
        ('/campaigns/save',            handlers.campaigns.SaveHandler),
        ('/campaigns/addplayers',      handlers.addplayers.MainHandler),
        ('/campaigns/addcharacters',   handlers.addcharacters.MainHandler),
        ('/campaigns/removeplayer',    handlers.removeplayer.MainHandler),
        ('/campaigns/removecharacter', handlers.removecharacter.MainHandler),
        ('/campaigns/main',            handlers.campaigns.MainHandler),
        ('/campaigns/initialize',      handlers.initialize.MainHandler),
        ('/campaigns/.*/main',         handlers.view.MainHandler),
        ('/campaigns/.*',              handlers.index.MainHandler),

        ('/main/?',                    handlers.main.MainHandler),
        ('/help/?',                    handlers.help.MainHandler),
        ('/new/?',                     handlers.newfeatures.MainHandler),
        ('/links/?',                   handlers.links.MainHandler),
        ('/terms/?',                   handlers.terms.MainHandler),
        ('/privacy/?',                 handlers.privacy.MainHandler),
        ('.*/googleGadget/?',          handlers.googlegadget.MainHandler),
        ('.*/googleGroup/?',           handlers.googleGroup.MainHandler),

        ('/tasks/searchindexing',      handlers.searchindexing.search.SearchIndexing),

        ('/search/.*',                 handlers.search_main.MainHandler),

        ('/monsters/.*',               handlers.monsters.MainHandler),
        ('/encounters/.*',             handlers.encounters.MainHandler),

        ('/auth',                      handlers.auth.MainHandler),

        ('/upload',                    handlers.upload.MainHandler),
        ('/savesettings',              handlers.savesettings.MainHandler),
        ('/campaigncreate',            handlers.campaigncreate.MainHandler),
        ('/replace',                   handlers.replace.MainHandler),
        ('/applyfixes',                handlers.applyfixes.MainHandler),
        ('/emailchanged',              handlers.emailchanged.MainHandler),
        ('/download',                  handlers.download.MainHandler),
        ('/delete/?',                  handlers.delete.MainHandler),
        ('/privatize',                 handlers.privatize.MainHandler),
        ('/publicize',                 handlers.publicize.MainHandler),
        ('/reporturl',                 handlers.reporturl.MainHandler),

        ('/quickfixes',                handlers.quickfixes.MainHandler),
        ('/changeowner',               handlers.changeowner.MainHandler),
        ('/emailtoid',                 handlers.emailtoid.MainHandler),
        ('/adddonatinguser',           handlers.adddonatinguser.MainHandler),
        ('/fixme',                     handlers.fixme.MainHandler),
        ('/manifest',                  handlers.manifest.MainHandler),
        ('/browserinfo',               handlers.browserinfo.MainHandler),
        ('/updatenextdonation',        handlers.updatenextdonation.MainHandler),
        ('/linksquad',                 handlers.linksquad.MainHandler),

        ('/proxywotc/.*',              handlers.wotc.ProxyHandler),
        ('/dditest',                   handlers.wotc.TestHandler),
        ('/compendium/?.*',            handlers.wotc.CompendiumHandler),

    ], debug=False)
    wsgiref.handlers.CGIHandler().run(application)

from IP4ELibs import autoretry_datastore_timeouts
autoretry_datastore_timeouts()

if __name__ == '__main__':
    #import cProfile,pstats
    #prof = cProfile.Profile()
    #prof = prof.runctx("main()", globals(), locals())
    #print "<div style='text-align:left;'><pre>"
    #stats = pstats.Stats(prof)
    #stats.sort_stats("time")
    #stats.print_stats(80)
    #stats.print_callees()
    #stats.print_callers()
    #print "</pre></div>"
    main()
