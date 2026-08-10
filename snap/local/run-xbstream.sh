#!/bin/bash

set -eo pipefail  # Exit on error

exec "${SNAP}/usr/bin/setpriv" \
    --clear-groups \
    --reuid snap_daemon \
    --regid snap_daemon \
    -- \
    "${SNAP}/usr/bin/xbstream" "$@"
