fail_install() {
    rm -rf $MODPATH
    rm -f $MODDIR/update
    exit 1
}

waiting() {
    sleep $1
}

# Basic Variable
MODDIR=$NVBASE/modules/$MODID
# Module Info
MODMODIFY=`grep_prop modify $MODPATH/module.prop`
MODVERSION=`grep_prop version $MODPATH/module.prop`
# System Info
BUILDHOST=`getprop ro.build.host`
MIUIVERSION=`getprop ro.system.build.version.incremental`
HYPEROSVERSION=`getprop ro.mi.os.version.name`
BUILDDISPLAY=`getprop ro.build.display.id`

# Module Description
ModulePropDescription="Restore CN HyperOS features for any HyperOS 3 device/build."
sed -i "s/<DESCRIPTION>/${ModulePropDescription}/g" $MODPATH/module.prop

# Print Info
ui_print ""
ui_print "*******************************************"
ui_print "  ${LANG_PROJECTNAME}"
ui_print "*******************************************"
ui_print "  ${LANG_TEXT_AUTHOR}: $MODAUTH"
if [ -n "$MODIFY" ]; then
ui_print "  ${LANG_TEXT_MODIFIED}: $MODMODIFY"
fi
ui_print ""
ui_print "  ${LANG_TEXT_MODULE_VERSION}: $MODVERSION"
ui_print "  Target HyperOS: 3.x, any device/build"
ui_print ""
ui_print "  ${LANG_TEXT_CURRENT_MIUI_VERSION}: $MIUIVERSION"
ui_print "  Current HyperOS Version: ${HYPEROSVERSION:-unknown}"
ui_print "  ${LANG_TEXT_ANDROID_API_LEVEL}: $API"
ui_print "*******************************************"
ui_print "- ${LANG_TEXT_INSTALLING_WILL_START_IN_THREE_SECONDS}"
ui_print "*******************************************"
waiting 3

# Volume Key Process
# . $MODPATH/tools/volumn_key.sh (Removed to prevent hang)
waiting 1

# Compatibility Checking
ui_print ""
ui_print "*******************************************"
ui_print "  ${LANG_TITLE_COMPATIBILITY_CHECK}"
ui_print "*******************************************"
ui_print "- ${LANG_TEXT_CHECKING}"
waiting 1
# Error Checking
if ! $BOOTMODE ;then
    ui_print ""
    ui_print "  * ${LANG_COMPATIBILITY_CHECK_BOOTMODE}"
    ui_print ""
    ui_print "    ${LANG_TEXT_EXIT_WITHOUT_MODIFICATION}"
    ui_print "*******************************************"
    ui_print "- ${LANG_TEXT_INSTALLING_FAIL}"
    fail_install
fi

if [ -e $MODDIR/disable ] ;then
    ui_print ""
    ui_print "  * ${LANG_COMPATIBILITY_CHECK_ERROR_DISABLED_1}"
    ui_print "    ${LANG_COMPATIBILITY_CHECK_ERROR_DISABLED_2}"
    ui_print ""
    ui_print "    ${LANG_TEXT_EXIT_WITHOUT_MODIFICATION}"
    ui_print "*******************************************"
    ui_print "- ${LANG_TEXT_INSTALLING_FAIL}"
    fail_install
fi

if [ -e $MODDIR/system/etc/localization/AuthManager ] ;then
    ui_print ""
    ui_print "  * ${LANG_COMPATIBILITY_CHECK_ERROR_AUTHMANAGER_1}"
    ui_print "    ${LANG_COMPATIBILITY_CHECK_ERROR_AUTHMANAGER_2}"
    ui_print "*******************************************"
    ui_print "- ${LANG_TEXT_INSTALLING_FAIL}"
    fail_install
fi

if [ -e "$MODPATH/HyperOS3EULocalization.ini" ]; then
    . "$MODPATH/HyperOS3EULocalization.ini"
elif [ -e "$MODPATH/MiuiEuLocalization.ini" ]; then
    . "$MODPATH/MiuiEuLocalization.ini"
