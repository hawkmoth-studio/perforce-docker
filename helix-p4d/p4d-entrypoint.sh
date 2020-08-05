#!/bin/bash

set -e


# copy default perforce configuration to docker volume
P4_CONF_DIR="/data/config"
if [[ ! -d "${P4_CONF_DIR}" ]]; then
    mkdir -pv "${P4_CONF_DIR}"
    cp -rvf "/etc/perforce"/* "${P4_CONF_DIR}/"
fi
# link docker volume directory to default perforce config location
mv /etc/perforce{,.backup}
ln -sv "${P4_CONF_DIR}" "/etc/perforce"


# create directories, set correct ownership
for d in "${P4ROOT}" "${P4SSLDIR}"; do
    mkdir -pv "${d}"
    chown -R perforce:perforce "${d}"
done


# check if p4d service is configured
if ! gosu perforce p4dctl list 2>/dev/null | grep -q "${P4NAME}"; then
    /opt/perforce/sbin/configure-helix-p4d.sh \
        "${P4NAME}" \
        -n \
        -p "${P4PORT}" \
        -r "${P4ROOT}" \
        -u "${P4USER}" \
        -P "${P4PASSWD}" \
        --unicode \
        --case "${P4CASE}"
    # configure-helix-p4d.sh starts p4d in background by default
    gosu perforce p4dctl stop "${P4NAME}"
fi


# exec docker command
gosu perforce bash -c "$@"

