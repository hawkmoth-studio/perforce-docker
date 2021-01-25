#!/bin/bash

set -e

# if unicode support is enabled and p4d service has already been configured,
# make sure that p4d is switched to unicode mode
if [[ "${P4D_USE_UNICODE}" == "true" ]]; then
    if gosu perforce p4dctl list 2>/dev/null | grep -q "${P4NAME}"; then
        gosu perforce p4d -xi -r "${P4ROOT}"
    fi
fi
