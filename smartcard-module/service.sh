#!/system/bin/sh
MODDIR=${0%/*}
LOG=/data/local/tmp/HyperOS3SmartCardRestore.log

{
  echo "HyperOS3 Smart Card Restore service check"
  date 2>/dev/null || true
  echo "module=$MODDIR"
  for pkg in com.miui.nextpay com.miui.tsmclient com.unionpay.tsmservice.mi com.xiaomi.payment com.rongcard.eid com.xiaomi.otrpbroker; do
    path="$(pm path "$pkg" 2>/dev/null | head -n 1)"
    echo "$pkg ${path:-missing}"
  done
} > "$LOG" 2>&1
