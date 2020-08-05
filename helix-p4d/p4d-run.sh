#!/bin/bash

set -e

trap "p4dctl stop \"${P4NAME}\"" SIGINT

p4dctl start "${P4NAME}"
sleep infinity

