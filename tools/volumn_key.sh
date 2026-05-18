#!/system/bin/sh

ui_print "[Volume key check]"
case "$ZIPFILE" in
    *novk*) ui_print "Volume-key detection disabled."; exit 1;;
esac
ui_print "Using default volume-key configuration."
