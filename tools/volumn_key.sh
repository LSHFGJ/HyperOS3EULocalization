chooseport() {
  # Original idea by chainfire @xda-developers, improved on by ianmacd @xda-developers
  # note from chainfire @xda-developers: getevent behaves weird when piped through Android grep variants
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events
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
ui_print "                                           "
ui_print "*******************************************"
ui_print "  音量键测试"
ui_print "*******************************************"
OIFS=$IFS; IFS=\|; MID=false; NEW=false
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
  *novk*) ui_print "- 未检测到音量键，跳过。"; exit 1;;
  *) 
    ui_print "- 将使用默认音量键配置。"
    VKSEL=chooseport
    ;;
esac
IFS=$OIFS
ui_print "*******************************************"
