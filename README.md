# HyperOS3 EU Localization

为 xiaomi.eu HyperOS3 ROM 恢复原版 HyperOS 功能的 Magisk/KernelSU 模块。

Reintegrate original HyperOS features for xiaomi.eu HyperOS3 ROM.

## 功能 / Features

- 🔧 恢复国行版本地化功能（小爱同学、负一屏、短信、传送门、黄页等）
- 💳 小米钱包、公交卡、MiPay 支持
- 📅 日历、天气、音乐、录音机
- 🎨 字体、主题管理器、通知过滤
- 🛡️ Xposed 模块提供签名绕过和系统增强

## 安装要求 / Requirements

- Xiaomi 13 (fuxi) 搭载 xiaomi.eu HyperOS 3 ROM（仅在该环境下测试通过）
- Magisk / KernelSU / APatch 等 Root 方案
- LSPosed / LSPatch（用于 Xposed 模块功能）

## 安装 / Installation

### Magisk 模块

1. 下载 `HyperOS3_EU_Localization_v*.zip`
2. 在 Magisk/KernelSU 管理器中刷入
3. 按提示选择需要的功能
4. 重启设备

### Toolbox APK（可选）

1. 安装 `HyperOS3_Toolbox_v*.apk`
2. 在 LSPosed 中启用该模块
3. 勾选需要作用的应用范围
4. 重启设备

## 参考仓库 / Credits

本项目 fork 自以下仓库：

- [MinaMichita/MiuiEULocalizationToolsBox](https://github.com/MinaMichita/MiuiEULocalizationToolsBox) - 原版 MIUI EU 本地化模块

感谢原作者 [**@MinaMichita**](https://github.com/MinaMichita) 的开创性工作！

## 目录结构 / Structure

```
HyperOS3EULocalization/
├── META-INF/           # Magisk 安装脚本
├── system/             # 系统覆盖文件
├── toolbox/            # Xposed 模块源码
├── customize.sh        # 安装脚本
├── service.sh          # 启动脚本
├── module.prop         # 模块信息
└── README.md
```


## HyperOS 3 basic services adaptation

This branch aligns the basic CN service payloads with the actual fuxi xiaomi.eu package paths to avoid duplicate package scans when restoring existing apps:

- 小爱同学: `com.miui.voiceassist` -> `system/product/app/VoiceAssistAndroidT`; related AI vision/service payloads use `system/product/app/AiAsstVision` and `system/product/app/MIUIAiasstService`.
- 负一屏: `com.miui.personalassistant` -> `system/product/priv-app/PersonalAssistant`.
- 短信: `com.android.mms` -> `system/product/priv-app/Mms`.
- 传送门: `com.miui.contentextension` -> `system/product/priv-app/MIUIContentExtension`.
- 黄页: `com.miui.yellowpage` -> `system/product/priv-app/MIUIYellowPage`.

On KernelSU/SukiSU, restored module-mounted apps must be able to see module mounts in their own process namespaces. If a restored app crashes at early `ActivityThread` binding with empty resources, set App Profile -> Custom and turn off `Umount modules` / `卸载模块` for the restored package. For this basic-services set, that means `com.miui.voiceassist`, `com.xiaomi.aiasst.vision`, `com.xiaomi.aiasst.service`, `com.miui.personalassistant`, `com.android.mms`, `com.miui.contentextension`, `com.miui.yellowpage`, and related host processes such as `com.miui.hybrid` when they load restored resources.

## 许可证 / License

本项目基于 Apache License 2.0 开源。
