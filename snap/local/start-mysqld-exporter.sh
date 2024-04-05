#!/bin/bash

set -eo pipefail # Exit on error

EXPORTER_OPTS=(
    "--no-collect.binlog_size"
    "--no-collect.info_schema.processlist"
    "--no-collect.info_schema.tables"
    "--no-collect.info_schema.tablestats"
    "--no-collect.info_schema.userstats"
    "--no-collect.info_schema.query_response_time"
    "--no-collect.perf_schema.indexiowaits"
    "--no-collect.perf_schema.tableiowaits"
    "--no-collect.perf_schema.tablelocks"
    "--no-collect.auto_increment.columns"
)
EXPORTER_PATH="/usr/bin/prometheus-mysqld-exporter"
SOCKET="/var/run/mysqld/mysqld.sock"

if [ -n "$SNAP" ]; then
    # When running as a snap, expect `exporter.user` and `exporter.password`
    EXPORTER_USER="$(snapctl get exporter.user)"
    EXPORTER_PASS="$(snapctl get exporter.password)"
    SOCKET="${SNAP_COMMON}${SOCKET}"
fi


if [ -z "${EXPORTER_USER}" ] || [ -z "${EXPORTER_PASS}" ]; then
    echo "Error: both EXPORTER_USER and EXPORTER_PASS must be set" >&2
    exit 1
fi
DATA_SOURCE_NAME="${EXPORTER_USER}:${EXPORTER_PASS}@unix(${SOCKET})"

if [ -z "$SNAP" ]; then
    exec env DATA_SOURCE_NAME="${DATA_SOURCE_NAME}" \
        "${EXPORTER_PATH}" \
        "${EXPORTER_OPTS[@]}"
else
    # For security measures, daemons should not be run as sudo.
    # Execute mysqld-exporter as the non-sudo user: snap-daemon.
    exec "$SNAP"/usr/bin/setpriv \
        --clear-groups \
        --reuid snap_daemon \
        --regid snap_daemon \
        -- \
        env DATA_SOURCE_NAME="${DATA_SOURCE_NAME}" \
        "${SNAP}${EXPORTER_PATH}" \
        "${EXPORTER_OPTS[@]}"
fi
