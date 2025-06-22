#!/bin/bash

set -e

# only perform database upgrade if explicitly allowed
if [[ "${P4D_DATABASE_UPGRADE}" != "true" ]]; then
    exit 0
fi

# check that the p4d service is already configured
if ! gosu perforce p4dctl list 2>/dev/null | grep -q "${P4NAME}"; then
    exit 0
fi

# enable database upgrade on next run
echo "Running database upgrade procedure..."
gosu perforce p4dctl exec -t p4d "${P4NAME}" -- -xu
