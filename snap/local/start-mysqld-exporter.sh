#!/bin/bash

set -eo pipefail # Exit on error

EXPORTER_OPTS="--no-collect.binlog_size \
--no-collect.info_schema.processlist \
--no-collect.info_schema.tables \
--no-collect.info_schema.tablestats \
--no-collect.info_schema.userstats \
--no-collect.info_schema.query_response_time \
--no-collect.perf_schema.indexiowaits \
--no-collect.perf_schema.tableiowaits \
--no-collect.perf_schema.tablelocks \
--no-collect.auto_increment.columns"
EXPORTER_PATH="/usr/bin/prometheus-mysqld-exporter"
SOCKET="/var/run/mysqld/mysqld.sock"

if [ -z "$SNAP" ]; then
    # When not running as a snap, expect `DATA_SOURCE_NAME` to be set.
    if [ -z "$DATA_SOURCE_NAME" ]; then
        echo "DATA_SOURCE_NAME must be set"
        exit 1
    fi
    exec "$EXPORTER_PATH" $(echo "$EXPORTER_OPTS")
else
    # When running as a snap, expect `exporter.user` and `exporter.password`
    EXPORTER_USER="$(snapctl get exporter.user)"
    EXPORTER_PASS="$(snapctl get exporter.password)"
    EXPORTER_PATH="${SNAP}${EXPORTER_PATH}"
    SOCKET="${SNAP_COMMON}${SOCKET}"

    if [[ -z "$EXPORTER_USER" || -z "$EXPORTER_PASS" ]]; then
        echo "exporter.user and exporter.password must be set"
        exit 1
    fi

    # For security measures, daemons should not be run as sudo.
    # Execute mysqlrouter as the non-sudo user: snap-daemon.
    exec "$SNAP"/usr/bin/setpriv \
        --clear-groups \
        --reuid snap_daemon \
        --regid snap_daemon -- \
        env DATA_SOURCE_NAME="${EXPORTER_USER}:${EXPORTER_PASS}@unix(${SOCKET})/" \
        "$EXPORTER_PATH" $(echo "$EXPORTER_OPTS")
fi
