from google.appengine.api import users

class AuthorizedModel:
    """ Mixed into classes that require authorization to view.

        Such classes must define isPublic and owner properties,
        or override the authorizeUserAbility method because it references them.
    """

    # Abilities to pass into authorizeUserAbility
    OWNER  = 'owner'        # Owner of an object
    MEMBER = 'member'       # "Member" of a campaign, or in a campaign with another character.
    PUBLIC = 'public'       # Everyone
    ADMIN  = 'admin'        # My own bad self

    VIEW    = 'view'        # View an object without state
    MONITOR = 'monitor'     # View the object's state
    EDIT    = 'edit'        # Make changes to the object.
    DELETE  = 'delete'      # Delete the object.

    def authorizeAnyUserAbilityFromList(self, user, abilityList):
        for ability in abilityList:
            if self.authorizeUserAbility(user, ability):
                return True
        return False

    def authorizeUserAbility(self, user, ability):

        # Admins make an end run around most auth checks, but showing items as public
        # when they aren't actually has strange side effects, so we don't do that here.
        if ability == self.PUBLIC:
            return self.isPublic
        if users.is_current_user_admin():
            return True

        if ability == self.OWNER:
            return user == self.owner
        if ability == self.MEMBER:
            return user == self.owner # override in subclass if memberships, e.g. Campaign
        if ability == self.ADMIN:
            return users.is_current_user_admin()

        if ability == self.VIEW:
            return self.authorizeAnyUserAbilityFromList(user, (self.OWNER, self.PUBLIC, self.MEMBER))
        if ability == self.MONITOR:
            return self.authorizeAnyUserAbilityFromList(user, (self.OWNER, self.MEMBER))
        if ability in (self.DELETE, self.EDIT):
            return self.authorizeAnyUserAbilityFromList(user, (self.ADMIN, self.OWNER))

        return False
