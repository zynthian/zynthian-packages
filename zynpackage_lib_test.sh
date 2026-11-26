#!/bin/bash
# Self-test of zynpackage_lib.sh: no network, no zynthian needed (downloads and zynthian tools are stubbed).
#   bash zynpackage_lib_test.sh

HERE="$(cd "$(dirname "$0")" && pwd)"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
export ZYNTHIAN_PLUGINS_DIR="$T/plugins" ZYNTHIAN_CONFIG_DIR="$T/config" ZYNTHIAN_SYS_DIR="$T/sys" MACHINE_HW_NAME="aarch64"
mkdir -p "$T/bin" "$T/config" "$T/sys/sbin" "$T/src/p.lv2"
echo manifest > "$T/src/p.lv2/manifest.ttl"
tar -C "$T/src" -czf "$T/plugin.tar.gz" p.lv2
mkdir -p "$T/arc/Inst" "$T/arc/Other"
echo sfz > "$T/arc/Inst/a.sfz"; echo sfz > "$T/arc/Other/b.sfz"
tar -C "$T/arc" -cJf "$T/archive.tar.xz" Inst Other
printf '#!/bin/bash\necho "$@" >> "%s/tool.log"\n' "$T" > "$T/sys/sbin/zyngine_tool.py"
# wget stub: logs the URL, serves the plugin tarball; wget [-q] (-O <file> | -O-) <url>
cat > "$T/bin/wget" <<STUB
#!/bin/bash
url="\${@: -1}"; dest=""
while [ \$# -gt 1 ]; do
    case "\$1" in -O-) dest="-" ;; -O) dest="\$2"; shift ;; esac
    shift
done
echo "\$url" >> "$T/wget.log"
case "\$url" in *.tar.gz) f="$T/plugin.tar.gz" ;; *.tar.xz|*.zip) f="$T/archive.tar.xz" ;; *) exit 1 ;; esac
if [ "\$dest" = "-" ]; then cat "\$f"; else cp "\$f" "\$dest"; fi
STUB
# bsdtar stub: bsdtar -xf - -C <dir>  (the "zip" served by the wget stub is a tar.xz)
printf '#!/bin/bash\necho "bsdtar $*" >> "%s/bsdtar.log"\nexec tar -xJ -C "${@: -1}"\n' "$T" > "$T/bin/bsdtar"
chmod +x "$T/bin/wget" "$T/bin/bsdtar" "$T/sys/sbin/zyngine_tool.py"
# git stub: ls-remote answers with a commit; clone [--depth 1] [--branch <ref>] <url> <dir> creates <dir> with a file and .git
cat > "$T/bin/git" <<'STUB'
#!/bin/bash
case "$1" in
    ls-remote) echo -e "abc123\tHEAD" ;;
    clone) echo "$@" >> "$(dirname "$0")/../git.log"; mkdir -p "${@: -1}/.git" "${@: -1}/w.zyngui.lv2" && echo instrument > "${@: -1}/inst.sfz" && echo widget > "${@: -1}/w.zyngui.lv2/w.py" ;;
esac
STUB
chmod +x "$T/bin/git"
export PATH="$T/bin:$PATH"

fails=0
check() {  # check <description> <expected> <actual>
    if [ "$2" == "$3" ]; then echo "ok   $1"; else echo "FAIL $1: expected '$2', got '$3'"; fails=$((fails + 1)); fi
}

# Package script as a subshell: run <command> with the given variables
pkg() {  # pkg <type> <version> <command>
    (
        source "$HERE/zynpackage_lib.sh"
        PACKAGE_TYPE="$1"; GITHUB="owner/repo"; VERSION="$2"
        SYMBOL="p"; PLUGIN_URI="urn:p"; BUNDLE="w.zyngui.lv2"; DST_DIR="$T/sfz/My Dir"; DIRNAME="My Inst"
        zynpackage_main "$3"
    ) 2>/dev/null
}

check "git_repo" "https://github.com/owner/repo.git" "$(pkg lv2_plugin "" git_repo)"
check "git_version: last commit without a release" "abc123" "$(pkg lv2_plugin "" git_version)"
check "git_version: not implemented with a release" "" "$(pkg lv2_plugin v0.1.0 git_version)"
(source "$HERE/zynpackage_lib.sh"; GITHUB=owner/repo
 VERSION=v1.2.3; check "release url (tag)" "https://github.com/owner/repo/releases/download/v1.2.3/f.tar.gz" "$(github_release_url f.tar.gz)"
 VERSION=""; check "release url (latest build)" "https://github.com/owner/repo/releases/download/latest/f.tar.gz" "$(github_release_url f.tar.gz)"
 MACHINE_HW_NAME=x86_64; check "arch x86_64" "x86_64" "$(zynpackage_arch)"
 MACHINE_HW_NAME=aarch64; check "arch aarch64" "arm64" "$(zynpackage_arch)"
 MACHINE_HW_NAME=armv7l; zynpackage_arch >/dev/null 2>&1; check "arch unsupported fails" "1" "$?"
 exit $fails) || fails=$((fails + $?))

