#!/usr/bin/env bash

set -euo pipefail

MANIFEST_URL="https://public-scripts.github.io/setup-scripts/apps-manifest.json"
APP_ID="nomachine"

TMP_MANIFEST="/tmp/apps-manifest.json"

#######################################
# Detect OS
#######################################
detect_os() {
    source /etc/os-release

    case "$ID" in
        ubuntu)
            OS="ubuntu"
            ;;
        debian)
            OS="debian"
            ;;
        rhel|centos)
            OS="rhel"
            ;;
        rocky)
            OS="rocky"
            ;;
        almalinux)
            OS="almalinux"
            ;;
        *)
            echo "Unsupported OS: $ID"
            exit 1
            ;;
    esac

    OS_VERSION="${VERSION_ID}"
}

#######################################
# Detect Architecture
#######################################
detect_arch() {
    ARCH_RAW=$(uname -m)

    case "$ARCH_RAW" in
        x86_64)
            if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
                ARCH="amd64"
            else
                ARCH="x86_64"
            fi
            ;;
        aarch64|arm64)
            if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
                ARCH="arm64"
            else
                ARCH="aarch64"
            fi
            ;;
        *)
            echo "Unsupported architecture: $ARCH_RAW"
            exit 1
            ;;
    esac
}

#######################################
# Download Manifest
#######################################
download_manifest() {
    echo "Downloading manifest..."
    curl -fsSL "$MANIFEST_URL" -o "$TMP_MANIFEST"
}

#######################################
# Get Latest Version
#######################################
load_manifest_data() {

    LATEST_VERSION=$(jq -r \
        ".apps.${APP_ID}.currentVersion" \
        "$TMP_MANIFEST")

    DOWNLOAD_URL=$(jq -r \
        ".apps.${APP_ID}.versions.\"${LATEST_VERSION}\".\"${OS}\" | to_entries[0].value.\"${ARCH}\".downloadUrl" \
        "$TMP_MANIFEST")

    PACKAGE_TYPE=$(jq -r \
        ".apps.${APP_ID}.versions.\"${LATEST_VERSION}\".\"${OS}\" | to_entries[0].value.\"${ARCH}\".packageType" \
        "$TMP_MANIFEST")

    if [[ "$DOWNLOAD_URL" == "null" ]]; then
        echo "No package found for:"
        echo "OS=$OS ARCH=$ARCH"
        exit 1
    fi
}

#######################################
# Installed Version
#######################################
get_installed_version() {

    if [[ -x /usr/NX/bin/nxserver ]]; then
        INSTALLED_VERSION=$(
            /usr/NX/bin/nxserver --version 2>/dev/null |
            grep -oE '[0-9]+\.[0-9]+\.[0-9]+' |
            head -1
        )
    else
        INSTALLED_VERSION=""
    fi
}

#######################################
# Install Package
#######################################
install_package() {

    PKG="/tmp/nomachine.${PACKAGE_TYPE}"

    echo "Downloading package..."
    curl -L "$DOWNLOAD_URL" -o "$PKG"

    case "$PACKAGE_TYPE" in
        deb)
            dpkg -i "$PKG" || apt-get install -f -y
            ;;
        rpm)
            rpm -Uvh "$PKG"
            ;;
        *)
            echo "Unsupported package type: $PACKAGE_TYPE"
            exit 1
            ;;
    esac

    if [[ -x /etc/NX/nxserver ]]; then
        /etc/NX/nxserver --restart || true
    fi
}

#######################################
# Main
#######################################

detect_os
detect_arch
download_manifest
load_manifest_data
get_installed_version

echo "OS               : $OS"
echo "Architecture     : $ARCH"
echo "Latest Version   : $LATEST_VERSION"
echo "Installed Version: ${INSTALLED_VERSION:-Not Installed}"

if [[ -z "${INSTALLED_VERSION}" ]]; then

    read -rp "NoMachine not installed. Install? (y/N): " ANSWER

    if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
        install_package
    fi

elif [[ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]]; then

    read -rp "Upgrade NoMachine $INSTALLED_VERSION -> $LATEST_VERSION ? (y/N): " ANSWER

    if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
        install_package
    fi

else
    echo "NoMachine is already up-to-date."
fi