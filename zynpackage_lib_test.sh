#!/bin/bash
# Self-test of zynpackage_lib.sh: no network, no zynthian needed (downloads and zynthian tools are stubbed).
#   bash zynpackage_lib_test.sh

HERE="$(cd "$(dirname "$0")" && pwd)"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
export ZYNTHIAN_PLUGINS_DIR="$T/plugins" ZYNTHIAN_CONFIG_DIR="$T/config" ZYNTHIAN_SYS_DIR="$T/sys" MACHINE_HW_NAME="aarch64"
mkdir -p "$T/bin" "$T/config" "$T/sys/sbin" "$T/src/p.lv2" "$T/src/repo-main/w.zyngui.lv2"
echo manifest > "$T/src/p.lv2/manifest.ttl"
echo widget > "$T/src/repo-main/w.zyngui.lv2/w.py"
tar -C "$T/src" -czf "$T/plugin.tar.gz" p.lv2
tar -C "$T/src" -czf "$T/archive.tar.gz" repo-main
printf '#!/bin/bash\necho "$@" >> "%s/tool.log"\n' "$T" > "$T/sys/sbin/zyngine_tool.py"
# wget stub: logs the URL, serves the plugin tarball or the repository archive; wget [-q] (-O <file> | -O-) <url>
cat > "$T/bin/wget" <<STUB
#!/bin/bash
url="\${@: -1}"; dest=""
while [ \$# -gt 1 ]; do
    case "\$1" in -O-) dest="-" ;; -O) dest="\$2"; shift ;; esac
    shift
done
echo "\$url" >> "$T/wget.log"
case "\$url" in */archive/*) f="$T/archive.tar.gz" ;; *.tar.gz) f="$T/plugin.tar.gz" ;; *) exit 1 ;; esac
if [ "\$dest" = "-" ]; then cat "\$f"; else cp "\$f" "\$dest"; fi
STUB
chmod +x "$T/bin/wget" "$T/sys/sbin/zyngine_tool.py"
# git stub: ls-remote answers with a commit
printf '#!/bin/bash\necho -e "abc123\\tHEAD"\n' > "$T/bin/git"
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
        SYMBOL="p"; PLUGIN_URI="urn:p"; BUNDLE="w.zyngui.lv2"
        zynpackage_main "$3"
    ) 2>/dev/null
}

check "git_repo" "https://github.com/owner/repo.git" "$(pkg lv2_plugin "" git_repo)"
check "git_version: last commit without a release" "abc123" "$(pkg lv2_plugin "" git_version)"
check "git_version: not implemented with a release" "" "$(pkg lv2_plugin v0.1.0 git_version)"
(source "$HERE/zynpackage_lib.sh"; GITHUB=owner/repo
 VERSION=v1.2.3; check "release url (tag)" "https://github.com/owner/repo/releases/download/v1.2.3/f.tar.gz" "$(github_release_url f.tar.gz)"
 VERSION=""; check "release url (latest build)" "https://github.com/owner/repo/releases/download/latest/f.tar.gz" "$(github_release_url f.tar.gz)"
 VERSION=v1.2.3; check "archive url (tag)" "https://github.com/owner/repo/archive/refs/tags/v1.2.3.tar.gz" "$(github_archive_url)"
 VERSION=""; check "archive url (HEAD)" "https://github.com/owner/repo/archive/HEAD.tar.gz" "$(github_archive_url)"
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
check "widget: tag archive downloaded" "https://github.com/owner/repo/archive/refs/tags/v0.1.0.tar.gz" "$(tail -1 "$T/wget.log")"
check "widget: uninstall" "uninstalled" "$(pkg lv2_widget v0.1.0 uninstall)"
pkg lv2_widget "" install >/dev/null
check "widget: HEAD archive downloaded" "https://github.com/owner/repo/archive/HEAD.tar.gz" "$(tail -1 "$T/wget.log")"

[ "$fails" -eq 0 ] && echo "All tests passed" || echo "$fails test(s) FAILED"
exit "$fails"
