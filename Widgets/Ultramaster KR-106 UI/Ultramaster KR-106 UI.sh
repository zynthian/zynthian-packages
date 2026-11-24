#!/usr/bin/env bash
# Zynthian package for the *original* Ultramaster KR-106 LV2 host.
# Version managed by the package catalog's info.yml (not git HEAD).
set -euo pipefail

PKG_NAME="Ultramaster KR-106 UI"
BUNDLE="kr106_gui-zyngui.lv2"
DEST_ROOT="/zynthian/zynthian-plugins/lv2-widgets"
STAMP="/zynthian/config/lv2.stamp"
TARGET="$DEST_ROOT/$BUNDLE"
RELEASE="ultramaster-kr106-ui-v0.5.2"
ASSET="Ultramaster_KR106_UI_v0.5.2_Widget_Tomita.zip"
DOWNLOAD_URL="https://github.com/Nicolaz71/zynthian-widgets/releases/download/$RELEASE/$ASSET"
EXPECTED_SHA256="11f8185f8e1b592d7a0a21f5deb3452a9e05d0daeccc2aacc66f395c5e9ca064"
ORIGINAL_URI="https://kayrock.org/kr106"

is_our_widget() {
  [ -d "$1" ] && [ ! -L "$1" ] &&
  [ -f "$1/manifest.ttl" ] &&
  [ -f "$1/zynthian_widget_kr106_gui.py" ] &&
  grep -Fq "<$ORIGINAL_URI>" "$1/manifest.ttl" &&
  grep -Fq 'zyngui:widget' "$1/manifest.ttl"
}

is_installed() {
  if is_our_widget "$TARGET"; then
    echo installed
  else
    echo 'not installed'
  fi
}

notify_lv2() {
  if [ -d "$(dirname "$STAMP")" ]; then
    touch "$STAMP"
  else
    echo "WARNING: $(dirname "$STAMP") does not exist; LV2 rescan marker not updated." >&2
  fi
}

do_install() {
  if [ -L "$TARGET" ]; then
    echo "ERROR: Refusing to replace symlink $TARGET" >&2
    return 1
  fi
  if [ -e "$TARGET" ] && ! is_our_widget "$TARGET"; then
    echo "ERROR: $TARGET exists but is not the original KR-106 widget. No changes made." >&2
    return 1
  fi

  mkdir -p "$DEST_ROOT"
  local work backup new_bundle
  work=$(mktemp -d "${TMPDIR:-/tmp}/kr106-ui-package.XXXXXXXX")
  trap 'rm -rf -- "$work"' RETURN

  if command -v curl >/dev/null 2>&1; then
    curl --fail --location --silent --show-error --retry 3 \
      --output "$work/release.zip" "$DOWNLOAD_URL"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$work/release.zip" "$DOWNLOAD_URL"
  else
    echo 'ERROR: curl or wget is required.' >&2
    return 1
  fi

  printf '%s  %s\n' "$EXPECTED_SHA256" "$work/release.zip" | sha256sum --check --status || {
    echo 'ERROR: Release SHA-256 mismatch; refusing install.' >&2
    return 1
  }

  unzip -q "$work/release.zip" -d "$work/unpacked"
  new_bundle="$work/unpacked/$BUNDLE"
  if ! is_our_widget "$new_bundle"; then
    echo 'ERROR: Invalid bundle or wrong host plugin URI in downloaded release.' >&2
    return 1
  fi
  if find "$new_bundle" -type l -print -quit | grep -q .; then
    echo 'ERROR: Unexpected symlink found in widget release.' >&2
    return 1
  fi
  if find "$new_bundle" -type f -name '*.so' -print -quit | grep -q .; then
    echo 'ERROR: This package is UI-only; binary libraries are not permitted.' >&2
    return 1
  fi

  # Repeat installs of exactly this released widget leave the current copy untouched.
  if is_our_widget "$TARGET" &&
      cmp -s "$TARGET/manifest.ttl" "$new_bundle/manifest.ttl" &&
      cmp -s "$TARGET/zynthian_widget_kr106_gui.py" "$new_bundle/zynthian_widget_kr106_gui.py" &&
      cmp -s "$TARGET/zynthian_widget_kr106_gui.html" "$new_bundle/zynthian_widget_kr106_gui.html"; then
    notify_lv2
    echo installed
    return 0
  fi

  backup=''
  if [ -e "$TARGET" ]; then
    backup="$DEST_ROOT/.kr106-ui-backup-$(date -u +%Y%m%dT%H%M%SZ)-$$"
    mv -- "$TARGET" "$backup"
    echo "Previous widget backup: $backup" >&2
  fi

  if ! mv -- "$new_bundle" "$TARGET"; then
    if [ -n "$backup" ] && [ -e "$backup" ] && [ ! -e "$TARGET" ]; then
      mv -- "$backup" "$TARGET"
    fi
    echo 'ERROR: Widget installation failed; previous copy restored when possible.' >&2
    return 1
  fi
  notify_lv2
  echo installed
}

do_uninstall() {
  if is_our_widget "$TARGET"; then
    rm -rf -- "$TARGET"
    notify_lv2
    echo uninstalled
  elif [ ! -e "$TARGET" ]; then
    echo 'not installed'
  else
    echo 'ERROR: Existing bundle does not match this package; refusing removal.' >&2
    return 1
  fi
}

case "${1:-}" in
  install) do_install ;;
  uninstall) do_uninstall ;;
  installed) is_installed ;;
  *) echo 'Usage: <package-script> {install|uninstall|installed}' >&2; exit 2 ;;
esac
