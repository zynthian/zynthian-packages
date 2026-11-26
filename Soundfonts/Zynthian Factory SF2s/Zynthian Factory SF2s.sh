#!/bin/bash
# Package script of Zynthian Factory SF2s: archive from os.zynthian.org, extracted in the soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="archive"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts"
ARCHIVES=("https://os.zynthian.org/packages/Soundfonts/Zynthian Factory SF2s/sf2.tar.xz")
ITEMS_FILE="file_list.txt"
INSTALLED_ITEM="sf2/JAzz BAzz.sf2"

# To extract file_list.txt =>
# tar -t --no-recursion -f sf2.tar.xz sf2/* > file_list.txt

zynpackage_main "$@"
