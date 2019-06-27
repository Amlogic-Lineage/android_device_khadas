ifeq ($(TARGET_BUILD_CTS), true)

#ADDITIONAL_DEFAULT_PROPERTIES += ro.vold.forceencryption=1
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.screen.landscape.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.landscape.xml \
    frameworks/native/data/etc/android.software.cts.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.cts.xml \
    frameworks/native/data/etc/android.software.voice_recognizers.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.voice_recognizers.xml

ifeq ($(TARGET_BUILD_GOOGLE_ATV), true)
PRODUCT_COPY_FILES += \
    device/khadas/common/android.software.google_atv.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.google_atv.xml
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.live_tv.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.software.live_tv.xml
PRODUCT_PACKAGE_OVERLAYS += device/khadas/common/atv_gms_overlay
PRODUCT_PACKAGES += \
    TvProvider \
    GooglePackageInstaller \
    com.android.media.tv.remoteprovider.xml \
    com.android.media.tv.remoteprovider
$(call add-clean-step, rm -rf $(OUT_DIR)/vendor/etc/permissions/android.hardware.camera.front.xml)
$(call add-clean-step, rm -rf $(OUT_DIR)/vendor/priv-app/DLNA)

else
#PRODUCT_PACKAGE_OVERLAYS += device/khadas/common/aosp_gms_overlay
#PRODUCT_PACKAGES += \
#    QuickSearchBox \
#    Contacts \
#    Calendar \
#    BlockedNumberProvider \
#    BookmarkProvider \
#    MtpDocumentsProvider \
#    DownloadProviderUi
endif

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.app.rotation=original \
    media.amplayer.widevineenable=true

#WITH_DEXPREOPT := true
#WITH_DEXPREOPT_PIC := true

PRODUCT_PACKAGES += \
    Bluetooth \
    PrintSpooler

else
PRODUCT_PACKAGES += \
    libfwdlockengine

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.app.rotation=middle_port

endif

ifneq ($(TARGET_BUILD_GOOGLE_ATV), true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.device_admin.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_admin.xml
PRODUCT_PACKAGES += \
    ManagedProvisioning
endif

ifeq ($(TARGET_BUILD_NETFLIX), true)
PRODUCT_COPY_FILES += \
	device/khadas/common/droidlogic.software.netflix.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/droidlogic.software.netflix.xml

endif

ifeq ($(BOARD_AVB_ENABLE), true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml
endif


PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/tablet_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tablet_core_hardware.xml \
    frameworks/native/data/etc/android.software.freeform_window_management.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.freeform_window_management.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.software.sip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.xml \
    frameworks/native/data/etc/android.software.picture_in_picture.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.picture_in_picture.xml \
    frameworks/native/data/etc/android.hardware.screen.portrait.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.screen.portrait.xml \
    frameworks/native/data/etc/android.hardware.location.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.hdmi.cec.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.hdmi.cec.xml \
    frameworks/native/data/etc/android.hardware.camera.external.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.external.xml \
    frameworks/native/data/etc/android.hardware.gamepad.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.gamepad.xml

$(call inherit-product-if-exists, external/hyphenation-patterns/patterns.mk)
