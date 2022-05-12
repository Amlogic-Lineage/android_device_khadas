# Copyright (C) 2017 Amlogic Corporation.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# default module name if not called or get name from Android.mk
AML_KERNEL_MODULE_NAME ?= aml_chcon

# default parameter if they're not defined
AML_SECURE_LIB ?= "/odm/lib/ms12/libdolbyms12.so"
AML_SECURE_CON ?= "u:object_r:dolby_lib_file:s0"

# generic form for all modules
$(AML_KERNEL_MODULE_NAME)-objs := aml_chcon_main.o

ccflags-y += -DAML_SECURE_LIB=\"$(AML_SECURE_LIB)\" \
             -DAML_SECURE_CON=\"$(AML_SECURE_CON)\"

obj-m := $(AML_KERNEL_MODULE_NAME).o

all:
	$(MAKE) -C $(KERNEL_SRC) M=$(M)  modules

modules_install:
	$(MAKE) INSTALL_MOD_STRIP=1  M=$(M) -C $(KERNEL_SRC) modules_install
	mkdir -p ${OUT_DIR}/../vendor_lib/modules
	cd ${OUT_DIR}/$(M)/; find -name "*.ko" -exec cp {} ${OUT_DIR}/../vendor_lib/modules/aml_chcon.ko \;
clean:
	$(MAKE) -C $(KERNEL_SRC) M=$(M) clean