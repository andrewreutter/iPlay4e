"""
Usage:

    getTwo = memcache.CachedFunction( lambda cf: 2, 'getTwo')
    getTwo() # Returns 2
    getTwo() # Returns 2 faster
    getTwo() # Returns 2 faster

"""

from google.appengine.api import memcache
import logging

class CachedFunction:

    def __init__(self, key, getFunction, time=0):
        self.key, self._getFunction, self.time = key, getFunction, time

    def __call__(self):

        cacheValue = memcache.get(self.key) or None
        logging.info('retrieved %s from memcache: %r' % (self.key,cacheValue))

        if cacheValue is None:
            cacheValue = self._getFunction(self)
            if not memcache.set(self.key, cacheValue, self.time):
                logging.error('memcache set of %s failed' % self.key)
            else:
                logging.info('memcache set of %s succeeded' % self.key)
        return cacheValue

    def clear(self):
        logging.info('clearing cache for %s' % self.key)
        memcache.delete(self.key)
