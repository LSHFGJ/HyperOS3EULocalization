# HyperOS3 EU Localization

为 xiaomi.eu HyperOS 3 ROM 恢复部分国区组件的 Magisk / KernelSU / APatch 模块。

## 目录

- [功能范围](#功能范围)
- [安装要求](#安装要求)
- [安装与选择](#安装与选择)
- [KernelSU 注意事项](#kernelsu--sukisu--apatch-注意事项)
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

### Focus / XMS 权限补全

模块内置一个静态 product overlay：`system/product/overlay/FocusXmsOverlay/FocusXmsOverlay.apk`。它面向 `miui.systemui.plugin` 补全 `config_pass_xms_permission`，用于恢复短信验证码等已在 Focus 白名单链路中的应用发送灵动岛弹幕通知的权限门槛。

> [!NOTE]
> 模块不再绑定固定机型或固定版本号，但仍然面向 HyperOS 3。非 xiaomi.eu 或非 HyperOS 3 环境可能可以刷入，但不保证功能表现。建议先完整备份重要数据，并确认能进入 Recovery / Fastboot 以便回滚。

## 安装与选择

1. 下载 `HyperOS3_EU_Localization_v2.0.zip`。
2. 如果使用 KernelSU，先安装并启用可用的挂载元模块。
3. 在 Magisk / KernelSU / SukiSU / APatch 管理器中刷入模块。
4. 安装器会通过音量键询问是否启用功能组：
   - **基础服务**：小爱、负一屏、短信、传送门、黄页等。
   - **小米钱包**：智能卡、公交卡、MiPay 支付服务相关链路。
   - **小米应用商店**：应用商店 / GetApps。
   - **系统优化**：国际版标识屏蔽、快应用框架和少量属性项。
5. 重启设备。
6. 如果使用 KernelSU / SukiSU / APatch，请按下一节检查 App Profile。

## KernelSU 注意事项

> [!IMPORTANT]
> KernelSU 场景要求先具备可用的 systemless 文件挂载元模块 / 挂载能力；推荐 [`magic_mount_rs`](https://github.com/KernelSU-Modules-Repo/magic_mount_rs)，其他等价元模块也可以。App Profile 的 `Umount modules` / `卸载模块` 只是第二层命名空间可见性开关，不能替代底层挂载能力。

SukiSU Ultra / APatch / Magisk 等如果已经自带可用的系统文件挂载能力，通常不需要额外安装元模块。

基于 KernelSU 的 Root 管理器建议关闭以下应用的 `Umount modules` 以确保全部功能可用：

```text
android.uid.system
com.android.smspush
android.uid.nfc
com.miui.nextpay
com.xiaomi.market
com.miui.personalassistant
com.android.permissioncontroller
android.uid.phone
com.android.mms
com.xiaomi.payment
com.miui.home
com.miui.voiceassist
com.mipay.wallet
```

## 项目结构

```text
HyperOS3EULocalization/
├── META-INF/                         # 模块安装入口
├── archive/                          # 暂时停用的实验性组件归档
├── scripts/                          # 构建与诊断脚本
├── system/product/app/               # 普通系统应用 payload
├── system/product/overlay/           # Focus / XMS 静态 overlay payload
├── system/product/priv-app/          # 特权应用 payload
├── overlay-src/                      # overlay 源码留档
├── tools/                            # 安装时处理逻辑
├── customize.sh                      # 安装器交互脚本
├── module.prop                       # 模块元信息
└── service.sh                        # 开机服务脚本
```

## 致谢

本项目基于 [MinaMichita/MiuiEULocalizationToolsBox](https://github.com/MinaMichita/MiuiEULocalizationToolsBox) 的原始工作继续调整，感谢原作者的开创性工作。