elif [ -e /sdcard/Download/MiuiEuLocalization.ini ]; then
    . /sdcard/Download/MiuiEuLocalization.ini
else
    ui_print "- Config not found, using defaults."
fi

# Warning Checking
CheckingPass=true

if [[ $BUILDHOST != "xiaomi.eu" ]] ;then
    CheckingPass=false
    ui_print ""
    ui_print "  * ${LANG_COMPATIBILITY_CHECK_WARNING_NOT_EU_ROM_1}"
    waiting 2
    ui_print "    ${LANG_COMPATIBILITY_CHECK_WARNING_NOT_EU_ROM_2}"
    waiting 4
fi

if [[ "$MIUIVERSION $HYPEROSVERSION $BUILDDISPLAY" != *"OS3"* && "$HYPEROSVERSION" != 3* ]] ;then
    CheckingPass=false
    ui_print ""
    ui_print "  * Warning: HyperOS 3 was not detected from system properties."
    ui_print "    Continuing because this module no longer gates by exact build."
    ui_print "    ${LANG_TEXT_CURRENT_MIUI_VERSION}: $MIUIVERSION"
    ui_print "    Current HyperOS Version: ${HYPEROSVERSION:-unknown}"
    waiting 3
fi

# Checking Result
if $CheckingPass ;then
    ui_print ""
    ui_print "- $LANG_COMPATIBILITY_CHECK_PASSED"
    ui_print "*******************************************"
    waiting 2
else
    ui_print ""
    ui_print "- ${LANG_COMPATIBILITY_CHECK_NOT_PASSED_1}"
    waiting 2
    ui_print "  ${LANG_COMPATIBILITY_CHECK_NOT_PASSED_2}"
    waiting 2
    ui_print "  ${LANG_TEXT_CONTINUE_INSTALLING}"
    waiting 2
    # Removed interactive check here, assume YES
    ui_print "  (Auto-continuing...)"
    ui_print "*******************************************"
    waiting 2
fi

ui_print ""
ui_print "*******************************************"
ui_print "  ${LANG_TITLE_FUNCTION}"
ui_print "*******************************************"
# Reading Config
ui_print "- ${LANG_TEXT_READING_CONFIG}"

waiting 1
ui_print ""

if [[ $Fonts == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_FONTS}"
elif [[ $Fonts == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_FONTS}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_FONTS}"
    Fonts=false
fi
ui_print ""

if [ ! -e "$MODPATH/system/product/app/MINextpay" ] || [ ! -e "$MODPATH/system/product/app/MITSMClient" ] || [ ! -e "$MODPATH/system/product/app/UPTsmService" ] ;then
    Mipay=false
    ui_print "   ${LANG_TEXT_READING_CONFIG_UNSUPPORT} ${LANG_TEXT_READING_CONFIG_MIPAY}"
else
    if [[ $Mipay == true ]] ;then
        ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_MIPAY}"
    elif [[ $Mipay == false ]] ;then
        ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_MIPAY}"
    else
        ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_MIPAY}"
        Mipay=false
    fi
fi
ui_print ""

