#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULE_DIR="$ROOT_DIR/smartcard-module"
BUILD_SCRIPT="$ROOT_DIR/scripts/build-smartcard-module.sh"
DIAG_SCRIPT="$ROOT_DIR/scripts/collect-smartcard-diagnostics.sh"
UPDATE_BINARY="$MODULE_DIR/META-INF/com/google/android/update-binary"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "missing file: ${path#$ROOT_DIR/}"
}

assert_executable() {
  local path="$1"
  assert_file "$path"
  [[ -x "$path" ]] || fail "file is not executable: ${path#$ROOT_DIR/}"
}

assert_contains() {
  local path="$1"
  local pattern="$2"
  grep -Eq "$pattern" "$path" || fail "${path#$ROOT_DIR/} does not contain pattern: $pattern"
}

assert_not_contains_tree() {
  local path="$1"
  local pattern="$2"
  if grep -RInE "$pattern" "$path" >/tmp/smartcard_module_forbidden_matches.txt 2>/dev/null; then
    cat /tmp/smartcard_module_forbidden_matches.txt >&2
    fail "forbidden pattern found under ${path#$ROOT_DIR/}: $pattern"
  fi
}

assert_file "$MODULE_DIR/module.prop"
assert_executable "$MODULE_DIR/customize.sh"
assert_executable "$MODULE_DIR/post-fs-data.sh"
assert_executable "$MODULE_DIR/service.sh"
assert_executable "$MODULE_DIR/uninstall.sh"
assert_file "$MODULE_DIR/system.prop"
assert_file "$MODULE_DIR/config/smartcard-components.tsv"
assert_executable "$MODULE_DIR/META-INF/com/google/android/update-binary"
assert_file "$MODULE_DIR/META-INF/com/google/android/updater-script"
assert_executable "$BUILD_SCRIPT"
assert_executable "$DIAG_SCRIPT"

assert_file "$ROOT_DIR/system/product/app/VoiceAssistAndroidT/VoiceAssistAndroidT.apk"
assert_file "$ROOT_DIR/system/product/app/AiAsstVision/AiAsstVision.apk"
assert_file "$ROOT_DIR/system/product/app/MIUIAiasstService/MIUIAiasstService.apk"
assert_file "$ROOT_DIR/system/product/priv-app/PersonalAssistant/PersonalAssistant.apk"
assert_file "$ROOT_DIR/system/product/priv-app/Mms/Mms.apk"
assert_file "$ROOT_DIR/system/product/priv-app/MIUIContentExtension/MIUIContentExtension.apk"
assert_file "$ROOT_DIR/system/product/priv-app/MIUIYellowPage/MIUIYellowPage.apk"

