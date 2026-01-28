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
    query = "INSTALL COMPONENT 'file://component_audit_log_filter'"

    command = [
        "mysql",
        "--user=root",
        "--password=newpass",
        f"--socket={COMMON}/var/run/mysqld/mysqld.sock",
        f"--execute={query}",
    ]

    subprocess.run(
        command,
        check=True,
    )


@pytest.mark.run(after="test_install_audit_plugin")
def test_audit_log_file():
    # Ensure file is readable
    audit_file = f"{COMMON}/var/lib/mysql/audit_filter.log"
    subprocess.run(["sudo", "chmod", "644", audit_file], check=True)

    with open(audit_file) as f:
        content = f.read()
        content = "\n".join(content.splitlines()[1:])

    assert json.loads(content)
