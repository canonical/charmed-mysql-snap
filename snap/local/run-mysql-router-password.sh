#!/bin/bash

# For security measures, applications should not be run as sudo.
# Execute mysqlrouter as the non-sudo user: snap-daemon.
exec "${SNAP}/usr/bin/setpriv" \
    --clear-groups \
    --reuid snap_daemon \
    --regid snap_daemon \
    -- \
    "${SNAP}/usr/bin/mysqlrouter_passwd" \
    "$@"
