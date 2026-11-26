#!/bin/bash
# Package script of Terkelsen Marimba: the GitHub repository sfzinstruments/Terkelsen.Marimba, installed in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="github_clone"
GITHUB="sfzinstruments/Terkelsen.Marimba"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Percussion"
DIRNAME="Terkelsen Marimba"

zynpackage_main "$@"
