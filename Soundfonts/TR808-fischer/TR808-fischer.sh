#!/bin/bash

DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Drum Machines"
RELEASE="2607"
DOWNLOAD_URL="https://github.com/zynthian/TR808-fischer/archive/refs/tags/$RELEASE.zip"
DIRNAME="TR808-fischer"

do_install() {
    set -ex
    mkdir -p "$DST_DIR"
    cd "$DST_DIR"
    wget -q "$DOWNLOAD_URL"
    unzip -q "$RELEASE.zip"
    rm -f "$RELEASE.zip"
    mv "$DIRNAME-$RELEASE" "$DIRNAME"
    rm -rf "$DIRNAME/package"
    set +x
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        rm -rf "$DST_DIR/$DIRNAME"
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    if [[ -d "$DST_DIR/$DIRNAME" ]]; then
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

