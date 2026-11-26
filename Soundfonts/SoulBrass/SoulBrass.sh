#!/bin/bash
# Package script of SoulBrass: the GitHub repository jlearman/zynthian-soul-brass, installed in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="github_clone"
GITHUB="jlearman/zynthian-soul-brass"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Brass"
DIRNAME="SoulBrass"

zynpackage_main "$@"
