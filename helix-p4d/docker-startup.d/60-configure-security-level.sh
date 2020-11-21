#!/bin/bash

set -e

# set security level
echo "Setting security level: ${P4D_SECURITY}"
p4 configure set security="${P4D_SECURITY}" 1>/dev/null
