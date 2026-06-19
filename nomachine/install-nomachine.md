# NoMachine Installer

Install or upgrade NoMachine automatically using a manifest-driven installer.

## Prerequisites

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y curl jq
```

### RHEL / Rocky / AlmaLinux

```bash
sudo dnf install -y curl jq
```

## Installation

### Download the Installer

```bash
curl -fsSL https://public-scripts.github.io/setup-scripts/install-nomachine.sh -o install-nomachine.sh
```

### Make the Script Executable

```bash
chmod +x install-nomachine.sh
```

### Run the Installer

```bash
sudo ./install-nomachine.sh
```

## One-Line Installation

```bash
curl -fsSL https://public-scripts.github.io/setup-scripts/install-nomachine.sh | sudo bash
```

## What the Script Does

* Detects Linux distribution and architecture.
* Downloads the latest application manifest.
* Checks whether NoMachine is already installed.
* Compares the installed version with the latest version from the manifest.
* Prompts for installation or upgrade when required.
* Downloads and installs the correct package.
* Restarts NoMachine services automatically.

## Verify Installation

Check installed version:

```bash
/usr/NX/bin/nxserver --version
```

Check service status:

```bash
sudo /etc/NX/nxserver --status
```

Restart NoMachine:

```bash
sudo /etc/NX/nxserver --restart
```

## Supported Platforms

| Distribution | Architecture    |
| ------------ | --------------- |
| Ubuntu       | amd64, arm64    |
| Debian       | amd64, arm64    |
| RHEL         | x86_64, aarch64 |
| Rocky Linux  | x86_64, aarch64 |
| AlmaLinux    | x86_64, aarch64 |

```
```
