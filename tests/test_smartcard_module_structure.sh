#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_SCRIPT="$ROOT_DIR/scripts/build-smartcard-module.sh"
DIAG_SCRIPT="$ROOT_DIR/scripts/collect-smartcard-diagnostics.sh"
UPDATE_BINARY="$ROOT_DIR/META-INF/com/google/android/update-binary"

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

assert_not_contains() {
  local path="$1"
  local pattern="$2"
  if grep -Eq "$pattern" "$path"; then
    fail "${path#$ROOT_DIR/} contains forbidden pattern: $pattern"
  fi
}

assert_not_contains_tree() {
  local path="$1"
  local pattern="$2"
  if grep -RInE --exclude='*.apk' --exclude-dir='.git' --exclude-dir='.worktrees' --exclude-dir='tests' "$pattern" "$path" >/tmp/smartcard_module_forbidden_matches.txt 2>/dev/null; then
    cat /tmp/smartcard_module_forbidden_matches.txt >&2
    fail "forbidden pattern found under ${path#$ROOT_DIR/}: $pattern"
  fi
}

assert_zip_entry() {
  local archive="$1"
  local entry="$2"
  unzip -l "$archive" "$entry" >/dev/null 2>&1 || fail "${archive#$ROOT_DIR/} missing zip entry: $entry"
}

assert_missing_path() {
  local path="$1"
  [[ ! -e "$path" ]] || fail "path should not exist: ${path#$ROOT_DIR/}"
}

assert_missing_path "$ROOT_DIR/smartcard-module"
assert_missing_path "$ROOT_DIR/toolbox"
assert_missing_path "$ROOT_DIR/.github/workflows/module-structure.yml"
assert_missing_path "$ROOT_DIR/system/product/app/MipayService"
assert_missing_path "$ROOT_DIR/system/product/data-app"
assert_executable "$BUILD_SCRIPT"
assert_executable "$DIAG_SCRIPT"
assert_executable "$UPDATE_BINARY"

assert_file "$ROOT_DIR/system/product/app/VoiceAssistAndroidT/VoiceAssistAndroidT.apk"
assert_file "$ROOT_DIR/system/product/app/AiAsstVision/AiAsstVision.apk"
assert_file "$ROOT_DIR/system/product/app/MIUIAiasstService/MIUIAiasstService.apk"
assert_file "$ROOT_DIR/system/product/priv-app/PersonalAssistant/PersonalAssistant.apk"
assert_file "$ROOT_DIR/system/product/priv-app/Mms/Mms.apk"
assert_file "$ROOT_DIR/system/product/priv-app/MIUIContentExtension/MIUIContentExtension.apk"
assert_file "$ROOT_DIR/system/product/priv-app/MIUIYellowPage/MIUIYellowPage.apk"
assert_file "$ROOT_DIR/system/product/app/MINextpay/MINextpay.apk"
assert_file "$ROOT_DIR/system/product/app/MITSMClient/MITSMClient.apk"
assert_file "$ROOT_DIR/system/product/app/UPTsmService/UPTsmService.apk"
assert_file "$ROOT_DIR/system/product/app/UPTsmService/lib/arm64/libuptsmservice.so"
assert_file "$ROOT_DIR/system/product/overlay/MmsFocusOverlay/MmsFocusOverlay.apk"
assert_file "$ROOT_DIR/overlay-src/MmsFocusOverlay/AndroidManifest.xml"
assert_file "$ROOT_DIR/overlay-src/MmsFocusOverlay/res/values/arrays.xml"
assert_missing_path "$ROOT_DIR/system/product/overlay/HyperOS3MmsFocusAuthOverlay"
assert_missing_path "$ROOT_DIR/overlay-src/HyperOS3MmsFocusAuthOverlay"

