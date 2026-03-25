#!/bin/bash

set -eo pipefail  # Exit on error

exec "${SNAP}/usr/sbin/mysqld" --defaults-file="${SNAP_DATA}/etc/mysql/mysql.cnf" --initialize "$@"
