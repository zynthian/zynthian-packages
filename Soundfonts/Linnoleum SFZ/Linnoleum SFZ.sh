#!/bin/bash

DESTINY_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Drum Machines"
URL_DOWNLOAD_BASE="https://os.zynthian.org/packages/Soundfonts/Linnoleum SFZ"


do_install() {
    mkdir -p "$DESTINY_DIR"
    wget -q -O- "$URL_DOWNLOAD_BASE/Linnoleum.tar.xz" | tar -xJ -C "$DESTINY_DIR"
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        rm -rf "$DESTINY_DIR/Linnoleum"
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    if [[ -d "$DESTINY_DIR/Linnoleum" ]]; then
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

