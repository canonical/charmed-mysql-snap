# Copyright 2024 Canonical Ltd.
# See LICENSE file for licensing details.

import json
import yaml
import subprocess
import pytest

COMMON = "/var/snap/charmed-mysql/common"
CURRENT = "/var/snap/charmed-mysql/current"


def test_install():
    with open("snap/snapcraft.yaml") as file:
        snapcraft = yaml.safe_load(file)

    subprocess.run(
        f"sudo snap remove --purge {snapcraft['name']}".split(),
        check=True,
    )
    subprocess.run(
        f"sudo snap install ./{snapcraft['name']}_{snapcraft['version']}_amd64.snap --devmode".split(),
        check=True,
    )


@pytest.mark.run(after="test_install")
def test_setup():
    # run initialization script
    subprocess.run(["sudo", "tests/setup.sh"], check=True)


@pytest.mark.run(after="test_setup")
def test_install_audit_plugin():
    # install audit plugin
    command = [
        "mysql",
        "-u",
        "root",
        "--password=newpass",
        "-S",
        f"{COMMON}/var/run/mysqld/mysqld.sock",
        "-e",
        "INSTALL PLUGIN audit_log SONAME 'audit_log.so'",
    ]

    subprocess.run(
        command,
        check=True,
    )


@pytest.mark.run(after="test_install_audit_plugin")
def test_audit_log_file():
    # Ensure file is readable
    audit_file = f"{COMMON}/var/lib/mysql/audit.log"
    subprocess.run(["sudo", "chmod", "644", audit_file], check=True)

    with open(audit_file) as f:
        content = f.read()

    # assert last record is a `Quit` from previous command
    assert json.loads(content.splitlines()[-1])["audit_record"]["name"] == "Quit"
