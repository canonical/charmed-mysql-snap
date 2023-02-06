#!/bin/bash

# For security measures, daemons should not be run as sudo. Execute mysql as the non-sudo user: snap-daemon.
$SNAP/usr/bin/setpriv --clear-groups --reuid snap_daemon \
  --regid snap_daemon -- $SNAP/usr/bin/mysqlrouter "$@"
