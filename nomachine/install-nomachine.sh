#!/bin/bash

set -e

NOMACHINE_URL="https://web9001.nomachine.com/download/9.7/Linux/nomachine_9.7.3_1_amd64.deb"
PACKAGE_NAME="nomachine_9.7.3_1_amd64.deb"
TMP_DIR="/tmp"
PACKAGE_FILE="${TMP_DIR}/${PACKAGE_NAME}"

echo "======================================"
echo " NoMachine Installer / Upgrader"
echo "======================================"

# Check root
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root or with sudo."
    exit 1
fi

# Function: Download package
download_package() {
    echo ""
    echo "Downloading NoMachine package..."
    wget -O "${PACKAGE_FILE}" "${NOMACHINE_URL}"

    if [[ ! -f "${PACKAGE_FILE}" ]]; then
        echo "Download failed."
        exit 1
    fi
}

# Function: Install/Upgrade
install_nomachine() {
    echo ""
    echo "Installing/Upgrading NoMachine..."

    dpkg -i "${PACKAGE_FILE}"

    # Fix dependencies if required
    apt-get install -f -y

    echo ""
    echo "Restarting NoMachine..."
    /etc/NX/nxserver --restart || true

    echo ""
    echo "Installed Version:"
    /usr/NX/bin/nxserver --version || true

    echo ""
    echo "Service Status:"
    /etc/NX/nxserver --status || true
}

# Check if NoMachine is installed
if command -v nxserver >/dev/null 2>&1 || [[ -d /usr/NX ]]; then

    echo ""
    echo "NoMachine is already installed."

    CURRENT_VERSION=$(/usr/NX/bin/nxserver --version 2>/dev/null | head -n1)

    if [[ -n "$CURRENT_VERSION" ]]; then
        echo "Current Version: $CURRENT_VERSION"
    fi

    echo ""
    read -p "Do you want to upgrade to v9.7.3? (y/N): " UPGRADE

    if [[ "$UPGRADE" =~ ^[Yy]$ ]]; then
        download_package
        install_nomachine
    else
        echo "Upgrade cancelled."
        exit 0
    fi

else

    echo ""
    echo "NoMachine is not installed."
    read -p "Install NoMachine v9.7.3? (y/N): " INSTALL

    if [[ "$INSTALL" =~ ^[Yy]$ ]]; then
        download_package
        install_nomachine
    else
        echo "Installation cancelled."
        exit 0
    fi

fi

echo ""
echo "Done."