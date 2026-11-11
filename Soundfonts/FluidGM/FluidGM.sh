#!/bin/bash

# Note: nonstandard install/uninstall/is_installed, due to replacing just one sf2
# file where the original is in /usr/share, and the release artifact is not a zip.

# Note: whenever the repo is updated with a new version, these variables need to be
# updated accordingly: RELEASE and CHECKSUM

# release URL: https://github.com/jlearman/fluid-soundfont/releases/download/v3.2/FluidR3_GM.sf2
# zynthian file: /zynthian/zynthian-plugins/lv2/FluidGM.lv2/FluidPlug.sf2
# standard file: /usr/share/sounds/sf2/FluidR3_GM.sf2

DST_DIR="$ZYNTHIAN_PLUGINS_DIR/lv2/FluidGM.lv2"
ORIG_FILE="/usr/share/sounds/sf2/FluidR3_GM.sf2"
REPO="fluid-soundfont"
RELEASE="v3.2"
ARTIFACT="FluidR3_GM.sf2"
CHKSUM="1842102224"
ZYN_FNAME="FluidPlug.sf2"
DOWNLOAD_URL="https://github.com/jlearman/$REPO/archive/refs/tags/$RELEASE/$ARTIFACT"
REPO_URL="https://github.com/jlearman/$REPO.git"

do_install() {
    local -
    set -x
    mkdir -p "$DST_DIR"
    cd "$DST_DIR"
    wget -q "$DOWNLOAD_URL"
    mv "$ARTIFACT" "$ZYN_FNAME"
    set +x
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        # nonstandard: just copy the original library file
        mv "$ORIG_FILE" "$ZYN_FNAME"
    else
        echo "not installed"
    fi
}

is_installed() {
    # nonstandard: check the checksum against the new version
    if [[ $(cksum "$ZYN_FNAME" | cut -d' ' -f1 ) == "$CHECKSUM" ]] ; then
        echo "installed"
    else
        echo "not installed"
    fi
}

git_repo() {
    echo "$REPO_URL"
}

git_version() {
    git ls-remote "$REPO_URL" HEAD | awk '{ print $1 }'
}

if [[ "$1" == "install" ]]; then
    do_install
elif [[ "$1" == "uninstall" ]]; then
    do_uninstall
elif [[ "$1" == "installed" ]]; then
    echo $(is_installed)
elif [[ "$1" == "git_version" ]]; then
    echo $(git_version)
elif [[ "$1" == "git_repo" ]]; then
    echo $(git_repo)
fi

