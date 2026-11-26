#!/bin/bash
# Package script of Linnoleum SFZ: archive from os.zynthian.org, extracted in the soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="archive"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Drum Machines"
ARCHIVES=("https://os.zynthian.org/packages/Soundfonts/Linnoleum SFZ/Linnoleum.tar.xz")
ITEMS=("Linnoleum")

zynpackage_main "$@"
