
# To prevent from including GMS twice in Google's internal source.
ifeq ($(wildcard vendor/unbundled_google),)
ifneq ($(BOARD_COMPILE_ATV), false)
PRODUCT_USE_PREBUILT_GTVS := yes
DONT_DEXPREOPT_PREBUILTS := true
endif
endif

ifneq ($(wildcard vendor/google_gtvs_gtv),)
ifneq ($(BOARD_COMPILE_ATV), false)
PRODUCT_USE_PREBUILT_GTVS_GTV := yes
endif
endif

ifneq ($(wildcard vendor/google_gtvs),)
ifneq ($(BOARD_COMPILE_ATV), false)
include vendor/amlogic/common/gms/google/gms.mk
include vendor/amlogic/common/gms/google/mainline_modules_atv.mk
endif
endif

ifeq ($(BOARD_COMPILE_ATV), false)
include device/khadas/common/mainline_modules_aosp.mk
endif
# Inherit from those products. Most specific first.
# Get the TTS language packs
$(call inherit-product-if-exists, external/svox/pico/lang/all_pico_languages.mk)


# Get IRDETO middleware framework.
ifeq ($(TARGET_BUILD_IRDETO), true)
$(call inherit-product-if-exists, vendor/irdeto/hal/irdeto.mk)
$(call inherit-product-if-exists, vendor/irdeto/irdeto-sdk/irdeto-sdk.mk)
endif

# Define the host tools and libs that are parts of the SDK.
ifneq ($(filter sdk win_sdk sdk_addon,$(MAKECMDGOALS)),)
-include sdk/build/product_sdk.mk
-include development/build/product_sdk.mk

PRODUCT_PACKAGES += \
    EmulatorSmokeTests
endif

# Net:
#   Vendors can use the platform-provided network configuration utilities (ip,
#   iptable, etc.) to configure the Linux networking stack, but these utilities
#   do not yet include a HIDL interface wrapper. This is a solution on
#   Android O.
PRODUCT_PACKAGES += \
    netutils-wrapper-1.0

ifneq ($(BOARD_COMPILE_ATV), false)
PRODUCT_PACKAGES += \
    PlayAutoInstallStub \
    LauncherCustomization

#No need a2dp sink now,remove it #
ifeq ($(BOARD_ENABLE_A2DP_SINK),true)
PRODUCT_PACKAGES += \
    BlueOverlay
PRODUCT_PRODUCT_PROPERTIES += persist.bluetooth.enablenewavrcp=false
endif

endif

ifneq ($(TARGET_BUILD_KERNEL_4_9), true)
ifneq ($(AB_OTA_UPDATER),true)
TARGET_RECOVERY_FSTAB := device/khadas/common/recovery/recovery_5.4.fstab
else
TARGET_RECOVERY_FSTAB := device/khadas/common/recovery/recovery_5.4_ab.fstab
endif
else
ifneq ($(AB_OTA_UPDATER),true)
TARGET_RECOVERY_FSTAB := device/khadas/common/recovery/recovery.fstab
else
TARGET_RECOVERY_FSTAB := device/khadas/common/recovery/recovery_4.9_ab.fstab
endif
endif

TARGET_RELEASETOOLS_EXTENSIONS := device/khadas/common/scripts
TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888
TARGET_RECOVERY_UI_LIB += libamlogic_ui librecovery_amlogic
TARGET_RECOVERY_UI_LIB += \
    libsystemcontrol_static \
    libcutils \
    libz \
    libjsoncpp \
    liblog \
    libenv_droid

ifneq ($(AB_OTA_UPDATER),true)
TARGET_RECOVERY_UPDATER_LIBS := libinstall_amlogic
TARGET_RECOVERY_UPDATER_EXTRA_LIBS += libsystemcontrol_static libfdt libtinyxml2
endif

PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=320

ifeq ($(TARGET_BUILD_LIVETV),true)
    USE_OEM_TV_APP := true
endif

$(call inherit-product, device/google/atv/products/atv_base.mk)

PRODUCT_PRODUCT_VNDK_VERSION := current

# Put en_US first in the list, so make it default.
PRODUCT_LOCALES := en_US

AMLOGIC_PRODUCT := true

# If want kernel build with KASAN, set it to true
ENABLE_KASAN := false

# PPPoE Feature
ifeq ($(BUILD_WITH_PPPOE),true)
PRODUCT_PACKAGES += \
    PPPoE \
    libpppoejni \
    libpppoe \
    pppoe_wrapper \
    pppoe \
    droidlogic.frameworks.pppoe \
    droidlogic.external.pppoe \
    droidlogic.software.pppoe.xml
