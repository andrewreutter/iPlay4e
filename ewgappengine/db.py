"""
Provides a dropin replacement for google.appengine.ext.db; change this:

    from google.appengine.ext import db
to:
    from ewgappengine import db

then create subclasses of db.Model as usual, including the creation of db.Property
subclass instances.

What does this get you?

- Extended Model class: when you subclass db.Model, you gain the following
  additional functionality:

    - Referential integrity via support for the ReferenceListProperty class.
      See below for more information.

    - Pretty names for classes (used by ewgappengine.management).  Calling the getPrettyClassName()
      method, or accessing the prettyClassName property of a Model class or instance will return
      the name of the class, unless the PRETTY_CLASS_NAME call variable has been set, in which case
      it will be returned instead.

    - Default ordering and string representations via the NAME_PROPERTY class variable.
      If you define this variable:
      
        - Calling get() with no arguments will return model objects sorted by the specified property.

        - The value for the specified property will become the default string representation.

      Example:

        class Tag(db.Model):
            NAME_PROPERTY = 'name'
            name = db.StringProperty(required=True)

        tags = Tag.get() # will be ordered by name.
        for tag in tags: # print a list of each tag's name.
            print tag

    - Class and instance-scoped caching via memcache.  
      For our example, we want to cache both the individual and aggregate
      HTML representations of our tags.

        tagToHTML = lambda t: '<div>%s</div>' % t
        getAllTags = lambda T: T.get()
        getAllTagsHTML = lambda T: ''.join( [ t.getEntityCache( 'html' ) for t in T.getKindCache( 'all' ) ] )
        Tag.setEntityCacheFunctionForKey( tagToHTML, 'html' )
        Tag.setKindCacheFunctionForKey( getAllTags, 'all' )
        Tag.setKindCacheFunctionForKey( getAllTagsHTML, 'html' )

        tagsHTML = Tag.getKindCache( 'html' ) # builds the cache, both Kind and Entity level
        tagsHTML = Tag.getKindCache( 'html' ) # now blazingly fast

      Any time put() or delete() is called on an instance of the class, the cache for that Entity 
      is cleared, as is the cache for the Kind.  In addition, as referential integrity is enforced
      for ReferenceListProperty references, the cache responds as well.

      To disable caching, call db.disableCaching().  To reenable it, call db.enableCaching().

- New property type: ReferenceListProperty.  This acts much like a ListProperty(db.Key),
  with the following differences and added functionality:

    - Instantiate with another model class instead of the db.Key data type, e.g.:

        from ewgappengine import db

        class Tag(db.Model):
            name = db.StringProperty(required=True)

        class Post(db.Model):
            title = db.StringProperty(required=True)
            text = db.TextProperty()
            tags = db.ReferenceListProperty(Tag)

      Note that this requires your classes to be defined in an order based on their
      dependencies on one another.

    - Within an instance of the model class containing the property, the property will 
      appear as a list of model instance instead of a list of keys:

        for post in Post.get():
            print post.title
            for tag in post.tags:
                print '\t', tag.name

      Note that the underlying data type is still a db.Key; you will need to be aware
      of these when creating gql queries.

    - Instances of the reference class automatically gain a property based on the name
      of the referring class.  This property provides a way of finding the objects that
      refer to it:

        for tag in Tag.get():
            print tag.name
            for post in tag.postReferrers:
                print '\t', post.title

    - Referential integrity maintenance.  Deleting an instance of the reference class will
      automatically delete all references to that instance found in the ReferenceListProperty
      valuse of other objects:

        tag.delete() # all Post objects will have any references to the tag removed.
"""

import os, cgi, re
from google.appengine.ext.db import *
from google.appengine.api import memcache
from google.appengine.ext.webapp import template
from google.appengine.api import users

CURRENT_USER = 42 # used for default with UserProperty to make current user default.

MEMCACHING = True
def disableCaching():
    global MEMCACHING
    MEMCACHING = False
def enableCaching():
    global MEMCACHING
    MEMCACHING = True

MEMCACHE_VERSION_TIME = '125688723017'

class WeakRefProp(property):
    pass
class RefProp(property):
    pass
class RefListProp(property):
    pass

