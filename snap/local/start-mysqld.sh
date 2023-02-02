#!/bin/bash

$SNAP/usr/bin/setpriv --clear-groups --reuid snap_daemon \
  --regid snap_daemon -- $SNAP/usr/sbin/mysqld --defaults-file=$CONFIG_DIR/mysql.conf.d/mysqld.cnf