assert_contains "$MODULE_DIR/module.prop" '^id=HyperOS3SmartCardRestore$'
assert_contains "$MODULE_DIR/module.prop" '^targetDevices=pandora,fuxi$'
assert_contains "$MODULE_DIR/module.prop" '^targetHyperOS=OS3\.0\.306\.0\.WBLCNXM,3\.0\.2\.0\.WMCCNXM$'
assert_contains "$MODULE_DIR/customize.sh" 'Target: Xiaomi 17 Pro \(pandora\) / Xiaomi 13 \(fuxi\)'
assert_contains "$MODULE_DIR/customize.sh" 'is_supported_device\(\)'
assert_contains "$MODULE_DIR/customize.sh" 'pandora\|fuxi'
assert_contains "$MODULE_DIR/README.md" 'Xiaomi 13 `fuxi`'
assert_contains "$MODULE_DIR/system.prop" '^ro\.se\.type=eSE,HCE,UICC$'
assert_contains "$BUILD_SCRIPT" '^ROM_ROOT="\$\{ROM_ROOT:-/mnt/e/rom\}"$'
assert_contains "$BUILD_SCRIPT" '^WORK_DIR="\$\{WORK_DIR:-\$ROM_ROOT/_analysis/build-smartcard\}"$'
assert_contains "$BUILD_SCRIPT" '^OUT_DIR="\$\{OUT_DIR:-\$ROM_ROOT/_analysis/out\}"$'
assert_contains "$BUILD_SCRIPT" '^MOUNT_ROOT="\$\{MOUNT_ROOT:-\$\{TMPDIR:-/tmp\}/hyperos-smartcard-mount\}"$'
assert_contains "$BUILD_SCRIPT" '^LOCAL_PAYLOAD_DIR="\$\{LOCAL_PAYLOAD_DIR:-\$ROOT_DIR/system/product/app\}"$'
assert_contains "$BUILD_SCRIPT" '^KEEP_WORK="\$\{KEEP_WORK:-0\}"$'
assert_contains "$BUILD_SCRIPT" 'HyperOS3SmartCardRestore_v0\.1\.0-pandora-fuxi\.zip'
assert_contains "$BUILD_SCRIPT" 'require_command 7z'
assert_contains "$BUILD_SCRIPT" '7z not found'
assert_contains "$BUILD_SCRIPT" '^cleanup_work_files\(\) \{$'
assert_contains "$BUILD_SCRIPT" 'rm -f "\$PRODUCT_IMG"'
assert_contains "$BUILD_SCRIPT" 'rm -rf "\$MODULE_BUILD"'
assert_contains "$BUILD_SCRIPT" 'rm -f "\$ZIP_PATH"'
assert_contains "$BUILD_SCRIPT" 'copy_component\(\)'
assert_contains "$BUILD_SCRIPT" 'apk_has_dex\(\)'
assert_contains "$BUILD_SCRIPT" 'classes\.dex'
assert_contains "$BUILD_SCRIPT" 'Local component has no dex, falling back to CN product'
assert_contains "$BUILD_SCRIPT" 'rm -rf "\$MODULE_BUILD/system/product/app/\$component/oat"'
assert_contains "$DIAG_SCRIPT" '^OUT_ROOT="\$\{OUT_ROOT:-/mnt/e/rom/_analysis/device-logs\}"$'
assert_contains "$DIAG_SCRIPT" 'logcat -b crash'
assert_contains "$DIAG_SCRIPT" 'dumpsys package'
assert_contains "$DIAG_SCRIPT" 'com\.xiaomi\.payment'
assert_contains "$DIAG_SCRIPT" 'NAMESPACE_PROBES='
assert_contains "$DIAG_SCRIPT" 'com\.android\.permissioncontroller'
assert_contains "$DIAG_SCRIPT" 'com\.miui\.home'
assert_contains "$DIAG_SCRIPT" 'com\.android\.systemui'
assert_contains "$DIAG_SCRIPT" 'nsenter -t'
assert_contains "$DIAG_SCRIPT" 'MITSMClient\.apk'
assert_contains "$DIAG_SCRIPT" 'HyperOS3SmartCardRestore'
assert_contains "$MODULE_DIR/README.md" 'Umount modules'
assert_contains "$MODULE_DIR/README.md" 'com\.miui\.tsmclient'
assert_contains "$MODULE_DIR/README.md" 'com\.android\.permissioncontroller'
assert_contains "$MODULE_DIR/README.md" 'com\.miui\.home'
assert_contains "$MODULE_DIR/README.md" 'com\.android\.systemui'
assert_contains "$UPDATE_BINARY" 'KernelSU'
assert_contains "$UPDATE_BINARY" 'APatch'
assert_contains "$UPDATE_BINARY" 'bootmode module manager'
assert_contains "$UPDATE_BINARY" 'customize\.sh'
assert_contains "$UPDATE_BINARY" 'Magisk-compatible|root-module'
assert_contains "$ROOT_DIR/customize.sh" '/system/bin/timeout 1 /system/bin/getevent'
assert_contains "$ROOT_DIR/tools/unity_install.sh" 'HyperOS3EULocalization\.ini'
assert_contains "$ROOT_DIR/tools/unity_install.sh" 'system/product/app/AiAsstVision'
assert_contains "$ROOT_DIR/tools/unity_install.sh" 'system/product/priv-app/PersonalAssistant'
assert_contains "$ROOT_DIR/tools/unity_install.sh" 'system/product/priv-app/Mms'
assert_contains "$ROOT_DIR/README.md" 'com\.miui\.voiceassist'
assert_contains "$ROOT_DIR/README.md" 'com\.miui\.personalassistant'
assert_contains "$ROOT_DIR/README.md" 'com\.android\.mms'
assert_contains "$ROOT_DIR/README.md" 'com\.miui\.contentextension'
assert_contains "$ROOT_DIR/README.md" 'com\.miui\.yellowpage'
assert_contains "$ROOT_DIR/README.md" 'Umount modules'
assert_contains "$ROOT_DIR/README.md" 'com\.xiaomi\.aiasst\.vision'
assert_contains "$ROOT_DIR/README.md" 'com\.xiaomi\.aiasst\.service'
assert_contains "$ROOT_DIR/README.md" 'com\.miui\.hybrid'

assert_contains "$MODULE_DIR/config/smartcard-components.tsv" $'^MINextpay\tcom\.miui\.nextpay\tproduct/app/MINextpay\trequired$'
assert_contains "$MODULE_DIR/config/smartcard-components.tsv" $'^MITSMClient\tcom\.miui\.tsmclient\tproduct/app/MITSMClient\trequired$'
assert_contains "$MODULE_DIR/config/smartcard-components.tsv" $'^UPTsmService\tcom\.unionpay\.tsmservice\.mi\tproduct/app/UPTsmService\trequired$'

assert_not_contains_tree "$MODULE_DIR" '(LSPosed|LSPatch|Xposed|Riru|Zygisk|metamagisk|元模块)'
assert_not_contains_tree "$MODULE_DIR" '/data/adb/magisk/util_functions\.sh'

if [[ -e "$ROOT_DIR/system/product/app/AiasstVision" || -e "$ROOT_DIR/system/product/priv-app/MiuiMms" || -e "$ROOT_DIR/system/product/priv-app/MIUIPersonalAssistantPhoneOS3" ]]; then
  fail "legacy payload path still exists; use actual fuxi codePath directory names"
fi

printf 'Smart card module structure looks valid.\n'
