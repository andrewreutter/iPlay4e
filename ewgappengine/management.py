import os, types, logging

from google.appengine.api import users, images
from google.appengine.ext.webapp import template
from ewgappengine import db, djangoforms
from google.appengine.api import memcache
from django.core.paginator import ObjectPaginator, InvalidPage
from handlers import AuthenticatingHandler

class ManagementHandler(AuthenticatingHandler):

    def renderManagementTemplate( self, templateDict, fileName ):
        myDir = os.path.dirname(__file__)
        fullPath = os.path.join( myDir, '..', 'ewgappengine', 'html', fileName )
        return template.render( fullPath, templateDict )

class MultiManagementInterface:

    def __init__(self):
        self.managementInterfaces = []

    def fromModelModule(self, modelModule):
        modelClasses = [ getattr( modelModule, moduleAttr ) for moduleAttr in dir(modelModule) ]
        modelClasses = [ mc for mc in modelClasses if hasattr(mc, 'NAME_PROPERTY') ]
        [ self.addManagementInterface(djangoforms.autoForm(mc)) for mc in modelClasses ]
        return self

    def fromFormModule( self, formModule ):
        moduleAttrs = dir(formModule)
        moduleObjects = [ getattr( formModule, moduleAttr ) for moduleAttr in moduleAttrs ]
        [ self.addManagementInterface(mo) for mo in moduleObjects if hasattr( mo, 'Meta' ) ]
        return self

    def addManagementInterface( self, formClass ):
        managementInterface = ManagementInterface(formClass)
        managementInterface.MMI = self
        self.managementInterfaces.append( managementInterface )

    def getUrlHandlerTuples( self, nonAdminRedirect=None ):
        retTuples = []
        [ [ retTuples.append( uht ) for uht in mi.getUrlHandlerTuples() ] for mi in self.managementInterfaces ]
        self.MMHandler.MMI = self
        self.MMHandler.nonAdminRedirect = nonAdminRedirect
        retTuples.append(('/', self.MMHandler))
        return retTuples

    class MMHandler(ManagementHandler):

        def getAuthenticated(self, user, logoutUrl):
            # You best be an admin!
            if not users.is_current_user_admin():
                if self.nonAdminRedirect:
                    self.redirect(self.nonAdminRedirect)
                else:
                    self.redirect(logoutUrl)
                return

            # If we are part of a multi-management interface, create navigation.
            modelClasses = \
                [ mi.modelClass for mi in self.MMI.managementInterfaces if not mi.modelClass.getReferenceProperties() ]
            modelClassNames = [ mc.__name__ for mc in modelClasses ]
            modelClassPrettyNames = [ mc.getPrettyClassName() for mc in modelClasses ]
            modelClassNameNames = [ mc.NAME_PROPERTY for mc in modelClasses ]
            managementNav = ''.join( [ '<a href="#%s">%s</a>' % (mcn,mcpn) for mcn, mcpn in zip(modelClassNames, modelClassPrettyNames) ] )
            self.response.out.write(self.renderManagementTemplate(locals(), 'Page.html'))

        def getUnauthenticated(self, loginUrl):
            if self.nonAdminRedirect:
                return self.redirect( self.nonAdminRedirect )
            super(MMHandler,self).getUnauthenticated(loginUrl)

