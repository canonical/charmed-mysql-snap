#!/bin/bash

set -eo pipefail  # Exit on error

exec "${SNAP}/usr/sbin/mysqld" --initialize "$@"
