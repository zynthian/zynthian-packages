#!/bin/bash

DESTINY_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Pianos/VCSL_Keys"
URL_DOWNLOAD="https://versilian-studios.com/Distro/VCSL_Keys.zip"


do_install() {
    mkdir -p "$DESTINY_DIR"
    cd $DESTINY_DIR || return 0
    wget $URL_DOWNLOAD
    unzip VCSL_Keys.zip
    rm -f VCSL_Keys.zip
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        rm -rf "$DESTINY_DIR"
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    if [[ -d "$DESTINY_DIR" ]]; then
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

