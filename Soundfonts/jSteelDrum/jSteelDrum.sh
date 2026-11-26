#!/bin/bash
# Package script of jSteelDrum: the GitHub repository sfzinstruments/jlearman.SteelDrum, installed in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="github_clone"
GITHUB="sfzinstruments/jlearman.SteelDrum"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Percussion"
DIRNAME="jSteelDrum"

zynpackage_main "$@"
