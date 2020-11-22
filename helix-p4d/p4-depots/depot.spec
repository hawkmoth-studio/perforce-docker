# A Perforce Depot Specification.
# 
#  Depot:       The name of the depot.
#  Owner:       The user who created this depot.
#  Date:        The date this specification was last modified.
#  Description: A short description of the depot (optional).
#  Type:        Whether the depot is 'local', 'remote',
#               'stream', 'spec', 'archive', 'tangent',
#               'unload', 'extension' or 'graph'.
#               Default is 'local'.
#  Address:     Connection address (remote depots only).
#  Suffix:      Suffix for all saved specs (spec depot only).
#  StreamDepth: Depth for streams in this depot (stream depots only).
#  Map:         Path translation information (must have ... in it).
#  SpecMap:     For spec depot, which specs should be recorded (optional).
#
# Use 'p4 help depot' to see more about depot forms.
