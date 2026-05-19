#!/bin/bash

set -e

# set environment variables
export P4D_CASE_SENSITIVE="${P4D_CASE_SENSITIVE:-false}"
export P4D_FILETYPE_BYPASSLOCK="${P4D_FILETYPE_BYPASSLOCK:-1}"
export P4D_SECURITY="${P4D_SECURITY:-2}"
export P4D_USE_UNICODE="${P4D_USE_UNICODE:-true}"

export INSTALL_SWARM_TRIGGER="${INSTALL_SWARM_TRIGGER:-false}"
export SWARM_TRIGGER_HOST="${SWARM_TRIGGER_HOST:-http://swarm}"

# link p4dctl service configuration file into /etc/perforce/
P4_CONF_DIR="/data/config"
if [[ ! -d "${P4_CONF_DIR}" ]]; then
    echo "Initializing configuration files in /etc/perforce"
    mkdir -p "${P4_CONF_DIR}"
    cp -rf "/etc/perforce"/* "${P4_CONF_DIR}/"
fi
# link docker volume directory to default perforce config location
if [[ ! -L /etc/perforce ]]; then
    mv /etc/perforce /etc/perforce.orig
    ln -s "${P4_CONF_DIR}" "/etc/perforce"
fi

# set P4CHARSET if unset and server is running in unicode mode
if [[ "${P4D_USE_UNICODE}" == "true" ]]; then
    export P4CHARSET="${P4CHARSET:-auto}"
fi

# validate swarm trigger parameters
if [[ "${INSTALL_SWARM_TRIGGER}" == "true" ]]; then
    if [[ -z "${SWARM_TRIGGER_HOST}" ]]; then
        echo "Unable to install swarm triggers: SWARM_TRIGGER_HOST is not set!"
        exit 1
    fi
    if [[ -z "${SWARM_TRIGGER_TOKEN}" ]]; then
        echo "Unable to install swarm triggers: SWARM_TRIGGER_TOKEN is not set!"
        exit 1
    fi
fi

# Sentinel: skip init when server is already configured.
# Without this, every container restart re-runs /docker-startup.d/*.sh,
# and 50-configure-helix-p4d.sh fails with
#   "Can't change P4ROOT for existing servers"
#   "FATAL: Need to be logged in as a superuser"
# which kills the container and triggers a restart loop.
P4ROOT="${P4ROOT:-/data/master/root}"
SERVER_INITIALIZED=0
if [[ -f "${P4ROOT}/db.config" ]]; then
    SERVER_INITIALIZED=1
fi

if [[ "${SERVER_INITIALIZED}" -eq 1 ]]; then
    echo "Server already initialized at ${P4ROOT} — skipping init scripts."
else
    # run in subshell to prevent environment variable changes
    (
        # during initialization, P4PORT is set to localhost
        # so no other services can connect remotely
        # and interfere with initialization process
        # shellcheck disable=SC2030
        if [[ "${P4PORT}" == "ssl:"* ]]; then
            export P4PORT="ssl:localhost:1666"
        else
            export P4PORT="localhost:1666"
        fi
        # run all scripts from /docker-startup.d
        for f in /docker-startup.d/*.sh; do
            bash "${f}" || exit 1
        done
    )

    # make sure p4d is not started after initialization
    echo "Stopping local-only p4d server..."
    gosu perforce p4dctl stop "${P4NAME}" &>/dev/null || true
fi

# exec docker command
exec "$@"
