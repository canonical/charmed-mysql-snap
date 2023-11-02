#!/bin/bash

# For security measures, applications should not be run as sudo.
# Execute mysqld_safe as the non-sudo user: snap-daemon
# Note: group is set to root due to backups related intricacies.
exec $SNAP/usr/bin/setpriv --clear-groups --reuid snap_daemon \
  --regid root -- $SNAP/usr/bin/mysqld_safe --defaults-file=$SNAP_DATA/etc/mysql/mysql.cnf "$@"