class ManagementInterface(ManagementHandler):

    MMI = None # Will get updated with a reference to our MultiManagementInterface, if any.

    def getUrlHandlerTuples(self):
        modelClassName = self.modelClassName
        retTuples = \
            [   ('/%s/list' % modelClassName, self.ListPage ),
                ('/%s/list/[0-9]*' % modelClassName, self.ListPage ),
                ('/%s/table' % modelClassName, self.TablePage ),
                ('/%s/save' % modelClassName, self.SaveHandler ),
                ('/%s/viewprop' % modelClassName, self.ViewPropHandler ),
                ('/%s/saveprop' % modelClassName, self.SavePropHandler ),
                ('/%s/editprop' % modelClassName, self.EditPropHandler ),
                ('/%s/delete' % modelClassName, self.DeleteHandler ),
                ('/%s/edit' % modelClassName, self.EditPage ),
                ('/%s/view' % modelClassName, self.ViewPage ),
            ]

        # Add URLs for our referring classes of the form: /Model1/key/Model2/table
        for refProp in getattr(self.modelClass, 'referringProperties', []):
            refClass = refProp.model_class
            refUrl = '/%s/.*/%s/table' % (modelClassName, refClass.__name__)
            refHandler = self.__class__(djangoforms.autoForm(refClass)).TablePage
            retTuples.append( (refUrl, refHandler) )
        return retTuples

    def modelToListItemHTML( self, model, parent, propertyName):
        modelClass = model.__class__
        modelClassName = modelClass.__name__
        modelKey = model.key()
        listItemValues = []
        listItemWrappables = []
        for attrName in model.LIST_ITEM_PROPERTIES:
            listItemValue = getattr( model, attrName )
            listItemProperty = getattr( model.__class__, attrName )
            listItemPropertyClass = listItemProperty.__class__
            if issubclass(listItemPropertyClass, db.ListProperty):
                listItemWrappables.append(False)
                listItemValue = ', '.join( str(liv) for liv in listItemValue )
            elif issubclass(listItemPropertyClass, db.RefProp):
                listItemWrappables.append(False)
                referringPropertyName = listItemProperty.name
                referringClass = listItemProperty.model_class
                referringClassName = referringClass.__name__
                referringClassNameProp = referringClass.NAME_PROPERTY
                numReferrers = model.getReferrersViaProperty(listItemProperty).count(1000)
                listItemValue = \
                """ 
                    <a href="" 
                     onclick="fetchSubModels(this,'%(modelKey)s', '%(referringClassName)s', '%(referringPropertyName)s', '%(referringClassNameProp)s');return false;"
                    >View %(numReferrers)d...</a>
                """ % locals()
            elif listItemPropertyClass is db.TextProperty:
                listItemWrappables.append(True)
            else:
                listItemWrappables.append(False)
            listItemValues.append(listItemValue)

        listItemDefs = \
            [ {'value':value, 'wrappable':wrappable} for value, wrappable in zip(listItemValues, listItemWrappables) ]
        numValuesPlusOne = len(listItemValues) + 1
        return self.renderManagementTemplate( locals(), 'ListItem.html' )

    def buildListHTML(self, pageNumber, propertyName, parent):
        modelClass, modelClassName = self.modelClass, self.modelClassName
        modelClassDisplayName = modelClass.getPrettyClassName()
        if propertyName and parent:
            gql = 'WHERE %s = :1 ORDER BY %s' % (propertyName,modelClass.NAME_PROPERTY)
            #logging.debug(gql + '(' + parent + ')')
            models = ( propertyName and modelClass.gql(gql, db.get(parent)) ) or modelClass.get()
        else:
            models = modelClass.all()

        paginator = ObjectPaginator(models, 10, orphans=2)
        if paginator.pages < pageNumber:
            pageNumber = paginator.pages
        pageNumber0 = pageNumber - 1
        models = paginator.get_page(pageNumber0)

        firstOnPage, lastOnPage, numModels = \
            paginator.first_on_page(pageNumber0), paginator.last_on_page(pageNumber0), paginator.hits
        hasPreviousPage, hasNextPage = \
            paginator.has_previous_page(pageNumber0), paginator.has_next_page(pageNumber0)
        previousPage, nextPage = pageNumber -1, pageNumber + 1

        listItems = []
        for model in models:
            modelToListItemHTML = \
                lambda model, s=self, p=parent, pn=propertyName: s.modelToListItemHTML(model,p,pn)
            cacheKey = 'listItemHTML' + parent
            self.modelClass.setEntityCacheFunctionForKey(modelToListItemHTML, cacheKey)
            listItems.append(model.getEntityCache(cacheKey))
        listItems = '\n'.join(listItems)
        return self.renderManagementTemplate(locals(), 'List.html')

    def getModelPageNumber(self, model):
        modelKey = model.key()
        allModels = self.modelClass.get()
        paginator = ObjectPaginator(allModels, 10, orphans=2)
        for pageNumber in range( paginator.pages ):
            for thisModel in paginator.get_page(pageNumber):
                if thisModel.key() == modelKey:
                    return pageNumber

    def __init__( self, formClass ):
        self.formClass, self.pageTemplate = formClass, 'Body.html'

        self.modelClass = formClass.Meta.model
        self.modelClassName = modelClassName = self.modelClass.__name__
        self.listCacheKey = '%sListHTML' % modelClassName
        self.listTemplate = '%sList.html' % modelClassName

        class TablePage(ManagementHandler):
            MI = None

            def getTableHTML(self, user, logoutUrl):
                propertyName = self.request.get('prop') or ''
                parent = self.request.get('parent') or ''
                try:
                    pageNumber=int(self.request.get('page'))
                except ValueError:
                    pageNumber = 1

                # Build (or retrieve from cache) the HTML for that page of models.
                modelClass, modelClassName = self.MI.modelClass, self.MI.modelClassName
                cacheKey = 'listhtml%(pageNumber)d%(parent)s' % locals()
                getListHTML = lambda MC, s=self.MI, pn=pageNumber: s.buildListHTML(pn, propertyName, parent)
                modelClass.setKindCacheFunctionForKey(getListHTML, cacheKey)
                return self.MI.modelClass.getKindCache(cacheKey)

            def postAuthenticated(self, user, logoutUrl):
                self.response.out.write(self.getTableHTML(user, logoutUrl))
            getAuthenticated = postAuthenticated
        
        class ListPage(TablePage):
            MI = None
        
            def getAuthenticated(self, user, logoutUrl):
                return self.show(user, logoutUrl)
            postAuthenticated = getAuthenticated

            def show(self, user, logoutUrl, form=None, model=None, togglePage=0, fullPage=1, reloadOnCancel=0):
                modelClass, modelClassName = self.MI.modelClass, self.MI.modelClassName
                modelClassDisplayName = modelClass.getPrettyClassName()
                modelClassNamePropName = modelClass.NAME_PROPERTY
                parent = self.request.get('parent')
                propertyName = self.request.get('prop')
                form = form or self.MI.formClass()
                managementNew = self.renderManagementTemplate( locals(), 'management.html' )
                if fullPage:
                    listHTML = self.getTableHTML(user, logoutUrl)
                    self.response.out.write( self.renderManagementTemplate( locals(), self.MI.pageTemplate ) )
                else:
                    self.response.out.write(managementNew)

            def redirectToList(self, pageWithModel, displayType='list', returnUrl=0):
                parent = self.request.get('parent') or ''
                parent = ( parent and '&parent=%s' % parent ) or ''
                prop = self.request.get('prop') or ''
                prop = ( prop and '&prop=%s' % prop ) or ''
                retUrl = '/%s/%s?page=%d%s%s' % ( self.MI.modelClassName, displayType, pageWithModel+1, parent, prop )
                if returnUrl:
                    return retUrl
                return self.redirect( retUrl )

            def getEditPropForm(self, form, model, showProp, propNames):

                modelClassName = self.MI.modelClassName
                modelKey = model.key()
                propInputs = '\n'.join( \
                    [ '<input type="hidden" name="prop" value="%s">' % propName for propName in propNames ] )
                return \
                    u"""<form method="POST" action="/%(modelClassName)s/saveprop"
                         id="editForm%(modelClassName)s%(modelKey)s"
                         enctype="multipart/form-data"
                        >
                            <table>
                                %(form)s
                                <tr>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <input name="_action" type="submit" value="Submit">
                                        <input type="button" class="Cancel" value="Cancel">
                                    </td>
                                </tr>
                            </table>
                            <input type="hidden" name="_key" value="%(modelKey)s">
                            <input type="hidden" name="showProp" value="%(showProp)s">
                            %(propInputs)s
                        </form>
                    """ % locals()

        class DeleteHandler(ListPage):
            MI = None
        
            def getAuthenticated(self, user, logoutUrl):
                model = self.MI.modelClass.get(self.request.get('key'))
                if model:
                    pageWithModel = (model and self.MI.getModelPageNumber(model)) or 0
                    model.delete()
                else:
                    pageWithModel = 0

                if self.request.get('noview'):
                    self.response.out.write(' ')
                else:
                    return self.redirectToList(pageWithModel, displayType='table')

            postAuthenticated = getAuthenticated

        class EditPropHandler(ListPage):
            MI = None

            def getAuthenticated(self, user, logoutUrl):
                key = self.request.get('_key')
                if key == 'NEW':
                    defaultDict = self.MI.modelClass.defaultDict(toJavascript=0)
                    model = self.MI.modelClass(**defaultDict)
                    model.put()
                else:
                    model = (key and self.MI.modelClass.get(key)) or None
                showProp = self.request.get('showProp', None)
                propNames = self.request.get('prop', None, allow_multiple=True)
                if not (model and showProp and propNames):
                    self.response.out.write('ERROR! model or property missing')
                    return

                form = djangoforms.autoFormForProperties(self.MI.modelClass, propNames)(instance=model)
                self.response.out.write(self.getEditPropForm(form, model, showProp, propNames))
                
            postAuthenticated = getAuthenticated

        class ViewPropHandler(ListPage):
            MI = None

            def postAuthenticated(self, user, logoutUrl):
                key = self.request.get('_key')
                model = (key and self.MI.modelClass.get(key)) or None
                showProp = self.request.get('showProp', None)
                if (model and showProp):
                    propValue = getattr(model, showProp)
                    self.response.out.write(propValue)
            getAuthenticated = postAuthenticated

        class SavePropHandler(ViewPropHandler):
            MI = None

            def postAuthenticated(self, user, logoutUrl):
                key = self.request.get('_key')
                model = (key and self.MI.modelClass.get(key)) or None
                showProp = self.request.get('showProp', None)
                propNames = self.request.get('prop', None, allow_multiple=True)
                if not (model and showProp and propNames):
                    self.response.out.write('ERROR! model or property missing')
                    return

                for blobName in ('imageData', 'dnd4eData'):
                    if blobName in propNames:
                        propNames.remove(blobName)
                        imageData = self.request.get(blobName)
                        try:
                            theImage = images.Image(imageData)
                            theImage.resize(width=323)
                            imageData = theImage.execute_transforms()
                        except images.Error:
                            imageData = None
    
                        if imageData:
                            model.imageData = db.Blob(imageData)
                            model.put()
    
                        # If that was the only property, we're done.
                        if not propNames:
                            if imageData:
                                self.response.out.write('<div class="Response" style="display:none;">')
                                super(SavePropHandler,self).postAuthenticated(user,logoutUrl)
                                self.response.out.write('</div>')
                            else:
                                logging.debug('invalid imageData for SaveProp in ' + str(self.request.POST))
                                data = djangoforms.autoFormForProperties(self.MI.modelClass, [blobName])(instance=model)
                                self.response.out.write('<font color="red">Invalid image file</font>')
                                self.response.out.write( self.getEditPropForm(data, model, showProp, [blobName]))
                                return
    
                # If the user input was bad, redisplay the edit form.
                data = djangoforms.autoFormForProperties(self.MI.modelClass, propNames)(self.request.POST, instance=model)
                if not data.is_valid():
                    logging.debug('invalid data for SaveProp in ' + str(self.request.POST))
                    self.response.out.write( self.getEditPropForm(data, model, showProp, propNames))
                    return
                #else:
                    #logging.debug('valid data for SaveProp in ' + str(self.request.POST))

                # Otherwise, save and display the new property value in a div that js will
                # pluck from.  We do it this way so the content is invisible instead of flashing
                # in the modalbox briefly.
                if self.request.get('_action') != 'Cancel':
                    model = data.save()
                self.response.out.write('<div class="Response" style="display:none;">')
                super(SavePropHandler,self).postAuthenticated(user,logoutUrl)
                self.response.out.write('</div>')

        class SaveHandler(ListPage):
            MI = None
        
            def postAuthenticated(self, user, logoutUrl):
                # Are we editing or creating?
                key = self.request.get('_key')
                model = (key and self.MI.modelClass.get(key)) or None

                # If the data is bad, redisplay the editing form.
                data = self.MI.formClass(self.request.POST, getattr(self.request, 'FILES', None), instance=model)
                if not data.is_valid():
                    form=data
                    logging.debug('invalid data in '+str(self.request.POST))
                    return self.show(user, logoutUrl, form=form, model=model, togglePage=((key and 2) or 1), fullPage=0)

                # Save the object.
                #logging.info('valid data in '+str(self.request.POST))
                newObject = data.save(commit=False)
                prop, parent = self.request.get('prop'), self.request.get('parent')
                if prop and parent:
                    setattr(newObject, prop, db.get(parent))

                if self.request.get('_action') != 'Cancel':
                    newObject.put()

                if self.request.get('_action') == 'Save and Continue':
                    return self.show(user, logoutUrl, form=data, model=newObject, togglePage=1, fullPage=0, reloadOnCancel=1)

                if self.request.get('customview'):
                    self.response.out.write(newObject.customView)
                    return

                modelClassName = newObject.__class__.__name__
                pageWithModel = self.MI.getModelPageNumber(newObject)
                targetUrl = self.redirectToList(pageWithModel, returnUrl=1)
                retHtml = \
                """ <div id="tempRedirector"><img src="/images/DivLoadingSpinner.gif"></div>
                    <script>
                        var targetDiv = $('tempRedirector').parentNode.parentNode.parentNode;
                        getUrlIntoDiv('%(targetUrl)s', targetDiv,
                        [   function() 
                            {   initModelToggle( '%(modelClassName)s', '%(parent)s', 0 );
                            }
                        ], {cacheUrl:1,refreshUrl:1} );
                    </script>
                """ % locals()
                self.response.out.write(retHtml)

            getAuthenticated = postAuthenticated
        
        class EditPage(ListPage):
            MI = None

            def postAuthenticated(self, user, logoutUrl):

                # Find out what model we're editing or copying.
                parent = self.request.get('parent') or ''
                propertyName = self.request.get('prop') or ''
                key = self.request.get('key')
                model = self.MI.modelClass.get(key)

                # If we're copying, go ahead and do so.
                copying = self.request.get('copy')
                if copying:
                    model = model.copy(basedOn=model)
                    key = model.key
                    reloadOnCancel = 1
                else:
                    reloadOnCancel = 0

                # If we were asked for the custom view of the new object, give it.
                if self.request.get('customview'):
                    self.response.out.write(model.customView)
                    return

                # Build and display a form for editing it.
                form=self.MI.formClass(instance=model)
                modelClassName = self.MI.modelClassName
                modelClassDisplayName = self.MI.modelClass.getPrettyClassName()
                modelClassNamePropName = self.MI.modelClass.NAME_PROPERTY
                managementNew = self.renderManagementTemplate( locals(), 'management.html' )
                self.response.out.write(managementNew)

            getAuthenticated = postAuthenticated

        class ViewPage(ManagementHandler):

            def getAuthenticated(self, user, logoutUrl):
                key = self.request.get('key')
                model = db.get(key)
                pageBody = model.customView
                if self.request.get('printLink'):
                    modelClassName = model.__class__.__name__
                    parent = self.request.get('parent')
                    pageBody = \
                    u"""<div class="ManagementTableNav">
                            <input type="button" value="Print" 
                             onclick="printCustomModel('%(modelClassName)s','%(key)s');return false;"
                            >
                            <input type="button" value="Done" 
                             onclick="MODEL_TOGGLES['modelToggle%(modelClassName)s%(parent)s'].toggle(0,null,null);"
                            >
                        </div>
                        %(pageBody)s
                    """ % locals()
                elif self.request.get('print'):
                    # Autoprinting is stupid, and has timing issues with the pagination script.
                    #pageBody = \
                        #u"""<script>Event.observe( window, 'load', window.print );</script>%(pageBody)s""" % locals()
                    pageBody = self.renderManagementTemplate(locals(), 'Page.html')
                self.response.out.write(pageBody)
            postAuthenticated = getAuthenticated

        for magicClass in (ListPage, SaveHandler, EditPropHandler, ViewPropHandler, SavePropHandler, DeleteHandler, EditPage, TablePage, ViewPage):
            magicClass.MI = self
            setattr(self, magicClass.__name__, magicClass)
