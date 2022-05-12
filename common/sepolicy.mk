$(warning current build platform is $(PLATFORM_VERSION))
BOARD_SEPOLICY_DIRS += \
    device/khadas/common/sepolicy \
    device/khadas/common/sepolicy/aml_core

BOARD_SEPOLICY_DIRS += device/khadas/common/sepolicy/q
#add atv prop sepolicy
PRODUCT_PUBLIC_SEPOLICY_DIRS  += device/khadas/common/sepolicy/product/public
PRODUCT_PRIVATE_SEPOLICY_DIRS += device/khadas/common/sepolicy/product/private
