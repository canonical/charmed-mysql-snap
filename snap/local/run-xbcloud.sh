#!/bin/bash

set -eo pipefail  # Exit on error

exec "${SNAP}/usr/bin/setpriv" \
    --clear-groups \
    --reuid snap_daemon \
    --regid root \
    -- \
    "${SNAP}/usr/bin/xbcloud" "$@"