if [[ $HybridPlatform == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_HYBRIDPLATFORM}"
elif [[ $HybridPlatform == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_HYBRIDPLATFORM}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_HYBRIDPLATFORM}"
    HybridPlatform=false
fi
ui_print ""

if [[ $ContentExtension == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_CONTENTEXTENSION}"
elif [[ $ContentExtension == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_CONTENTEXTENSION}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_CONTENTEXTENSION}"
    ContentExtension=false
fi
ui_print ""

if [[ $VirtualSim == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_VIRTUALSIM}"
elif [[ $VirtualSim == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_VIRTUALSIM}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_VIRTUALSIM}"
    VirtualSim=false
fi
ui_print ""

if [[ $PersonalAssistant == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_PERSONALASSISTANT}"
elif [[ $PersonalAssistant == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_PERSONALASSISTANT}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_PERSONALASSISTANT}"
    PersonalAssistant=false
fi
ui_print ""

if [[ $Calendar == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_CALENDAR}"
elif [[ $Calendar == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_CALENDAR}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_CALENDAR}"
    Calendar=false
fi
ui_print ""

if [[ $MiuiIme == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_MIUIIME}"
elif [[ $MiuiIme == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_MIUIIME}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_MIUIIME}"
    MiuiIme=false
fi
ui_print ""

if [[ $SogouInput == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_SOUGOUINPUT}"
elif [[ $SogouInput == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_SOUGOUINPUT}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_SOUGOUINPUT}"
    SogouInput=false
fi
ui_print ""

if [[ $Mms == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_MMS}"
elif [[ $Mms == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_MMS}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_MMS}"
    Mms=false
fi
ui_print ""

if [[ $YellowPage == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_YELLOWPAGE}"
elif [[ $YellowPage == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_YELLOWPAGE}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_YELLOWPAGE}"
    YellowPage=false
fi
ui_print ""

if [[ $AiAsst == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_AIASST}"
elif [[ $AiAsst == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_AIASST}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_AIASST}"
    AiAsst=false
fi
ui_print ""

if [[ $VoiceAssist == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_VOICEASSIST}"

    if [ ! -e $MODPATH/system/product/app/VoiceTrigger_$API ] ;then
        VoiceTrigger=false
        ui_print "   ${LANG_TEXT_READING_CONFIG_UNSUPPORT} ${LANG_TEXT_READING_CONFIG_VOICETRIGGER}"
    else
        if [[ $VoiceTrigger == true ]] ;then
            ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_VOICETRIGGER}"
        elif [[ $VoiceTrigger == false ]] ;then
            ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_VOICETRIGGER}"
        else
            ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_VOICETRIGGER}"
            VoiceTrigger=false
        fi
    fi
elif [[ $VoiceAssist == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_VOICEASSIST}"

    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_VOICETRIGGER}"
    VoiceTrigger=false
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_VOICEASSIST}"
    VoiceAssist=false
    VoiceTrigger=false
fi
ui_print ""

if [[ $Weather == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_PERSONALASSISTANT}"
elif [[ $Weather == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_PERSONALASSISTANT}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_PERSONALASSISTANT}"
    Weather=false
fi
ui_print ""

if [[ $ThemeManager == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_THEMEMANAGER}"
elif [[ $ThemeManager == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_THEMEMANAGER}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_THEMEMANAGER}"
    ThemeManager=false
fi
ui_print ""

if [[ $GboardTheme == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_GBOARDTHEME}"
elif [[ $GboardTheme == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_GBOARDTHEME}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_GBOARDTHEME}"
    GboardTheme=false
fi
ui_print ""

if [[ $VideocallBeautify == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_VIDEOCALLBEAUTIFY}"
elif [[ $VideocallBeautify == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_VIDEOCALLBEAUTIFY}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_VIDEOCALLBEAUTIFY}"
    VideocallBeautify=false
fi
ui_print ""

if [[ $NotificationFilter == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_NOTIFICATIONFILTER}"
elif [[ $NotificationFilter == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_NOTIFICATIONFILTER}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_NOTIFICATIONFILTER}"
    NotificationFilter=false
fi
ui_print ""

if [[ $Music == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_MUSIC}"
elif [[ $Music == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_MUSIC}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_MUSIC}"
    Music=false
fi
ui_print ""

if [ ! -e $MODPATH/system/app/MiuiAudioMonitor_$API ] ;then
    SoundRecorder=false
    ui_print "   ${LANG_TEXT_READING_CONFIG_UNSUPPORT} ${LANG_TEXT_READING_CONFIG_SOUNUDRECORDER}"
else
    if [[ $SoundRecorder == true ]] ;then
        ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_SOUNUDRECORDER}"
    elif [[ $SoundRecorder == false ]] ;then
        ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_SOUNUDRECORDER}"
    else
        ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_SOUNUDRECORDER}"
        SoundRecorder=false
    fi
fi
ui_print ""

if [[ $RemoveMod == true ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_TRUE} ${LANG_TEXT_READING_CONFIG_REMOVEMOD}"
elif [[ $RemoveMod == false ]] ;then
    ui_print "   ${LANG_TEXT_READING_CONFIG_FALSE} ${LANG_TEXT_READING_CONFIG_REMOVEMOD}"
else
    ui_print "   ${LANG_TEXT_READING_CONFIG_NOT_FOUND} ${LANG_TEXT_READING_CONFIG_REMOVEMOD}"
    RemoveMod=false
fi

waiting 5

# Config Saving
touch $MODPATH/system/etc/localization/SelectionSaved

if $Fonts ;then
    touch $MODPATH/system/etc/localization/Fonts
fi

if $Mipay ;then
    touch $MODPATH/system/etc/localization/Mipay
fi

if $HybridPlatform ;then
    touch $MODPATH/system/etc/localization/HybridPlatform
fi

if $ContentExtension ;then
    touch $MODPATH/system/etc/localization/ContentExtension
fi

if $VirtualSim ;then
    touch $MODPATH/system/etc/localization/VirtualSim
fi

if $PersonalAssistant ;then
    touch $MODPATH/system/etc/localization/PersonalAssistant
fi

if $Calendar ;then
    touch $MODPATH/system/etc/localization/Calendar
fi

if $MiuiIme ;then
    touch $MODPATH/system/etc/localization/MiuiIme
fi

if $SogouInput ;then
    touch $MODPATH/system/etc/localization/SogouInput
fi

if $Mms ;then
    touch $MODPATH/system/etc/localization/Mms
fi

if $YellowPage ;then
    touch $MODPATH/system/etc/localization/YellowPage
fi

if $AiAsst ;then
    touch $MODPATH/system/etc/localization/AiAsst
fi

if $VoiceAssist ;then
    touch $MODPATH/system/etc/localization/VoiceAssist
    if $VoiceTrigger ;then
        touch $MODPATH/system/etc/localization/VoiceTrigger
    fi
fi

if $Weather ;then
    touch $MODPATH/system/etc/localization/Weather
fi

if $ThemeManager ;then
    touch $MODPATH/system/etc/localization/ThemeManager
fi

if $GboardTheme ;then
    touch $MODPATH/system/etc/localization/GboardTheme
fi

if $VideocallBeautify ;then
    touch $MODPATH/system/etc/localization/VideocallBeautify
fi

if $NotificationFilter ;then
    touch $MODPATH/system/etc/localization/NotificationFilter
fi

if $Music ;then
    touch $MODPATH/system/etc/localization/Music
fi

if $SoundRecorder ;then
    touch $MODPATH/system/etc/localization/SoundRecorder
fi

if $RemoveMod ;then
    touch $MODPATH/system/etc/localization/RemoveMod
fi

# Dependence Processing
if $Calendar || $VirtualSim || $Mms || $ContentExtension || $Weather || $PersonalAssistant || $ThemeManager || $AiAsst || $NotificationFilter || $Music || $SoundRecorder || $VoiceAssist || $MiuiIme || $AiAsst || $YellowPage ;then
    RemoveMod=true
fi

if $AiAsst ;then
    YellowPage=true
fi

if $RemoveMod ;then
    Calendar=true
    Contacts=true
    Weather=true
else
    Contacts=false
fi

if $PersonalAssistant || $ContentExtension ;then
    MiuiContentCatcher=true
else
    MiuiContentCatcher=false
fi
if $ContentExtension ;then
    CatcherPatch=true
else
    CatcherPatch=false
fi

ui_print ""
ui_print "- ${LANG_TEXT_INSTALLING}"

# File Processing
if ! $Fonts ;then
    rm -rf $MODPATH/system/fonts
else
    cp $MODPATH/system/fonts/MiLanProVF.ttf $MODPATH/system/fonts/MiSansVF.ttf 
fi

if ! $Mipay ;then
    rm -rf $MODPATH/system/product/app/MINextpay
    rm -rf $MODPATH/system/product/app/MITSMClient
    rm -rf $MODPATH/system/product/app/MipayService
    rm -rf $MODPATH/system/product/app/UPTsmService
fi

if ! $HybridPlatform ;then
    rm -rf $MODPATH/system/product/app/HybridAccessory
    rm -rf $MODPATH/system/product/app/HybridPlatform
fi

if ! $ContentExtension ;then
    rm -rf $MODPATH/system/product/priv-app/MIUIContentExtension
fi

if ! $PersonalAssistant ;then
    rm -rf $MODPATH/system/product/priv-app/PersonalAssistant
fi

if ! $Calendar ;then
    rm -rf $MODPATH/system/product/data-app/MIUICalendar
fi

if ! $SogouInput ;then
    rm -rf $MODPATH/system/product/app/SogouInput
fi

if ! $Mms ;then
    rm -rf $MODPATH/system/product/priv-app/Mms
fi

if ! $YellowPage ;then
    rm -rf $MODPATH/system/product/priv-app/MIUIYellowPage
fi

if ! $AiAsst ;then
    rm -rf $MODPATH/system/product/app/MIUIAiasstService
fi

if ! $VoiceAssist ;then
    rm -rf $MODPATH/system/product/app/AiAsstVision
    rm -rf $MODPATH/system/product/app/VoiceAssistAndroidT
    rm -rf $MODPATH/system/product/app/MIUIAiasstService
fi
if ! $VoiceTrigger ;then
    rm -rf $MODPATH/system/product/app/VoiceTrigger_*
    rm -rf $MODPATH/system/vendor/etc/XiaoAiNiZaiNa.uim
    rm -rf $MODPATH/system/vendor/etc/XiaoAiTongXue.uim
    rm -rf $MODPATH/system/vendor/lib/liblistensoundmodel2.so
    rm -rf $MODPATH/system/lib64/libmisys_jni.so
else
    mv $MODPATH/system/product/app/VoiceTrigger_$API $MODPATH/system/product/app/VoiceTrigger
    rm -rf $MODPATH/system/product/app/VoiceTrigger_*
fi

if ! $Weather ;then
    rm -rf $MODPATH/system/product/data-app/MIUIWeather
fi

if ! $ThemeManager ;then
    rm -rf $MODPATH/system/app/ThemeManager
fi

if ! $Music ;then
    rm -rf $MODPATH/system/product/data-app/MIUIMusicT
fi

if ! $SoundRecorder ;then
    rm -rf $MODPATH/system/app/MiuiAudioMonitor_*
else
    mv $MODPATH/system/app/MiuiAudioMonitor_$API $MODPATH/system/app/MiuiAudioMonitor
    rm -rf $MODPATH/system/app/MiuiAudioMonitor_*
fi

if ! $Contacts ;then
    rm -rf $MODPATH/system/priv-app/Contacts
fi

if ! $RemoveMod ;then
    rm -rf $MODPATH/system/vendor/camera
else
    mkdir -p $MODPATH/system/priv-app/CleanMaster
    touch $MODPATH/system/priv-app/CleanMaster/CleanMaster.apk
    mkdir -p $MODPATH/system/product/priv-app/CleanMaster
    touch $MODPATH/system/product/priv-app/CleanMaster/CleanMaster.apk
fi

if ! $MiuiContentCatcher ;then
    rm -rf $MODPATH/system/system_ext/app/MiuiContentCatcher
fi

if ! $ContentExtension ;then
    rm -rf $MODPATH/system/system_ext/app/CatcherPatch
fi

# Build Processing
echo "" >> $MODPATH/system.prop

if $Mipay ;then
    echo "ro.se.type=eSE,HCE,UICC" >> $MODPATH/system.prop
fi

if $Calendar ;then
    echo "ro.miui.mcc=9460" >> $MODPATH/system.prop
fi

if $AiAsst ;then
    echo "ro.vendor.audio.aiasst.support=true" >> $MODPATH/system.prop
fi

if $MiuiIme ;then
    echo "ro.miui.support_miui_ime_bottom=1" >> $MODPATH/system.prop
fi

if $VideocallBeautify ;then
    echo "persist.vendor.vcb.enable=true" >> $MODPATH/system.prop
    echo "persist.vendor.vcb.ability=true" >> $MODPATH/system.prop
fi

if $GboardTheme ;then
    echo "ro.com.google.ime.theme_dir=" >> $MODPATH/system.prop
    echo "ro.com.google.ime.theme_file=" >> $MODPATH/system.prop
fi

if $RemoveMod ;then
    echo "ro.product.mod_device=xiaomieu" >> $MODPATH/system.prop
    echo "ro.miui.region=CN" >> $MODPATH/system.prop
fi

echo "" >> $MODPATH/system.prop
echo "moe.minamigo.miuieulocalization=$MODVERSION" >> $MODPATH/system.prop

# Data Cleaning
if $ThemeManager ; then
    rm -rf /data/miui/cust_variant
fi

if $PersonalAssistant ;then
    if [ ! -e $MODDIR/system/etc/localization/PersonalAssistant ] ;then
        rm -rf /data/data/com.miui.personalassistant/*
    fi
else
    if [ -e $MODDIR/system/etc/localization/PersonalAssistant ] ;then
        rm -rf /data/data/com.miui.personalassistant/*
    fi
fi

if $Calendar ;then
    if [ ! -e $MODDIR/system/etc/localization/Calendar ] ;then
        rm -rf /data/data/com.android.calendar/*
    fi
else
    if [ -e $MODDIR/system/etc/localization/Calendar ] ;then
        rm -rf /data/data/com.android.calendar/*
    fi
fi

if $Mms ;then
    if [ ! -e $MODDIR/system/etc/localization/Mms ] ;then
        rm -rf /data/data/com.android.mms/*
    fi
else
    if [ -e $MODDIR/system/etc/localization/Mms ] ;then
        rm -rf /data/data/com.android.mms/*
    fi
fi

if $Weather ;then
    if [ ! -e $MODDIR/system/etc/localization/Weather ] ;then
        rm -rf /data/data/com.miui.weather/*
    fi
else
    if [ -e $MODDIR/system/etc/localization/Weather ] ;then
        rm -rf /data/data/com.miui.weather/*
    fi
fi

if $ThemeManager ;then
    if [ ! -e $MODDIR/system/etc/localization/ThemeManager ] ;then
        rm -rf /data/data/com.android.thememanager/*
    fi
else
    if [ -e $MODDIR/system/etc/localization/ThemeManager ] ;then
        rm -rf /data/data/com.android.thememanager/*
    fi
fi

if $Music ;then
    if [ ! -e $MODDIR/system/etc/localization/Music ] ;then
        rm -rf /data/data/com.miui.player/*
    fi
else
    if [ -e $MODDIR/system/etc/localization/Music ] ;then
        rm -rf /data/data/com.miui.player/*
    fi
fi

if $Contacts ;then
    if [ ! -e $MODDIR/system/etc/localization/Contacts ] ;then
        rm -rf /data/data/com.android.contacts/*
    fi
else
    if [ -e $MODDIR/system/etc/localization/Contacts ] ;then
        rm -rf /data/data/com.android.contacts/*
    fi
fi

# Cache Cleaning
mkdir -p $MODPATH/system/etc/localization/SystemVersion
touch $MODPATH/system/etc/localization/SystemVersion/$SYSTEM_VERSION
rm -rf /data/system/package_cache/*

ui_print ""
ui_print "- ${LANG_TEXT_INSTALLING_COMPLETED}"
ui_print "*******************************************"
ui_print "- ${LANG_TEXT_INSTALLING_SUCCESS}"
waiting 2
