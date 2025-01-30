#!/bin/bash

if [ -z "$SNAP" ]; then
    exec "/usr/bin/mysql-pitr-helper" \
        collect
else
    # For security measures, applications should not be run as sudo.
    # Execute mysqlsh as the non-sudo user: snap-daemon.
    exec "${SNAP}/usr/bin/setpriv" \
        --clear-groups \
        --reuid snap_daemon \
        --regid snap_daemon \
        -- \
        env HOSTS="$(snapctl get mysql-pitr-helper-collector.hosts)" \
        env USER="$(snapctl get mysql-pitr-helper-collector.user)" \
        env PASS="$(snapctl get mysql-pitr-helper-collector.pass)" \
        env STORAGE_TYPE="$(snapctl get mysql-pitr-helper-collector.storage-type)" \
        env BUFFER_SIZE="$(snapctl get mysql-pitr-helper-collector.buffer-size)" \
        env COLLECT_SPAN_SEC="$(snapctl get mysql-pitr-helper-collector.collect-span-sec)" \
        env VERIFY_TLS="$(snapctl get mysql-pitr-helper-collector.verify-tls)" \
        env TIMEOUT_SECONDS="$(snapctl get mysql-pitr-helper-collector.timeout-seconds)" \
        env ENDPOINT="$(snapctl get mysql-pitr-helper-collector.endpoint)" \
        env ACCESS_KEY_ID="$(snapctl get mysql-pitr-helper-collector.access-key-id)" \
        env SECRET_ACCESS_KEY="$(snapctl get mysql-pitr-helper-collector.secret-access-key)" \
        env S3_BUCKET_URL="$(snapctl get mysql-pitr-helper-collector.s3-bucket-url)" \
        env DEFAULT_REGION="$(snapctl get mysql-pitr-helper-collector.default-region)" \
        env AZURE_ENDPOINT="$(snapctl get mysql-pitr-helper-collector.azure-endpoint)" \
        env AZURE_CONTAINER_PATH="$(snapctl get mysql-pitr-helper-collector.azure-container-path)" \
        env AZURE_STORAGE_CLASS="$(snapctl get mysql-pitr-helper-collector.azure-storage-class)" \
        env AZURE_STORAGE_ACCOUNT="$(snapctl get mysql-pitr-helper-collector.azure-storage-account)" \
        env AZURE_ACCESS_KEY="$(snapctl get mysql-pitr-helper-collector.azure-access-key)" \
        "${SNAP}/usr/bin/mysql-pitr-helper" \
        collect
fi
