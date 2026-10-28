#!/bin/bash

DESTINY_DIR="$ZYNTHIAN_DATA_DIR/presets/lv2"
URL_DOWNLOAD="https://os.zynthian.org/packages/IRs/X42 IRs/ir-lv2-presets.tar.xz"

declare -a colnames=("ccgb" "jezwells" "l480" "openairlib" "samplicity-m7" "teufelsberg")


do_install() {
    # Install LV2 presets (include IR files)
    mkdir -p "$DESTINY_DIR"
    wget -q -O- "$URL_DOWNLOAD" | tar -xJ -C "$DESTINY_DIR"
    # Create sym linke
    mkdir -p "$ZYNTHIAN_DATA_DIR/files/IRs"
    for colname in "${colnames[@]}"; do
        ln -s "$DESTINY_DIR/$colname-ir.lv2" "$ZYNTHIAN_DATA_DIR/files/IRs/$colname"
    done
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        for colname in "${colnames[@]}"; do
            rm -rf "$DESTINY_DIR/$colname-ir.lv2"
            rm -f "$ZYNTHIAN_DATA_DIR/files/IRs/$colname"
        done
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    for colname in "${colnames[@]}"; do
        if [[ ! -d "$DESTINY_DIR/$colname-ir.lv2" ]]; then
            echo "not installed"
            return
        fi
    done
    echo "installed"
}

if [[ "$1" == "install" ]]; then
    do_install
elif [[ "$1" == "uninstall" ]]; then
    do_uninstall
elif [[ "$1" == "installed" ]]; then
    echo $(is_installed)
fi

