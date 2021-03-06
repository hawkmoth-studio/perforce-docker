#!/bin/bash

set -e

# check if swarm triggers need to be installed
if [[ "${INSTALL_SWARM_TRIGGER}" != "true" ]]; then
    exit 0
fi

# log to console
echo "Installing Swarm triggers..."

# create workspace directory
P4_WORKSPACE_PATH="/tmp/${P4NAME}"
mkdir -p "${P4_WORKSPACE_PATH}"
cd "${P4_WORKSPACE_PATH}"

# configure paths
SWARM_TRIGGER_INSTALL_DIR="${P4_WORKSPACE_PATH}/.swarm/triggers"
SWARM_TRIGGER_SCRIPT_PATH="${SWARM_TRIGGER_INSTALL_DIR}/swarm-trigger.pl"
SWARM_TRIGGER_CONF_PATH="${SWARM_TRIGGER_INSTALL_DIR}/swarm-trigger.conf"

SWARM_TRIGGER_SCRIPT_SOURCE="/opt/perforce/swarm-triggers/bin/swarm-trigger.pl"

# set perforce client id
# shellcheck disable=SC2155
export P4CLIENT="$(hostname)"

# create depot .swarm if it does not exist
if [[ "$(p4 depots -e '.swarm' | wc -l)" == "0" ]]; then
    p4 depot -i <<EOF
Depot:  .swarm
Owner:  ${P4USER}
Description:
        Depot used for storing Helix Swarm triggers and configuration.
Type:   local
Address:        local
Suffix: .p4s
StreamDepth:    //.swarm/1
Map:    .swarm/...
EOF
fi

# establish connection to server
p4 client -i <<EOF 1>/dev/null
Client: ${P4CLIENT}
Owner:  ${P4USER}
Host:   $(hostname)
Description:
        Used by ${P4USER} for Swarm trigger setup.
Root:   ${P4_WORKSPACE_PATH}
Options:        noallwrite noclobber nocompress unlocked nomodtime normdir
SubmitOptions:  submitunchanged
LineEnd:        local
View:
        //.swarm/... //${P4CLIENT}/.swarm/...
EOF

# sync files with the server
p4 sync 1>/dev/null

# install swarm triggers
mkdir -p "${SWARM_TRIGGER_INSTALL_DIR}"

# install / update swarm-trigger.pl
if [[ ! -f "${SWARM_TRIGGER_SCRIPT_PATH}" ]]; then
    cp -f "${SWARM_TRIGGER_SCRIPT_SOURCE}" "${SWARM_TRIGGER_SCRIPT_PATH}"
    p4 add "${SWARM_TRIGGER_SCRIPT_PATH}" 1>/dev/null
elif [[ "$(md5sum "${SWARM_TRIGGER_SCRIPT_PATH}" | awk '{ print $1 }')" != "$(md5sum "${SWARM_TRIGGER_SCRIPT_SOURCE}" | awk '{ print $1 }')" ]]; then
    p4 unlock -f "${SWARM_TRIGGER_SCRIPT_PATH}" 1>/dev/null
    p4 edit "${SWARM_TRIGGER_SCRIPT_PATH}" 1>/dev/null
    cp -f "${SWARM_TRIGGER_SCRIPT_SOURCE}" "${SWARM_TRIGGER_SCRIPT_PATH}"
fi

# write swarm-trigger.conf to a temporary file
SWARM_TRIGGER_CONF_SOURCE=$(mktemp /tmp/swarm-trigger.conf.XXXXXX)
cat <<EOF >"${SWARM_TRIGGER_CONF_SOURCE}"
SWARM_HOST="${SWARM_TRIGGER_HOST}"
SWARM_TOKEN="${SWARM_TRIGGER_TOKEN}"
EOF
# install / update swarm-trigger.conf
if [[ ! -f "${SWARM_TRIGGER_CONF_PATH}" ]]; then
    cp -f "${SWARM_TRIGGER_CONF_SOURCE}" "${SWARM_TRIGGER_CONF_PATH}"
    p4 add "${SWARM_TRIGGER_CONF_PATH}" 1>/dev/null