check "plugin: not installed" "not installed" "$(pkg lv2_plugin v0.1.0 installed)"
check "plugin: install" "installed" "$(pkg lv2_plugin v0.1.0 install | tail -1)"
check "plugin: installed" "installed" "$(pkg lv2_plugin v0.1.0 installed)"
check "plugin: bundle unpacked" "manifest" "$(cat "$ZYNTHIAN_PLUGINS_DIR/lv2/p.lv2/manifest.ttl")"
check "plugin: release asset downloaded" "https://github.com/owner/repo/releases/download/v0.1.0/p-lv2-arm64.tar.gz" "$(tail -1 "$T/wget.log")"
check "plugin: enabled" "-r ENABLE urn:p" "$(cat "$T/tool.log")"
check "plugin: uninstall" "uninstalled" "$(pkg lv2_plugin v0.1.0 uninstall)"
check "plugin: uninstall again" "not installed" "$(pkg lv2_plugin v0.1.0 uninstall)"
pkg lv2_plugin "" install >/dev/null
check "plugin: latest build downloaded" "https://github.com/owner/repo/releases/download/latest/p-lv2-arm64.tar.gz" "$(tail -1 "$T/wget.log")"

check "widget: not installed" "not installed" "$(pkg lv2_widget v0.1.0 installed)"
check "widget: install" "installed" "$(pkg lv2_widget v0.1.0 install | tail -1)"
check "widget: bundle unpacked" "widget" "$(cat "$ZYNTHIAN_PLUGINS_DIR/lv2-widgets/w.zyngui.lv2/w.py")"
check "widget: lv2.stamp touched" "yes" "$([ -f "$ZYNTHIAN_CONFIG_DIR/lv2.stamp" ] && echo yes)"
check "widget: only the bundle installed" "w.zyngui.lv2" "$(ls -A "$ZYNTHIAN_PLUGINS_DIR/lv2-widgets")"
check "widget: tag cloned" "clone --depth 1 --branch v0.1.0 https://github.com/owner/repo.git" "$(tail -1 "$T/git.log" | sed 's| /.*$||')"
check "widget: uninstall" "uninstalled" "$(pkg lv2_widget v0.1.0 uninstall)"
pkg lv2_widget "" install >/dev/null
check "widget: default branch cloned" "clone --depth 1 https://github.com/owner/repo.git" "$(tail -1 "$T/git.log" | sed 's| /.*$||')"

check "clone: not installed" "not installed" "$(pkg github_clone "" installed)"
check "clone: install" "installed" "$(pkg github_clone "" install | tail -1)"
check "clone: installed" "installed" "$(pkg github_clone "" installed)"
check "clone: files installed" "instrument" "$(cat "$T/sfz/My Dir/My Inst/inst.sfz")"
check "clone: .git removed" "no" "$([ -e "$T/sfz/My Dir/My Inst/.git" ] && echo yes || echo no)"
check "clone: temp dir removed" "My Inst" "$(ls -A "$T/sfz/My Dir")"
check "clone: default branch" "clone --depth 1 https://github.com/owner/repo.git" "$(tail -1 "$T/git.log" | sed 's| /.*$||')"
pkg github_clone "" install >/dev/null
check "clone: reinstall over an existing one" "installed" "$(pkg github_clone "" installed)"
pkg github_clone v2.0 install >/dev/null
check "clone: tag" "clone --depth 1 --branch v2.0 https://github.com/owner/repo.git" "$(tail -1 "$T/git.log" | sed 's| /.*$||')"
check "clone: uninstall" "uninstalled" "$(pkg github_clone "" uninstall)"
check "clone: uninstall again" "not installed" "$(pkg github_clone "" uninstall)"

# --- github_clone hooks
mkpkg_clone() {
    printf '#!/bin/bash\nsource "%s/zynpackage_lib.sh"\nPACKAGE_TYPE="github_clone"\nGITHUB="owner/repo"\nDST_DIR="%s"\nDIRNAME="Inst"\n%s\nzynpackage_main "$@"\n' "$HERE" "$T/cl" "$1" > "$T/clone_hooks.sh"
}
mkdir -p "$T/legacy"; touch "$T/legacy/demo.mp3"
mkpkg_clone 'post_uninstall() { rm -f "'"$T"'/legacy/demo.mp3"; }'
bash "$T/clone_hooks.sh" install >/dev/null 2>&1
check "clone: install leaves the legacy file alone" "yes" "$([ -f "$T/legacy/demo.mp3" ] && echo yes)"
bash "$T/clone_hooks.sh" uninstall >/dev/null 2>&1
check "clone: post_uninstall hook removes the legacy file" "no" "$([ -f "$T/legacy/demo.mp3" ] && echo yes || echo no)"
mkpkg_clone 'pre_install() { exit 1; }'
bash "$T/clone_hooks.sh" install >/dev/null 2>&1
check "clone: pre_install can stop the install" "not installed" "$(bash "$T/clone_hooks.sh" installed)"

