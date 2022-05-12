# -----------------------------------------------------------------
# odm_ext partition image
ifdef BOARD_ODM_EXTIMAGE_FILE_SYSTEM_TYPE
TARGET_COPY_OUT_ODM_EXT := odm_ext
TARGET_OUT_ODM_EXT := $(PRODUCT_OUT)/$(TARGET_COPY_OUT_ODM_EXT)

INTERNAL_ODM_EXTIMAGE_FILES := \
    $(filter $(TARGET_OUT_ODM_EXT)/%,\
      $(ALL_DEFAULT_INSTALLED_MODULES)\
      $(ALL_PDK_FUSION_FILES)) \
    $(PDK_FUSION_SYMLINK_STAMP)
# platform.zip depends on $(INTERNAL_ODM_EXTIMAGE_FILES).
$(INSTALLED_PLATFORM_ZIP) : $(INTERNAL_ODM_EXTIMAGE_FILES)

INSTALLED_FILES_FILE_ODM_EXT := $(PRODUCT_OUT)/installed-files-odm_ext.txt
INSTALLED_FILES_JSON_ODM_EXT := $(INSTALLED_FILES_FILE_ODM_EXT:.txt=.json)
$(INSTALLED_FILES_FILE_ODM_EXT): .KATI_IMPLICIT_OUTPUTS := $(INSTALLED_FILES_JSON_ODM_EXT)
$(INSTALLED_FILES_FILE_ODM_EXT) : $(INTERNAL_ODM_EXTIMAGE_FILES) $(FILESLIST) $(FILESLIST_UTIL)
	@echo Installed file list**: $@
	mkdir -p $(TARGET_OUT_ODM_EXT)/logo_files
	cp $(TARGET_AMLOGIC_RES_PACKAGE)/* $(TARGET_OUT_ODM_EXT)/logo_files/
	mkdir -p $(TARGET_OUT_ODM_EXT)/etc/tvconfig
	cp -rf $(TVCONFIG_FILES) $(TARGET_OUT_ODM_EXT)/etc/tvconfig/
	mkdir -p $(TARGET_OUT_ODM_EXT)/etc/tvconfig/pq
	cp -rf $(PQ_FILES) $(TARGET_OUT_ODM_EXT)/etc/tvconfig/pq
	@mkdir -p $(dir $@)
	@rm -f $@
	$(hide) $(FILESLIST) $(TARGET_OUT_ODM_EXT) > $(@:.txt=.json)
	$(hide) $(FILESLIST_UTIL) -c $(@:.txt=.json) > $@

odm_extimage_intermediates := \
    $(call intermediates-dir-for,PACKAGING,odm_ext)
BUILT_ODM_EXTIMAGE_TARGET := $(PRODUCT_OUT)/odm_ext.img
# We just build this directly to the install location.
INSTALLED_ODM_EXTIMAGE_TARGET := $(BUILT_ODM_EXTIMAGE_TARGET)

# odm_ext.img currently is a stub impl
$(INSTALLED_ODM_EXTIMAGE_TARGET) : $(INTERNAL_ODM_EXTIMAGE_FILES) $(INTERNAL_USERIMAGES_DEPS) $(INSTALLED_FILES_FILE_ODM_EXT) $(PRODUCT_OUT)/system.img
	$(call pretty,"Target odm_ext fs image::::: $(INSTALLED_ODM_EXTIMAGE_TARGET)")
	@mkdir -p $(TARGET_OUT_ODM_EXT)
	@mkdir -p $(odm_extimage_intermediates) && rm -rf $(odm_extimage_intermediates)/odm_ext_image_info.txt
	$(call generate-userimage-prop-dictionary, $(odm_extimage_intermediates)/odm_ext_image_info.txt, skip_fsck=true)
	PATH=$(HOST_OUT_EXECUTABLES):$$PATH \
		mkuserimg_mke2fs -s $(PRODUCT_OUT)/odm_ext $(INSTALLED_ODM_EXTIMAGE_TARGET) $(BOARD_ODM_EXTIMAGE_FILE_SYSTEM_TYPE) \
	 odm_ext $(BOARD_ODM_EXTIMAGE_PARTITION_SIZE) -j 0 -T 1230768000 -B $(PRODUCT_OUT)/odm_ext.map -L odm_ext --inode_size 256 -M 0 \
	 $(PRODUCT_OUT)/obj/ETC/file_contexts.bin_intermediates/file_contexts.bin
	$(call assert-max-image-size,$(INSTALLED_ODM_EXTIMAGE_TARGET),$(BOARD_ODM_EXTIMAGE_PARTITION_SIZE))
	-cp $(PRODUCT_OUT)/odm_ext.map $(AML_TARGET)/IMAGES/
	-cp $(PRODUCT_OUT)/odm_ext.img $(AML_TARGET)/IMAGES/

# We need a (implicit) rule for odm_ext.map, in order to support the INSTALLED_RADIOIMAGE_TARGET above.
$(INSTALLED_ODM_EXTIMAGE_TARGET): .KATI_IMPLICIT_OUTPUTS := $(PRODUCT_OUT)/odm_ext.map

.PHONY: odm_ext_image
odm_ext_image : $(INSTALLED_ODM_EXTIMAGE_TARGET)
$(call dist-for-goals, odm_ext_image, $(INSTALLED_ODM_EXTIMAGE_TARGET))

endif
