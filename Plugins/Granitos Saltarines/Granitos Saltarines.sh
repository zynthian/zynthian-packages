#!/bin/bash

REPO="granitos_saltarines"
VERSION="v0.1.0"

if [ "${MACHINE_HW_NAME}" == "aarch64" ]; then
    CPU_ARCH="arm64"
elif [ "${MACHINE_HW_NAME}" == "x86_64" ]; then
    CPU_ARCH="x86_64"
fi

DIRNAME="$REPO.lv2"
FILENAME="$REPO-lv2-$CPU_ARCH.tar.gz"
REPO_URL="https://github.com/jofemodo/$REPO.git"
DOWNLOAD_URL="https://github.com/jofemodo/$REPO/releases/download/$VERSION/$FILENAME"

DST_DIR="$ZYNTHIAN_PLUGINS_DIR/lv2"

do_install() {
    set -ex
    mkdir -p "$DST_DIR"
    cd $DST_DIR
    wget "$DOWNLOAD_URL"
    tar xfv $FILENAME
    rm -f $FILENAME
    set +x
    echo "installed"
}

do_uninstall() {
    if [[ $(is_installed) == "installed" ]]; then
        rm -rf "$DST_DIR/$DIRNAME"
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

is_installed() {
    if [[ -d "$DST_DIR/$DIRNAME" ]]; then
        echo "installed"
    else
        echo "not installed"
    fi
}

git_repo() {
    echo $REPO_URL
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