elif [[ "$(md5sum "${SWARM_TRIGGER_CONF_PATH}" | awk '{ print $1 }')" != "$(md5sum "${SWARM_TRIGGER_CONF_SOURCE}" | awk '{ print $1 }')" ]]; then
    p4 unlock -f "${SWARM_TRIGGER_CONF_PATH}" 1>/dev/null
    p4 edit "${SWARM_TRIGGER_CONF_PATH}" 1>/dev/null
    cp -f "${SWARM_TRIGGER_CONF_SOURCE}" "${SWARM_TRIGGER_CONF_PATH}"
fi
# remove temporary swarm-trigger.conf file
rm -vf "${SWARM_TRIGGER_CONF_SOURCE}"

# check if there are any changes to commit
if [[ "$(p4 status 2>/dev/null | wc -l)" != "0" ]]; then
    # submit updated triggers
    p4 submit -d 'Installed / updated swarm triggers.' 1>/dev/null || true
fi

# configure triggers
p4 triggers -i <<EOF 1>/dev/null
Triggers:
    swarm.job        form-commit    job    "%//.swarm/triggers/swarm-trigger.pl% -c %//.swarm/triggers/swarm-trigger.conf% -t job        -v %formname%"
    swarm.user       form-commit    user   "%//.swarm/triggers/swarm-trigger.pl% -c %//.swarm/triggers/swarm-trigger.conf% -t user       -v %formname%"
    swarm.userdel    form-delete    user   "%//.swarm/triggers/swarm-trigger.pl% -c %//.swarm/triggers/swarm-trigger.conf% -t userdel    -v %formname%"
    swarm.group      form-commit    group  "%//.swarm/triggers/swarm-trigger.pl% -c %//.swarm/triggers/swarm-trigger.conf% -t group      -v %formname%"
    swarm.groupdel   form-delete    group  "%//.swarm/triggers/swarm-trigger.pl% -c %//.swarm/triggers/swarm-trigger.conf% -t groupdel   -v %formname%"
    swarm.changesave form-save      change "%//.swarm/triggers/swarm-trigger.pl% -c %//.swarm/triggers/swarm-trigger.conf% -t changesave -v %formname%"
    swarm.shelve     shelve-commit  //...  "%//.swarm/triggers/swarm-trigger.pl% -c %//.swarm/triggers/swarm-trigger.conf% -t shelve     -v %change%"
    swarm.commit     change-commit  //...  "%//.swarm/triggers/swarm-trigger.pl% -c %//.swarm/triggers/swarm-trigger.conf% -t commit     -v %change%"
    swarm.shelvedel  shelve-delete  //...  "%//.swarm/triggers/swarm-trigger.pl% -c %//.swarm/triggers/swarm-trigger.conf% -t shelvedel  -v %change% -w %client% -u %user% -d %quote%%clientcwd%^^^%quote% -a %quote%%argsQuoted%%quote% -s %quote%%serverVersion%%quote%"
#    The following three triggers are used by workflow. If workflow is disabled in the Swarm configuration then they should be disabled.
    swarm.enforce    change-submit  //...  "%//.swarm/triggers/swarm-trigger.pl% -c %//.swarm/triggers/swarm-trigger.conf% -t checkenforced -v %change% -u %user%"
    swarm.strict     change-content //...  "%//.swarm/triggers/swarm-trigger.pl% -c %//.swarm/triggers/swarm-trigger.conf% -t checkstrict   -v %change% -u %user%"
    swarm.shelvesub  shelve-submit  //...  "%//.swarm/triggers/swarm-trigger.pl% -c %//.swarm/triggers/swarm-trigger.conf% -t checkshelve   -v %change% -u %user%"
EOF

# log to console
echo "Swarm triggers successfully installed."

# disconnect from server
p4 client -f -d "${P4CLIENT}" 1>/dev/null
# remove workspace files
rm -rf "${P4_WORKSPACE_PATH}"
