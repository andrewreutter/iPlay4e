import sys, os

from google.appengine.ext.db.djangoforms import *

# Remove the standard version of Django.
for k in [k for k in sys.modules if k.startswith('django')]:
    del sys.modules[k]
    sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))
    os.environ['DJANGO_SETTINGS_MODULE'] = 'settings'

# XXX Stuff from django that won't work live at Google.
def smart_unicode(s, encoding='utf-8', strings_only=False, errors='strict'): # was force_unicode
    """
    Similar to smart_unicode, except that lazy instances are resolved to
    strings, rather than kept as lazy objects.

    If strings_only is True, don't convert (some) non-string-like objects.
    """
    if strings_only and isinstance(s, (types.NoneType, int, long, datetime.datetime, datetime.date, datetime.time, float)):
        return s
    try:
        if not isinstance(s, basestring,):
            if hasattr(s, '__unicode__'):
                s = unicode(s)
            else:
                s = unicode(str(s), encoding, errors)
        elif not isinstance(s, unicode):
            # Note: We use .decode() here, instead of unicode(s, encoding,
            # errors), so that if s is a SafeString, it ends up being a
            # SafeUnicode at the end.
            s = s.decode(encoding, errors)
    except UnicodeDecodeError, e:
        raise DjangoUnicodeDecodeError(s, *e.args)
    return s

import django.template
from django.utils.html import escape

from itertools import chain
import db
import logging

def autoForm(modelClass):
    class NewForm(ModelForm):
        class Meta:
            model = modelClass
            exclude = [ p.name for p in modelClass.getReferenceProperties() ]
    return NewForm

def autoFormForProperties(modelClass, propNames):
    class NewForm(ModelForm):
        class Meta:
            model = modelClass
            exclude = [ p for p in modelClass.properties() if p not in propNames ]
    return NewForm

class EWGSelectMultiple(forms.SelectMultiple):

    def value_from_datadict( self, data, files, name ):
        ret = [ d[1] for d in data.items() if d[0] == name ]
        #logging.debug('value_from_datadict: %r' % (ret,))
        return ret

    def render(self, name, value, attrs=None, choices=()):
        if value is None: value = []
        has_id = attrs and attrs.has_key('id')
        final_attrs = self.build_attrs(attrs, name=name)
        str_values = set([smart_unicode(v) for v in value]) # Normalize to strings.

        # Loop through all of our options, collecting currently active ones into
        # one list, and inactive ones into another.
        finalName = final_attrs['name']
        unusedValues = []
        numSoFar = 0
        scriptPieces = \
        [u"""<ul></ul><script type="text/javascript" language="javascript">
                setTimeout( function() {
        """ ]
        for i, (option_value, option_label) in enumerate(chain(self.choices, choices)):
            smartLabel, smartValue = smart_unicode(option_label), escape(smart_unicode(option_value))
            if smartValue in str_values:
                optionIndex = i + 1 - numSoFar
                numSoFar += 1
                scriptPieces.append( \
                """ addListItem(%(optionIndex)d, $('select%(finalName)s'), '%(finalName)s');
                """ % locals() )
            unusedValues.append( (smartLabel,smartValue) )
        scriptPieces.append(u'}, 100);</script>')
        scriptHTML = u'\n'.join(scriptPieces)

        selectPieces = []
        selectPieces.append( \
            u'<select id="select%(finalName)s" onchange="addListItem(-1, this, \'%(finalName)s\');">' % locals() )
        selectPieces.append(u'<option>Add...</option>')
        # XXX selectPieces.append(u'<option>New...</option>')
        unusedValues.sort()
        for smartLabel, smartValue in unusedValues:
            selectPieces.append(u'<option value="%s">%s</option>' % (smartValue, smartLabel) )
        selectPieces.append(u'</select>')
        selectHTML = u'\n'.join(selectPieces)

        return u'%s\n%s' % (selectHTML,scriptHTML)
        return u'\n'.join(output)

    def id_for_label(self, id_):
        # See the comment for RadioSelect.id_for_label()
        if id_:
            id_ += '_0'
        return id_
    id_for_label = classmethod(id_for_label)

class ModelMultipleChoiceField(ModelChoiceField):
    def _generate_choices(self):
        """ Don't show the default ------ value and do a get() so the models are sorted.
        """
        #logging.info('building ModelMultipleChoiceField for class %s' % self.reference_class.__name__)
        #logging.info('yielding values from %r' % ([str(g) for g in self.reference_class.get()],))
        for inst in self.autoFilter( self.reference_class.get() ):
            if inst is None:
                raise RuntimeError, 'None found in get() from %r' % ( self.reference_class,)
            yield (inst.key(), unicode(inst))

    def clean(self, value):
        if value == []: return value
        return super(ModelMultipleChoiceField,self).clean(value)

class ReferenceListProperty(db.ReferenceListProperty):
  __metaclass__ = monkey_patch

  def get_form_field(self, **kwargs):
    """Return a Django form field appropriate for a reference property.

    This defaults to a ModelChoiceField instance.
    """
    defaults = \
        {   'form_class': ModelMultipleChoiceField,
            'reference_class': self.reference_class,
            'widget': EWGSelectMultiple,
            'empty_label': None,
        }
    defaults.update(kwargs)
    ret = super(ReferenceListProperty, self).get_form_field(**defaults)
    ret.autoFilter = self.autoFilter
    return ret

  def get_value_for_form(self, instance):
    """Extract the property value from the instance for use in a form.
    """
    return [ a.key() for a in getattr(instance, self.name) ]

  def make_value_from_form(self, value):
    """ Convert the list of Models into a list of keys.
    """
    #logging.debug('make_value_from_from for %s: %r' % (self.reference_class.__name__, value))
    return value

class WeakReferenceProperty(db.WeakReferenceProperty):
    __metaclass__ = monkey_patch

    def get_form_field(self, **kwargs):
        defaults = \
        {   'form_class': ModelMultipleChoiceField,
            'reference_class': self.reference_class,
            'empty_label': None,
        }
        defaults.update(kwargs)
        ret = super(WeakReferenceProperty,self).get_form_field(**defaults)
        ret.autoFilter = self.autoFilter
        return ret

