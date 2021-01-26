#!/bin/bash

set -e

# set environment variables
export SWARM_USER="${SWARM_USER:-${P4USER}}"
export SWARM_PASSWD="${SWARM_PASSWD:-${P4PASSWD}}"
export SWARM_USER_CREATE="${SWARM_USER_CREATE:-false}"
export SWARM_GROUP_CREATE="${SWARM_GROUP_CREATE:-false}"

export SWARM_HOST="${SWARM_HOST:-localhost}"
export SWARM_PORT="${SWARM_PORT:-80}"
export SWARM_SSL_PORT="${SWARM_SSL_PORT:-443}"
export SWARM_SSL_ENABLE="${SWARM_SSL_ENABLE:-false}"

export EMAIL_HOST="${EMAIL_HOST:-localhost}"

export SWARM_DATA_DIR="/opt/perforce/swarm/data"

# set P4CHARSET if unset and server is running in unicode mode
export P4D_USE_UNICODE="${P4D_USE_UNICODE:-true}"
if [[ "${P4D_USE_UNICODE}" == "true" ]]; then
    export P4CHARSET="${P4CHARSET:-auto}"
fi

# validate ssl configuration
if [[ "${SWARM_SSL_ENABLE}" == "true" ]]; then
    echo "WARNING! Running Swarm with HTTPS support enabled can lead to certain bugs."
    echo "         Consider running behind a reverse proxy instead."

    if [[ -z "${SWARM_SSL_CERTIFICATE_FILE}" ]]; then
        SWARM_SSL_CERTIFICATE_FILE="/etc/ssl/certs/ssl-cert-snakeoil.pem"
        echo "WARNING! Using default certificate file: ${SWARM_SSL_CERTIFICATE_FILE}"
    fi
    if [[ -z "${SWARM_SSL_CERTIFICATE_KEY_FILE}" ]]; then
        SWARM_SSL_CERTIFICATE_KEY_FILE="/etc/ssl/private/ssl-cert-snakeoil.key"
        echo "WARNING! Using default certificate key file: ${SWARM_SSL_CERTIFICATE_KEY_FILE}"
    fi
fi

# run all scripts from /docker-startup.d
for f in /docker-startup.d/*.sh; do
    bash "${f}" || exit 1
done

# exec docker command
exec "$@"
