#!/bin/bash

DESTINY_DIR="$ZYNTHIAN_DATA_DIR/files/IRs"
ZIP_FILENAME="Conners-IR-Library_v2.0.0.zip"
URL_DOWNLOAD="https://github.com/itsmusician/IR-Library/releases/download/v2.0.0/$ZIP_FILENAME"


do_install() {
    mkdir -p "$DESTINY_DIR"
    wget -q -O- "$URL_DOWNLOAD" | bsdtar -xvf- -C "$DESTINY_DIR"
    mv "$DESTINY_DIR/IR-Library-main" "$DESTINY_DIR/Conners"
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        rm -rf "$DESTINY_DIR/Conners"
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {

    if [[ -d "$DESTINY_DIR/Conners" ]]; then
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
