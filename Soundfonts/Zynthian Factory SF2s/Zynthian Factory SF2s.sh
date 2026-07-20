#!/bin/bash

DESTINY_DIR="$ZYNTHIAN_DATA_DIR/soundfonts"
URL_BASE="https://os.zynthian.org/packages/Soundfonts/Zynthian Factory SF2s"
URL_DOWNLOAD="$URL_BASE/sf2.tar.xz"
URL_FILELIST="$URL_BASE/file_list.txt"

# To extract file_list.txt =>
# tar -t --no-recursion -f sf2.tar.xz sf2/* > file_list.txt


do_install() {
    mkdir -p "$DESTINY_DIR"
    wget -q -O- "$URL_DOWNLOAD" | tar -xJ -C "$DESTINY_DIR"
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        #IFS=$'\n' file_list=( $(wget -q -O- $URL_FILELIST) )
        SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
        readarray -t file_list < "$SCRIPT_DIR/file_list.txt"
        for dir in "${file_list[@]}"; do
            rm -rf "$DESTINY_DIR/$dir"
        done
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    if [[ -f "$DESTINY_DIR/sf2/JAzz BAzz.sf2" ]]; then
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
