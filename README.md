# HyperOS3 EU Localization

为 xiaomi.eu HyperOS 3 ROM 恢复部分国区组件的 Magisk / KernelSU / APatch 模块。

这个项目当前的 v2.0 版本是一个精简模块：优先保证 **小米智能卡 / 公交卡链路** 和 **旧版短信验证码灵动岛** 可用，同时保留少量基础国区组件。它不是完整的国区系统功能包，也不包含旧 Toolbox / LSPosed hook。

## 目录

- [功能范围](#功能范围)
- [不包含的内容](#不包含的内容)
- [安装要求](#安装要求)
- [安装与选择](#安装与选择)
- [KernelSU / SukiSU / APatch 注意事项](#kernelsu--sukisu--apatch-注意事项)
- [本地构建](#本地构建)
- [排查问题](#排查问题)
- [项目结构](#项目结构)

## 功能范围

### 小米智能卡 / 公交卡链路

模块会恢复智能卡相关组件：

| 功能 | 包 / 组件 | 模块路径 |
| --- | --- | --- |
| 小米智能卡客户端 | `com.miui.tsmclient` | `system/product/app/MITSMClient` |
| 小米钱包 | `com.mipay.wallet` | `system/product/app/MipayWallet` |
| 小米支付 / NextPay | `com.miui.nextpay` | `system/product/app/MINextpay` |
| 银联 TSM 服务 | `com.unionpay.tsmservice.mi` | `system/product/app/UPTsmService` |
| 小米支付服务 | `com.xiaomi.payment` | `system/product/app/PaymentService` |

智能卡核心 payload 已从当前 pandora 国行 HyperOS 3 ROM 对齐。`com.mipay.wallet` 钱包主 APK 来自小米应用商店官方分发包，因为当前 pandora ROM 镜像中只保留了它的图标和 pipeline 信息，没有预装 APK 本体。

### 短信验证码灵动岛修复

模块包含一个静态 RRO overlay：

- overlay 路径：`system/product/overlay/MmsFocusOverlay`
- 目标包：`miui.systemui.plugin`
- 作用：把 `com.android.mms` 加入 focus/XMS 权限白名单，让旧版短信的验证码通知更容易进入灵动岛流程。

### 可选基础组件

安装时可以选择恢复以下基础组件：

| 功能 | 包 / 组件 | 模块路径 |
| --- | --- | --- |
| 小爱语音 | `com.miui.voiceassist` | `system/product/app/VoiceAssistAndroidT` |
| 小爱视觉 | `com.xiaomi.aiasst.vision` | `system/product/app/AiAsstVision` |
| 小爱服务 | `com.xiaomi.aiasst.service` | `system/product/app/MIUIAiasstService` |
| 负一屏 | `com.miui.personalassistant` | `system/product/priv-app/PersonalAssistant` |
| 短信 | `com.android.mms` | `system/product/priv-app/Mms` |
| 传送门 | `com.miui.contentextension` | `system/product/priv-app/MIUIContentExtension` |
| 黄页 | `com.miui.yellowpage` | `system/product/priv-app/MIUIYellowPage` |
| 快应用框架 | `com.miui.hybrid` | `system/product/app/HybridPlatform` |
| 小米应用商店 / GetApps | `com.xiaomi.market` | `system/product/app/MIUISuperMarket` |

安装器中还保留了国际版标识屏蔽选项，它会写入少量系统属性，不是独立恢复应用。

## 不包含的内容

当前 v2.0 不包含：

- 旧 Toolbox 源码或 LSPosed hook 功能
- 旧媒体生活 payload
- 旧 `MipayService`
- 单独的智能卡子模块或单独 APK 产物
- 云端结构检测 workflow

## 安装要求

- xiaomi.eu HyperOS 3 ROM
- Magisk、KernelSU、SukiSU 或 APatch 等 Root 模块管理器
- 建议先完整备份重要数据，并确认能进入 Recovery / Fastboot 以便回滚

> [!NOTE]
> 模块不再绑定固定机型或固定版本号，但仍然面向 HyperOS 3。非 xiaomi.eu 或非 HyperOS 3 环境可能可以刷入，但不保证功能表现。

## 安装与选择

1. 下载或本地构建 `HyperOS3_EU_Localization_v2.0.zip`。
2. 在 Magisk / KernelSU / SukiSU / APatch 管理器中刷入模块。
3. 安装器会通过音量键询问是否启用功能组：
   - **基础服务**：小爱、负一屏、短信、传送门、黄页等。
   - **小米钱包**：智能卡、公交卡、MiPay 支付服务相关链路。
   - **小米应用商店**：应用商店 / GetApps。
   - **系统优化**：国际版标识屏蔽、快应用框架和少量属性项。
4. 重启设备。
5. 如果使用 KernelSU / SukiSU / APatch，请按下一节检查 App Profile。

## KernelSU / SukiSU / APatch 注意事项

> [!IMPORTANT]
> KernelSU / SukiSU / APatch 的 App Profile 可能会让某些应用看不到模块挂载出来的 `/product/app/...` 资源。若智能卡、短信、桌面入口、权限弹窗或 SystemUI 相关功能异常，请在对应应用的 App Profile 中关闭 `Umount modules` / `卸载模块`。

智能卡链路建议至少关闭以下应用的 `Umount modules`：

```text
com.miui.tsmclient
com.mipay.wallet
com.xiaomi.payment
com.android.permissioncontroller
com.miui.home
com.android.systemui
```

如果同时测试基础组件，也建议关闭：

```text
com.miui.voiceassist
com.xiaomi.aiasst.vision
com.xiaomi.aiasst.service
com.miui.personalassistant
com.android.mms
com.miui.contentextension
com.miui.yellowpage
com.miui.hybrid
com.xiaomi.market
```

> [!TIP]
> 判断是否是挂载命名空间问题，可以看应用进程内是否能访问类似 `system/product/app/MITSMClient/MITSMClient.apk` 对应的挂载路径。仓库提供了诊断脚本用于收集这类信息。

## 本地构建

常用构建命令：

```bash
ROM_ROOT="/mnt/e/rom" \
CN_ROM_DIR="/mnt/e/rom/pandora_images_OS3.0.306.0.WBLCNXM_20260407.0000.00_16.0_cn_7d3f994591" \
scripts/build-smartcard-module.sh
```

默认输出：

```text
/mnt/e/rom/_analysis/out/HyperOS3_EU_Localization_v2.0.zip
```

构建脚本行为：

- 默认把大文件临时目录放在 `ROM_ROOT/_analysis/build-smartcard`。
- 默认把最终 zip 放在 `ROM_ROOT/_analysis/out`。
- 如果本地智能卡 payload 不完整，需要通过 `CN_ROM_DIR` 指向国行 HyperOS 3 ROM 镜像目录。
- 需要系统中存在 `7z`；如需从 EROFS 镜像提取 payload，还需要可用的 `erofsfuse`。

## 排查问题

### 收集智能卡诊断日志

连接设备后运行：

```bash
scripts/collect-smartcard-diagnostics.sh
```

如果想先清空 logcat、复现问题后再收集：

```bash
scripts/collect-smartcard-diagnostics.sh --clear-first
```

日志默认写入：

```text
/mnt/e/rom/_analysis/device-logs
```

### 常见现象

| 现象 | 优先检查 |
| --- | --- |
| 智能卡打不开或闪退 | `com.miui.tsmclient` 是否关闭 `Umount modules` |
| 权限弹窗或卡片资源异常 | `com.android.permissioncontroller` 是否能看到模块挂载 |
| 桌面入口或最近任务显示异常 | `com.miui.home` 是否关闭 `Umount modules` |
| 灵动岛 / 通知相关异常 | `com.android.systemui` 与 `com.android.mms` 的 App Profile |
| 构建失败提示 payload 不完整 | `CN_ROM_DIR` 是否指向包含 `images/super.img` 的国行 ROM 目录 |

## 项目结构

```text
HyperOS3EULocalization/
├── META-INF/                         # 模块安装入口
├── overlay-src/                      # 短信灵动岛 overlay 源文件
├── scripts/                          # 构建与诊断脚本
├── system/product/app/               # 普通系统应用 payload
├── system/product/priv-app/          # 特权应用 payload
├── system/product/overlay/           # 已构建 overlay APK
├── tools/                            # 安装时处理逻辑
├── customize.sh                      # 安装器交互脚本
├── module.prop                       # 模块元信息
└── service.sh                        # 开机服务脚本
```

## 致谢

本项目基于 [MinaMichita/MiuiEULocalizationToolsBox](https://github.com/MinaMichita/MiuiEULocalizationToolsBox) 的原始工作继续调整，感谢原作者的开创性工作。
