fail_install() {
    rm -rf $MODPATH
    rm -f $MODDIR/update
    exit 1
}

waiting() {
    sleep $1
}

log_section() {
    ui_print ""
    ui_print "[$1]"
}

log_item() {
    ui_print "- $1"
}

log_warn() {
    ui_print "! $1"
}

mark_selected() {
    local name="$1"
    touch "$MODPATH/system/etc/localization/$name"
}

remove_path() {
    rm -rf "$MODPATH/$1"
}

bool_enabled() {
    [ "${1:-false}" = "true" ]
}

MODDIR=$NVBASE/modules/$MODID
MODMODIFY=`grep_prop modify $MODPATH/module.prop`
MODVERSION=`grep_prop version $MODPATH/module.prop`
BUILDHOST=`getprop ro.build.host`
MIUIVERSION=`getprop ro.system.build.version.incremental`
HYPEROSVERSION=`getprop ro.mi.os.version.name`
BUILDDISPLAY=`getprop ro.build.display.id`

ModulePropDescription="Restore selected CN HyperOS components for HyperOS 3."
sed -i "s/<DESCRIPTION>/${ModulePropDescription}/g" $MODPATH/module.prop

log_section "Module"
log_item "${LANG_PROJECTNAME} $MODVERSION"
log_item "Target: HyperOS 3.x, any device/build"
log_item "Current: ${HYPEROSVERSION:-unknown} / $MIUIVERSION / API $API"
waiting 1

log_section "Compatibility"
if ! $BOOTMODE ;then
    log_warn "Install from a Magisk/KernelSU/APatch module manager."
    fail_install
fi

if [ -e $MODDIR/disable ] ;then
    log_warn "Existing disabled module found. Enable or remove it first."
    fail_install
fi

if [ -e $MODDIR/system/etc/localization/AuthManager ] ;then
    log_warn "Old AuthManager mode detected. Remove the old module first."
    fail_install
fi

if [ -e "$MODPATH/HyperOS3EULocalization.ini" ]; then
    . "$MODPATH/HyperOS3EULocalization.ini"
elif [ -e "$MODPATH/MiuiEuLocalization.ini" ]; then
    . "$MODPATH/MiuiEuLocalization.ini"
elif [ -e /sdcard/Download/MiuiEuLocalization.ini ]; then
    . /sdcard/Download/MiuiEuLocalization.ini
else
    log_warn "Config not found, using defaults."
fi

if [[ $BUILDHOST != "xiaomi.eu" ]] ;then
    log_warn "xiaomi.eu build host was not detected. Continuing."
fi

if [[ "$MIUIVERSION $HYPEROSVERSION $BUILDDISPLAY" != *"OS3"* && "$HYPEROSVERSION" != 3* ]] ;then
    log_warn "HyperOS 3 was not detected from system properties. Continuing."
fi

Mipay=${Mipay:-false}
AppStore=${AppStore:-false}
HybridPlatform=${HybridPlatform:-false}
ContentExtension=${ContentExtension:-false}
PersonalAssistant=${PersonalAssistant:-false}
Mms=${Mms:-false}
YellowPage=${YellowPage:-false}
AiAsst=${AiAsst:-false}
VoiceAssist=${VoiceAssist:-false}
RemoveMod=${RemoveMod:-false}

if [ ! -e "$MODPATH/system/product/app/MINextpay" ] || [ ! -e "$MODPATH/system/product/app/MITSMClient" ] || [ ! -e "$MODPATH/system/product/app/MipayWallet" ] || [ ! -e "$MODPATH/system/product/app/UPTsmService" ] || [ ! -e "$MODPATH/system/product/app/PaymentService" ] ;then
    Mipay=false
    log_warn "Smart-card payload incomplete; disabling Xiaomi smart card."
fi

if [ ! -e "$MODPATH/system/product/app/MIUISuperMarket" ] ;then
    AppStore=false
    log_warn "Xiaomi App Store payload missing; disabling App Store."
fi

if bool_enabled "$AiAsst" ;then
    YellowPage=true
fi

if bool_enabled "$Mms" || bool_enabled "$ContentExtension" || bool_enabled "$PersonalAssistant" || bool_enabled "$AiAsst" || bool_enabled "$VoiceAssist" || bool_enabled "$YellowPage" ;then
    RemoveMod=true
fi

if bool_enabled "$RemoveMod" ;then
    Contacts=true
else
    Contacts=false
fi

if bool_enabled "$PersonalAssistant" || bool_enabled "$ContentExtension" ;then
    MiuiContentCatcher=true
else
    MiuiContentCatcher=false
fi

if bool_enabled "$ContentExtension" ;then
    CatcherPatch=true
else
    CatcherPatch=false
fi

mkdir -p "$MODPATH/system/etc/localization"
touch "$MODPATH/system/etc/localization/SelectionSaved"

