# Copyright 2024 Canonical Ltd.
# See LICENSE file for licensing details.

import yaml
import subprocess
import time
import pytest


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

        subprocess.run(
            f"sudo  install -o snap_daemon /dev/null /var/snap/{snapcraft['name']}/common/var/log/mysql/error.log".split(),
            check=True,
        )


@pytest.mark.run(after="test_install")
def test_all_apps():
    with open("snap/snapcraft.yaml") as file:
        snapcraft = yaml.safe_load(file)

        override = {
            "mysqlrouter": "--version",
            "xtrabackup": "--version",
        }

        sudo = ["mysqlrouter", "mysqlsh", "mysqlrouter-passwd"]
        # pitr helper requires s3 credentials
        skip = ["mysql-pitr-helper"]

        for app, data in snapcraft["apps"].items():
            if not bool(data.get("daemon")) and app not in skip:
                print(f"Testing {snapcraft['name']}.{app}....")
                subprocess.run(
                    f"{'sudo' if app in sudo else ''} {snapcraft['name']}.{app} {override.get(app, '--help')}".split(),
                    check=True,
                )


@pytest.mark.run(after="test_install")
def test_all_services():
    with open("snap/snapcraft.yaml") as file:
        snapcraft = yaml.safe_load(file)

        subprocess.run(
            [
                "sudo",
                "install",
                "-o",
                "snap_daemon",
                "-m",
                "600",
                "tests/mysqlrouter.conf",
                f"/var/snap/{snapcraft['name']}/current/etc/mysqlrouter/mysqlrouter.conf",
            ],
            check=True,
        )
        subprocess.run(
            [
                "sudo",
                f"{snapcraft['name']}.mysqlrouter-passwd",
                "set",
                f"/var/snap/{snapcraft['name']}/current/etc/mysqlrouter/mysqlrouter.pwd",
                "user",
            ],
            input="password",
            encoding="utf-8",
            check=True,
        )

        skip = ["mysqlrouter-service", "mysql-pitr-helper-collector"]

        subprocess.run(
            f"sudo snap start {snapcraft['name']}.mysqlrouter-service".split(),
            check=True,
        )
        time.sleep(5)
        service = subprocess.run(
            f"snap services {snapcraft['name']}.mysqlrouter-service".split(),
            check=True,
            capture_output=True,
            encoding="utf-8",
        )
        assert (
            "active" == service.stdout.split("\n")[1].split()[2]
        ), "Failed to start mysql-router service"

        service_configs = {
            "mysqld-exporter": {
                "exporter.user": "user",
                "exporter.password": "password",
            },
            "mysqlrouter-exporter": {
                "mysqlrouter-exporter.user": "user",
                "mysqlrouter-exporter.password": "password",
                "mysqlrouter-exporter.url": "http://127.0.0.1:8081",
                "mysqlrouter-exporter.service-name": "mysql-router/0",
            },
        }

        for app, data in snapcraft["apps"].items():
            if bool(data.get("daemon")) and app not in skip:
                print(f"\nTesting {snapcraft['name']}.{app} service....")

                if app in service_configs:
                    for config, value in service_configs[app].items():
                        subprocess.run(
                            f"sudo snap set {snapcraft['name']} {config}={value}".split(),
                            check=True,
                        )

                service_name = f"{snapcraft['name']}.{app}"
                subprocess.run(f"sudo snap start {service_name}".split(), check=True)
                time.sleep(5)
                service = subprocess.run(
                    f"snap services {service_name}".split(),
                    check=True,
                    capture_output=True,
                    encoding="utf-8",
                )
                subprocess.run(f"sudo snap stop {service_name}".split())

                assert (
                    "active" == service.stdout.split("\n")[1].split()[2]
                ), f"Failed to start {service_name}"
