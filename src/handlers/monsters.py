import characters
from IP4ELibs import BaseHandler

class MainHandler(characters.MainHandler):
    TYPE = 'Monster'

def main():
    BaseHandler.BaseHandler.main(MainHandler)

if __name__ == '__main__':
    main()
