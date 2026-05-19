# v2 Slim Cleanup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make the v2 module match the current MVP: smart-card payloads from the current pandora CN ROM, short MMS focus overlay naming, no stale no-payload installer options, and concise flash logs.

**Architecture:** Keep Android system app payloads in per-app directories under `system/product/{app,priv-app,overlay}` for PackageManager and Magisk/KernelSU compatibility. Treat smart-card APK replacement as a binary payload refresh from `CN_ROM_DIR/images/super.img`. Use `tests/test_smartcard_module_structure.sh` as the regression guard for shipped paths, stale names, stale options, and build artifacts.

**Tech Stack:** Bash installer scripts, Magisk/KernelSU/APatch module layout, Android product partition payloads, static RRO overlay, zip-based module build.

---

### Task 1: Add RED structure tests

**Files:**
- Modify: `tests/test_smartcard_module_structure.sh`

**Steps:**
1. Assert new overlay paths exist: `system/product/overlay/FocusXmsOverlay/FocusXmsOverlay.apk` and `overlay-src/FocusXmsOverlay/*`.
2. Assert legacy verbose overlay paths and package names do not exist.
3. Assert stale no-payload installer options are absent from `customize.sh` and `tools/unity_install.sh`: `Fonts`, `SogouInput`, `MiuiIme`, `GboardTheme`, `VideocallBeautify`, `NotificationFilter`, `VirtualSim`, `VoiceTrigger`.
4. Assert verbose installer line-art is absent: box glyphs and long star/divider runs.
5. Run `bash tests/test_smartcard_module_structure.sh`; expected result is FAIL before implementation.

### Task 2: Replace old APK payloads from current pandora CN ROM

**Files:**
- Replace binary payload directories under `system/product/app/` and `system/product/priv-app/`.

**Steps:**
1. Mount/extract `product_a.img` from `CN_ROM_DIR=/mnt/e/rom/pandora_images_OS3.0.306.0.WBLCNXM_20260407.0000.00_16.0_cn_7d3f994591`.
2. Copy matching product directories for every retained payload: `AiAsstVision`, `HybridPlatform`, `MINextpay`, `MITSMClient`, `MIUIAiasstService`, `VoiceAssistAndroidT`, `PersonalAssistant`, `Mms`, `MIUIContentExtension`, `MIUIYellowPage`, and `UPTsmService` when present.
3. Remove copied `oat` directories to keep the module portable.
4. Verify APK mtimes/sizes changed from stale January payloads where CN ROM provides replacements.

### Task 3: Rename MMS focus overlay

**Files:**
- Move the verbose MMS focus overlay source directory to `overlay-src/FocusXmsOverlay`.
- Move the verbose packaged MMS focus overlay directory to `system/product/overlay/FocusXmsOverlay`.
- Modify: `overlay-src/FocusXmsOverlay/AndroidManifest.xml`
- Modify: `tests/test_smartcard_module_structure.sh`
- Modify: `README.md`

**Steps:**
1. Rename source and packaged overlay directories/APKs.
2. Change manifest package to `focus.xms.overlay`.
3. Keep target package `miui.systemui.plugin`, static overlay, priority, and target SDK 28.
4. Verify APK still contains `AndroidManifest.xml`, `resources.arsc`, and signature metadata.

### Task 4: Slim installer options and logs

**Files:**
- Modify: `customize.sh`
- Modify: `tools/unity_install.sh`
- Modify: `lang/en_US.ini`
- Modify: `lang/zh_CN.ini`
- Modify: `META-INF/com/google/android/update-binary`
- Modify: `service.sh` if no longer needed by removed markers.

**Steps:**
1. Keep only feature keys backed by current payload/behavior: `Mipay`, `VoiceAssist`, `PersonalAssistant`, `Mms`, `ContentExtension`, `YellowPage`, `AiAsst`, `RemoveMod`, `HybridPlatform`.
2. Remove stale no-payload option reads, markers, properties, and service logic.
3. Replace box-art and per-option true/false dumps with compact section/status lines.
4. Add missing English log keys if still referenced.

### Task 5: Verify and build

**Files:**
- Test: `tests/test_smartcard_module_structure.sh`

**Steps:**
1. Run `bash tests/test_smartcard_module_structure.sh`.
2. Run `bash -n customize.sh service.sh tools/unity_install.sh tools/volumn_key.sh META-INF/com/google/android/update-binary tests/test_smartcard_module_structure.sh scripts/build-smartcard-module.sh scripts/collect-smartcard-diagnostics.sh`.
3. Run full local build with the pandora CN ROM.
4. Verify built zip contains required payloads and does not contain old overlay names or stale removed payload groups.
5. Consult Oracle before final status.