# --- archive type: package scripts as files (they read their ITEMS_FILE next to themselves)
D="$T/sf"
mkpkg() {  # mkpkg <name> <script body>: a package script that sources the library
    printf '#!/bin/bash\nsource "%s/zynpackage_lib.sh"\nPACKAGE_TYPE="archive"\nDST_DIR="%s"\n%s\nzynpackage_main "$@"\n' "$HERE" "$D" "$2" > "$T/$1.sh"
}
run() { bash "$T/$1.sh" "$2" 2>/dev/null; }

mkpkg single 'ARCHIVES=("https://h/Inst.tar.xz")
ITEMS=("Inst")'
check "archive: not installed" "not installed" "$(run single installed)"
check "archive: install" "installed" "$(run single install | tail -1)"
check "archive: extracted" "sfz" "$(cat "$D/Inst/a.sfz")"
check "archive: installed" "installed" "$(run single installed)"
check "archive: uninstall removes only its items" "Other" "$(run single uninstall >/dev/null; ls "$D")"
check "archive: uninstall again" "not installed" "$(run single uninstall)"
rm -rf "$D"

mkpkg multi 'ARCHIVES=("https://h/a.tar.xz" "https://h/b.tar.xz")
ITEMS=("Nope" "Other")'
run multi install >/dev/null
check "archive: any item means installed" "installed" "$(run multi installed)"
run multi uninstall >/dev/null
check "archive: installed after install/uninstall" "not installed" "$(run multi installed)"
check "archive: both archives downloaded" "2" "$(grep -c 'a.tar.xz\|b.tar.xz' "$T/wget.log")"
rm -rf "$D"

printf 'sub/one\n\nsub/two\n\n' > "$T/list.txt"
mkpkg listed 'ARCHIVES=("https://h/Inst.tar.xz")
ITEMS_FILE="list.txt"
ITEMS_PREFIX="pre/"
INSTALLED_ITEM="Inst/a.sfz"'
run listed install >/dev/null
mkdir -p "$D/pre/sub/one" "$D/pre/sub/two" "$D/pre/sub/keep"
check "archive: installed item" "installed" "$(run listed installed)"
run listed uninstall >/dev/null
check "archive: file list with prefix, blank lines ignored, DST_DIR kept" "keep" "$(ls "$D/pre/sub"; [ -d "$D" ] || echo NO_DST_DIR)"
rm -rf "$D"

mkpkg hooks 'ARCHIVES=("https://h/Inst.tar.xz")
ITEMS=("Inst")
pre_install() { echo pre >> "'"$T"'/hooks.log"; }
post_install() { echo post >> "'"$T"'/hooks.log"; mv "$DST_DIR/Other" "$DST_DIR/Renamed"; }
post_uninstall() { echo un >> "'"$T"'/hooks.log"; }'
run hooks install >/dev/null; run hooks uninstall >/dev/null
check "archive: hooks run in order" "pre post un" "$(tr '\n' ' ' < "$T/hooks.log" | sed 's/ $//')"
check "archive: post_install renamed" "Renamed" "$(ls "$D")"
rm -rf "$D" "$T/hooks.log"

mkpkg blocked 'ARCHIVES=("https://h/Inst.tar.xz")
ITEMS=("Inst")
pre_install() { echo "uninstall the other package first"; exit 1; }'
run blocked install >/dev/null; rc=$?
check "archive: pre_install can stop the install" "no" "$([ -d "$D/Inst" ] && echo yes || echo no)"

mkpkg zipped 'ARCHIVES=("https://h/z.zip")
ITEMS=("Inst")
EXTRACT_SUBDIR="Sub"'
run zipped install >/dev/null
check "archive: zip extracted with bsdtar into EXTRACT_SUBDIR" "sfz" "$(cat "$D/Sub/Inst/a.sfz")"
rm -rf "$D"

mkpkg unsupported 'ARCHIVES=("https://h/file.rar")
ITEMS=("x")'
check "archive: unsupported format fails" "not installed" "$(run unsupported install >/dev/null; run unsupported installed)"

# git_version / git_repo only for packages with a repository
check "archive: no git_version without GITHUB" "" "$(run single git_version)"
check "archive: no git_repo without GITHUB" "" "$(run single git_repo)"

[ "$fails" -eq 0 ] && echo "All tests passed" || echo "$fails test(s) FAILED"
exit "$fails"
