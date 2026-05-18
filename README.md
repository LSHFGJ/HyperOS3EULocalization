# HyperOS3 EU Localization

为 xiaomi.eu HyperOS 3 ROM 恢复国区 HyperOS 功能的 Magisk/KernelSU/APatch 模块。

Reintegrate original HyperOS features for xiaomi.eu HyperOS 3 ROMs without a fixed device or build requirement.

## 功能 / Features

- 🔧 恢复国行版本地化功能（小爱同学、负一屏、短信、传送门、黄页等）
- 💳 小米钱包、小米智能卡、公交卡、MiPay 支持
- 📅 日历、天气、音乐、录音机
- 🎨 字体、主题管理器、通知过滤

## 安装要求 / Requirements

- 任意机型 / 任意版本号的 xiaomi.eu HyperOS 3 ROM
- Magisk / KernelSU / APatch 等 Root 方案
- KernelSU/SukiSU 用户需要为恢复的应用关闭 App Profile 中的 `Umount modules` / `卸载模块`

## 安装 / Installation

### Magisk 模块

1. 下载 `HyperOS3_EU_Localization_*.zip`
2. 在 Magisk/KernelSU 管理器中刷入
3. 按提示选择需要的功能
4. 重启设备

## 参考仓库 / Credits

本项目 fork 自以下仓库：

- [MinaMichita/MiuiEULocalizationToolsBox](https://github.com/MinaMichita/MiuiEULocalizationToolsBox) - 原始本地化项目

感谢原作者 [**@MinaMichita**](https://github.com/MinaMichita) 的开创性工作！

## 目录结构 / Structure

```
HyperOS3EULocalization/
├── META-INF/           # Magisk 安装脚本
├── system/             # 系统覆盖文件
├── customize.sh        # 安装脚本
├── service.sh          # 启动脚本
├── module.prop         # 模块信息
└── README.md
```


## HyperOS 3 basic services adaptation

This branch aligns the basic CN service payloads with the actual HyperOS 3 package paths to avoid duplicate package scans when restoring existing apps:

- 小爱同学: `com.miui.voiceassist` -> `system/product/app/VoiceAssistAndroidT`; related AI vision/service payloads use `system/product/app/AiAsstVision` and `system/product/app/MIUIAiasstService`.
- 负一屏: `com.miui.personalassistant` -> `system/product/priv-app/PersonalAssistant`.
- 短信: `com.android.mms` -> `system/product/priv-app/Mms`.
- 传送门: `com.miui.contentextension` -> `system/product/priv-app/MIUIContentExtension`.
- 黄页: `com.miui.yellowpage` -> `system/product/priv-app/MIUIYellowPage`.
- 小米智能卡: `com.miui.tsmclient` -> `system/product/app/MITSMClient`; related payment payloads use `system/product/app/MINextpay` and `system/product/app/UPTsmService` when available.

On KernelSU/SukiSU, restored module-mounted apps must be able to see module mounts in their own process namespaces. If a restored app crashes at early `ActivityThread` binding with empty resources, set App Profile -> Custom and turn off `Umount modules` / `卸载模块` for the restored package. For this basic-services set, that means `com.miui.voiceassist`, `com.xiaomi.aiasst.vision`, `com.xiaomi.aiasst.service`, `com.miui.personalassistant`, `com.android.mms`, `com.miui.contentextension`, `com.miui.yellowpage`, and related host processes such as `com.miui.hybrid` when they load restored resources.

For 小米智能卡, also disable module unmounting for `com.miui.tsmclient`, `com.android.permissioncontroller`, `com.miui.home`, and `com.android.systemui`. These processes resolve `/product/app/MITSMClient/MITSMClient.apk` resources for labels, permission prompts, launcher, recents, notifications, and System UI surfaces.

## 许可证 / License

本项目基于 Apache License 2.0 开源。
