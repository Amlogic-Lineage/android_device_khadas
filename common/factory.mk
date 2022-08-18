include device/khadas/common/odm_ext.mk


IMGPACK := $(BUILD_OUT_EXECUTABLES)/logo_img_packer$(BUILD_EXECUTABLE_SUFFIX)
PRODUCT_UPGRADE_OUT := $(PRODUCT_OUT)/upgrade
PRODUCT_COMMON_DIR := device/khadas/common/products/$(PRODUCT_TYPE)
AML_UPGRADE_TOOL_DIR := $(BOARD_AML_VENDOR_PATH)/tools/aml_upgrade
AML_PKG_ADD_USB_BIN := $(AML_UPGRADE_TOOL_DIR)/aml_pkg_add_usb_bin.app
AML_IMG_PKG_TOOL	:= $(AML_UPGRADE_TOOL_DIR)/aml_image_v2_packer

#$(warning Build dtbo image here, make sure BOARD_PREBUILT_DTBOIMAGE is defined before this warning)

ifeq ($(TARGET_NO_RECOVERY),true)
BUILT_IMAGES := boot.img
else
BUILT_IMAGES := boot.img recovery.img
endif

ifeq ($(BUILDING_VENDOR_BOOT_IMAGE),true)
BUILT_IMAGES += vendor_boot.img
endif

VB_CHECK_IMAGES := vbmeta.img boot.img
VB_CHECK_IMAGES += vendor.img system.img product.img dtbo.img
ifneq ($(TARGET_NO_RECOVERY),true)
VB_CHECK_IMAGES += recovery.img
endif

ifeq ($(BUILDING_VENDOR_BOOT_IMAGE),true)
VB_CHECK_IMAGES += vendor_boot.img
endif

ifeq ($(BOARD_USES_ODMIMAGE),true)
VB_CHECK_IMAGES += odm.img
endif

ifeq ($(BUILDING_SYSTEM_EXT_IMAGE),true)
VB_CHECK_IMAGES += system_ext.img
endif

ifeq ($(BOARD_USES_VBMETA_SYSTEM),true)
VB_CHECK_IMAGES += vbmeta_system.img
endif

ifdef BOARD_PREBUILT_DTBOIMAGE
BUILT_IMAGES += dtbo.img
endif

ifneq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
BUILT_IMAGES += system.img

BUILT_IMAGES += vendor.img

ifeq ($(BOARD_USES_ODMIMAGE),true)
BUILT_IMAGES += odm.img
endif

ifeq ($(BOARD_USES_PRODUCTIMAGE),true)
BUILT_IMAGES += product.img
endif

ifeq ($(BOARD_USES_SYSTEM_OTHER_ODEX),true)
BUILT_IMAGES += system_other.img
endif
endif

ifeq ($(BUILD_WITH_AVB),true)
BUILT_IMAGES += vbmeta.img
endif

ifeq ($(BOARD_USES_ODM_EXTIMAGE), true)
BUILT_IMAGES += odm_ext.img
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/odm_ext.img $(PRODUCT_OUT)/odm_ext.map
BOARD_PACK_RADIOIMAGES += odm_ext.img odm_ext.map
endif

ifeq ($(BOARD_USES_DYNAMIC_FINGERPRINT),true)
BUILT_IMAGES += oem.img
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/oem.img
BOARD_PACK_RADIOIMAGES += oem.img
VB_CHECK_IMAGES += oem.img
endif

ifeq ($(BOARD_USES_VBMETA_SYSTEM),true)
BUILT_IMAGES += vbmeta_system.img
endif

ifeq ($(strip $(HAS_BUILD_NUMBER)),false)
  # BUILD_NUMBER has a timestamp in it, which means that
  # it will change every time.  Pick a stable value.
  FILE_NAME := eng.$(BUILD_USERNAME)
else
  FILE_NAME := $(file <$(BUILD_NUMBER_FILE))
endif

name_aml := $(TARGET_PRODUCT)
ifeq ($(TARGET_BUILD_TYPE),debug)
  name_aml := $(name_aml)_debug
endif

INTERNAL_OTA_PACKAGE_TARGET := $(PRODUCT_OUT)/$(name_aml)-ota-$(FILE_NAME_TAG).zip

AML_TARGET := $(PRODUCT_OUT)/obj/PACKAGING/target_files_intermediates/$(name_aml)-target_files-$(FILE_NAME)

AML_TARGET_ZIP := $(PRODUCT_OUT)/super_empty_all.img

ifeq ($(BUILD_WITH_AVB),true)
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += \
    --include_descriptors_from_image $(INSTALLED_BOARDDTB_TARGET)

