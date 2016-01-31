import StringIO, zipfile, os

from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    DEVICES_TO_MANIFESTS = \
    {   'iPad': """\
fullpageInstructions.html
characters/initialize?key=<key>
143371090575/xsl/fullold.xsl
143371090575/xsl/UI.xsl
143371090575/css/combo.css
143371090575/css/blueprint/print.css
143371090575/js/combo.js
143371090575/html/loading.html
143371090575/html/loadingSimple.html
143371090575/html/plain.html
143371090575/images/folder_open_document.png
143371090575/images/chevronsmall.png
143371090575/images/DivLoadingSpinner.gif
143371090575/images/chain.png
143371090575/images/lock.png
143371090575/images/minus_circle_small.png
143371090575/images/plus_circle_small.png
143371090575/images/exclamation-red-16.png
143371090575/images/d2016px.png
143371090575/images/eye.png""",
        'iPhone': """\
fullpageInstructions.html
characters/initialize?key=<key>
143371090575/xsl/jPint.xsl
143371090575/xsl/UIMobile.xsl
143371090575/css/jPint.css
143371090575/js/combo.js
143371090575/js/jPint.js
143371090575/html/loading.html
143371090575/html/loadingSimple.html
143371090575/html/plain.html
143371090575/images/d2024px.png
143371090575/images/build.png
143371090575/images/lists.png
143371090575/images/loot.png
143371090575/images/combat.png
143371090575/images/powers.png
143371090575/images/question_frame.png
143371090575/images/chevron.png
143371090575/images/plus_circle.png""",
    }

    def get(self):

        deviceType, key = self.request.get('device', None), self.request.get('key', None)
        if not key:
            return self.response.out.write('no key parameter provided')
        deviceManifest = self.DEVICES_TO_MANIFESTS.get(deviceType, None)
        if deviceManifest is None:
            return self.response.out.write('device parameter must be in %r' % (self.DEVICES_TO_MANIFESTS.keys(),))

        self.response.headers["Content-Type"] = 'text/cache-manifest'
        self.response.out.write(deviceManifest.replace('<key>', key))

def main():
    BaseHandler.BaseHandler.main(MainHandler)
if __name__ == '__main__':
    main()
