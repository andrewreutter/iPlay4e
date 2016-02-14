""" Wrappers for db operations.
"""

from google.appengine.ext import db

def get(key):
    """ We have some keys from the old iPlay4e Master/Slave app.
        This method handles converting the key before doing db.get().
    """

    if type(key) == type([]):
        newKey = [hrdKey(k) for k in key]
    else:
        newKey = hrdKey(key)

    return db.get(newKey)

def hrdKey(key):
    """ Convert a key string or Key instance to the current application ID.
    """

    if key.__class__.__name__ != 'Key':
        key = db.Key(key)
    return str(db.Key.from_path(key.kind(), key.id_or_name()))

def unHrdKey(key):
    """ Convert a key string from the current application ID to the old 'iplay4e'.
    """

    return key.replace('ag1zfmlwbGF5NGUtaHJkch', 'agdpcGxheTRlch')
    oldKeyObject = db.Key(key)
    return str(db.Key.from_path(oldKeyObject.kind(), oldKeyObject.id_or_name()))

