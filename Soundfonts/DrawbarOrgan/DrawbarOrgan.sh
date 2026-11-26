#!/bin/bash
# Package script of DrawbarOrgan: the GitHub repository jlearman/zynthian-b3-sfz, installed in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="github_clone"
GITHUB="jlearman/zynthian-b3-sfz"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Organs"
DIRNAME="DrawbarOrgan"

zynpackage_main "$@"