# Add a dependency of AVBTOOL to INSTALLED_BOARDDTB_TARGET
$(INSTALLED_BOARDDTB_TARGET): $(AVBTOOL)

# Add a dependency of dtb.img to vbmeta.img
$(INSTALLED_VBMETAIMAGE_TARGET): $(INSTALLED_BOARDDTB_TARGET)
vbmetaimage: $(INSTALLED_BOARDDTB_TARGET)
endif


# Adds to <product name>-img-<build number>.zip so can be flashed.  b/110831381
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/dt.img
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/bootloader.img
BOARD_PACK_RADIOIMAGES += dt.img bootloader.img
$(warning echo "radio add dt and bootloader")

INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/super_empty_all.img
BOARD_PACK_RADIOIMAGES += super_empty_all.img

ifeq ($(TARGET_UPDATE_IDATTESTATION),true)
INSTALLED_RADIOIMAGE_TARGET += device/khadas/common/id_attestation.xml
BOARD_PACK_RADIOIMAGES += id_attestation.xml
endif

BOARD_PACK_RADIOIMAGES += $(filter system.img vendor.img,$(BUILT_IMAGES))

UPGRADE_FILES := \
        aml_sdc_burn.ini \
        u-boot.bin.sd.bin  u-boot.bin.usb.bl2 u-boot.bin.usb.tpl \
        u-boot.bin.sd.bin.signed  u-boot.bin.usb.signed

TOOL_ITEMS := usb_flow.aml keys.conf
UPGRADE_FILES += $(TOOL_ITEMS)

ifneq ($(TARGET_USE_SECURITY_MODE),true)
UPGRADE_FILES += \
        platform.conf
else # secureboot mode
UPGRADE_FILES += \
        u-boot-usb.bin.aml \
        platform_enc.conf
endif

UPGRADE_FILES := $(addprefix $(TARGET_DEVICE_DIR)/upgrade/,$(UPGRADE_FILES))
UPGRADE_FILES := $(wildcard $(UPGRADE_FILES)) #extract only existing files for burnning

PACKAGE_CONFIG_FILE := aml_upgrade_package

ifeq ($(AB_OTA_UPDATER),true)
ifneq ($(BUILDING_VENDOR_BOOT_IMAGE),true)
PACKAGE_CONFIG_FILE := $(PACKAGE_CONFIG_FILE)_AB_only
else
PACKAGE_CONFIG_FILE := $(PACKAGE_CONFIG_FILE)_AB_vendor_boot
endif
endif

PACKAGE_CONFIG_FILE := $(TARGET_DEVICE_DIR)/upgrade/$(PACKAGE_CONFIG_FILE).conf

ifeq ($(PRODUCT_GOOGLEREF_SECURE_BOOT),true)
ifeq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
PACKAGE_CONFIG_FILE := $(TARGET_DEVICE_DIR)/upgrade/aml_upgrade_package_enc_avb_dynamic.conf
else
PACKAGE_CONFIG_FILE := $(TARGET_DEVICE_DIR)/upgrade/aml_upgrade_package_enc_avb.conf
endif
endif

ifeq ($(wildcard $(PACKAGE_CONFIG_FILE)),)
	PACKAGE_CONFIG_FILE := $(PRODUCT_COMMON_DIR)/upgrade_4.9/$(notdir $(PACKAGE_CONFIG_FILE))
endif ## ifeq ($(wildcard $(TARGET_DEVICE_DIR)/upgrade/$(PACKAGE_CONFIG_FILE)))
UPGRADE_FILES += $(PACKAGE_CONFIG_FILE)

