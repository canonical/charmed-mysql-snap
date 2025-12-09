# MySQL Snap
[![Release to Snap Store](https://github.com/canonical/charmed-mysql-snap/actions/workflows/release.yaml/badge.svg)](https://github.com/canonical/charmed-mysql-snap/actions/workflows/release.yaml)

This repository contains the packaging metadata for creating a snap of MySQL built from the official Ubuntu repositories.  For more information on snaps, visit [snapcraft.io](https://snapcraft.io/). 

## Installing the Snap
The snap can be installed directly from the Snap Store.  Follow the link below for more information.
<br>

[![Get it from the Snap Store](https://snapcraft.io/static/images/badges/en/snap-store-black.svg)](https://snapcraft.io/charmed-mysql)


## Building the Snap
The steps outlined below are based on the assumption that you are building the snap with the latest LTS of Ubuntu.  If you are using another version of Ubuntu or another operating system, the process may be different.

### Clone Repository
```bash
git clone git@github.com:canonical/charmed-mysql-snap.git
cd charmed-mysql-snap
```

### Installing and Configuring Prerequisites
```bash
sudo snap install snapcraft
sudo snap install lxd
sudo lxd init --auto
```

### Packing and Installing the Snap
In order to properly test the confinement of the snap, we must install it using the `--dangerous` flag,
instead of the `--devmode` one. See snap [installation modes](https://snapcraft.io/docs/install-modes).

```bash
snapcraft pack
sudo snap install ./charmed-mysql*.charm --dangerous
```

## License
The MySQL Server Snap is free software, distributed under the Apache
Software License, version 2.0. See
[LICENSE](https://github.com/canonical/mysql-server-snap/blob/8.0/edge/licenses)
for more information.
