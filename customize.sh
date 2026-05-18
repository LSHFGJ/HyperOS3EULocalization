##########################################################################################
#
# HyperOS3 EU Localization - Magisk/KernelSU/APatch Module Installer
# Forked from MiuiEULocalization by MinaMiGo
#
##########################################################################################

SKIPUNZIP=1
ASH_STANDALONE=1

REPLACE=""

##########################################################################################
# Helper Functions
##########################################################################################

print_banner() {
    ui_print ""
    ui_print "╔══════════════════════════════════════════════════════════════╗"
    ui_print "║                                                              ║"
    ui_print "║           HyperOS 3 EU Localization Module                   ║"
    ui_print "║                                                              ║"
    ui_print "╠══════════════════════════════════════════════════════════════╣"
    ui_print "║  Version: v2.0                                                ║"
    ui_print "║  Author:  LSHFGJ                                             ║"
    ui_print "║  Target:  Any HyperOS 3 device/build                         ║"
    ui_print "╚══════════════════════════════════════════════════════════════╝"
    ui_print ""
}

print_step() {
    ui_print "  ► $1"
}

print_success() {
    ui_print "  ✓ $1"
}

print_info() {
    ui_print "  ℹ $1"
}

# Volume Key Detection
chooseport() {
    local timeout=10
    local start_time=$(date +%s)
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -ge $timeout ]; then
            return 0 # Default to YES/UP
        fi

        /system/bin/timeout 1 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events || true
        if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
            break
        fi
    done

    if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
        return 0
    else
        return 1
    fi
}

vk_choose() {
    ui_print "      [音量+] 是 (Yes)    [音量-] 否 (No)"
    ui_print "      (10秒内无操作将默认选择 是)"
    if chooseport; then
        return 0
    else
        return 1
    fi
}

set_config() {
    local key=$1
    local value=$2
    sed -i "s/^$key=.*/$key=$value/g" $MODPATH/HyperOS3EULocalization.ini
}

enable_all() {
    local keys="Mipay VoiceAssist PersonalAssistant Mms ContentExtension YellowPage AiAsst VoiceTrigger RemoveMod Fonts HybridPlatform VirtualSim MiuiIme SogouInput GboardTheme VideocallBeautify NotificationFilter"
    for key in $keys; do
        set_config $key "true"
    done
}

generate_default_config() {
    cat > $MODPATH/HyperOS3EULocalization.ini <<EOF
Fonts=false
Mipay=false
HybridPlatform=false
ContentExtension=false
VirtualSim=false
PersonalAssistant=false
MiuiIme=false
SogouInput=false
Mms=false
YellowPage=false
AiAsst=false
VoiceAssist=false
VoiceTrigger=false
GboardTheme=false
VideocallBeautify=false
NotificationFilter=false
RemoveMod=false
EOF
}

##########################################################################################
# Installation
##########################################################################################

print_banner

ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_step "Extracting module files..."
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2
print_success "Files extracted"
ui_print ""

# Generate default config
generate_default_config

ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print "                    功能选择 / Feature Selection"
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ui_print ""

ui_print "  ┌─────────────────────────────────────────────────────────────┐"
ui_print "  │  Q1: 快速安装全部功能？                                      │"
ui_print "  │      Install all features?                                  │"
ui_print "  └─────────────────────────────────────────────────────────────┘"
if vk_choose; then
    print_success "已选择：安装全部功能"
    enable_all
else
    print_info "进入自定义选择模式..."
    ui_print ""

    ui_print "  ┌─────────────────────────────────────────────────────────────┐"
    ui_print "  │  Q2: 基础服务                                               │"
    ui_print "  │      小爱同学 / 负一屏 / 短信 / 传送门 / 黄页                  │"
    ui_print "  └─────────────────────────────────────────────────────────────┘"
    if vk_choose; then
        print_success "已选中：基础服务"
        set_config "VoiceAssist" "true"
        set_config "PersonalAssistant" "true"
        set_config "Mms" "true"
        set_config "ContentExtension" "true"
        set_config "YellowPage" "true"
        set_config "AiAsst" "true"
        set_config "VoiceTrigger" "true"
    else
        print_info "已跳过"
    fi
    ui_print ""

    ui_print "  ┌─────────────────────────────────────────────────────────────┐"
    ui_print "  │  Q3: 小米钱包                                               │"
    ui_print "  │      钱包 / 公交卡 / MiPay                                   │"
    ui_print "  └─────────────────────────────────────────────────────────────┘"
    if vk_choose; then
        print_success "已选中：小米钱包"
        set_config "Mipay" "true"
    else
        print_info "已跳过"
    fi
    ui_print ""

    ui_print "  ┌─────────────────────────────────────────────────────────────┐"
    ui_print "  │  Q4: 系统优化                                               │"
    ui_print "  │      屏蔽国际标识 / 字体 / 快应用                            │"
    ui_print "  └─────────────────────────────────────────────────────────────┘"
    if vk_choose; then
        print_success "已选中：系统优化"
        set_config "RemoveMod" "true"
        set_config "Fonts" "true"
        set_config "HybridPlatform" "true"
        set_config "SogouInput" "true"
        set_config "MiuiIme" "true"
    else
        print_info "已跳过"
    fi
fi

ui_print ""
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_step "Installing components..."
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Execute installation script
chmod -R 0755 $MODPATH/tools
. $MODPATH/tools/unity_install.sh

ui_print ""
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_step "Cleaning up..."
ui_print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Delete extra files
rm -rf \
$MODPATH/system/placeholder $MODPATH/customize.sh \
$MODPATH/*.md $MODPATH/.git* $MODPATH/LICENSE $MODPATH/tools $MODPATH/lang 2>/dev/null

# Set Permissions
set_perm_recursive $MODPATH 0 0 0755 0644
print_success "Installation completed"

ui_print ""
ui_print "╔══════════════════════════════════════════════════════════════╗"
ui_print "║                                                              ║"
ui_print "║              ✓ INSTALLATION COMPLETED                        ║"
ui_print "║                                                              ║"
ui_print "║  Please reboot your device to apply changes.                 ║"
ui_print "║                                                              ║"
    ui_print "║  KernelSU/SukiSU users: disable app-profile module unmount  ║"
    ui_print "║  for restored apps if labels/resources cannot be loaded.     ║"
ui_print "║                                                              ║"
ui_print "╚══════════════════════════════════════════════════════════════╝"
ui_print ""
