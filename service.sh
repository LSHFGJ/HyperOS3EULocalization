#!/system/bin/sh
MODDIR=${0%/*}

SYSTEM_VERSION=`getprop ro.system.build.version.incremental`

cache_clean() {
    if [ ! -f $MODDIR/system/etc/localization/SystemVersion/$SYSTEM_VERSION ] ;then
        rm -rf /data/system/package_cache/*
        rm -rf $MODDIR/system/etc/localization/SystemVersion/*
        mkdir -p $MODDIR/system/etc/localization/SystemVersion
        touch $MODDIR/system/etc/localization/SystemVersion/$SYSTEM_VERSION
    fi
}

cache_clean