PRODUCT_PROPERTY_OVERRIDES += \
   ro.vendor.platform.has.pppoe=true
endif

PRODUCT_PACKAGES += \
    gsi_tool \
    gsid \
    android.hardware.weaver@1.0

#Get some property
$(call inherit-product, device/khadas/common/product_property.mk)

PRODUCT_PACKAGES += \
    libfdt \
    libufdt\
    ExoPlayer

PRODUCT_HOST_PACKAGES += \
    dtc \
    mkdtimg \
    imgdiff

PRODUCT_SUPPORTS_CAMERA := true

#default hardware composer version is 2.0
TARGET_USES_HWC2 := true

ifneq ($(wildcard $(BOARD_AML_VENDOR_PATH)/frameworks/av/LibPlayer),)
    WITH_LIBPLAYER_MODULE := true
else
    WITH_LIBPLAYER_MODULE := false
endif

$(warning BOARD_COMPILE_ATV is $(BOARD_COMPILE_ATV))
ifeq ($(BOARD_COMPILE_ATV), false)
PRODUCT_PACKAGES += \
    WifiOverlay \
    AppInstaller \
    FileBrowser \
    RemoteIME \
    NativeImagePlayer \
    imageserver \
    MboxLauncher \
    DLNA \
    BluetoothRemote \
    Gallery2 \
    MusicFX \
    Music \
    webview \
    Browser2 \
    DeskClock \
    FileBrower \
    SystemUIOverlay

#add camera app
PRODUCT_PACKAGES += Camera2
endif

PRODUCT_PACKAGES += \
    Bluetooth \
    DroidOverlay \
    PrintSpooler \
    SubTitle

ifeq ($(AB_OTA_UPDATER),true)
    PRODUCT_PACKAGES += \
        ABUpdater
else
    PRODUCT_PACKAGES += \
        OTAUpgrade
endif

PRODUCT_PACKAGES += \
    TetheringOverlay \
    InProcessTetheringOverlay

ifeq ($(TARGET_BUILD_LIVETV), true)
    PRODUCT_PACKAGES += \
        libjnidtvepgscanner

    ifeq ($(TARGET_LIVETV_BUILT_FROM_SOURCE), true)
        PRODUCT_PACKAGES += \
            LiveTv \
            libtunertvinput_jni
    else
        PRODUCT_PACKAGES += \
            DroidLogicLiveTv
    endif
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.platform.build.livetv=true
endif

PRODUCT_PACKAGES += \
    droidlogic \
    droidlogic-res \
    droidlogic.software.core.xml \
    systemcontrol \
    systemcontrol_static \
    libsystemcontrolservice \
    vendor.amlogic.hardware.systemcontrol@1.0

#subtitle related
PRODUCT_PACKAGES += \
    subtitleserver \
    libSubtitleClient \
    libsubtitlebinder \
    vendor.amlogic.hardware.subtitleserver@1.0 \
    libsubtitlemanager_jni \
    libsubtitlemanagerproduct_jni

#add tv library
PRODUCT_PACKAGES += \
    droidlogic-tv \
    droidlogic.tv.software.core.xml \
    libtv_jni

PRODUCT_PACKAGES += \
    pppd \
    hostapd \
    wpa_supplicant \
    wpa_supplicant.conf \
    dhcpcd.conf \
    libds_jni \
    libsrec_jni \
    system_key_server \
    libwpa_client \
    network \
    sdptool \
    e2fsck \
    mkfs.exfat \
    mount.exfat \
    fsck.exfat \
    ntfs-3g \
    ntfsfix \
    mkntfs \
    libxml2

#add camera feature
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.external.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.external.xml

#add BluetoothMidiService
PRODUCT_PACKAGES += \
    BluetoothMidiService

#amlogic HALs
PRODUCT_PACKAGES += \
    libGLES_meson_mali \
    libamgralloc_ext \
    gralloc.amlogic \
    hwcomposer.amlogic \
    memtrack.amlogic \
    screen_source.amlogic

#glscaler and 3d format api
PRODUCT_PACKAGES += \
    libdisplaysetting

#native image player surface overlay so
PRODUCT_PACKAGES += \
    libsurfaceoverlay_jni

PRODUCT_PACKAGES += \
    libOmxCore \
    libOmxVideo \
    libOmxAudio \
    libHwAudio_dcvdec \
    libHwAudio_dtshd  \
    libthreadworker_alt \
    libdatachunkqueue_alt \
    libOmxBase \
    libomx_av_core_alt \
    libomx_framework_alt \
    libomx_worker_peer_alt \
    libfpscalculator_alt \
    libomx_clock_utils_alt \
    libomx_timed_task_queue_alt \
    libstagefrighthw

