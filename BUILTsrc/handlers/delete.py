from google.appengine.api import users

from IP4ELibs import models, BaseHandler

class MainHandler(BaseHandler.BaseHandler):

    def get(self):
        self.response.headers['Content-Type'] = 'text/javascript'

        user = users.get_current_user()
        try:
            model = self.getAuthorizedModelOfClasses(self.DELETE, models.getSearchableClasses())
        except ValueError:
            return

        model.delete()
        if self.request.referrer.count('/search/'):
            return self.response.out.write('parent.location.reload();')
        else:
            return self.response.out.write('parent.location = "%s"' \
                % self.request.referrer.replace('%s/main' % self.request.get('key'), ''))

def main():
    BaseHandler.BaseHandler.main(MainHandler)
if __name__ == '__main__':
    main()
