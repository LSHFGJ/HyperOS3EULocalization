#!/system/bin/sh
SKIPUNZIP=1
ASH_STANDALONE=1

ui_print "*******************************"
ui_print " HyperOS3 Smart Card Restore"
ui_print " Target: Xiaomi 17 Pro (pandora) / Xiaomi 13 (fuxi)"
ui_print "*******************************"

unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >&2

is_supported_device() {
  case "$1" in
    pandora|fuxi) return 0 ;;
    *) return 1 ;;
  esac
}

device="$(getprop ro.product.device)"
vendor_device="$(getprop ro.product.vendor.device)"
if ! is_supported_device "$device" && ! is_supported_device "$vendor_device"; then
  ui_print "! Warning: this module targets pandora/fuxi, current device is ${device:-unknown}/${vendor_device:-unknown}."
fi

missing=false
for apk in \
  "$MODPATH/system/product/app/MINextpay/MINextpay.apk" \
  "$MODPATH/system/product/app/MITSMClient/MITSMClient.apk" \
  "$MODPATH/system/product/app/UPTsmService/UPTsmService.apk"; do
  if [ ! -f "$apk" ]; then
    ui_print "! Missing required payload: ${apk#$MODPATH/}"
    missing=true
  fi
done

if $missing; then
  ui_print "! Build the module zip with scripts/build-smartcard-module.sh before flashing."
  abort "Required smart-card payload is incomplete."
fi

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH/system/product/app" 0 0 0755 0644

ui_print "- Smart Card payload installed systemlessly."
ui_print "- Reboot is required."
