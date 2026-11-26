#!/bin/bash
# Package script of Zynthian Salamander Grand: the GitHub repository jlearman/zynthian-salamander-grand, installed in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="github_clone"
GITHUB="jlearman/zynthian-salamander-grand"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Pianos"
DIRNAME="Zynthian Salamander Grand"

zynpackage_main "$@"
