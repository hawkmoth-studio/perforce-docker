#!/bin/bash

set -e

# test if swarm is already configured (config.php exists)
if [[ -f "/opt/perforce/swarm/data/config.php" ]]; then
    exit 0
fi

# run configure-swarm.sh
CONFIGURE_SWARM_CMD=("/opt/perforce/swarm/sbin/configure-swarm.sh")
CONFIGURE_SWARM_CMD+=("--non-interactive")
if [[ "${SWARM_INIT_FORCE}" == "true" ]]; then
    CONFIGURE_SWARM_CMD+=("--force")
fi
CONFIGURE_SWARM_CMD+=("--p4port" "${P4PORT}")
CONFIGURE_SWARM_CMD+=("--swarm-user" "${SWARM_USER}")
CONFIGURE_SWARM_CMD+=("--swarm-passwd" "${SWARM_PASSWD}")
CONFIGURE_SWARM_CMD+=("--swarm-host" "${SWARM_HOST}")
CONFIGURE_SWARM_CMD+=("--swarm-port" "${SWARM_PORT}")
CONFIGURE_SWARM_CMD+=("--email-host" "${EMAIL_HOST}")
if [[ "${SWARM_USER_CREATE}" == "true" ]]; then
    CONFIGURE_SWARM_CMD+=("--create")
    if [[ "${SWARM_GROUP_CREATE}" == "true" ]]; then
        CONFIGURE_SWARM_CMD+=("--create-group")
    fi
    CONFIGURE_SWARM_CMD+=("--super-user" "${P4USER}")
    CONFIGURE_SWARM_CMD+=("--super-passwd" "${P4PASSWD}")
fi
"${CONFIGURE_SWARM_CMD[@]}"

# configure-swarm.sh starts apache2 automatically
apachectl -k graceful-stop
