#!/bin/bash
# Package script of Hydrogen Drumkits: archive from os.zynthian.org, extracted in the soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="archive"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts"
ARCHIVES=("https://os.zynthian.org/packages/Soundfonts/Hydrogen Drumkits/hydrogen.tar.xz")
ITEMS_FILE="dir_list.txt"      # the kits: directories of hydrogen/
ITEMS_PREFIX="hydrogen/"
INSTALLED_ITEM="hydrogen/3355606kit"

# The drumkits are presets of these plugins
regenerate_lv2_presets() {
    regenerate_lv2_presets.sh "http://www.openavproductions.com/fabla"
    regenerate_lv2_presets.sh "http://github.com/nicklan/drmr"
}

post_install() {
    regenerate_lv2_presets
}

post_uninstall() {
    regenerate_lv2_presets
}

zynpackage_main "$@"
