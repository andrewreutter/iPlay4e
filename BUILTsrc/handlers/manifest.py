import StringIO, zipfile, os

from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    DEVICES_TO_MANIFESTS = \
    {   'iPad': """\
fullpageInstructions.html
characters/initialize?key=<key>
145541695845/xsl/fullold.xsl
145541695845/xsl/UI.xsl
145541695845/css/combo.css
145541695845/css/blueprint/print.css
145541695845/js/combo.js
145541695845/html/loading.html
145541695845/html/loadingSimple.html
145541695845/html/plain.html
145541695845/images/folder_open_document.png
145541695845/images/chevronsmall.png
145541695845/images/DivLoadingSpinner.gif
145541695845/images/chain.png
145541695845/images/lock.png
145541695845/images/minus_circle_small.png
145541695845/images/plus_circle_small.png
145541695845/images/exclamation-red-16.png
145541695845/images/d2016px.png
145541695845/images/eye.png""",
        'iPhone': """\
fullpageInstructions.html
characters/initialize?key=<key>
145541695845/xsl/jPint.xsl
145541695845/xsl/UIMobile.xsl
145541695845/css/jPint.css
145541695845/js/combo.js
145541695845/js/jPint.js
145541695845/html/loading.html
145541695845/html/loadingSimple.html
145541695845/html/plain.html
145541695845/images/d2024px.png
145541695845/images/build.png
145541695845/images/lists.png
145541695845/images/loot.png
145541695845/images/combat.png
145541695845/images/powers.png
145541695845/images/question_frame.png
145541695845/images/chevron.png
145541695845/images/plus_circle.png""",
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
