#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROM_ROOT="${ROM_ROOT:-/mnt/e/rom}"
WORK_DIR="${WORK_DIR:-$ROM_ROOT/_analysis/build-smartcard}"
OUT_DIR="${OUT_DIR:-$ROM_ROOT/_analysis/out}"
MOUNT_ROOT="${MOUNT_ROOT:-${TMPDIR:-/tmp}/hyperos-smartcard-mount}"
LOCAL_PAYLOAD_DIR="${LOCAL_PAYLOAD_DIR:-$ROOT_DIR/system/product/app}"
CN_ROM_DIR="${CN_ROM_DIR:-}"
MODULE_VERSION="${MODULE_VERSION:-v2.0}"
KEEP_WORK="${KEEP_WORK:-0}"

EROF_FUSE="${EROF_FUSE:-}"
FUSE_LIBRARY_PATH="${FUSE_LIBRARY_PATH:-}"

usage() {
  cat <<USAGE
Usage: ROM_ROOT=/mnt/e/rom $0

Builds a unified HyperOS3 EU Localization module zip under OUT_DIR with smart-card payloads staged in.
All large intermediates are written under WORK_DIR, which defaults to E:.
The FUSE mountpoint uses MOUNT_ROOT, which defaults to native temp space for WSL.
Set CN_ROM_DIR to a HyperOS 3 CN ROM image directory when local payloads are incomplete.
Set KEEP_WORK=1 to preserve extracted images for debugging.
USAGE
}

if [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

require_command() {
  local command_name="$1"
  local error_message="$2"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf '%s\n' "$error_message" >&2
    exit 1
  fi
}

require_command 7z "7z not found. Install p7zip-full or make 7z available in PATH."

apk_has_dex() {
  local apk_path="$1"
  unzip -l "$apk_path" 'classes.dex' >/dev/null 2>&1
}

needs_cn_product() {
  local component
  for component in MINextpay MITSMClient UPTsmService PaymentService MIUISuperMarket; do
    local local_apk="$LOCAL_PAYLOAD_DIR/$component/$component.apk"
    if [ ! -f "$local_apk" ] || ! apk_has_dex "$local_apk"; then
      return 0
    fi
  done
  return 1
}

if needs_cn_product; then
  if [ -z "$CN_ROM_DIR" ]; then
    printf 'Set CN_ROM_DIR to a HyperOS 3 CN ROM image directory because local smart-card payloads are incomplete.\n' >&2
    exit 1
  fi

  if [ ! -f "$CN_ROM_DIR/images/super.img" ]; then
    printf 'CN super image not found: %s\n' "$CN_ROM_DIR/images/super.img" >&2
    exit 1
  fi
fi

if needs_cn_product && [ -z "$EROF_FUSE" ]; then
  if command -v erofsfuse >/dev/null 2>&1; then
    EROF_FUSE="$(command -v erofsfuse)"
  elif [ -x "$ROM_ROOT/_analysis/tools/erofsfuse/usr/bin/erofsfuse" ]; then
    EROF_FUSE="$ROM_ROOT/_analysis/tools/erofsfuse/usr/bin/erofsfuse"
    FUSE_LIBRARY_PATH="${FUSE_LIBRARY_PATH:-$ROM_ROOT/_analysis/tools/libfuse2t64/lib/x86_64-linux-gnu:$ROM_ROOT/_analysis/tools/libfuse2t64/usr/lib/x86_64-linux-gnu}"
  else
    printf 'erofsfuse not found. Install erofsfuse or set EROF_FUSE.\n' >&2
    exit 1
  fi
fi

mkdir -p "$WORK_DIR" "$OUT_DIR"
PRODUCT_IMG="$WORK_DIR/cn_product_a.img"
MOUNT_DIR="$MOUNT_ROOT/mnt_cn_product"
MODULE_BUILD="$WORK_DIR/HyperOS3EULocalization"
ZIP_PATH="$OUT_DIR/HyperOS3_EU_Localization_${MODULE_VERSION}.zip"

cleanup_work_files() {
  if [ "$KEEP_WORK" != "1" ]; then
    rm -f "$PRODUCT_IMG"
    rm -rf "$MODULE_BUILD"
  fi
}

cleanup_mount() {
  fusermount -u "$MOUNT_DIR" >/dev/null 2>&1 || true
  rmdir "$MOUNT_DIR" "$MOUNT_ROOT" >/dev/null 2>&1 || true
}

cleanup_all() {
  cleanup_mount
  cleanup_work_files
}
trap cleanup_all EXIT

copy_component() {
  local component="$1"
  local local_src="$LOCAL_PAYLOAD_DIR/$component"
  local local_apk="$local_src/$component.apk"
  local cn_src="$MOUNT_DIR/app/$component"
  local dst="$MODULE_BUILD/system/product/app/"

  if [ -d "$local_src" ] && [ -f "$local_apk" ] && apk_has_dex "$local_apk"; then
    cp -a "$local_src" "$dst"
  elif [ -d "$local_src" ] && [ -f "$local_apk" ] && [ -d "$cn_src" ]; then
    printf 'Local component has no dex, falling back to CN product: %s\n' "$component" >&2
    cp -a "$cn_src" "$dst"
  elif [ -d "$cn_src" ]; then
    cp -a "$cn_src" "$dst"
  else
    printf 'Required component missing from local payload and CN product: %s\n' "$component" >&2
    exit 1
  fi

  rm -rf "$MODULE_BUILD/system/product/app/$component/oat"
}

rm -rf "$MODULE_BUILD" "$MOUNT_DIR"
mkdir -p "$MODULE_BUILD/system/product/app"

if needs_cn_product; then
  mkdir -p "$MOUNT_DIR"

  if [ ! -f "$PRODUCT_IMG" ]; then
    7z x -y "$CN_ROM_DIR/images/super.img" -o"$WORK_DIR" product_a.img >/dev/null
    mv "$WORK_DIR/product_a.img" "$PRODUCT_IMG"
  fi

  if [ -n "$FUSE_LIBRARY_PATH" ]; then
    LD_LIBRARY_PATH="$FUSE_LIBRARY_PATH" "$EROF_FUSE" "$PRODUCT_IMG" "$MOUNT_DIR" >/dev/null
  else
    "$EROF_FUSE" "$PRODUCT_IMG" "$MOUNT_DIR" >/dev/null
  fi
fi

cp -a "$ROOT_DIR/META-INF" "$ROOT_DIR/module.prop" "$ROOT_DIR/customize.sh" "$ROOT_DIR/service.sh" "$ROOT_DIR/uninstall.sh" "$ROOT_DIR/lang" "$ROOT_DIR/tools" "$MODULE_BUILD/"
cp -a "$ROOT_DIR/system" "$MODULE_BUILD/"

for component in MINextpay MITSMClient UPTsmService PaymentService MIUISuperMarket; do
  copy_component "$component"
done

cleanup_mount

rm -f "$ZIP_PATH"
(cd "$MODULE_BUILD" && zip -qr "$ZIP_PATH" .)
printf 'Built %s\n' "$ZIP_PATH"
