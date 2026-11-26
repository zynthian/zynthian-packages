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
#   PACKAGE_TYPE  lv2_plugin | lv2_widget | github_clone | archive
#   GITHUB        owner/repo of the package's repository
#   VERSION       release tag (vX.Y.Z) to install; empty: no release yet, install the latest build
#                 (lv2_widget and github_clone: tag or branch to clone, empty: the default branch)
#   SYMBOL        lv2_plugin: plugin symbol (<SYMBOL>.lv2 bundle, <SYMBOL>-lv2-<arch>.tar.gz in the release)
#   PLUGIN_URI    lv2_plugin: plugin URI, to enable it in the engines DB after installing
#   BUNDLE        lv2_widget: widget bundle directory in the repository (e.g. tuna.zyngui.lv2)
#   DST_DIR       github_clone: directory where the repository is installed, as DST_DIR/DIRNAME
#   DIRNAME       github_clone: name of the installed directory
#   SUBDIR        github_clone: optional directory of the repository to install (default: the whole repository)
#   ARCHIVES      archive: array with the URLs of the archives (.tar.xz, .tar.gz or .zip) to download and extract
#   DST_DIR       archive: directory where the archives are extracted (EXTRACT_SUBDIR: optional, inside DST_DIR)
#   ITEMS         archive: array with what the archives install, relative to DST_DIR: uninstall removes them
#   ITEMS_FILE    archive: alternative to ITEMS, a file (next to the script) with one item per line
#   ITEMS_PREFIX  archive: optional prefix of the items of ITEMS_FILE, relative to DST_DIR
#   INSTALLED_ITEM archive: optional item (relative to DST_DIR) whose presence means "installed" (default: any item)
#
# Hooks (functions defined by the package script) of the archive and github_clone types: pre_install (before
# downloading; exit to stop), post_install (after extracting, e.g. to rename), post_uninstall.
#
# git_version and git_repo are only implemented for packages with GITHUB (no output otherwise).
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
    [ -z "$GITHUB" ] || echo "https://github.com/$GITHUB.git"
}

# Last commit of the default branch: webconf uses it to offer updates when the package has no "version" in info.yml.
# Not implemented (no output) for a release (VERSION set): webconf then uses the "version" of info.yml.
git_version() {
    [ -n "$GITHUB" ] && [ -z "$VERSION" ] || return 0
    git ls-remote "$(git_repo)" HEAD | awk '{ print $1 }'
}

# Run the hook function $1 (pre_install, post_install, post_uninstall) if the package script defines it
zynpackage_run_hook() {
    if declare -F "$1" >/dev/null; then
        "$1"
    fi
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

# --- LV2 widget: widget bundle from the repository (a github_clone of its BUNDLE directory) -----------------------

lv2_widget_install() {
    DST_DIR="$ZYNTHIAN_PLUGINS_DIR/lv2-widgets"; DIRNAME="$BUNDLE"; SUBDIR="$BUNDLE"
    github_clone_install
    touch "$ZYNTHIAN_CONFIG_DIR/lv2.stamp"
}

lv2_widget_uninstall() {
    DST_DIR="$ZYNTHIAN_PLUGINS_DIR/lv2-widgets"; DIRNAME="$BUNDLE"
    github_clone_uninstall
    touch "$ZYNTHIAN_CONFIG_DIR/lv2.stamp"
}

lv2_widget_is_installed() {
    DST_DIR="$ZYNTHIAN_PLUGINS_DIR/lv2-widgets"; DIRNAME="$BUNDLE"
    github_clone_is_installed
}

# --- GitHub clone: the repository (without .git), or its directory SUBDIR, is installed as DST_DIR/DIRNAME ----

github_clone_install() {
    set -ex
    zynpackage_run_hook pre_install
    mkdir -p "$DST_DIR"
    tmp="$(mktemp -d "$DST_DIR/.install.XXXXXX")"
    trap 'rm -rf "$tmp"' EXIT
    local branch=()
    if [ -n "$VERSION" ]; then
        branch=(--branch "$VERSION")
    fi
    git clone --depth 1 "${branch[@]}" "$(git_repo)" "$tmp/clone"
    rm -rf "$tmp/clone/.git"
    rm -rf "$DST_DIR/$DIRNAME"
    mv "$tmp/clone/$SUBDIR" "$DST_DIR/$DIRNAME"
    zynpackage_run_hook post_install
    set +x
    echo "installed"
}

github_clone_uninstall() {
    if [[ $(github_clone_is_installed) == "installed" ]]; then
        rm -rf "$DST_DIR/$DIRNAME"
        zynpackage_run_hook post_uninstall
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

github_clone_is_installed() {
    if [[ -d "$DST_DIR/$DIRNAME" ]]; then
        echo "installed"
    else
        echo "not installed"
    fi
}

# --- Archive: archives (.tar.xz, .tar.gz, .zip) extracted into DST_DIR; uninstall removes ITEMS ---------------

# What the archives install: ITEMS, or the lines of ITEMS_FILE (next to the package script)
archive_items() {
    if [ -n "$ITEMS_FILE" ]; then
        cat "$(dirname "$0")/$ITEMS_FILE"
    else
        printf '%s\n' "${ITEMS[@]}"
    fi
}

archive_install() {
    set -e -o pipefail -x
    zynpackage_run_hook pre_install
    local url dest="$DST_DIR${EXTRACT_SUBDIR:+/$EXTRACT_SUBDIR}"
    mkdir -p "$dest"
    for url in "${ARCHIVES[@]}"; do
        case "$url" in
            *.tar.xz) wget -q -O- "$url" | tar -xJ -C "$dest" ;;
            *.tar.gz) wget -q -O- "$url" | tar -xz -C "$dest" ;;
            *.zip) wget -q -O- "$url" | bsdtar -xf - -C "$dest" ;;
            *) echo "unsupported archive: $url"; exit 1 ;;
        esac
    done
    zynpackage_run_hook post_install
    set +x
    echo "installed"
}

archive_uninstall() {
    if [[ $(archive_is_installed) == "installed" ]]; then
        local item
        while IFS= read -r item; do
            if [ -n "$item" ]; then   # never remove DST_DIR itself
                rm -rf "$DST_DIR/$ITEMS_PREFIX$item"
            fi
        done < <(archive_items)
        zynpackage_run_hook post_uninstall
        echo "uninstalled"
    else
        echo "not installed"
    fi
}

archive_is_installed() {
    if [ -n "$INSTALLED_ITEM" ]; then
        if [ -e "$DST_DIR/$INSTALLED_ITEM" ]; then
            echo "installed"
        else
            echo "not installed"
        fi
        return
    fi
    local item
    while IFS= read -r item; do
        if [ -n "$item" ] && [ -e "$DST_DIR/$ITEMS_PREFIX$item" ]; then
            echo "installed"
            return
        fi
    done < <(archive_items)
    echo "not installed"
}