ifeq ($(BOARD_COMPILE_CTS),true)
PRODUCT_PACKAGES += \
    libsecmem \
    libsecmem_sys \
    secmem \
    2c1a33c0-44cc-11e5-bc3b-0002a5d5c51b
endif

# Dm-verity
ifeq ($(BUILD_WITH_DM_VERITY), true)
    PRODUCT_SYSTEM_VERITY_PARTITION = /dev/block/system
    PRODUCT_VENDOR_VERITY_PARTITION = /dev/block/vendor

    # Provides dependencies necessary for verified boot
    PRODUCT_SUPPORTS_BOOT_SIGNER := true
    PRODUCT_SUPPORTS_VERITY := true
    PRODUCT_SUPPORTS_VERITY_FEC := true

    # The dev key is used to sign boot and recovery images, and the verity
    # metadata table. Actual product deliverables will be re-signed by hand.
    # We expect this file to exist with the suffixes ".x509.pem" and ".pk8".
    PRODUCT_VERITY_SIGNING_KEY := device/khadas/common/security/verity

    ifneq ($(TARGET_USE_SECURITY_DM_VERITY_MODE_WITH_TOOL),true)
        PRODUCT_PACKAGES += \
            verity_key.amlogic
    endif
endif

#Bluetooth idc config file
PRODUCT_COPY_FILES += \
    device/khadas/common/keyboards/Vendor_1d5a_Product_c082.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/Vendor_1d5a_Product_c082.idc \
    device/khadas/common/keyboards/Vendor_7545_Product_0180.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/Vendor_7545_Product_0180.idc \
    device/khadas/common/keyboards/Vendor_0508_Product_0110.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/Vendor_0508_Product_0110.idc \
    device/khadas/common/keyboards/Vendor_18d1_Product_0100.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/Vendor_18d1_Product_0100.idc
#########################################################################
#
#                                                App optimization
#
#########################################################################
ifeq ($(BUILD_WITH_APP_OPTIMIZATION),true)

PRODUCT_COPY_FILES += \
    device/khadas/common/optimization/liboptimization_32.so:$(TARGET_COPY_OUT_VENDOR)/lib/liboptimization.so \
    device/khadas/common/optimization/config:$(TARGET_COPY_OUT_VENDOR)/package_config/config

PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.app.optimization=true

ifeq ($(ANDROID_BUILD_TYPE), 64)
PRODUCT_COPY_FILES += \
    device/khadas/common/optimization/liboptimization_64.so:$(TARGET_COPY_OUT_VENDOR)/lib64/liboptimization.so
endif
endif

#######################################################################
#
#                     metadata encryption
#
#######################################################################
ifneq ($(TARGET_BUILD_KERNEL_4_9),true)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.crypto.volume.metadata.method=dm-default-key \
    ro.crypto.dm_default_key.options_format.version=2 \
    ro.crypto.volume.options=::v2 \
    ro.crypto.state=encrypted
endif

#########################################################################
#
#                                                Secure OS
#
#########################################################################
ifeq ($(TARGET_USE_OPTEEOS),true)
PRODUCT_PACKAGES += \
	tee-supplicant \
	libteec \
	tee_helloworld \
	tee_crypto \
	tee_xtest \
	tdk_auto_test \
	tee_helloworld_ta \
	tee_fail_test_ta \
	tee_crypt_ta \
	tee_os_test_ta \
	tee_rpc_test_ta \
	tee_sims_ta \
	tee_storage_ta \
	tee_storage2_ta \
	tee_storage_benchmark_ta \
	tee_aes_perf_ta \
	tee_sha_perf_ta \
	tee_sdp_basic_ta \
	tee_concurrent_ta \
	tee_concurrent_large_ta \
	tee_stest \
	tee_provision \
	tee_key_inject \
	libprovision \
	tee_provision_ta \
	tee_hdcp \
	tee_hdcp_ta \
	tee_ciplus_ta

endif

#########################################################################
#
#                                     hardware interfaces
#
#########################################################################
PRODUCT_PACKAGES += \
     libwifi-hal-aml \
     android.hardware.wifi@1.0-service.droidlogic \
     android.hardware.usb@1.0-service

# healthd hal 2.1
PRODUCT_PACKAGES += android.hardware.health@2.1-service.droidlogic

#Audio HAL
PRODUCT_PACKAGES += \
     android.hardware.audio@5.0-impl:32 \
     android.hardware.audio@4.0-impl:32 \
     android.hardware.audio.effect@5.0-impl:32 \
     android.hardware.audio.effect@4.0-impl:32 \
     android.hardware.audio@2.0-impl:32 \
     android.hardware.audio.effect@2.0-impl:32 \
     android.hardware.audio@2.0-service-droidlogic

