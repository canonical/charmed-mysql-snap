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


@pytest.mark.run(after="test_install")
def test_all_apps():
    with open("snap/snapcraft.yaml") as file:
        snapcraft = yaml.safe_load(file)

        override = {
            "mysqlrouter": "--version",
            "xtrabackup": "--version",
        }

        sudo = ["mysqlrouter", "mysqlsh", "mysqlrouter-passwd"]

        for app, data in snapcraft["apps"].items():
            if not bool(data.get("daemon")):
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
            f"sudo cp tests/templates/mysqlrouter.conf /var/snap/{snapcraft['name']}/current/etc/mysqlrouter/mysqlrouter.conf".split(),
            check=True,
        )
        subprocess.run(
            f"sudo {snapcraft['name']}.mysqlrouter-passwd set /var/snap/{snapcraft['name']}/current/etc/mysqlrouter/mysqlrouter.pwd user".split(),
            input="password",
            encoding="utf-8",
            check=True,
        )

        skip = ["mysqlrouter-service"]

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
        assert "active" == service.stdout.split("\n")[1].split()[2]

        service_configs = {
            "mysqld-exporter": {
                "exporter.user": "user",
                "exporter.password": "password",
            },
            "mysqlrouter-exporter": {
                "mysqlrouter-exporter.user": "user",
                "mysqlrouter-exporter.password": "password",
                "mysqlrouter-exporter.url": "http://127.0.0.1:8081",
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

                subprocess.run(
                    f"sudo snap start {snapcraft['name']}.{app}".split(), check=True
                )
                time.sleep(5)
                service = subprocess.run(
                    f"snap services {snapcraft['name']}.{app}".split(),
                    check=True,
                    capture_output=True,
                    encoding="utf-8",
                )
                subprocess.run(f"sudo snap stop {snapcraft['name']}.{app}".split())

                assert "active" == service.stdout.split("\n")[1].split()[2]
