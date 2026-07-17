#!/bin/bash

DESTINY_DIR="$ZYNTHIAN_DATA_DIR/soundfonts"
URL_BASE="https://os.zynthian.org/packages/Soundfonts/Zynthian Factory SFZs"
URL_DOWNLOAD="$URL_BASE/sfz.tar.xz"
URL_DIRLIST="$URL_BASE/dir_list.txt"

# To extract dir_list.txt =>
# tar -t --no-recursion -f sfz.tar.xz sfz/*/* > dir_list.txt


do_install() {
    mkdir -p "$DESTINY_DIR"
    wget -q -O- "$URL_DOWNLOAD" | tar -xJ -C "$DESTINY_DIR"
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        IFS=$'\n' dir_list=( $(wget -q -O- $URL_DIRLIST) )
        for dir in "${dir_list[@]}"; do
            rm -rf "$DESTINY_DIR/$dir"
        done
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    if [[ -d "$DESTINY_DIR/sfz/Guitars/RealBanjo" ]]; then
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
