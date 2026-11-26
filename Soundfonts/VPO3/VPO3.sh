#!/bin/bash
# Package script of VPO3: archives from os.zynthian.org, extracted in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="archive"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz"
ARCHIVES=("https://os.zynthian.org/packages/Soundfonts/VPO3/VPO3-std.tar.xz" "https://os.zynthian.org/packages/Soundfonts/VPO3/VPO3-perf.tar.xz")
ITEMS=("VPO3-std" "VPO3-perf" "VPO3")

zynpackage_main "$@"
