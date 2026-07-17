#!/bin/bash

DESTINY_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/"
URL_DOWNLOAD_BASE="https://os.zynthian.org/packages/Soundfonts/VPO3"


do_install() {
    wget -q -O- "$URL_DOWNLOAD_BASE/VPO3-std.tar.xz" | tar -xJ -C "$DESTINY_DIR"
    wget -q -O- "$URL_DOWNLOAD_BASE/VPO3-perf.tar.xz" | tar -xJ -C "$DESTINY_DIR"
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        rm -rf "$DESTINY_DIR/VPO3-perf"
        rm -rf "$DESTINY_DIR/VPO3-std"
        rm -rf "$DESTINY_DIR/VPO3"
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    if [[ -d "$DESTINY_DIR/VPO3-std" ]]; then
        echo "installed"
    elif [[ -d "$DESTINY_DIR/VPO3" ]]; then
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

