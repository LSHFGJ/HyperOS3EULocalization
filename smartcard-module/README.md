# HyperOS3 Smart Card Restore

Systemless smart-card component restoration for xiaomi.eu HyperOS 3 on Xiaomi 17 Pro (`pandora`) and Xiaomi 13 `fuxi`.

This module uses the standard Magisk module layout so Magisk, KernelSU, and APatch can consume it through their own module loaders. It does not include a runtime hook dependency and does not require a meta module.

## Install path

Flash the generated module zip from the Magisk, KernelSU, or APatch module manager while Android is booted. Recovery-style flashing without a module-manager helper is rejected because `customize.sh` needs the standard module installer functions.

The first tested payload source is the Xiaomi 17 Pro (`pandora`) CN HyperOS 3 build. Xiaomi 13 `fuxi` on `3.0.2.0.WMCCNXM` is also allowed for validation because the smart-card APK version is not treated as the primary compatibility boundary for this MVP.

### KernelSU / SukiSU app profile requirement

On KernelSU/SukiSU, the smart-card app process and system UI processes that resolve smart-card labels must be allowed to see module mounts. If `com.miui.tsmclient` is left on an app profile that unmounts modules, Android can scan `/product/app/MITSMClient/MITSMClient.apk` during package parsing while the app process later cannot see the same path in its mount namespace. That mismatch causes empty dex/resource paths such as `DexPathList[[]]`, `ClassNotFoundException` for framework/app classes, and early crashes.

If `com.android.permissioncontroller` cannot see the same APK, runtime permission prompts can fail to load the app label resource and fall back from `android:label` to the application class name, showing `com.miui.tsmclient.App` instead of `小米智能卡`.

If `com.miui.home` or `com.android.systemui` cannot see the APK, recents, launcher, notification, or other system UI surfaces can show the same fallback name even though the app itself works.

For SukiSU Ultra, set:

1. Superuser -> search `com.miui.tsmclient`, `com.android.permissioncontroller`, `com.miui.home`, and `com.android.systemui`.
2. App Profile -> Custom.
3. Turn off `Umount modules` / `卸载模块` for those packages.
4. Reboot, or rescan profiles and restart `com.miui.tsmclient`.

After the profile is correct, `nsenter` from root should be able to see `/product/app/MITSMClient/MITSMClient.apk` from inside the relevant process mount namespaces.

## Build path

Build the flashable zip from the repository root with:

```sh
ROM_ROOT=/mnt/e/rom scripts/build-smartcard-module.sh
```

Large intermediate files default to `/mnt/e/rom/_analysis/build-smartcard` so the WSL filesystem is not filled during extraction. The extracted CN `product_a.img` is deleted after the build by default; set `KEEP_WORK=1` only when you intentionally need to debug the mounted image.

## MVP payload

- `system/product/app/MINextpay`
- `system/product/app/MITSMClient`
- `system/product/app/UPTsmService`
- `system.prop` with `ro.se.type=eSE,HCE,UICC`

`PaymentService` CN replacement and `XMNfcNci` are intentionally staged as optional follow-ups because they affect payment/NFC core behavior.
