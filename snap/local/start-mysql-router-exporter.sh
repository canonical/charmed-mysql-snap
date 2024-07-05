#!/bin/bash

set -eo pipefail # Exit on error

EXPORTER_OPTS=(
    "--collect.metadata.status"
    "--collect.route.connections.byte_from_server"
    "--collect.route.connections.byte_to_server"
    "--collect.route.connections.time_started"
    "--collect.route.connections.time_connected_to_server"
    "--collect.route.connections.time_last_sent_to_server"
    "--collect.route.connections.time_received_from_server"
)
EXPORTER_PATH="/usr/bin/mysqlrouter_exporter"

if [ -n "$SNAP" ]; then
    MYSQLROUTER_EXPORTER_LISTEN_PORT="$(snapctl get mysqlrouter-exporter.listen-port)"
    MYSQLROUTER_EXPORTER_USER="$(snapctl get mysqlrouter-exporter.user)"
    MYSQLROUTER_EXPORTER_PASS="$(snapctl get mysqlrouter-exporter.password)"
    MYSQLROUTER_EXPORTER_URL="$(snapctl get mysqlrouter-exporter.url)"
    MYSQLROUTER_EXPORTER_SERVICE_NAME="$(snapctl get mysqlrouter-exporter.service-name)"
    MYSQLROUTER_TLS_CACERT_PATH="$(snapctl get mysqlrouter.tls-cacert-path)"
    MYSQLROUTER_TLS_CERT_PATH="$(snapctl get mysqlrouter.tls-cert-path)"
    MYSQLROUTER_TLS_KEY_PATH="$(snapctl get mysqlrouter.tls-key-path)"
fi

# Validate certain required input args
if [ -z "${MYSQLROUTER_EXPORTER_URL}" ]; then
    if [ -n "${SNAP}" ]; then
        echo "Error: mysqlrouter-exporter.url must be set" >&2
    else
        echo "Error: MYSQLROUTER_EXPORTER_URL must be set" >&2
    fi
    exit 1
fi

if [ -z "${MYSQLROUTER_EXPORTER_USER}" ]; then
    if [ -n "${SNAP}" ]; then
        echo "Error: mysqlrouter-exporter.user must be set" >&2
    else
        echo "Error: MYSQLROUTER_EXPORTER_USER must be set" >&2
    fi
    exit 1
fi

if [ -z "${MYSQLROUTER_EXPORTER_PASS}" ]; then
    if [ -n "${SNAP}" ]; then
        echo "Error: mysqlrouter-exporter.password must be set" >&2
    else
        echo "Error: MYSQLROUTER_EXPORTER_PASS must be set" >&2
    fi
    exit 1
fi

if [ -z "${MYSQLROUTER_EXPORTER_SERVICE_NAME}" ]; then
    if [ -n "${SNAP}" ]; then
        echo "Error: mysqlrouter-exporter.service-name must be set" >&2
    else
        echo "Error: MYSQLROUTER_EXPORTER_SERVICE_NAME must be set" >&2
    fi
    exit 1
fi

# Modify the listen-port if supplied
if [ -n "${MYSQLROUTER_EXPORTER_LISTEN_PORT}" ]; then
    EXPORTER_OPTS+=("--listen-port=${MYSQLROUTER_EXPORTER_LISTEN_PORT}")
fi

# Execute the mysqlrouter_exporter command 
if [ -n "${SNAP}" ]; then
    SETPRIV_OPTIONS=(
        "--clear-groups"
        "--reuid"
        "snap_daemon"
        "--regid"
        "snap_daemon"
    )

    EXPORTER_ENV=(
        "MYSQLROUTER_EXPORTER_URL=${MYSQLROUTER_EXPORTER_URL}"
        "MYSQLROUTER_EXPORTER_USER=${MYSQLROUTER_EXPORTER_USER}"
        "MYSQLROUTER_EXPORTER_PASS=${MYSQLROUTER_EXPORTER_PASS}"
    )

    EXPORTER_OPTS+=("--service-name=${MYSQLROUTER_SERVICE_NAME}")

    if [[
        -n "${MYSQLROUTER_TLS_CACERT_PATH}" && \
        -n "${MYSQLROUTER_TLS_CERT_PATH}" && \
        -n "${MYSQLROUTER_TLS_KEY_PATH}"
    ]]; then
        EXPORTER_ENV+=("MYSQLROUTER_TLS_CACERT_PATH=${MYSQLROUTER_TLS_CACERT_PATH}")
        EXPORTER_ENV+=("MYSQLROUTER_TLS_CERT_PATH=${MYSQLROUTER_TLS_CERT_PATH}")
        EXPORTER_ENV+=("MYSQLROUTER_TLS_KEY_PATH=${MYSQLROUTER_TLS_KEY_PATH}")
    else
        EXPORTER_OPTS+=("--skip-tls-verify")
    fi

    # For security measures, daemons should not be run as sudo.
    # Execute mysqlrouter-exporter as the non-sudo user: snap-daemon.
    exec "${SNAP}"/usr/bin/setpriv "${SETPRIV_OPTIONS[@]}" -- \
        env "${EXPORTER_ENV[@]}" "${SNAP}${EXPORTER_PATH}" "${EXPORTER_OPTS[@]}"
else
    if [[ -z "$MYSQLROUTER_TLS_CACERT_PATH" || -z "$MYSQLROUTER_TLS_CERT_PATH" || -z "$MYSQLROUTER_TLS_KEY_PATH" ]]; then
        EXPORTER_OPTS+=("--skip-tls-verify")
    fi

    "${EXPORTER_PATH}" "${EXPORTER_OPTS[@]}"
fi
