$(warning current build platform is $(PLATFORM_VERSION))
BOARD_SEPOLICY_DIRS += \
    device/amlogic/common/sepolicy \
    device/amlogic/common/sepolicy/aml_core

BOARD_SEPOLICY_DIRS += device/amlogic/common/sepolicy/q
#add atv prop sepolicy
PRODUCT_PUBLIC_SEPOLICY_DIRS  += device/amlogic/common/sepolicy/product/public
PRODUCT_PRIVATE_SEPOLICY_DIRS += device/amlogic/common/sepolicy/product/private
