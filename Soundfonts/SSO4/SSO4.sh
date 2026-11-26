#!/bin/bash
# Package script of SSO4: Sonatina Symphonic Orchestra, the zip of the GitHub release VERSION, extracted in the sfz soundfonts.
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="archive"
GITHUB="peastman/sso"
VERSION="v4.0"                  # release tag; "version" in info.yml
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz"
ARCHIVES=("https://github.com/$GITHUB/archive/refs/tags/$VERSION.zip")
ITEMS=("SSO4")

post_install() {
    local zip_dir="sso-${VERSION#v}"   # directory at the top of the zip file
    mv "$DST_DIR/$zip_dir/Sonatina Symphonic Orchestra" "$DST_DIR/SSO4"
    mv "$DST_DIR/$zip_dir/LICENSE" "$DST_DIR/SSO4"
    mv "$DST_DIR/$zip_dir/README.md" "$DST_DIR/SSO4"
    rm -rf "$DST_DIR/$zip_dir"
}

zynpackage_main "$@"
