#!/bin/bash
# Package script of Zynthian Factory Legacy SFZs: archive from os.zynthian.org, extracted in the soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="archive"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts"
ARCHIVES=("https://os.zynthian.org/packages/Soundfonts/Zynthian Factory SFZs/sfz.tar.xz")
ITEMS_FILE="dir_list.txt"
INSTALLED_ITEM="sfz/Guitars/RealBanjo"

# To extract dir_list.txt =>
# tar -t --no-recursion -f sfz.tar.xz sfz/*/* > dir_list.txt

pre_install() {
    if [[ -f "$DST_DIR/factory_sfz_list.txt" ]]; then
        echo "Uninstall Zynthian Factory SFZs package first!"
        exit 1
    fi
}

zynpackage_main "$@"
