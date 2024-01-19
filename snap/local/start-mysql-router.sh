#!/bin/bash

# For security measures, daemons should not be run as sudo.
# Execute mysqlrouter as the non-sudo user: snap-daemon.
EXTRA_OPTIONS="$(snapctl get mysqlrouter.extra-options)"

exec "${SNAP}/usr/bin/setpriv" \
    --clear-groups \
    --reuid snap_daemon \
    --regid snap_daemon \
    -- \
    "${SNAP}/usr/bin/mysqlrouter" \
    --config "${SNAP_DATA}/etc/mysqlrouter/mysqlrouter.conf" \
    "${EXTRA_OPTIONS}"
