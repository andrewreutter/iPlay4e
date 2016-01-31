from IP4ELibs import BaseHandler

class MainHandler(BaseHandler.BaseHandler):

  def get(self):
    self.response.out.write('Hello encounters!')

def main():
    BaseHandler.BaseHandler.main(MainHandler)
if __name__ == '__main__':
    main()