ifneq ($(TARGET_BUILD_KERNEL_4_9),true)
PRODUCT_PACKAGES += \
    android.hardware.audio@6.0-impl:32 \
    android.hardware.audio.effect@6.0-impl:32
endif

#Camera HAL
PRODUCT_PACKAGES += \
     camera.amlogic \
     android.hardware.camera.provider@2.5-legacy \
     android.hardware.camera.provider@2.5-service

#Power HAL
PRODUCT_PACKAGES += \
    android.hardware.power.aidl-service.droidlogic

#Memtack HAL
PRODUCT_PACKAGES += \
     android.hardware.memtrack@1.0-impl \
     android.hardware.memtrack@1.0-service

# Gralloc HAL
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@4.0-impl-arm \
    android.hardware.graphics.allocator@4.0-impl-arm \
    android.hardware.graphics.allocator@4.0-service

# HW Composer
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.4-service.droidlogic

# dumpstate binderized
PRODUCT_PACKAGES += \
    android.hardware.dumpstate@1.1-service.droidlogic

# Keymaster HAL
ifeq ($(TARGET_USE_HW_KEYMASTER),true)
PRODUCT_PACKAGES += \
    android.hardware.keymaster@4.1-service.amlogic
else
PRODUCT_PACKAGES += \
    android.hardware.keymaster@4.0-impl \
    android.hardware.keymaster@4.0-service
endif

# new gatekeeper HAL
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-service.software

#DRM HAL
ifeq ($(TARGET_BUILD_KERNEL_4_9),true)
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service
endif

PRODUCT_PACKAGES += \
    android.hardware.drm@1.3-service.widevine \
    android.hardware.drm@1.3-service.clearkey \
    move_widevine_data.sh \
    android.hardware.drm@1.3-service.playready

# HDMITX CEC HAL
PRODUCT_PACKAGES += \
    android.hardware.tv.cec@1.0-impl \
    android.hardware.tv.cec@1.0-service \
    hdmicecd \
    libhdmicec \
    libhdmicec_jni \
    vendor.amlogic.hardware.hdmicec@1.0 \
    hdmi_cec.amlogic

#Android new device will use AIDL to instead of HIDL
ifeq ($(BOARD_ENABLE_LIGHT_CONTROL),true)
    PRODUCT_PACKAGES += \
        lights
endif

#usb gadget hal
PRODUCT_PACKAGES += \
    android.hardware.usb.gadget@1.1-service.droidlogic

#thermal hal
PRODUCT_PACKAGES += \
    android.hardware.thermal@2.0-service.droidlogic

#normally, every device need a config file, currently all chips are the same
PRODUCT_COPY_FILES += \
    device/khadas/common/thermal_info_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config.json

#PRODUCT_PACKAGES += \
#    android.hardware.cas@1.2-service

#bt audio hal
PRODUCT_PACKAGES += \
    android.hardware.bluetooth.audio@2.0-impl \
    android.hardware.bluetooth.audio@2.0-service

#bufferhub hal
PRODUCT_PACKAGES += \
    android.frameworks.bufferhub@1.0-impl \
    android.frameworks.bufferhub@1.0-service

#Atrace HAL
PRODUCT_PACKAGES += \
     android.hardware.atrace@1.0-service

#oemlock HAL
PRODUCT_PACKAGES += \
    android.hardware.oemlock@1.0-service.droidlogic

ifeq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.oem_unlock_supported = 0
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.oem_unlock_supported = 1
endif

#all product need this prop when play pvr file
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.tv.dtv.fake_pid = 0x1ffc

PRODUCT_PACKAGES += \
    fastbootd \
    android.hardware.fastboot@1.0 \
    android.hardware.fastboot@1.0-impl-amlogic

PRODUCT_COPY_FILES += \
    device/khadas/common/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml

ifeq ($(USE_XML_AUDIO_POLICY_CONF), 1)
PRODUCT_COPY_FILES += \
    device/khadas/common/audio/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml
endif

PRODUCT_COPY_FILES += \
    device/khadas/common/permissions/droidlogic-hiddenapi-whitelist.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/droidlogic-hiddenapi-package-whitelist.xml

ifneq ($(TARGET_BUILD_KERNEL_4_9),true)
PRODUCT_COPY_FILES += \
    device/khadas/common/initscripts/fs_5.4.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/fs.rc \
    device/khadas/common/initscripts/power_5.4.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/power.rc \
    device/khadas/common/powerhint5.4.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

