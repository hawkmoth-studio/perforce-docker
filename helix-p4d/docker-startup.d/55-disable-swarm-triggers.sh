#!/bin/bash

set -e

# only disable triggers if they are to be later installed
if [[ "${INSTALL_SWARM_TRIGGER}" != "true" ]]; then
    exit 0
fi

# triggers need to be disabled before updating user details or submitting trigger updates
# or else local changes will fail because swarm is not yet available
p4 triggers -i <<EOF 1>/dev/null
Triggers:
EOF

