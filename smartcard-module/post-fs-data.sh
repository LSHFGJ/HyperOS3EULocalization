#!/system/bin/sh
MODDIR=${0%/*}
MARKER="$MODDIR/.package-cache-cleared"

if [ ! -f "$MARKER" ]; then
  rm -rf /data/system/package_cache/* 2>/dev/null
  touch "$MARKER" 2>/dev/null
fi
