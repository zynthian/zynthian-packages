#!/bin/bash
# ZYNTHIAN PROJECT: common code for package install scripts
#
# A package script (<Category>/<Package>/<Package>.sh) sources this library, sets its variables and calls
# zynpackage_main. It must implement the commands install, uninstall, installed and, for git-managed packages,
# git_version and git_repo (see README.md). The library implements them for the packages whose files are published
# in a GitHub repository (LV2 plugins and zynthian widget bundles); a package script can redefine any function
# after sourcing the library.
#
# Variables of a package script:
#   PACKAGE_TYPE  lv2_plugin | lv2_widget
#   GITHUB        owner/repo of the package's repository
#   VERSION       release tag (vX.Y.Z) to install; empty: no release yet, install the latest build
#   SYMBOL        lv2_plugin: plugin symbol (<SYMBOL>.lv2 bundle, <SYMBOL>-lv2-<arch>.tar.gz in the release)
#   PLUGIN_URI    lv2_plugin: plugin URI, to enable it in the engines DB after installing
#   BUNDLE        lv2_widget: widget bundle directory in the repository (e.g. tuna.zyngui.lv2)
#
# Example:
#   source $ZYNTHIAN_DIR/zynthian-packages/zynpackage_lib.sh
#   PACKAGE_TYPE="lv2_plugin"
#   GITHUB="owner/my_plugin"
#   VERSION="v0.1.0"
#   SYMBOL="my_plugin"
#   PLUGIN_URI="https://zynthian.org/plugins/my_plugin"
#   zynpackage_main "$@"

# --- Generic ---------------------------------------------------------------------------------------------------

zynpackage_main() {
    case "$1" in
        install) do_install ;;
        uninstall) do_uninstall ;;
        installed) is_installed ;;
        git_version) git_version ;;
        git_repo) git_repo ;;
    esac
}

# Default handlers: the ones of the package type
do_install() { "${PACKAGE_TYPE}_install"; }
do_uninstall() { "${PACKAGE_TYPE}_uninstall"; }
is_installed() { "${PACKAGE_TYPE}_is_installed"; }

git_repo() {
    echo "https://github.com/$GITHUB.git"
}

# Last commit of the default branch: webconf uses it to offer updates when the package has no "version" in info.yml.
# Not implemented (no output) for a release (VERSION set): webconf then uses the "version" of info.yml.
git_version() {
    [ -z "$VERSION" ] || return 0
    git ls-remote "$(git_repo)" HEAD | awk '{ print $1 }'
}

# CPU architecture name used in the releases
zynpackage_arch() {
    case "$MACHINE_HW_NAME" in
        aarch64) echo "arm64" ;;
        x86_64) echo "x86_64" ;;
        *) echo "unsupported architecture: $MACHINE_HW_NAME" >&2; return 1 ;;
    esac
}

# Download URL of a file attached to the release VERSION (or to the rolling "latest" build when VERSION is empty)
github_release_url() {
    echo "https://github.com/$GITHUB/releases/download/${VERSION:-latest}/$1"
}

# Download URL of the repository source: the tag VERSION, or the last commit when VERSION is empty
github_archive_url() {
    if [ -n "$VERSION" ]; then
        echo "https://github.com/$GITHUB/archive/refs/tags/$VERSION.tar.gz"
    else
        echo "https://github.com/$GITHUB/archive/HEAD.tar.gz"
    fi
}

# --- LV2 plugin: bundle from the CI release/build, into zynthian-plugins/lv2 ---------------------------------

lv2_plugin_install() {
    set -ex
    local file="$SYMBOL-lv2-$(zynpackage_arch).tar.gz"
    mkdir -p "$ZYNTHIAN_PLUGINS_DIR/lv2"
    cd "$ZYNTHIAN_PLUGINS_DIR/lv2"
    wget -q -O "$file" "$(github_release_url "$file")"
    rm -rf "$SYMBOL.lv2"
    tar xzf "$file"
    rm -f "$file"
    set +x
    $ZYNTHIAN_SYS_DIR/sbin/zyngine_tool.py -r ENABLE "$PLUGIN_URI"
    echo "installed"
}

lv2_plugin_uninstall() {
    if [[ $(lv2_plugin_is_installed) == "installed" ]]; then
        rm -rf "$ZYNTHIAN_PLUGINS_DIR/lv2/$SYMBOL.lv2"
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

lv2_plugin_is_installed() {
    if [[ -d "$ZYNTHIAN_PLUGINS_DIR/lv2/$SYMBOL.lv2" ]]; then
        echo "installed"
    else
        echo "not installed"
    fi
}

# --- LV2 widget: widget bundle from the repository source, into zynthian-plugins/lv2-widgets ------------------

lv2_widget_install() {
    set -ex
    local tmp="$(mktemp -d)"
    wget -q -O- "$(github_archive_url)" | tar xz -C "$tmp"
    mkdir -p "$ZYNTHIAN_PLUGINS_DIR/lv2-widgets"
    rm -rf "$ZYNTHIAN_PLUGINS_DIR/lv2-widgets/$BUNDLE"
    mv "$tmp"/*/"$BUNDLE" "$ZYNTHIAN_PLUGINS_DIR/lv2-widgets/"
    rm -rf "$tmp"
    touch "$ZYNTHIAN_CONFIG_DIR/lv2.stamp"
    set +x
    echo "installed"
}

lv2_widget_uninstall() {
    if [[ $(lv2_widget_is_installed) == "installed" ]]; then
        rm -rf "$ZYNTHIAN_PLUGINS_DIR/lv2-widgets/$BUNDLE"
        touch "$ZYNTHIAN_CONFIG_DIR/lv2.stamp"
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

lv2_widget_is_installed() {
    if [[ -d "$ZYNTHIAN_PLUGINS_DIR/lv2-widgets/$BUNDLE" ]]; then
        echo "installed"
    else
        echo "not installed"
    fi
}
