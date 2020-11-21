#!/bin/bash

set -e

# add perforce bin directory to PATH
PATH="/opt/perforce/bin:${PATH}"

# set environment variables
export P4PORT="${P4PORT:-ssl:p4d:1666}"
export P4USER="${P4PASSWD:-p4admin}"
export P4PASSWD="${P4PASSWD:-P@ssw0rd}"

export SWARM_HOST="${SWARM_HOST:-localhost}"
export SWARM_PORT="${SWARM_PORT:-80}"
export SWARM_SSL_PORT="${SWARM_SSL_PORT:-443}"

export SWARM_DATA_DIR="/opt/perforce/swarm/data"

# validate ssl configuration
if [[ "${SWARM_SSL_ENABLE}" == "true" ]]; then
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