ifneq ($(TARGET_AMLOGIC_RES_PACKAGE),)
INSTALLED_AML_LOGO := $(PRODUCT_UPGRADE_OUT)/logo.img
$(INSTALLED_AML_LOGO): $(wildcard $(TARGET_AMLOGIC_RES_PACKAGE)/*) | $(IMGPACK) $(MINIGZIP)
	@echo "generate $(INSTALLED_AML_LOGO)"
	$(hide) mkdir -p $(PRODUCT_UPGRADE_OUT)/logo
	$(hide) rm -rf $(PRODUCT_UPGRADE_OUT)/logo/*
	@cp -rf $(TARGET_AMLOGIC_RES_PACKAGE)/* $(PRODUCT_UPGRADE_OUT)/logo
	$(foreach bmpf, $(filter %.bmp,$^), \
		if [ -n "$(shell find $(bmpf) -type f -size +256k)" ]; then \
			echo "logo pic $(bmpf) >256k gziped"; \
			$(MINIGZIP) -c $(bmpf) > $(PRODUCT_UPGRADE_OUT)/logo/$(notdir $(bmpf)); \
		else cp $(bmpf) $(PRODUCT_UPGRADE_OUT)/logo; \
		fi;)
	$(hide) $(IMGPACK) -r $(PRODUCT_UPGRADE_OUT)/logo $@
	@echo "Installed $@"
# Adds to <product name>-img-<build number>.zip so can be flashed.  b/110831381
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_UPGRADE_OUT)/logo.img
BOARD_PACK_RADIOIMAGES += logo.img

else
INSTALLED_AML_LOGO :=
endif

.PHONY: logoimg
logoimg: $(INSTALLED_AML_LOGO)

BOARD_AUTO_COLLECT_MANIFEST := false
ifneq ($(BOARD_AUTO_COLLECT_MANIFEST),false)
BUILD_TIME := $(shell date +%Y-%m-%d--%H-%M)
INSTALLED_MANIFEST_XML := $(PRODUCT_OUT)/manifests/manifest-$(BUILD_TIME).xml
$(INSTALLED_MANIFEST_XML):
	$(hide) mkdir -p $(PRODUCT_OUT)/manifests
	$(hide) mkdir -p $(PRODUCT_OUT)/upgrade
	# Below fails on google build servers, perhaps because of older version of repo installed
	repo manifest -r -o $(INSTALLED_MANIFEST_XML)
	$(hide) cp $(INSTALLED_MANIFEST_XML) $(PRODUCT_OUT)/upgrade/manifest.xml

.PHONY:build_manifest
build_manifest:$(INSTALLED_MANIFEST_XML)
else
INSTALLED_MANIFEST_XML :=
endif

INSTALLED_AML_USER_IMAGES :=
ifeq ($(TARGET_BUILD_USER_PARTS),true)
define aml-mk-user-img-template
INSTALLED_AML_USER_IMAGES += $(2)
$(eval tempUserSrcDir := $$($(strip $(1))_PART_DIR))
$(2): $(call intermediates-dir-for,ETC,file_contexts.bin)/file_contexts.bin $(MAKE_EXT4FS) $(shell find $(tempUserSrcDir) -type f)
	@echo $(MAKE_EXT4FS) -s -S $$< -l $$($(strip $(1))_PART_SIZE) -a $(1) $$@  $(tempUserSrcDir) && \
	$(MAKE_EXT4FS) -s -S $$< -l $$($(strip $(1))_PART_SIZE) -a $(1) $$@  $(tempUserSrcDir)
endef
.PHONY:contexts_add
contexts_add:$(TARGET_ROOT_OUT)/file_contexts
	$(foreach userPartName, $(BOARD_USER_PARTS_NAME), \
		$(shell sed -i "/\/$(strip $(userPartName))/d" $< && \
		echo -e "/$(strip $(userPartName))(/.*)?      u:object_r:system_file:s0" >> $<))
$(foreach userPartName, $(BOARD_USER_PARTS_NAME), \
	$(eval $(call aml-mk-user-img-template, $(userPartName),$(PRODUCT_OUT)/$(userPartName).img)))

define aml-user-img-update-pkg
	ln -sf $(TOP)/$(PRODUCT_OUT)/$(1).img $(PRODUCT_UPGRADE_OUT)/$(1).img && \
	sed -i "/file=\"$(1)\.img\"/d" $(2) && \
	echo -e "file=\"$(1).img\"\t\tmain_type=\"PARTITION\"\t\tsub_type=\"$(1)\"" >> $(2) ;
endef

.PHONY: aml_usrimg
aml_usrimg :$(INSTALLED_AML_USER_IMAGES)
endif # ifeq ($(TARGET_BUILD_USER_PARTS),true)

INSTALLED_AMLOGIC_BOOTLOADER_TARGET := $(PRODUCT_OUT)/bootloader.img
.PHONY: aml_bootloader
aml_bootloader : $(INSTALLED_AMLOGIC_BOOTLOADER_TARGET)

.PHONY: build_always
build_always:

ifeq ($(BOOTLOADER_INPUT),)
BOOTLOADER_INPUT := $(TARGET_DEVICE_DIR)/bootloader.img
ifeq ($(PRODUCT_USE_PREBUILD_SECURE_BOOTLOADER),true)
	BOOTLOADER_INPUT := $(TARGET_DEVICE_DIR)/bootloader_secure.img $(TARGET_DEVICE_DIR)/bootloader.img
endif# ifeq ($(PRODUCT_USE_PREBUILD_SECURE_BOOTLOADER),true)
#BOOTLOADER_INPUT_SIGNED := $(TARGET_DEVICE_DIR)/prebuilt/bootloader/bl33.bin
ifeq ($(TARGET_DEVICE),sabrina)
ifneq ($(PRODUCT_GOOGLEREF_SECURE_BOOT),true)
BOOTLOADER_INPUT := $(TARGET_DEVICE_DIR)/bootloader_unsign.img
endif
endif
endif # ifeq ($(BOOTLOADER_INPUT),)

ANDROID_HOME_DIR = $(shell pwd)
ifneq ($(wildcard bootloader/uboot/*),)
BOOTLOADER_DIR := $(ANDROID_HOME_DIR)/bootloader/uboot
else
ifneq ($(wildcard ~/bootloader/.*),)
BOOTLOADER_DIR := ~/bootloader/uboot
endif
endif

ifeq ($(PRODUCT_BUILD_SECURE_BOOT_IMAGE_DIRECTLY),true)
define aml-secureboot-sign-bootloader
	@echo -----aml-secureboot-sign-bootloader ------
	mv $(1) $(1).unsigned
	@echo $(PRODUCT_AML_SECUREBOOT_SIGNBOOTLOADER) --input $(1).unsigned --output $(1)
	$(hide) $(PRODUCT_AML_SECUREBOOT_SIGNBOOTLOADER) --input $(1).unsigned --output $(1)
	@echo ----- Made aml secure-boot singed bootloader: $(1) --------
endef #define aml-secureboot-sign-bootloader
ifeq ($(PRODUCT_BUILD_SECURE_BOOTLOADER_ONLY),true)
	BOOTLOADER_INPUT := $(BOOTLOADER_INPUT) $(INSTALLED_AMLOGIC_BOOTLOADER_TARGET).unsigned
endif # ifeq ($(PRODUCT_BUILD_SECURE_BOOTLOADER_ONLY),true)
endif#ifeq ($(PRODUCT_BUILD_SECURE_BOOT_IMAGE_DIRECTLY),true)

$(INSTALLED_AMLOGIC_BOOTLOADER_TARGET) : $(word 1,$(BOOTLOADER_INPUT))
	$(hide) cp $< $@
	$(hide) $(call aml-secureboot-sign-bootloader,$@)
	@echo "make $@: bootloader installed end"

$(call dist-for-goals, droidcore, $(INSTALLED_AMLOGIC_BOOTLOADER_TARGET))


ifeq ($(TARGET_SUPPORT_USB_BURNING_V2),true)
INSTALLED_AML_UPGRADE_PACKAGE_TARGET := $(PRODUCT_OUT)/update.img
$(warning will keep $(INSTALLED_AML_UPGRADE_PACKAGE_TARGET))
$(call dist-for-goals, droidcore, $(INSTALLED_AML_UPGRADE_PACKAGE_TARGET))

PACKAGE_CONFIG_FILE := $(PRODUCT_UPGRADE_OUT)/$(notdir $(PACKAGE_CONFIG_FILE))

ifeq ($(TARGET_USE_SECURITY_DM_VERITY_MODE_WITH_TOOL),true)
  SYSTEMIMG_INTERMEDIATES := $(PRODUCT_OUT)/obj/PACKAGING/systemimage_intermediates/system.img.
  SYSTEMIMG_INTERMEDIATES := $(SYSTEMIMG_INTERMEDIATES)verity_table.bin $(SYSTEMIMG_INTERMEDIATES)verity.img
  define security_dm_verity_conf
	  @echo "copy verity.img and verity_table.bin"
	  @sed -i "/verity_table.bin/d" $(PACKAGE_CONFIG_FILE)
	  @sed -i "/verity.img/d" $(PACKAGE_CONFIG_FILE)
	  $(hide) \
		sed -i "/aml_sdc_burn\.ini/ s/.*/&\nfile=\"system.img.verity.img\"\t\tmain_type=\"img\"\t\tsub_type=\"verity\"/" $(PACKAGE_CONFIG_FILE); \
		sed -i "/aml_sdc_burn\.ini/ s/.*/&\nfile=\"system.img.verity_table.bin\"\t\tmain_type=\"bin\"\t\tsub_type=\"verity_table\"/" $(PACKAGE_CONFIG_FILE);
	  cp $(SYSTEMIMG_INTERMEDIATES) $(PRODUCT_UPGRADE_OUT)/
  endef #define security_dm_verity_conf
endif # ifeq ($(TARGET_USE_SECURITY_DM_VERITY_MODE_WITH_TOOL),true)

define update-aml_upgrade-conf
	$(foreach f, $(TOOL_ITEMS), \
	if [ -f $(PRODUCT_UPGRADE_OUT)/$(f) ]; then \
		echo exist item $(f); \
		awk -v file="$(f)" \
		-v main="$(lastword $(subst ., ,$(f)))" \
		-v subtype="$(basename $(f))" \
		'BEGIN{printf("file=\"%s\"\t\tmain_type=\"%s\"\t\tsub_type=\"%s\"\n", file, main, subtype)}' >> $(PACKAGE_CONFIG_FILE) ; \
		sed -i '$$!H;$$!d;$$G' $(PACKAGE_CONFIG_FILE); \
		sed -i '1H;1d;/\[LIST_NORMAL\]/G' $(PACKAGE_CONFIG_FILE); \
	fi;)
endef #define update-aml_upgrade-conf

TARGET_USB_BURNING_V2_DEPEND_MODULES := $(AML_TARGET).zip #copy xx.img to $(AML_TARGET)/IMAGES for diff upgrade

INTERNAL_SUPERIMAGE_DIST_TARGET := $(PRODUCT_OUT)/obj/PACKAGING/super.img_intermediates/super.img
INSTALLED_SUPERIMAGE_EMPTY_TARGET := $(PRODUCT_OUT)/super_empty.img

.PHONY:aml_upgrade
aml_upgrade:$(INSTALLED_AML_UPGRADE_PACKAGE_TARGET)
$(INSTALLED_AML_UPGRADE_PACKAGE_TARGET): \
	$(addprefix $(PRODUCT_OUT)/,$(BUILT_IMAGES)) \
	$(INSTALLED_BOARDDTB_TARGET) \
	$(UPGRADE_FILES) \
	$(INSTALLED_AML_USER_IMAGES) \
	$(INSTALLED_AML_LOGO) \
	$(INSTALLED_MANIFEST_XML) \
	$(INSTALLED_AMLOGIC_BOOTLOADER_TARGET) \
	$(INTERNAL_SUPERIMAGE_DIST_TARGET) \
	$(TARGET_USB_BURNING_V2_DEPEND_MODULES)
	mkdir -p $(PRODUCT_UPGRADE_OUT)
	$(hide) $(foreach file,$(VB_CHECK_IMAGES), \
		cp $(AML_TARGET)/IMAGES/$(file) $(PRODUCT_OUT)/;\
		)
ifeq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
	ln -sf $(shell readlink -f $(INTERNAL_SUPERIMAGE_DIST_TARGET)) $(PRODUCT_UPGRADE_OUT)/super.img
endif
	$(hide) $(foreach file,$(UPGRADE_FILES), \
		echo cp $(file) $(PRODUCT_UPGRADE_OUT)/$(notdir $(file)); \
		cp -f $(file) $(PRODUCT_UPGRADE_OUT)/$(notdir $(file)); \
		)
	$(hide) $(foreach file,$(BUILT_IMAGES), \
		echo "ln -sf $(shell readlink -f $(PRODUCT_OUT)/$(file)) $(PRODUCT_UPGRADE_OUT)/$(file)"; \
		ln -sf $(shell readlink -f $(PRODUCT_OUT)/$(file)) $(PRODUCT_UPGRADE_OUT)/$(file); \
		)
	ln -sf $(shell readlink -f $(PRODUCT_OUT)/dt.img) $(PRODUCT_UPGRADE_OUT)/dt.img;
	cp $(INSTALLED_AMLOGIC_BOOTLOADER_TARGET) $(PRODUCT_UPGRADE_OUT)/bootloader.img
	@echo $(INSTALLED_AML_UPGRADE_PACKAGE_TARGET)
ifneq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
	$(hide) $(foreach file,$(VB_CHECK_IMAGES), \
		rm $(PRODUCT_UPGRADE_OUT)/$(file);\
		ln -sf $(shell readlink -f $(AML_TARGET)/IMAGES/$(file)) $(PRODUCT_UPGRADE_OUT)/$(file); \
		)
endif
ifneq ($(BOARD_USES_DYNAMIC_FINGERPRINT),true)
	echo "delete oem.img in $(PACKAGE_CONFIG_FILE)"
	sed -i "/oem.img/d" $(PACKAGE_CONFIG_FILE)
endif
ifneq ($(BUILDING_VENDOR_BOOT_IMAGE),true)
	echo "delete vendor_boot.img in $(PACKAGE_CONFIG_FILE)"
	sed -i "/vendor_boot.img/d" $(PACKAGE_CONFIG_FILE)
endif
	$(security_dm_verity_conf)
	$(update-aml_upgrade-conf)
	$(hide) $(foreach userPartName, $(BOARD_USER_PARTS_NAME), \
		$(call aml-user-img-update-pkg,$(userPartName),$(PACKAGE_CONFIG_FILE)))
	@echo "Package: $@"
ifneq ($(word 2,$(BOOTLOADER_INPUT)),)
	@echo $(AML_PKG_ADD_USB_BIN) --unpackDir $(PRODUCT_UPGRADE_OUT) --bootloader $(word 2,$(BOOTLOADER_INPUT)) --output $@
	$(hide) $(AML_PKG_ADD_USB_BIN) --appimage-extract-and-run --amlImgPacker $(AML_IMG_PKG_TOOL) \
		--unpackDir $(PRODUCT_UPGRADE_OUT) --imageCfg $(PACKAGE_CONFIG_FILE) \
		--bootloader $(word 2,$(BOOTLOADER_INPUT)) --output $@
else
	@echo $(AML_IMG_PKG_TOOL) -r $(PACKAGE_CONFIG_FILE)  $(PRODUCT_UPGRADE_OUT) $@
	$(hide) $(AML_IMG_PKG_TOOL) -r $(PACKAGE_CONFIG_FILE)  $(PRODUCT_UPGRADE_OUT) $@
endif# ifeq ($(PRODUCT_USE_PREBUILD_SECURE_BOOTLOADER),true)
	@echo " $@ installed"
else
#none
INSTALLED_AML_UPGRADE_PACKAGE_TARGET :=
endif

INSTALLED_AML_FASTBOOT_ZIP := $(PRODUCT_OUT)/$(TARGET_PRODUCT)-fastboot-flashall-$(FILE_NAME).zip
$(warning will keep $(INSTALLED_AML_FASTBOOT_ZIP))
$(call dist-for-goals, droidcore, $(INSTALLED_AML_FASTBOOT_ZIP))

FASTBOOT_IMAGES := boot.img
ifneq ($(TARGET_NO_RECOVERY),true)
	FASTBOOT_IMAGES += recovery.img
endif

ifeq ($(PRODUCT_BUILD_SECURE_BOOT_IMAGE_DIRECTLY),true)
ifneq ($(PRODUCT_BUILD_SECURE_BOOTLOADER_ONLY),true)
	FASTBOOT_IMAGES := $(addsuffix .encrypt, $(FASTBOOT_IMAGES))
endif # ifneq ($(PRODUCT_BUILD_SECURE_BOOTLOADER_ONLY),true)
endif#ifeq ($(PRODUCT_BUILD_SECURE_BOOT_IMAGE_DIRECTLY),true)

FASTBOOT_IMAGES += android-info.txt

FASTBOOT_IMAGES += system.img
FASTBOOT_IMAGES += vendor.img
ifeq ($(BOARD_USES_PRODUCTIMAGE),true)
	FASTBOOT_IMAGES += product.img
endif
ifeq ($(BOARD_USES_ODMIMAGE),true)
	FASTBOOT_IMAGES += odm.img
endif
ifeq ($(BUILDING_SYSTEM_EXT_IMAGE),true)
FASTBOOT_IMAGES += system_ext.img
endif

ifeq ($(BUILDING_VENDOR_BOOT_IMAGE),true)
FASTBOOT_IMAGES += vendor_boot.img
endif

ifdef BOARD_PREBUILT_DTBOIMAGE
FASTBOOT_IMAGES += dtbo.img
endif

ifeq ($(BUILD_WITH_AVB),true)
	FASTBOOT_IMAGES += vbmeta.img
endif

ifeq ($(BOARD_USES_SYSTEM_OTHER_ODEX),true)
FASTBOOT_IMAGES += system_other.img
endif

ifeq ($(BOARD_USES_ODM_EXTIMAGE), true)
FASTBOOT_IMAGES += odm_ext.img
endif

ifeq ($(BOARD_USES_DYNAMIC_FINGERPRINT),true)
FASTBOOT_IMAGES += oem.img
endif

ifeq ($(BOARD_USES_VBMETA_SYSTEM),true)
FASTBOOT_IMAGES += vbmeta_system.img
endif

.PHONY:aml_fastboot_zip
aml_fastboot_zip:$(INSTALLED_AML_FASTBOOT_ZIP)
$(INSTALLED_AML_FASTBOOT_ZIP): $(addprefix $(PRODUCT_OUT)/,$(FASTBOOT_IMAGES)) \
	$(BUILT_ODMIMAGE_TARGET) $(INSTALLED_AML_UPGRADE_PACKAGE_TARGET)\
	$(AML_TARGET_ZIP) $(INSTALLED_AMLOGIC_BOOTLOADER_TARGET)
	echo "install $@"
	rm -rf $(PRODUCT_OUT)/fastboot_auto
	mkdir -p $(PRODUCT_OUT)/fastboot_auto
	cd $(PRODUCT_OUT); cp $(FASTBOOT_IMAGES) fastboot_auto/
#ifeq ($(PRODUCT_BUILD_SECURE_BOOT_IMAGE_DIRECTLY),true)
#	cp $(PRODUCT_OUT)/bootloader.img.encrypt $(PRODUCT_OUT)/fastboot_auto/
#	cp $(PRODUCT_OUT)/dt.img.encrypt $(PRODUCT_OUT)/fastboot_auto/
#else
	cp $(INSTALLED_AMLOGIC_BOOTLOADER_TARGET) $(PRODUCT_OUT)/fastboot_auto/bootloader.img
	cp $(PRODUCT_OUT)/dt.img $(PRODUCT_OUT)/fastboot_auto/
#endif
	cp $(PRODUCT_OUT)/upgrade/logo.img $(PRODUCT_OUT)/fastboot_auto/
	cp device/khadas/common/scripts/fastboot_scripts/flash-all.sh $(PRODUCT_OUT)/fastboot_auto/
	cp device/khadas/common/scripts/fastboot_scripts/flash-all.bat $(PRODUCT_OUT)/fastboot_auto/
ifeq ($(AB_OTA_UPDATER),true)
ifeq ($(BUILDING_VENDOR_BOOT_IMAGE),true)
	cp device/khadas/common/scripts/fastboot_scripts/flash-all-ab.sh $(PRODUCT_OUT)/fastboot_auto/flash-all.sh
	cp device/khadas/common/scripts/fastboot_scripts/flash-all-ab.bat $(PRODUCT_OUT)/fastboot_auto/flash-all.bat
else
	cp device/khadas/common/scripts/fastboot_scripts/flash-all-ab-4.9.sh $(PRODUCT_OUT)/fastboot_auto/flash-all.sh
	cp device/khadas/common/scripts/fastboot_scripts/flash-all-ab-4.9.bat $(PRODUCT_OUT)/fastboot_auto/flash-all.bat
endif
endif
	cp $(PRODUCT_OUT)/super_empty.img $(PRODUCT_OUT)/fastboot_auto/
ifneq ($(BUILDING_SYSTEM_EXT_IMAGE),true)
	sed -i '/system_ext.img/d' $(PRODUCT_OUT)/fastboot_auto/flash-all.bat
	sed -i '/system_ext.img/d' $(PRODUCT_OUT)/fastboot_auto/flash-all.sh
endif
	$(hide) $(foreach file,$(VB_CHECK_IMAGES), \
		cp -f $(AML_TARGET)/IMAGES/$(file) $(PRODUCT_OUT)/fastboot_auto/$(file); \
		)
	cp -f $(PRODUCT_OUT)/super_empty_all.img $(PRODUCT_OUT)/fastboot_auto/super_empty_all.img
	cd $(PRODUCT_OUT)/fastboot_auto; zip -1 -r ../$(TARGET_PRODUCT)-fastboot-flashall-$(FILE_NAME).zip *

name := $(TARGET_PRODUCT)
ifeq ($(TARGET_BUILD_TYPE),debug)
  name := $(name)_debug
endif
name := $(name)-ota-amlogic-$(FILE_NAME)

AMLOGIC_OTA_PACKAGE_TARGET := $(PRODUCT_OUT)/$(name).zip

$(AMLOGIC_OTA_PACKAGE_TARGET): KEY_CERT_PAIR := $(DEFAULT_KEY_CERT_PAIR)

ifeq ($(AB_OTA_UPDATER),true)
$(AMLOGIC_OTA_PACKAGE_TARGET): $(BRILLO_UPDATE_PAYLOAD)
else
$(AMLOGIC_OTA_PACKAGE_TARGET): $(BRO)
endif

EXTRA_SCRIPT := $(TARGET_DEVICE_DIR)/../../../device/khadas/common/recovery/updater-script

$(AMLOGIC_OTA_PACKAGE_TARGET): $(AML_TARGET).zip $(BUILT_ODMIMAGE_TARGET)
	@echo "Package OTA2: $@"
	mkdir -p $(AML_TARGET)/IMAGES/
	cp $(PRODUCT_OUT)/super_empty_all.img $(AML_TARGET)/IMAGES/
	$(hide) PATH=$(foreach p,$(INTERNAL_USERIMAGES_BINARY_PATHS),$(p):)$$PATH MKBOOTIMG=$(MKBOOTIMG) \
	   ./device/khadas/common/scripts/ota_amlogic.py -v \
	   --block \
	   --extracted_input_target_files $(patsubst %.zip,%,$(BUILT_TARGET_FILES_PACKAGE)) \
	   -p $(HOST_OUT) \
	   -k $(DEFAULT_KEY_CERT_PAIR) \
	   $(if $(OEM_OTA_CONFIG), -o $(OEM_OTA_CONFIG)) \
	   $(BUILT_TARGET_FILES_PACKAGE) $@

.PHONY: ota_amlogic
ota_amlogic: $(AMLOGIC_OTA_PACKAGE_TARGET)

ifeq ($(TARGET_SUPPORT_USB_BURNING_V2),true)
INSTALLED_AML_EMMC_BIN := $(PRODUCT_OUT)/aml_emmc_mirror.bin.gz
AML_EMMC_BIN_GENERATOR := $(BOARD_AML_VENDOR_PATH)/tools/aml_upgrade/aml_emmc_bin_maker.app
PRODUCT_CFG_EMMC_LGC_TABLE := $(KERNEL_ROOTDIR)/$(KERNEL_DEVICETREE_DIR)/$(TARGET_PARTITION_DTSI)
AML_DTB_CRC_TOOL		:= $(BOARD_AML_VENDOR_PATH)/tools/aml_upgrade/dtb_pc
AML_IMG_PKG_TOOL		:= $(BOARD_AML_VENDOR_PATH)/tools/aml_upgrade/aml_image_v2_packer
ifeq ($(PRODUCT_CFG_EMMC_CAP),)
	PRODUCT_CFG_EMMC_CAP := bootloader/uboot/include/emmc_partitions.h
endif

$(INSTALLED_AML_EMMC_BIN): $(INSTALLED_AML_UPGRADE_PACKAGE_TARGET) $(PRODUCT_CFG_EMMC_CAP) \
		$(PRODUCT_CFG_EMMC_LGC_TABLE)  $(AML_EMMC_BIN_GENERATOR) | $(SIMG2IMG) $(MINIGZIP)
	@echo "Packaging $(INSTALLED_AML_EMMC_BIN)"
	@echo $(AML_EMMC_BIN_GENERATOR)  --emmcCHeader $(PRODUCT_CFG_EMMC_CAP) --partCfg $(PRODUCT_CFG_EMMC_LGC_TABLE) \
			--simg2img $(SIMG2IMG) --dtb_pc $(AML_DTB_CRC_TOOL) --amlImgPacker $(AML_IMG_PKG_TOOL) \
			--burnPkg $< --output $(basename $@)
	$(hide) $(AML_EMMC_BIN_GENERATOR) --appimage-extract-and-run  --emmcCHeader $(PRODUCT_CFG_EMMC_CAP) --partCfg $(PRODUCT_CFG_EMMC_LGC_TABLE) \
			--simg2img $(SIMG2IMG) --dtb_pc $(AML_DTB_CRC_TOOL) --amlImgPacker $(AML_IMG_PKG_TOOL) \
			--burnPkg $< --output $(basename $@)
	$(MINIGZIP) $(basename $@)
	@echo "installed $@"

.PHONY: aml_emmc_bin
aml_emmc_bin :$(INSTALLED_AML_EMMC_BIN)
endif # ifeq ($(TARGET_SUPPORT_USB_BURNING_V2),true)

$(AML_TARGET_ZIP): $(INSTALLED_SUPERIMAGE_EMPTY_TARGET)
ifeq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
	dd if=/dev/zero of=$(PRODUCT_OUT)/empty_1.bin bs=1 count=4096
	dd if=$(PRODUCT_OUT)/super_empty.img bs=1 count=4096 skip=0  of=$(PRODUCT_OUT)/empty_2.bin
	dd if=$(PRODUCT_OUT)/super_empty.img bs=1 count=4096 skip=4096  of=$(PRODUCT_OUT)/empty_3.bin
	cat $(PRODUCT_OUT)/empty_1.bin $(PRODUCT_OUT)/empty_2.bin $(PRODUCT_OUT)/empty_1.bin $(PRODUCT_OUT)/empty_3.bin > $(PRODUCT_OUT)/super_empty_all.img
endif

droidcore: $(INSTALLED_MANIFEST_XML)
otapackage: otatools-package

ifneq ($(BUILD_AMLOGIC_FACTORY_ZIP), false)
droidcore: $(INSTALLED_AML_UPGRADE_PACKAGE_TARGET) $(INSTALLED_AML_FASTBOOT_ZIP)
endif

$(INTERNAL_OTA_PACKAGE_TARGET): $(INSTALLED_AML_UPGRADE_PACKAGE_TARGET) $(AML_TARGET_ZIP) $(INSTALLED_MANIFEST_XML) $(INSTALLED_AML_FASTBOOT_ZIP)

.PHONY: aml_factory_zip
aml_factory_zip: $(INSTALLED_AML_UPGRADE_PACKAGE_TARGET) $(INSTALLED_MANIFEST_XML) $(INSTALLED_AML_FASTBOOT_ZIP)

$(AMLOGIC_OTA_PACKAGE_TARGET): $(INSTALLED_AML_UPGRADE_PACKAGE_TARGET) $(INSTALLED_MANIFEST_XML) $(AML_TARGET_ZIP) $(INSTALLED_AML_FASTBOOT_ZIP) $(INTERNAL_OTA_PACKAGE_TARGET)
