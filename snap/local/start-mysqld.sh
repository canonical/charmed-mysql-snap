#!/bin/bash

$SNAP/usr/bin/setpriv --clear-groups --reuid snap_daemon \
  --regid snap_daemon -- $SNAP/usr/sbin/mysqld --defaults-file=${SNAP_COMMON}/mysql/mysql.conf.d/mysqld.cnf
