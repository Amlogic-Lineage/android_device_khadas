PRODUCT_HAS_NETFLIX_PACKAGE := true
TARGET_BUILD_NETFLIX_MGKID  := true

# For NTS certification
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.nrdp.validation=ninja_8 \
    vendor.system.always.dolbyvision=true  \
    persist.vendor.sys.framerate.priority=true \
    ro.vendor.nrdp.modelgroup=$(TARGET_BUILD_NETFLIX_MODELGROUP)

PRODUCT_PACKAGES += \
    Netflix

PRODUCT_PROPERTY_OVERRIDES += \
   ro.vendor.hailstorm.version=4.2.0


PRODUCT_COPY_FILES += \
    device/amlogic/common/netflix/etc/netflix.xml:system/etc/sysconfig/netflix.xml \
    device/amlogic/common/netflix/etc/nrdp.xml:vendor/etc/permissions/nrdp.xml \
    device/amlogic/common/netflix/etc/nrdp_audio_platform_capabilities_ms12.json:vendor/etc/nrdp_audio_platform_capabilities_ms12.json \
    device/amlogic/common/netflix/etc/nrdp_audio_platform_capabilities.json:vendor/etc/nrdp_audio_platform_capabilities.json


ifeq ($(TARGET_WITH_VP9_NETFLIX), true)
PRODUCT_COPY_FILES += \
    device/amlogic/common/netflix/etc/nrdp_platform_capabilities_vp9.json:vendor/etc/nrdp_platform_capabilities.json
else ifeq ($(TARGET_WITH_HDR_PLAYBACK), true)
PRODUCT_COPY_FILES += \
    device/amlogic/common/netflix/etc/nrdp_platform_capabilities_hdr_playback.json:vendor/etc/nrdp_platform_capabilities.json
else
PRODUCT_COPY_FILES += \
    device/amlogic/common/netflix/etc/nrdp_platform_capabilities.json:vendor/etc/nrdp_platform_capabilities.json
endif

