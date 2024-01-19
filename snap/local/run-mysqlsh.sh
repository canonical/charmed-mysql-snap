#!/bin/bash

# For security measures, applications should not be run as sudo.
# Execute mysqlsh as the non-sudo user: snap-daemon.
exec $SNAP/usr/bin/setpriv --clear-groups --reuid snap_daemon \
  --regid snap_daemon -- env MYSQLSH_USER_CONFIG_HOME=/tmp/snap-private-tmp/snap.$SNAP_NAME/tmp \
  $SNAP/usr/bin/mysqlsh --log-file $SNAP_COMMON/var/log/mysqlsh/mysqlsh.log "$@"
