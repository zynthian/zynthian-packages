#!/bin/bash
# Package script of Osiris Piano: the GitHub repository jlearman/zynthian-osiris-piano, installed in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="github_clone"
GITHUB="jlearman/zynthian-osiris-piano"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Pianos"
DIRNAME="Osiris Piano"

zynpackage_main "$@"
