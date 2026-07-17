#!/bin/bash

DESTINY_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz"
URL_DOWNLOAD="https://github.com/peastman/sso/archive/refs/tags/v4.0.zip"

do_install() {
    mkdir -p "$DESTINY_DIR"
    wget -q -O- "$URL_DOWNLOAD" | bsdtar -xvf- -C "$DESTINY_DIR"
    mv "$DESTINY_DIR/sso-4.0/Sonatina Symphonic Orchestra" "$DESTINY_DIR/SSO4"
    mv "$DESTINY_DIR/sso-4.0/LICENSE" "$DESTINY_DIR/SSO4"
    mv "$DESTINY_DIR/sso-4.0/README.md" "$DESTINY_DIR/SSO4"
    rm -rf "$DESTINY_DIR/sso-4.0"
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        rm -rf "$DESTINY_DIR/SSO4"
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    if [[ -d "$DESTINY_DIR/SSO4" ]]; then
        echo "installed"
    else
        echo "not installed"
    fi
}

if [[ "$1" == "install" ]]; then
    do_install
elif [[ "$1" == "uninstall" ]]; then
    do_uninstall
elif [[ "$1" == "installed" ]]; then
    echo $(is_installed)
fi

