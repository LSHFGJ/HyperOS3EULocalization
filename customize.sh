##########################################################################################
# HyperOS3 EU Localization - Magisk/KernelSU/APatch Module Installer
##########################################################################################

SKIPUNZIP=1
ASH_STANDALONE=1

REPLACE=""

print_banner() {
    ui_print ""
    ui_print "[HyperOS3 EU Localization v2.0]"
    ui_print "Author: LSHFGJ"
    ui_print "Target: Any HyperOS 3 device/build"
    ui_print ""
}

print_step() {
    ui_print "- $1"
}

print_success() {
    ui_print "  OK: $1"
}

print_info() {
    ui_print "  $1"
}

chooseport() {
    local timeout=10
    local start_time=$(date +%s)

    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))

        if [ $elapsed -ge $timeout ]; then
            return 0
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
    ui_print "  [音量+] 是 / Yes    [音量-] 否 / No"
    ui_print "  10 秒内无操作默认选择 是"
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
    local keys="Mipay VoiceAssist PersonalAssistant Mms ContentExtension YellowPage AiAsst RemoveMod HybridPlatform"
    for key in $keys; do
        set_config $key "true"
    done
}

generate_default_config() {
    cat > $MODPATH/HyperOS3EULocalization.ini <<EOF
Mipay=false
HybridPlatform=false
ContentExtension=false
PersonalAssistant=false
Mms=false
YellowPage=false
AiAsst=false
VoiceAssist=false
RemoveMod=false
EOF
}

print_banner

print_step "Extracting module files"
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2
print_success "Files extracted"

generate_default_config

ui_print ""
print_step "Feature selection"
ui_print "Q1: Install all available features?"
if vk_choose; then
    print_success "Selected all features"
    enable_all
else
    print_info "Custom selection mode"

    ui_print ""
    ui_print "Q2: Basic services"
    ui_print "  XiaoAI / Assistant / MMS / Content Extension / Yellow Page"
    if vk_choose; then
        print_success "Selected basic services"
        set_config "VoiceAssist" "true"
        set_config "PersonalAssistant" "true"
        set_config "Mms" "true"
        set_config "ContentExtension" "true"
        set_config "YellowPage" "true"
        set_config "AiAsst" "true"
    else
        print_info "Skipped basic services"
    fi

    ui_print ""
    ui_print "Q3: Xiaomi smart card"
    ui_print "  Smart Card / Transit Card / MiPay chain"
    if vk_choose; then
        print_success "Selected Xiaomi smart card"
        set_config "Mipay" "true"
    else
        print_info "Skipped Xiaomi smart card"
    fi

    ui_print ""
    ui_print "Q4: System tweaks"
    ui_print "  CN region props / HybridPlatform"
    if vk_choose; then
        print_success "Selected system tweaks"
        set_config "RemoveMod" "true"
        set_config "HybridPlatform" "true"
    else
        print_info "Skipped system tweaks"
    fi
fi

ui_print ""
print_step "Installing selected components"
chmod -R 0755 $MODPATH/tools
. $MODPATH/tools/unity_install.sh

ui_print ""
print_step "Cleaning installer files"
rm -rf \
$MODPATH/system/placeholder $MODPATH/customize.sh \
$MODPATH/*.md $MODPATH/.git* $MODPATH/LICENSE $MODPATH/tools $MODPATH/lang 2>/dev/null

set_perm_recursive $MODPATH 0 0 0755 0644

ui_print ""
ui_print "INSTALLATION COMPLETED"
ui_print "Reboot required to apply changes."
ui_print "KernelSU/SukiSU: disable app-profile module unmount if resources are missing."
