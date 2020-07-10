#!/system/bin/sh

MARK=/data/local/symbol_thirdpart_apks_installed
PKGS=/system/preinstall/

if [ ! -e $MARK ]; then
echo "booting the first time, so pre-install some APKs."

find $PKGS -name "*\.apk" -exec sh /system/bin/pm install {} \;

# NO NEED to delete these APKs since we keep a mark under data partition.
# And the mark will be wiped out after doing factory reset, so you can install
# these APKs again if files are still there.
# busybox rm -rf $PKGS

touch $MARK
echo "OK, installation complete."
fi
