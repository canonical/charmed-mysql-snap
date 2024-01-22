#!/bin/bash

set -eo pipefail # Exit on error

EXPORTER_OPTS="--collect.metadata.status \
    --collect.route.connections.byte_from_server \
    --collect.route.connections.byte_to_server \
    --collect.route.connections.time_started \
    --collect.route.connections.time_connected_to_server \
    --collect.route.connections.time_last_sent_to_server \
    --collect.route.connections.time_received_from_server"
EXPORTER_PATH="/usr/bin/mysqlrouter_exporter"

if [ -n "$SNAP" ]; then
    EXPORTER_PATH="${SNAP}${EXPORTER_PATH}"
    MYSQLROUTER_EXPORTER_USER="$(snapctl get mysqlrouter-exporter.user)"
    MYSQLROUTER_EXPORTER_PASS="$(snapctl get mysqlrouter-exporter.password)"
    MYSQLROUTER_EXPORTER_URL="$(snapctl get mysqlrouter-exporter.url)"
    TLS_OPTS="--skip-tls-verify"

    if [ -z "$MYSQLROUTER_EXPORTER_URL" ]; then
        echo "mysqlrouter-exporter.url must be set"
        exit 1
    fi

    if [[ -z "$MYSQLROUTER_EXPORTER_USER" || -z "$MYSQLROUTER_EXPORTER_PASS" ]]; then
        echo "mysqlrouter-exporter.user and mysqlrouter-exporter.password must be set"
        exit 1
    fi

    # For security measures, daemons should not be run as sudo.
    # Execute mysqlrouter-exporter as the non-sudo user: snap-daemon.
    exec "$SNAP"/usr/bin/setpriv \
        --clear-groups \
        --reuid snap_daemon \
        --regid snap_daemon -- \
        env MYSQLROUTER_EXPORTER_URL="${MYSQLROUTER_EXPORTER_URL}" \
        MYSQLROUTER_EXPORTER_USER="${MYSQLROUTER_EXPORTER_USER}" \
        MYSQLROUTER_EXPORTER_PASS="${MYSQLROUTER_EXPORTER_PASS}" \
        "/snap/charmed-mysql/current$EXPORTER_PATH" $(echo "$EXPORTER_OPTS") "$TLS_OPTS"
else
    if [ -z "$MYSQLROUTER_EXPORTER_URL" ]; then
        echo "MYSQLROUTER_EXPORTER_URL must be set"
        exit 1
    fi

    if [ -z "$MYSQLROUTER_EXPORTER_USER" ]; then
        echo "MYSQLROUTER_EXPORTER_USER must be set"
        exit 1
    fi

    if [ -z "$MYSQLROUTER_EXPORTER_PASS" ]; then
        echo "MYSQLROUTER_EXPORTER_PASS must be set"
        exit 1
    fi

    if [[ -n "$MYSQLROUTER_TLS_CACERT_PATH" && -n "$MYSQLROUTER_TLS_CERT_PATH" && -n "$MYSQLROUTER_TLS_KEY_PATH" ]]; then
        TLS_OPTS=""
    else
        TLS_OPTS="--skip-tls-verify"
    fi

    "$EXPORTER_PATH" $(echo "$EXPORTER_OPTS") "$TLS_OPTS"
fi