else
PRODUCT_COPY_FILES += \
    device/khadas/common/initscripts/fs.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/fs.rc \
    device/khadas/common/initscripts/power.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/power.rc \
    device/khadas/common/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json
endif

PRODUCT_COPY_FILES += \
    device/khadas/common/initscripts/ueventd.amlogic.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc \
    device/khadas/common/initscripts/fs.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/fs.rc \
    device/khadas/common/initscripts/bluetooth.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/bluetooth.rc \
    device/khadas/common/initscripts/sysfs_permissions.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/sysfs_permissions.rc \
    device/khadas/common/initscripts/init.amlogic.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.amlogic.usb.rc

PRODUCT_COPY_FILES += \
    device/khadas/common/android.software.cant_save_state.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.cant_save_state.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.gamepad.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.gamepad.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml

ifeq ($(TARGET_BUILD_NETFLIX), true)
PRODUCT_COPY_FILES += \
	device/khadas/common/droidlogic.software.netflix.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/droidlogic.software.netflix.xml
endif

ifeq ($(BOARD_AVB_ENABLE), true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml
endif

ifneq ($(TARGET_BUILD_KERNEL_4_9),true)
#Factory Reset Protection
PRODUCT_PROPERTY_OVERRIDES += \
    ro.frp.pst=/dev/block/by-name/frp

#add project id and casefold attribute for data partition and external storage
#PRODUCT_QUOTA_PROJID := 1
#PRODUCT_VENDOR_PROPERTIES += external_storage.projid.enabled=true
PRODUCT_PROPERTY_OVERRIDES += \
    external_storage.projid.enabled=true \
    external_storage.casefold.enabled=true
endif

#########################################################################
#
#                    AB UPDATE
#
#########################################################################
ifeq ($(AB_OTA_UPDATER),true)
AB_OTA_PARTITIONS := \
    boot \
    system \
    vendor \
    vbmeta \
    odm \
    dtbo \
    product \
    bootloader

ifeq ($(BOARD_USES_ODM_EXTIMAGE), true)
AB_OTA_PARTITIONS += \
    odm_ext
endif

ifeq ($(BOARD_USES_DYNAMIC_FINGERPRINT),true)
AB_OTA_PARTITIONS += \
    oem
endif

ifeq ($(BOARD_USES_VBMETA_SYSTEM),true)
AB_OTA_PARTITIONS += \
    vbmeta_system
endif

ifeq ($(UPDATE_INC),false)
AB_OTA_PARTITIONS += \
    dt
PRODUCT_COPY_FILES += \
    device/khadas/common/initscripts/ab_link_dt.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/ab_link_dt.rc
endif

TARGET_BOOTLOADER_CONTROL_BLOCK := true

ifeq ($(TARGET_BUILD_KERNEL_4_9),true)
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 25165824
TARGET_NO_RECOVERY := false
AB_OTA_PARTITIONS += recovery
else
AB_OTA_PARTITIONS += system_ext
ifeq ($(BUILDING_VENDOR_BOOT_IMAGE),true)
AB_OTA_PARTITIONS += vendor_boot
TARGET_NO_RECOVERY := true
BOARD_USES_RECOVERY_AS_BOOT := true
else
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
TARGET_NO_RECOVERY := false
AB_OTA_PARTITIONS += recovery
endif
endif

else
TARGET_NO_RECOVERY := false

BOARD_CACHEIMAGE_PARTITION_SIZE := 69206016
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
ifeq ($(TARGET_BUILD_KERNEL_4_9),true)
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 25165824
else
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
endif
endif

ifeq ($(AB_OTA_UPDATER),true)
PRODUCT_PACKAGES += \
    android.hardware.boot@1.1-impl.droidlogic.recovery \
    android.hardware.boot@1.1-impl.droidlogic

PRODUCT_PACKAGES += \
    libsnapshot \
    libsnapshot_init \
    libsnapshot_nobinder \
    snapshotctl \
    libupdate_engine_boot_control

PRODUCT_HOST_PACKAGES += \
    delta_generator \
    brillo_update_payload

PRODUCT_PACKAGES += \
    update_engine \
    update_engine_client \
    update_verifier \
    android.hardware.boot@1.1 \
    android.hardware.boot@1.1-impl.droidlogic \
    android.hardware.boot@1.1-service.droidlogic

PRODUCT_PACKAGES += \
    update_engine_sideload \
    otacerts.recovery

endif

################# add for FFM ####################
ifeq ($(BOARD_HAS_MIC_TOGGLE), true)
PRODUCT_PACKAGES += \
    MicToggleProvider
endif
PRODUCT_PACKAGES += \
    MtpService
#########################################################################
