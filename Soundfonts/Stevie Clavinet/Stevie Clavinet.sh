#!/bin/bash
# Package script of Stevie Clavinet: the GitHub repository jlearman/stevie-clavinet, installed in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="github_clone"
GITHUB="jlearman/stevie-clavinet"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Pianos"
DIRNAME="Stevie Clavinet"

zynpackage_main "$@"
