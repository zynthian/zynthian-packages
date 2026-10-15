#!/bin/bash

REPO="zynthian-factory-sfzs"
URL_BASE="https://github.com/zynthian/$REPO"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts"
FLIST="factory_dir_list.txt"
FLIST_PATH="$DST_DIR/sfz/$FLIST"

do_install() {
    if [[ $(is_installed_legacy) == "installed" ]]; then
        echo "Legacy Factory SFZs installed! Uninstalling first ..."
        do_uninstall_legacy
    fi
    mkdir -p "$DST_DIR"
    cd "$DST_DIR"
    git clone --depth 1 "$URL_BASE"
    merge_move "./$REPO/sfz" "./sfz"
    rm -rf "./$REPO"
    echo "installed"
}

merge_move() {
    local src_dpath="$1"
    local dst_dpath="$2"

    # Input Validation
    if [ -z "$src_dpath" ] || [ -z "$dst_dpath" ]; then
        echo "Error: Missing arguments." >&2
        echo "Usage: merge_move <source_directory> <destination_directory>" >&2
        return 1
    fi

    if [ ! -d "$src_dpath" ]; then
        echo "Error: Source directory '$src_dpath' does not exist." >&2
        return 1
    fi

    # Convert paths to absolute paths to handle trailing slashes and relative inputs safely
    src_dpath=$(cd "$src_dpath" && pwd)
    mkdir -p "$dst_dpath"
    dst_dpath=$(cd "$dst_dpath" && pwd)

    echo "Starting merge from '$src_dpath' to '$dst_dpath'..."

    # Find and process files one by one without wasting disk space
    find "$src_dpath" -type f -exec sh -c '
        src="$1"
        dst="$2"
        shift 2
        for file; do
            rel_path="${file#$src/}"
            sub_dir=$(dirname "$rel_path")
            target_dir="$dst/$sub_dir"
            mkdir -p "$target_dir"
            mv "$file" "$target_dir/"
        done
    ' _ "$src_dpath" "$dst_dpath" {} +

    echo "Merge complete. Cleaning source..."
    # Clean up empty subdirectories left behind in the source path
    #find "$src_dpath" -type d -empty -delete 2>/dev/null
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        wget "https://raw.githubusercontent.com/zynthian/$REPO/refs/heads/main/sfz/$FLIST" -O "$FLIST_PATH"
        readarray -t dir_list < "$FLIST_PATH"
        for dir in "${dir_list[@]}"; do
            rm -rf "$DST_DIR/$dir"
        done
        rm -f "$FLIST_PATH"
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    if [[ -f "$FLIST_PATH" ]]; then
        echo "installed"
    else
        echo "not installed"
    fi
}

do_uninstall_legacy() {
    if [[ $(is_installed_legacy) == "installed" ]]; then
        #IFS=$'\n' dir_list=( $(wget -q -O- $URL_DIRLIST) )
        SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
        readarray -t dir_list < "$SCRIPT_DIR/legacy_dir_list.txt"
        for dir in "${dir_list[@]}"; do
            rm -rf "$DST_DIR/$dir"
        done
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed_legacy() {
    if [[ -d "$DST_DIR/sfz/Guitars/RealBanjo" ]]; then
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
