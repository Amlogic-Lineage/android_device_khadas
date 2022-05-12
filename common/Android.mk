#
# Copyright (C) 2019 The Android Open Source Project
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

# "Beast" to be removed later after s/Beast/beast/ gets done.

ifneq ($(filter adt2 adt3 ampere braun curie darwin atom beast Beast galilei franklin faraday deadpool sabrina fermi newton elektra marconi ohm redi oppen oppencas planck einstein t7_an400 ohm_mxl258c ohm_vmx dalton oppen_mxl258c,$(TARGET_DEVICE)),)

include $(all-subdir-makefiles)
endif
