#!/bin/bash
# Package script of Salamander Drumkit: archive from os.zynthian.org, extracted in the soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="archive"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Drums"
ARCHIVES=("https://os.zynthian.org/packages/Soundfonts/Salamander Drumkit/Salamander Drumkit.tar.xz")
ITEMS=("Salamander Drumkit")

zynpackage_main "$@"
