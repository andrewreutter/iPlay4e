import StringIO, zipfile, os

from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    DEVICES_TO_MANIFESTS = \
    {   'iPad': """\
fullpageInstructions.html
characters/initialize?key=<key>
TIME_TOKEN/xsl/fullold.xsl
TIME_TOKEN/xsl/UI.xsl
TIME_TOKEN/css/combo.css
TIME_TOKEN/css/blueprint/print.css
TIME_TOKEN/js/combo.js
TIME_TOKEN/html/loading.html
TIME_TOKEN/html/loadingSimple.html
TIME_TOKEN/html/plain.html
TIME_TOKEN/images/folder_open_document.png
TIME_TOKEN/images/chevronsmall.png
TIME_TOKEN/images/DivLoadingSpinner.gif
TIME_TOKEN/images/chain.png
TIME_TOKEN/images/lock.png
TIME_TOKEN/images/minus_circle_small.png
TIME_TOKEN/images/plus_circle_small.png
TIME_TOKEN/images/exclamation-red-16.png
TIME_TOKEN/images/d2016px.png
TIME_TOKEN/images/eye.png""",
        'iPhone': """\
fullpageInstructions.html
characters/initialize?key=<key>
TIME_TOKEN/xsl/jPint.xsl
TIME_TOKEN/xsl/UIMobile.xsl
TIME_TOKEN/css/jPint.css
TIME_TOKEN/js/combo.js
TIME_TOKEN/js/jPint.js
TIME_TOKEN/html/loading.html
TIME_TOKEN/html/loadingSimple.html
TIME_TOKEN/html/plain.html
TIME_TOKEN/images/d2024px.png
TIME_TOKEN/images/build.png
TIME_TOKEN/images/lists.png
TIME_TOKEN/images/loot.png
TIME_TOKEN/images/combat.png
TIME_TOKEN/images/powers.png
TIME_TOKEN/images/question_frame.png
TIME_TOKEN/images/chevron.png
TIME_TOKEN/images/plus_circle.png""",
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
