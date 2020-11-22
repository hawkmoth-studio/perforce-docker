# A Perforce User Specification.
#
#  User:        The user's user name.
#  Type:        Either 'service', 'operator', or 'standard'.
#               Default: 'standard'. Read only.
#  Email:       The user's email address; for email review.
#  Update:      The date this specification was last modified.
#  Access:      The date this user was last active.  Read only.
#  FullName:    The user's real name.
#  JobView:     Selects jobs for inclusion during changelist creation.
#  Password:    If set, user must have matching $P4PASSWD on client.
#  AuthMethod:  'perforce' if using standard authentication or 'ldap' if
#               this user should use native LDAP authentication.  The '+2fa'
#               modifier can be added to the AuthMethod, requiring the user to
#               perform multi factor authentication in addition to password
#               authentication. For example: 'perforce+2fa'.
#  Reviews:     Listing of depot files to be reviewed by user.
