#!/usr/bin/env bash

# =========================================================
# Node.js + npm Installer Script
# Supports:
#   - Latest LTS version
#   - Specific Node.js version
# Works on:
#   - Ubuntu/Debian
#   - RHEL/CentOS/Rocky/AlmaLinux
# =========================================================

set -e

# -----------------------------
# CONFIGURATION
# -----------------------------

# Default: latest LTS
# Example specific versions:
# NODE_VERSION="20"
# NODE_VERSION="22"

NODE_VERSION="${1:-lts}"

# -----------------------------
# FUNCTIONS
# -----------------------------

detect_os() {
    if [ -f /etc/debian_version ]; then
        OS="debian"
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
    else
        echo "Unsupported OS"
        exit 1
    fi
}

install_dependencies_debian() {
    sudo apt update
    sudo apt install -y curl ca-certificates gnupg
}

install_dependencies_rhel() {
    sudo dnf install -y curl ca-certificates
}

install_node_debian() {
    if [ "$NODE_VERSION" = "lts" ]; then
        echo "Installing latest Node.js LTS..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    else
        echo "Installing Node.js version $NODE_VERSION..."
        curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
    fi

    sudo apt install -y nodejs
}

install_node_rhel() {
    if [ "$NODE_VERSION" = "lts" ]; then
        echo "Installing latest Node.js LTS..."
        curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
    else
        echo "Installing Node.js version $NODE_VERSION..."
        curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | sudo bash -
    fi

    sudo dnf install -y nodejs
}

verify_installation() {
    echo ""
    echo "================================="
    echo "Installed Versions"
    echo "================================="
    node -v
    npm -v
}

# -----------------------------
# MAIN
# -----------------------------

detect_os

if [ "$OS" = "debian" ]; then
    install_dependencies_debian
    install_node_debian
elif [ "$OS" = "rhel" ]; then
    install_dependencies_rhel
    install_node_rhel
fi

verify_installation
