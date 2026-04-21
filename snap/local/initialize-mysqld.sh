#!/bin/bash

set -eo pipefail  # Exit on error

# Run mysqld initialization as snap_daemon user (similar to start-mysqld.sh)
# This ensures proper permissions from the start
exec "${SNAP}/usr/bin/setpriv" \
    --clear-groups \
    --reuid snap_daemon \
    --regid snap_daemon \
    -- \
    "${SNAP}/usr/sbin/mysqld" --defaults-file="${SNAP_DATA}/etc/mysql/mysql.cnf" --initialize "$@"
