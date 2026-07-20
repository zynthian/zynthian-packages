#!/bin/bash

DESTINY_DIR="$ZYNTHIAN_DATA_DIR/soundfonts"
URL_BASE="https://os.zynthian.org/packages/Soundfonts/Hydrogen Drumkits"
URL_DOWNLOAD="$URL_BASE/hydrogen.tar.xz"
URL_DIRLIST="$URL_BASE/dir_list.txt"

do_install() {
    mkdir -p "$DESTINY_DIR"
    wget -q -O- "$URL_DOWNLOAD" | tar -xJ -C "$DESTINY_DIR"
    regenerate_lv2_presets
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        #IFS=$'\n' dir_list=( $(wget -q -O- $URL_DIRLIST) )
        SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
        readarray -t dir_list < "$SCRIPT_DIR/dir_list.txt"
        for dir in "${dir_list[@]}"; do
            rm -rf "$DESTINY_DIR/hydrogen/$dir"
        done
        regenerate_lv2_presets
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    if [[ -d "$DESTINY_DIR/hydrogen/3355606kit" ]]; then
        echo "installed"
    else
        echo "not installed"
    fi
}

regenerate_lv2_presets() {
    #rm -rf "$ZYNTHIAN_MY_DATA_DIR/presets/lv2/fabla_hydrogen_presets.lv2"
    #rm -rf "$ZYNTHIAN_MY_DATA_DIR/presets/lv2/DrMr_Sampler_presets.lv2"
    regenerate_lv2_presets.sh "http://www.openavproductions.com/fabla"
    regenerate_lv2_presets.sh "http://github.com/nicklan/drmr"
}

if [[ "$1" == "install" ]]; then
    do_install
elif [[ "$1" == "uninstall" ]]; then
    do_uninstall
elif [[ "$1" == "installed" ]]; then
    echo $(is_installed)
fi

