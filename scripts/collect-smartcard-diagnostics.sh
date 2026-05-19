#!/usr/bin/env bash
set -euo pipefail

OUT_ROOT="${OUT_ROOT:-/mnt/e/rom/_analysis/device-logs}"
ADB="${ADB:-adb}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_DIR="$OUT_ROOT/smartcard-$STAMP"

PACKAGES="com.mipay.wallet com.miui.nextpay com.miui.tsmclient com.unionpay.tsmservice.mi com.xiaomi.payment com.xiaomi.market com.android.nfc com.android.permissioncontroller com.miui.home com.android.systemui com.rongcard.eid com.xiaomi.otrpbroker"
NAMESPACE_PROBES="com.mipay.wallet:/product/app/MipayWallet/MipayWallet.apk com.miui.tsmclient:/product/app/MITSMClient/MITSMClient.apk com.android.permissioncontroller:/product/app/MITSMClient/MITSMClient.apk com.miui.home:/product/app/MITSMClient/MITSMClient.apk com.android.systemui:/product/app/MITSMClient/MITSMClient.apk com.miui.nextpay:/product/app/MINextpay/MINextpay.apk com.unionpay.tsmservice.mi:/product/app/UPTsmService/UPTsmService.apk com.xiaomi.payment:/product/app/PaymentService/PaymentService.apk com.xiaomi.market:/product/app/MIUISuperMarket/MIUISuperMarket.apk"

usage() {
  cat <<USAGE
Usage: $0 [--clear-first]

Collect smart-card crash diagnostics from the currently connected adb device.
Writes logs under OUT_ROOT, which defaults to /mnt/e/rom/_analysis/device-logs.

Options:
  --clear-first  Clear logcat first, wait for you to reproduce the crash, then collect.
USAGE
}

clear_first=false
case "${1:-}" in
  --clear-first) clear_first=true ;;
  --help|-h) usage; exit 0 ;;
  "") ;;
  *) usage >&2; exit 1 ;;
esac

mkdir -p "$OUT_DIR"

"$ADB" wait-for-device

if $clear_first; then
  "$ADB" logcat -c
  printf 'Logcat cleared. Reproduce the smart-card crash, then press Enter to collect diagnostics.\n' >&2
  read -r _
fi

{
  printf 'timestamp=%s\n' "$STAMP"
  "$ADB" shell getprop ro.product.device 2>/dev/null | sed 's/^/ro.product.device=/' || true
  "$ADB" shell getprop ro.product.vendor.device 2>/dev/null | sed 's/^/ro.product.vendor.device=/' || true
  "$ADB" shell getprop ro.build.version.incremental 2>/dev/null | sed 's/^/ro.build.version.incremental=/' || true
  "$ADB" shell getprop ro.system.build.version.incremental 2>/dev/null | sed 's/^/ro.system.build.version.incremental=/' || true
} > "$OUT_DIR/device.txt"

"$ADB" shell getprop > "$OUT_DIR/getprop.txt" 2>&1 || true
"$ADB" shell pm list packages > "$OUT_DIR/packages.txt" 2>&1 || true

for package_name in $PACKAGES; do
  safe_name="${package_name//./_}"
  {
    printf '== pm path %s ==\n' "$package_name"
    "$ADB" shell pm path "$package_name" 2>&1 || true
    printf '\n== dumpsys package %s ==\n' "$package_name"
    "$ADB" shell dumpsys package "$package_name" 2>&1 || true
  } > "$OUT_DIR/package-$safe_name.txt"
done

for probe in $NAMESPACE_PROBES; do
  package_name="${probe%%:*}"
  probe_path="${probe#*:}"
  safe_name="${package_name//./_}"
  {
    printf '== process namespace probe for %s ==\n' "$package_name"
    printf 'probe_path=%s\n' "$probe_path"
    pid="$("$ADB" shell pidof "$package_name" 2>/dev/null | tr -d '\r' || true)"
    pid="${pid%% *}"
    printf 'pid=%s\n' "${pid:-not-running}"
    if [[ -n "$pid" ]]; then
      printf '\n== root namespace path ==\n'
      "$ADB" shell su -c "ls -l '$probe_path'" 2>&1 || true
      printf '\n== app mount namespace path ==\n'
      "$ADB" shell su -c "nsenter -t '$pid' -m -- ls -l '$probe_path'" 2>&1 || true
      printf '\n== app mount namespace module mounts ==\n'
"$ADB" shell su -c "nsenter -t '$pid' -m -- cat /proc/self/mountinfo | grep -E 'KSU|KernelSU|SukiSU|magic_mount|MagicMount|HyperOS3EULocalization|MipayWallet|MITSMClient|MINextpay|UPTsmService|PaymentService|MIUISuperMarket'" 2>&1 || true
    fi
  } > "$OUT_DIR/namespace-$safe_name.txt"
done

"$ADB" logcat -b crash -d -v threadtime > "$OUT_DIR/logcat-crash.txt" 2>&1 || true
"$ADB" logcat -d -v threadtime > "$OUT_DIR/logcat-threadtime.txt" 2>&1 || true
"$ADB" shell dumpsys dropbox --print data_app_crash system_app_crash > "$OUT_DIR/dropbox-crash.txt" 2>&1 || true

{
  printf 'Diagnostics written to %s\n' "$OUT_DIR"
  printf '\nNamespace visibility:\n'
grep -H -E 'pid=|No such file or directory|MipayWallet\.apk|MITSMClient\.apk|MINextpay\.apk|UPTsmService\.apk|PaymentService\.apk|MIUISuperMarket\.apk|KSU|KernelSU|SukiSU|magic_mount|MagicMount|HyperOS3EULocalization' \
    "$OUT_DIR"/namespace-*.txt 2>/dev/null || true
  printf '\nLikely crash lines:\n'
  grep -E 'FATAL EXCEPTION|AndroidRuntime|Process: (com\.mipay\.wallet|com\.(miui\.nextpay|miui\.tsmclient|unionpay\.tsmservice\.mi|xiaomi\.(payment|market)))|NoClassDefFoundError|ClassNotFoundException|SecurityException|UnsatisfiedLinkError|Resources\$NotFoundException' \
    "$OUT_DIR/logcat-crash.txt" "$OUT_DIR/logcat-threadtime.txt" "$OUT_DIR/dropbox-crash.txt" 2>/dev/null || true
} | tee "$OUT_DIR/summary.txt"
