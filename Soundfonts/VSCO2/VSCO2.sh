#!/bin/bash
# Package script of VSCO2: VSCO 2 Community Edition, the zip of the GitHub release VERSION, extracted in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="archive"
GITHUB="sgossner/VSCO-2-CE"
VERSION="1.1.0"                 # release tag; "version" in info.yml
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz"
ARCHIVES=("https://github.com/$GITHUB/archive/refs/tags/$VERSION.zip")
ITEMS=("VSCO2")

post_install() {
    mv "$DST_DIR/VSCO-2-CE-$VERSION" "$DST_DIR/VSCO2"   # VSCO-2-CE-<version>: directory at the top of the zip file
}

zynpackage_main "$@"
