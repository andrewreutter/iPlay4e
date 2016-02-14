import StringIO
import xml.dom.minidom
from xml.etree import ElementTree
from google.appengine.ext import db
from google.appengine.runtime import apiproxy_errors

class HasIP4XML:
    """ Mixed into Character, Monster, etc...to enable conversion of WOTC data to IP4XML.
        Those classes must:
            - define an ip4XML BlobProperty.
            - define an xmlVersion IntegerProperty.
            - define an XML_VERSION class constant, which increments if XML should be recalculated for all objects.
            - define the buildDom() method which will be used to generate ip4XML at need.
    """

    class DomTooLargeError(Exception):
        pass

    def buildDom(self):
        className = self.__class__.__name__
        raise RuntimeError, '%(className)s must implement buildDom()' % locals()

    def toXML(self):
        """ Get my XML, preferably from storage, but if necessary by building (and storing) it for the first time.
        """
        from IP4ELibs import models

        if self.xmlVersion != self.XML_VERSION:
            self.ip4XML = None
            self.xmlVersion = self.XML_VERSION

        # This is a little whack; toDom() causes self.ip4XML to get populated.
        return self.ip4XML and self.ip4XML or (self.toDom() and self.ip4XML)

    def toDom(self):
        """ Get my DOM, preferable by parsing stored IP4XML, but if necessary by building (and storing) it.
        """

        if self.ip4XML:
            ret = self.buildDomFromIP4XML()
        else:
            ret = self.saveDom(self.buildDom())
        return ret

    def saveDom(self, theDom):
        stringIO = StringIO.StringIO()
        #try:
        theDom.write(stringIO)
        #except TypeError:
            #raise RuntimeError, 'could not write DOM: %r, %s' % (theDom, theDom)
        self.ip4XML = stringIO.getvalue()
        stringIO.close()
        try:
            self.put()
        except apiproxy_errors.RequestTooLargeError:
            raise self.DomTooLargeError, 'this character is too large for iPlay4e, please try another'
        return theDom

    def buildDomFromIP4XML(self):
        # This branch allows for a couple different versions of the XML libraries...
        try:
            xmlObject = xml.etree.ElementTree.fromstring(self.ip4XML)
        except Exception, errorMessage:
            ip4XML = self.ip4XML
            raise RuntimeError, '%(errorMessage)s: %(ip4XML)s' % locals()
        return hasattr(xmlObject, 'getroot') and xmlObject.getroot() or xmlObject
