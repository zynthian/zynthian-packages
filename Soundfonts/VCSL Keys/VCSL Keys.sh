#!/bin/bash
# Package script of VCSL Keys: Versilian Community Sample Library keys, a zip extracted in the sfz pianos (it has no release tag).
# It uses the zynthian-packages library, so it needs the catalog at $ZYNTHIAN_DIR/zynthian-packages.

source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh

PACKAGE_TYPE="archive"
DST_DIR="$ZYNTHIAN_DATA_DIR/soundfonts/sfz/Pianos"
EXTRACT_SUBDIR="VCSL_Keys"
ARCHIVES=("https://versilian-studios.com/Distro/VCSL_Keys.zip")
ITEMS=("VCSL_Keys")

zynpackage_main "$@"
