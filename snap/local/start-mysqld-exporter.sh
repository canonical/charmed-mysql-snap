#!/bin/bash

# For security measures, daemons should not be run as sudo. Execute mysqlrouter as the non-sudo user: snap-daemon.
exec $SNAP/usr/bin/setpriv --clear-groups --reuid snap_daemon \
  --regid snap_daemon -- $SNAP/bin/mysqld_exporter --config.my-cnf=$SNAP_DATA/etc/mysql/mysql.cnf "$@"

