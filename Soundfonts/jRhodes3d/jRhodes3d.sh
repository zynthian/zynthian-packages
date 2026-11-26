#!/bin/bash
# Package script of jRhodes3d: the GitHub repository zynthian/jlearman.jRhodes3d, installed in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="github_clone"
GITHUB="zynthian/jlearman.jRhodes3d"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Pianos"
DIRNAME="jRhodes3d"

# Old versions of this package installed the demo mp3 in the audio tracks: remove it on uninstall
post_uninstall() {
    rm -f "$ZYNTHIAN_MY_DATA_DIR/files/Audio/Tracks/jRhodes3d-demo.mp3"
}

zynpackage_main "$@"
