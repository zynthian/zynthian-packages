#!/bin/bash
# Package script of Zynthian Meatbass: the GitHub repository jlearman/zynthian-meatbass, installed in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="github_clone"
GITHUB="jlearman/zynthian-meatbass"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Bass"
DIRNAME="Zynthian Meatbass"

zynpackage_main "$@"
