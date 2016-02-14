import StringIO, zipfile, os

from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):

        self.response.out.write('<html><body>')
        for hkey in self.request.headers:
            self.response.out.write('%s: %s<br/>' % (hkey, self.request.headers[hkey]))
        self.response.out.write('</body></html>')

def main():
    BaseHandler.BaseHandler.main(MainHandler)
if __name__ == '__main__':
    main()
