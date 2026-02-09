#!/bin/bash

# Touch mysqld_safe required log-files
touch $SNAP_COMMON/var/log/mysql/error.log

# For security measures, applications should not be run as sudo.
# Execute mysqld_safe as the non-sudo user: snap-daemon
# Note: group is set to root due to backups related intricacies.
exec "${SNAP}/usr/bin/setpriv" \
    --clear-groups \
    --reuid snap_daemon \
    --regid root \
    -- \
    "${SNAP}/usr/bin/mysqld_safe" \
    --defaults-file="${SNAP_DATA}/etc/mysql/mysql.cnf"
