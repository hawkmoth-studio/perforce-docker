#!/bin/bash

set -e

# allow to bypass exclusive locks (needed for Swarm reviews)
echo "Setting filetype.bypasslock to ${P4D_FILETYPE_BYPASSLOCK} (needed by Swarm)"
p4 configure set filetype.bypasslock="${P4D_FILETYPE_BYPASSLOCK}" 1>/dev/null