assert_contains "$ROOT_DIR/module.prop" '^id=HyperOS3EULocalization$'
assert_contains "$ROOT_DIR/module.prop" '^name=HyperOS3 EU 本地化$'
assert_contains "$ROOT_DIR/module.prop" '^version=v2\.0$'
assert_contains "$ROOT_DIR/module.prop" '^versionCode=20$'
assert_contains "$ROOT_DIR/module.prop" '^author=LSHFGJ$'
assert_not_contains "$ROOT_DIR/module.prop" 'target(Model|MiuiVersion)|WMCCNXM|WBLCNXM|fuxi|pandora'
assert_contains "$ROOT_DIR/customize.sh" 'HyperOS3 EU Localization v2\.0'
assert_contains "$ROOT_DIR/customize.sh" 'Author: LSHFGJ'
assert_contains "$ROOT_DIR/customize.sh" 'Target: Any HyperOS 3 device/build'
assert_not_contains "$ROOT_DIR/customize.sh" '╔|╚|║|━|┌|└|│|Feature Selection|Fonts|SogouInput|MiuiIme|GboardTheme|VideocallBeautify|NotificationFilter|VirtualSim|VoiceTrigger'
assert_not_contains "$ROOT_DIR/tools/unity_install.sh" 'MODTARGETMODEL|MODTARGETMIUIVERSION|LANG_TEXT_TARGET_MIUI_VERSION|LANG_TEXT_TARGET_MODEL'
assert_not_contains "$ROOT_DIR/tools/unity_install.sh" 'SYSTEM_VERSION_NOT_MATCH|targetMiuiVersion|targetModel'
assert_contains "$BUILD_SCRIPT" '^ROM_ROOT="\$\{ROM_ROOT:-/mnt/e/rom\}"$'
assert_contains "$BUILD_SCRIPT" '^WORK_DIR="\$\{WORK_DIR:-\$ROM_ROOT/_analysis/build-smartcard\}"$'
assert_contains "$BUILD_SCRIPT" '^OUT_DIR="\$\{OUT_DIR:-\$ROM_ROOT/_analysis/out\}"$'
assert_contains "$BUILD_SCRIPT" '^MOUNT_ROOT="\$\{MOUNT_ROOT:-\$\{TMPDIR:-/tmp\}/hyperos-smartcard-mount\}"$'
assert_contains "$BUILD_SCRIPT" '^LOCAL_PAYLOAD_DIR="\$\{LOCAL_PAYLOAD_DIR:-\$ROOT_DIR/system/product/app\}"$'
assert_contains "$BUILD_SCRIPT" '^KEEP_WORK="\$\{KEEP_WORK:-0\}"$'
assert_contains "$BUILD_SCRIPT" 'HyperOS3_EU_Localization_\$\{MODULE_VERSION\}\.zip'
assert_contains "$BUILD_SCRIPT" '^MODULE_VERSION="\$\{MODULE_VERSION:-v2\.0\}"$'
assert_contains "$BUILD_SCRIPT" 'Set CN_ROM_DIR to a HyperOS 3 CN ROM image directory'
assert_not_contains "$BUILD_SCRIPT" 'smartcard-module|SmartCardPayload|pandora|WBLCNXM|HyperOS3SmartCardRestore_v0\.1\.0-pandora-fuxi'
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
assert_contains "$DIAG_SCRIPT" 'HyperOS3EULocalization'
assert_not_contains "$DIAG_SCRIPT" 'HyperOS3MmsFocusAuthOverlay'
assert_contains "$ROOT_DIR/README.md" 'Umount modules'
assert_contains "$ROOT_DIR/README.md" 'com\.miui\.tsmclient'
assert_contains "$ROOT_DIR/README.md" 'com\.android\.permissioncontroller'
assert_contains "$ROOT_DIR/README.md" 'com\.miui\.home'
assert_contains "$ROOT_DIR/README.md" 'com\.android\.systemui'
assert_contains "$UPDATE_BINARY" 'KernelSU'
assert_contains "$UPDATE_BINARY" 'APatch'
assert_contains "$UPDATE_BINARY" 'bootmode module manager'
assert_contains "$UPDATE_BINARY" 'customize\.sh'
assert_contains "$UPDATE_BINARY" 'Magisk-compatible|root-module'
assert_not_contains "$UPDATE_BINARY" '\*\*\*\*\*\*\*\*\*\*'
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
assert_contains "$ROOT_DIR/README.md" 'com\.miui\.tsmclient'
assert_contains "$ROOT_DIR/README.md" 'system/product/app/MITSMClient'
assert_contains "$ROOT_DIR/README.md" 'system/product/overlay/MmsFocusOverlay'
assert_contains "$ROOT_DIR/tools/unity_install.sh" 'system/product/app/UPTsmService'
assert_contains "$ROOT_DIR/tools/unity_install.sh" 'system/product/app/MINextpay'
assert_contains "$ROOT_DIR/tools/unity_install.sh" 'system/product/app/MITSMClient'
assert_not_contains "$ROOT_DIR/tools/unity_install.sh" 'NextPay_\$API'
assert_not_contains "$ROOT_DIR/tools/unity_install.sh" 'system/product/app/MipayService'
assert_not_contains "$ROOT_DIR/tools/unity_install.sh" '\*\*\*\*\*\*\*\*\*\*|Fonts|SogouInput|MiuiIme|GboardTheme|VideocallBeautify|NotificationFilter|VirtualSim|VoiceTrigger|HybridAccessory|LANG_TEXT_READING_CONFIG_FONTS|LANG_TEXT_READING_CONFIG_MIUIIME|LANG_TEXT_READING_CONFIG_SOUGOUINPUT|LANG_TEXT_READING_CONFIG_GBOARDTHEME|LANG_TEXT_READING_CONFIG_VIDEOCALLBEAUTIFY|LANG_TEXT_READING_CONFIG_NOTIFICATIONFILTER'
assert_not_contains "$ROOT_DIR/customize.sh" 'Calendar|Weather|Music|SoundRecorder|ThemeManager|媒体与生活|日历 / 天气 / 音乐 / 录音机'
assert_not_contains "$ROOT_DIR/tools/unity_install.sh" 'Calendar|Weather|Music|SoundRecorder|ThemeManager|MIUICalendar|MIUIWeather|MIUIMusicT|MiuiAudioMonitor'
assert_not_contains "$ROOT_DIR/service.sh" 'NotificationFilter|notification_feature_process|persist\.sys\.notification_rank|com\.miui\.notification'
assert_not_contains "$ROOT_DIR/lang/zh_CN.ini" 'CALENDAR|WEATHER|THEMEMANAGER|MUSIC|SOUNUDRECORDER|FONTS|MIUIIME|SOUGOUINPUT|GBOARDTHEME|VIDEOCALLBEAUTIFY|NOTIFICATIONFILTER|NOTIFICATIONGROUP|VIRTUALSIM|VOICETRIGGER|日历|天气|主题壁纸|音乐|录音机|全面屏键盘优化|搜狗输入法|谷歌键盘|视频通话美颜|通知过滤|通知聚合|全球上网|语音唤醒|字体'
assert_not_contains "$ROOT_DIR/lang/en_US.ini" 'CALENDAR|WEATHER|THEMEMANAGER|MUSIC|SOUNUDRECORDER|FONTS|MIUIIME|SOUGOUINPUT|GBOARDTHEME|VIDEOCALLBEAUTIFY|NOTIFICATIONFILTER|NOTIFICATIONGROUP|VIRTUALSIM|VOICETRIGGER|日历|天气|主题壁纸|音乐|录音机|全面屏键盘优化|搜狗输入法|谷歌键盘|视频通话美颜|通知过滤|通知聚合|全球上网|语音唤醒|字体'
assert_not_contains "$ROOT_DIR/README.md" '日历、天气、音乐、录音机|主题管理器'
assert_contains "$ROOT_DIR/README.md" '^# HyperOS3 EU Localization$'
assert_contains "$ROOT_DIR/.github/workflows/release.yml" 'HyperOS3_EU_Localization_\$\{VERSION\}\.zip'
assert_contains "$ROOT_DIR/.github/workflows/release.yml" 'HyperOS3 EU Localization'
assert_contains "$ROOT_DIR/overlay-src/MmsFocusOverlay/AndroidManifest.xml" 'package="mms\.focus\.overlay"'
assert_contains "$ROOT_DIR/overlay-src/MmsFocusOverlay/AndroidManifest.xml" 'android:targetPackage="miui\.systemui\.plugin"'
assert_contains "$ROOT_DIR/overlay-src/MmsFocusOverlay/AndroidManifest.xml" 'android:isStatic="true"'
assert_contains "$ROOT_DIR/overlay-src/MmsFocusOverlay/AndroidManifest.xml" 'android:targetSdkVersion="28"'
assert_contains "$ROOT_DIR/overlay-src/MmsFocusOverlay/res/values/arrays.xml" '<string-array name="config_pass_xms_permission">'
assert_contains "$ROOT_DIR/overlay-src/MmsFocusOverlay/res/values/arrays.xml" '<item>com\.android\.mms</item>'
assert_zip_entry "$ROOT_DIR/system/product/overlay/MmsFocusOverlay/MmsFocusOverlay.apk" 'AndroidManifest.xml'
assert_zip_entry "$ROOT_DIR/system/product/overlay/MmsFocusOverlay/MmsFocusOverlay.apk" 'resources.arsc'
assert_zip_entry "$ROOT_DIR/system/product/overlay/MmsFocusOverlay/MmsFocusOverlay.apk" 'META-INF/OVERLAY.RSA'

assert_not_contains_tree "$ROOT_DIR" 'smartcard-module/|SmartCardPayload|HyperOS3MmsFocusAuthOverlay|hyperos3\.mms\.focus\.auth\.overlay'

if [[ -e "$ROOT_DIR/system/product/app/AiasstVision" || -e "$ROOT_DIR/system/product/priv-app/MiuiMms" || -e "$ROOT_DIR/system/product/priv-app/MIUIPersonalAssistantPhoneOS3" ]]; then
  fail "legacy payload path still exists; use actual HyperOS 3 codePath directory names"
fi

printf 'Smart card module structure looks valid.\n'