_OldModel = Model
class Model(_OldModel):

    NAME_PROPERTY = None

    def getReferenceProperties(thisClass):
        return [ p for p in thisClass.properties().values() if isinstance(p, ReferenceProperty) ]
    getReferenceProperties = classmethod(getReferenceProperties)

    def __init__(self, *args, **kw):
        _OldModel.__init__( *(self,)+args, **kw )

        self.referrerProperties = [ prop for prop in self.properties().values() if isinstance(prop, ReferenceProperty) ]

        # Create magic attributes for each property in another class that refers to us.
        for propListName, PropClass in \
        (   ('referringListProperties', RefListProp),
            ('referringProperties', RefProp),
            ('weakReferringProperties', WeakRefProp),
        ):
            refProps = getattr( self, propListName, [] )
            for refProp in refProps:
                modelClass = refProp.model_class
                newProperty = PropClass( lambda s, rp=refProp: s.getReferrersViaProperty(rp) )
                newProperty.model_class = modelClass
                newProperty.name = refProp.name
                setattr( self.__class__, '%sReferrers' % modelClass.__name__.lower(), newProperty )

    @property
    def referringPropertiesInfo(self):
        return \
            [   {   'referringProperty': fp, 
                    'kind': fp.model_class.kind(),
                    'prettyClassName': fp.model_class.getPrettyClassName(),
                } for fp in getattr(self, 'referringProperties', [] ) ]

    def __str__(self):
        nameField = self.NAME_PROPERTY
        if nameField is None:
            return super(_OldModel,self).__str__()
        return getattr( self, nameField )

    def copy(self, **kw):

        # Start with a copy of ourselves, including all properties.
        propValues = {}
        for k in self.properties().keys():
            try:
                propValues[k] = getattr(self, k)
            except Error:
                continue
        if hasattr(self, 'owner'):
            propValues['owner'] = users.get_current_user()
        propValues.update(kw)
        newModel = self.__class__(**propValues)
        newModel.put()

        # Then find all the objects that we own and copy them as well.
        for refProp in getattr(self, 'referringProperties', []):
            referrers = self.getReferrersViaProperty(refProp)
            for referrer in referrers:
                referrer.copy( **{ refProp.name: newModel } )

        return newModel

    @property
    def prettyClassName(self):
        return self.getPrettyClassName()

    def getPrettyClassName(thisClass):
        return getattr( thisClass, 'PRETTY_CLASS_NAME', thisClass.__name__ )
    getPrettyClassName = classmethod(getPrettyClassName)

    @property
    def customViewNoCache(self):
        return self._customView(users.get_current_user())

    @property
    def customView( self ):
        user = users.get_current_user()
        cacheKey = 'customView' + ( ( user and user.email() ) or '' )
        self.setEntityCacheFunctionForKey( lambda m: m._customView(user), cacheKey )
        return self.getEntityCache( cacheKey )

    def _customView(self, user):

        fileName = getattr( self, 'CUSTOM_VIEW_FILE', '%s.html' % self.__class__.__name__ )
        fullPath = os.path.join( os.path.dirname(__file__), '..', 'html', fileName)
        templateDict = {'model':self, 'user': user}
        templateDict.update(self.getCustomViewDict())
        return template.render( fullPath, templateDict )

    def getCustomViewDict(self):
        """ Override in the subclass to provide variables for use in the custom view template.
        """
        return {}

    def get(thisClass, *args, **kw):
        if thisClass.NAME_PROPERTY is not None and ( not (args or kw) ):
            #logging.info('Using default sort %s for %s' % (thisClass.NAME_PROPERTY, thisClass.kind()))
            return Query(thisClass).order( thisClass.NAME_PROPERTY )
        try:
            return _OldModel.get(*args, **kw)
        except TypeError, e:
            raise RuntimeError, (thisClass, args, kw, str(e))
    get = classmethod(get)

    def put(self):
        # Clear my cache and the cache of everything I refer to.
        if MEMCACHING:
            self.clearCache()

            # Also clear the cache of everything that refers to me.
            if self.is_saved():
                for propListName in ('referringListProperties', 'referringProperties', 'weakReferringProperties'):
                    for refProp in getattr(self, propListName, []):
                        [ referrer.clearCache() for referrer in self.getReferrersViaProperty(refProp) ]


        return _OldModel.put(self)

    def delete(self):

        # Delete all the objects that refer to me as their owner.
        for referringProperty in getattr( self, 'referringProperties', [] ):
            for referrer in self.getReferrersViaProperty(referringProperty):
                referrer.delete()

        # Delete myself from objects that refer to me in a list.
        myKey = self.key()
        for referringListProperty in getattr( self, 'referringListProperties', [] ):
            for referrer in self.getReferrersViaProperty(referringListProperty):
                references = getattr( referrer, referringListProperty.name )
                for reference in references:
                    if reference.key() == myKey:
                        references.remove(reference)
                        break
                referrer.put()

        # Clear my cache and the cache of objects I refer to.
        if MEMCACHING:
            self.clearCache()

        _OldModel.delete(self)

    def addWeakReferringProperty(myClass, property):
        myClass.weakReferringProperties = getattr( myClass, 'weakReferringProperties', [] )
        myClass.weakReferringProperties.append(property)
    addWeakReferringProperty = classmethod(addWeakReferringProperty)

    def addReferringProperty(myClass, property):
        myClass.referringProperties = getattr( myClass, 'referringProperties', [] )
        myClass.referringProperties.append(property)
    addReferringProperty = classmethod(addReferringProperty)

    def addReferringListProperty(myClass, property):
        myClass.referringListProperties = getattr( myClass, 'referringListProperties', [] )
        myClass.referringListProperties.append(property)
    addReferringListProperty = classmethod(addReferringListProperty)

    def getReferrersViaProperty( self, referringListProperty ):
        myKey = self.key()
        logging.info('fetching ' + referringListProperty.model_class.__name__ + ' REFERRERS via ' + referringListProperty.name + ' = ' + str(myKey))
        ret = referringListProperty.model_class.gql('WHERE %s = :1' % referringListProperty.name, myKey)
        ret.model_class = referringListProperty.model_class
        ret.defaultDict = ret.model_class.defaultDict()
        return ret

    def setEntityCacheFunctionForKey( thisClass, buildFunction, keyName ):
        entityCacheMap = thisClass.entityCacheMap = getattr( thisClass, 'entityCacheMap', {} )
        entityCacheMap[keyName] = buildFunction
    setEntityCacheFunctionForKey = classmethod(setEntityCacheFunctionForKey)

    def setKindCacheFunctionForKey( thisClass, buildFunction, keyName ):
        kindCacheMap = thisClass.kindCacheMap = getattr( thisClass, 'kindCacheMap', {} )
        kindCacheMap[keyName] = buildFunction
    setKindCacheFunctionForKey = classmethod(setKindCacheFunctionForKey)

    def getEntityCache(self, keyName, *args, **kw):
        if args or kw:
            return self.getEntityCacheWithArgs(keyName, args, kw)

        cacheKey = '%s%s' % ( self.key(), keyName )
        cacheValue = (MEMCACHING and memcache.get(cacheKey + MEMCACHE_VERSION_TIME)) or None
        #logging.info('retrieved %s from memcache: %r' % (cacheKey,cacheValue))
        if cacheValue is None:
            buildFunction = self.entityCacheMap[keyName]
            cacheValue = buildFunction(self)
            if MEMCACHING:
                if not memcache.set(cacheKey + MEMCACHE_VERSION_TIME, cacheValue):
                    logging.error('memcache set of %s failed' % cacheKey)
        return cacheValue

    def getEntityCacheWithArgs(self, keyName, args, kw):
        cacheKey = '%s%sWithArgs' % ( self.key(), keyName )
        cacheDict = (MEMCACHING and memcache.get(cacheKey + MEMCACHE_VERSION_TIME)) or {}

        kwItems = kw.items()
        kwItems.sort()
        dictKey = '%(args)r%(kwItems)r' % locals()
        cacheValue = cacheDict.get(dictKey, None)

        if cacheValue is None:
            buildFunction = self.entityCacheMap[keyName]
            cacheValue = cacheDict[dictKey] = buildFunction(self, *args, **kw)
            if MEMCACHING:
                if not memcache.set(cacheKey + MEMCACHE_VERSION_TIME, cacheDict):
                    logging.error('memcache set of %s failed' % cacheKey)
        return cacheValue

    def getKindCache(thisClass, keyName, *args, **kw):
        if args or kw:
            return thisClass.getKindCacheWithArgs(keyName, args, kw)
        cacheKey = '%s%s' % ( thisClass.__name__, keyName )
        try:
            cacheValue = (MEMCACHING and memcache.get(cacheKey + MEMCACHE_VERSION_TIME)) or None
        except KeyError:
            logging.error('GOOGLE 417: memcache get of %s failing' % cacheKey)
            cacheValue = None
        logging.debug('cache lookup of key %r: %r' % ( cacheKey, cacheValue ))
        if cacheValue is None:
            buildFunction = thisClass.kindCacheMap[keyName]
            cacheValue = buildFunction(thisClass)
            if not memcache.set(cacheKey + MEMCACHE_VERSION_TIME, cacheValue):
                logging.error('memcache set of %s failed' % cacheKey)
        return cacheValue
    getKindCache = classmethod(getKindCache)

    def getKindCacheWithArgs(thisClass, keyName, args, kw):
        cacheKey = '%s%sWithArgs' % ( thisClass.__name__, keyName )
        cacheDict = (MEMCACHING and memcache.get(cacheKey + MEMCACHE_VERSION_TIME)) or {}
        innerCacheKeys = cacheDict.keys()
        logging.debug('found innerCacheKeys %(innerCacheKeys)r for cacheKey %(cacheKey)r' % locals())

        kwItems = kw.items()
        kwItems.sort()
        dictKey = '%(args)r%(kwItems)r' % locals()
        cacheValue = cacheDict.get(dictKey, None)
        logging.debug('%s find innerCacheValue' % ((cacheValue and 'did') or 'did NOT'))

        if cacheValue is None:
            buildFunction = thisClass.kindCacheMap[keyName]
            cacheValue = cacheDict[dictKey] = buildFunction(thisClass, *args, **kw)
            if MEMCACHING:
                if not memcache.set(cacheKey + MEMCACHE_VERSION_TIME, cacheDict):
                    logging.error('memcache set of %s failed' % cacheKey)
        return cacheValue
    getKindCacheWithArgs = classmethod(getKindCacheWithArgs)

    def clearCache(self, alreadyClear = []):
        if not MEMCACHING:
            return

        className = self.__class__.__name__
        for keyName in getattr( self, 'kindCacheMap', {} ).keys():
            self._deleteFromMemcache('%s%s' % ( className, keyName ) )
            self._deleteFromMemcache('%s%sWithArgs' % ( className, keyName ) )
        if self.is_saved():
            myKey = self.key()
            for keyName in getattr( self, 'entityCacheMap', {} ).keys():
                self._deleteFromMemcache('%s%s' % ( myKey, keyName ) )
                self._deleteFromMemcache('%s%sWithArgs' % ( myKey, keyName ) )

        # Delete cache of objects I refer to, making sure to avoid circularity.
        alreadyClear.append(self)
        referredObjects = [ self.__getReferredObjectIfExists(prop) for prop in self.referrerProperties ]
        [ ro.clearCache(alreadyClear) for ro in referredObjects if ro and ro not in alreadyClear ]

    def __getReferredObjectIfExists(self, property):
        try:
            return getattr(self, property.name)
        except Error:
            return None

    def _deleteFromMemcache(self,key):
        delSuccess = memcache.delete(key + MEMCACHE_VERSION_TIME)
        if delSuccess == memcache.DELETE_SUCCESSFUL:
            logging.info('memcache delete of %s succeeded' % key)
        elif delSuccess == memcache.DELETE_ITEM_MISSING:
            logging.info('memcache delete of %s failed because key was missing' % key)
        elif delSuccess == memcache.DELETE_NETWORK_FAILURE:
            logging.error('memcache delete of %s failed for unknown reasons' % key)
        else:
            logging.error('memcache delete of %s unexpectedly returned %d' % (key, delSuccess))

    @property
    def showsChildren(self):
        if not hasattr(self, 'LIST_ITEM_PROPERTIES'):
            return False
        for lip in self.LIST_ITEM_PROPERTIES:
            if lip[-9:] == 'Referrers':
                return True
        return False

    def defaultDict(thisClass, toJavascript=1):
        retDict = {}
        for propName, propObject in thisClass.properties().items():
            defaultValue = propObject.default_value()
            if defaultValue is not None:
                #logging.debug('Testing %r: %r' % (propName, defaultValue))
                if toJavascript:
                    if defaultValue == []:
                        continue
                    elif defaultValue == True:
                        defaultValue = 1
                    elif defaultValue == False:
                        defaultValue = 0
                    elif isinstance(propObject, UserProperty):
                        defaultValue = defaultValue.email()
                retDict[propName] = defaultValue
                #logging.debug('Added %r: %r' % (propName, defaultValue))
        return retDict
    defaultDict = classmethod(defaultDict)

    def propertyToParagraphs(self, propName):
        paragraphs = getattr(self, propName).split('\n')
        pieces = []
        first = 1
        for i in range(len(paragraphs)):
            paragraph = paragraphs[i]
            if not paragraph:
                pieces.append('<br>')
                first = 1
            else:
                className = ( first and 'First' ) or ''
                escapedParagraph = cgi.escape(paragraph)
                escapedParagraph = self.wikiText(escapedParagraph)
                pieces.append( '<div class="p %(className)s">%(escapedParagraph)s</div>' % locals() )
                first = 0
        return '\n'.join(pieces)

    def wikiText(self, theText):
        theText = re.sub( r"'''(?P<itext>.*?)'''", r'<b>\g<itext></b>', theText )
        theText = re.sub( r"''(?P<itext>.*?)''", r'<i>\g<itext></i>', theText )
        return theText