log_section "Selected"
enabled_summary=""
for item in Mipay AppStore HybridPlatform ContentExtension PersonalAssistant Mms YellowPage AiAsst VoiceAssist RemoveMod; do
    eval "item_value=\${$item:-false}"
    if bool_enabled "$item_value" ;then
        mark_selected "$item"
        enabled_summary="$enabled_summary $item"
    fi
done
if [ -n "$enabled_summary" ]; then
    log_item "${enabled_summary# }"
else
    log_item "No optional payloads selected"
fi

log_section "Payloads"
if ! bool_enabled "$Mipay" ;then
    remove_path "system/product/app/MINextpay"
    remove_path "system/product/app/MITSMClient"
    remove_path "system/product/app/MipayWallet"
    remove_path "system/product/app/UPTsmService"
    remove_path "system/product/app/PaymentService"
fi

if ! bool_enabled "$AppStore" ;then
    remove_path "system/product/app/MIUISuperMarket"
fi

if ! bool_enabled "$HybridPlatform" ;then
    remove_path "system/product/app/HybridPlatform"
fi

if ! bool_enabled "$ContentExtension" ;then
    remove_path "system/product/priv-app/MIUIContentExtension"
fi

if ! bool_enabled "$PersonalAssistant" ;then
    remove_path "system/product/priv-app/PersonalAssistant"
fi

if ! bool_enabled "$Mms" ;then
    remove_path "system/product/priv-app/Mms"
fi

if ! bool_enabled "$YellowPage" ;then
    remove_path "system/product/priv-app/MIUIYellowPage"
fi

if ! bool_enabled "$AiAsst" ;then
    remove_path "system/product/app/MIUIAiasstService"
fi

if ! bool_enabled "$VoiceAssist" ;then
    remove_path "system/product/app/AiAsstVision"
    remove_path "system/product/app/VoiceAssistAndroidT"
    remove_path "system/product/app/MIUIAiasstService"
fi

if ! bool_enabled "$Contacts" ;then
    remove_path "system/priv-app/Contacts"
fi

if bool_enabled "$RemoveMod" ;then
    mkdir -p "$MODPATH/system/priv-app/CleanMaster"
    touch "$MODPATH/system/priv-app/CleanMaster/CleanMaster.apk"
    mkdir -p "$MODPATH/system/product/priv-app/CleanMaster"
    touch "$MODPATH/system/product/priv-app/CleanMaster/CleanMaster.apk"
else
    remove_path "system/vendor/camera"
fi

if ! bool_enabled "$MiuiContentCatcher" ;then
    remove_path "system/system_ext/app/MiuiContentCatcher"
fi

if ! bool_enabled "$CatcherPatch" ;then
    remove_path "system/system_ext/app/CatcherPatch"
fi

echo "" >> $MODPATH/system.prop

if bool_enabled "$Mipay" ;then
    echo "ro.se.type=eSE,HCE,UICC" >> $MODPATH/system.prop
fi

if bool_enabled "$AiAsst" ;then
    echo "ro.vendor.audio.aiasst.support=true" >> $MODPATH/system.prop
fi

if bool_enabled "$RemoveMod" ;then
    echo "ro.product.mod_device=xiaomieu" >> $MODPATH/system.prop
    echo "ro.miui.region=CN" >> $MODPATH/system.prop
fi

echo "" >> $MODPATH/system.prop
echo "moe.minamigo.miuieulocalization=$MODVERSION" >> $MODPATH/system.prop

log_section "Data cleanup"
if bool_enabled "$PersonalAssistant" ;then
    if [ ! -e $MODDIR/system/etc/localization/PersonalAssistant ] ;then
        rm -rf /data/data/com.miui.personalassistant/*
    fi
else
    if [ -e $MODDIR/system/etc/localization/PersonalAssistant ] ;then
        rm -rf /data/data/com.miui.personalassistant/*
    fi
fi

if bool_enabled "$Mms" ;then
    if [ ! -e $MODDIR/system/etc/localization/Mms ] ;then
        rm -rf /data/data/com.android.mms/*
    fi
else
    if [ -e $MODDIR/system/etc/localization/Mms ] ;then
        rm -rf /data/data/com.android.mms/*
    fi
fi

if bool_enabled "$Contacts" ;then
    if [ ! -e $MODDIR/system/etc/localization/Contacts ] ;then
        rm -rf /data/data/com.android.contacts/*
    fi
else
    if [ -e $MODDIR/system/etc/localization/Contacts ] ;then
        rm -rf /data/data/com.android.contacts/*
    fi
fi

mkdir -p "$MODPATH/system/etc/localization/SystemVersion"
touch "$MODPATH/system/etc/localization/SystemVersion/$SYSTEM_VERSION"
rm -rf /data/system/package_cache/*

log_item "Done"
waiting 1
