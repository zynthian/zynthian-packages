#!/bin/bash
# Package script of TR808-fischer: the GitHub repository zynthian/TR808-fischer, installed in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="github_clone"
GITHUB="zynthian/TR808-fischer"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Drum Machines"
DIRNAME="TR808-fischer"

zynpackage_main "$@"
