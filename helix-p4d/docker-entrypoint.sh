#!/bin/bash

set -e


# link p4dctl service configuration file into /etc/perforce/
P4_CONF_DIR="/data/config"
if [[ ! -d "${P4_CONF_DIR}" ]]; then
    mkdir -pv "${P4_CONF_DIR}"
    cp -rvf "/etc/perforce"/* "${P4_CONF_DIR}/"
fi
# link docker volume directory to default perforce config location
mv /etc/perforce{,.orig}
ln -sv "${P4_CONF_DIR}" "/etc/perforce"


# create directories, set correct ownership
for d in "${P4ROOT}" "${P4SSLDIR}"; do
    mkdir -pv "${d}"
    chown -R perforce:perforce "${d}"
done


# install TLS certificate files
chmod 0700 "${P4SSLDIR}"
if [[ -n "${P4D_SSL_CERTIFICATE_FILE}" ]]; then
    cp -Lvf "${P4D_SSL_CERTIFICATE_FILE}" "${P4SSLDIR}/certificate.txt"
    chmod 0600 "${P4SSLDIR}/certificate.txt"
fi
if [[ -n "${P4D_SSL_CERTIFICATE_KEY_FILE}" ]]; then
    cp -Lvf "${P4D_SSL_CERTIFICATE_KEY_FILE}" "${P4SSLDIR}/privatekey.txt"
    chmod 0600 "${P4SSLDIR}/privatekey.txt"
fi


# check if p4d service is configured
if ! gosu perforce p4dctl list 2>/dev/null | grep -q "${P4NAME}"; then
    CONFIGURE_P4D_CMD=("/opt/perforce/sbin/configure-helix-p4d.sh")
    CONFIGURE_P4D_CMD+=("${P4NAME}")
    CONFIGURE_P4D_CMD+=("-n")
    CONFIGURE_P4D_CMD+=("-p" "${P4PORT}")
    CONFIGURE_P4D_CMD+=("-r" "${P4ROOT}")
    CONFIGURE_P4D_CMD+=("-u" "${P4USER}")
    CONFIGURE_P4D_CMD+=("-P" "${P4PASSWD}")
    if [[ "${P4D_CASE_SENSITIVE}" == "true" ]]; then
        CONFIGURE_P4D_CMD+=("--case" "0")
    else
        CONFIGURE_P4D_CMD+=("--case" "1")
    fi
    if [[ "${P4D_USE_UNICODE}" == "true" ]]; then
        CONFIGURE_P4D_CMD+=("--unicode")
    fi
    # run configure script
    "${CONFIGURE_P4D_CMD[@]}"
    # configure-helix-p4d.sh starts p4d in background by default
    gosu perforce p4dctl stop "${P4NAME}"
fi

# exec docker command
exec "$@"