_OldReferenceProperty = ReferenceProperty

class WeakReferenceProperty(_OldReferenceProperty):
    """ A reference to a model of a specified type.
    """

    def __init__(self, referenceClass, **kw):
        self.autoFilter = kw.pop('autoFilter', lambda x:x)
        super(WeakReferenceProperty,self).__init__(referenceClass, **kw)
        self.reference_class = referenceClass
        self.reference_class.addWeakReferringProperty(self)

    def validate(self, value):
        value = super(WeakReferenceProperty,self).validate(value)
        if value is not None:
            try:
                valueKey = value.key()
            except AttributeError:
                valueKey = value
        return value

class ReferenceProperty(_OldReferenceProperty):
    """ A reference to a model of a specified type that owns us.
    """

    def __init__(self, referenceClass, **kw):
        super(ReferenceProperty,self).__init__(referenceClass, **kw)
        self.reference_class = referenceClass
        self.reference_class.addReferringProperty(self)

class ReferenceListProperty(ListProperty):
    """ A list of keys, all pointing to models of the same type.
    """

    def __init__( self, reference_class, **kw ):
        self.autoFilter = kw.pop('autoFilter', lambda x:x)
        super(ReferenceListProperty,self).__init__( Key, **kw )

        self.reference_class = reference_class
        self.reference_class.addReferringListProperty(self)

    def validate(self, value):
        value = super(ListProperty, self).validate(value)
        if value is not None:
            if not isinstance(value, list):
                raise BadValueError('Property %s must be a list' % self.name)
            referenceClass = self.reference_class
            for item in value:
                try:
                    valueKey = item.key()
                except AttributeError:
                    raise BadValueError('Items in the %s list must have or be keys, got %r' % (self.name, value))
        #logging.debug('validate %s: %r' % (self.reference_class.__name__, value))
        return value

    def get_value_for_datastore(self, modelInstance):
        ret = [ v.key() for v in super(ReferenceListProperty,self).get_value_for_datastore(modelInstance) ]
        #logging.debug('get_value_for_datatore %s: %r' % (self.reference_class.__name__, ret))
        return ret

    def make_value_from_datastore(self, value):
        ret = [ get(key) for key in value ]
        return ret

_OldStringProperty = StringProperty
class StringProperty(_OldStringProperty):

    def validate(self,value):
        try:
            if str(value) == '---------':
                value = u''
        except:
            pass
        return super(StringProperty,self).validate(value)

_OldUserProperty = UserProperty
class UserProperty(_OldUserProperty):

    def __init__(self, *args, **kw):
        self.__currentUserAsDefault = ( kw.pop('default', None ) == CURRENT_USER )
        super(UserProperty,self).__init__(*args, **kw)

    def default_value(self):
        return (self.__currentUserAsDefault and users.get_current_user()) or super(UserProperty,self).default_value()
