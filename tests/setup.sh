#!/bin/bash

set -e

COMMON="/var/snap/charmed-mysql/common"
CURRENT="/var/snap/charmed-mysql/current"

charmed-mysql.mysqlsh --help
touch ${COMMON}/var/log/mysql/error.log
chown -R snap_daemon ${COMMON}


cat <<EOF > ${CURRENT}/etc/mysql/mysql.conf.d/alter_pass.sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'newpass';
FLUSH PRIVILEGES;
EOF

cat <<EOF > ${CURRENT}/etc/mysql/mysql.conf.d/temp_init.cnf
[mysqld]
init_file=/var/snap/charmed-mysql/current/etc/mysql/mysql.conf.d/alter_pass.sql
loose-audit_log_format = JSON
loose-audit_log_strategy = SYNCHRONOUS
EOF


chown -R snap_daemon ${CURRENT}/etc/mysql/mysql.conf.d/*

snap start charmed-mysql.mysqld
sleep 2
snap restart charmed-mysql.mysqld
sleep 2

snap alias charmed-mysql.mysql mysql

