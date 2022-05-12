# Copyright (C) 2012 The Android Open Source Project
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

"""Emit extra commands needed for Group during OTA installation
(installing the bootloader)."""

import os
import sys
import shutil
import tempfile
import struct
import common
import sparse_img

import os
from common import BlockDifference, EmptyImage, GetUserImage

OPTIONS = common.OPTIONS
OPTIONS.ota_zip_check = True
OPTIONS.backup_zip = False

# The joined list of user image partitions of source and target builds.
# - Items should be added to the list if new dynamic partitions are added.
# - Items should not be removed from the list even if dynamic partitions are
#   deleted. When generating an incremental OTA package, this script needs to
#   know that an image is present in source build but not in target build.
USERIMAGE_PARTITIONS = [
]

def GetUserImages(input_tmp, input_zip):
  return {partition: GetUserImage(partition, input_tmp, input_zip)
          for partition in USERIMAGE_PARTITIONS
          if os.path.exists(os.path.join(input_tmp,
                                         "IMAGES", partition + ".img"))}

def FullOTA_GetBlockDifferences(info):
  images = GetUserImages(info.input_tmp, info.input_zip)
  return [BlockDifference(partition, image)
          for partition, image in images.items()]

def IncrementalOTA_GetBlockDifferences(info):
  source_images = GetUserImages(info.source_tmp, info.source_zip)
  target_images = GetUserImages(info.target_tmp, info.target_zip)

  # Use EmptyImage() as a placeholder for partitions that will be deleted.
  for partition in source_images:
    target_images.setdefault(partition, EmptyImage())

  # Use source_images.get() because new partitions are not in source_images.
  return [BlockDifference(partition, target_image, source_images.get(partition))
          for partition, target_image in target_images.items()]

def SetBootloaderEnv(script, name, val):
  """Set bootloader env name with val."""
  script.AppendExtra('set_bootloader_env("%s", "%s");' % (name, val))

def LoadInfoDict_amlogic(info_dict, input_file, input_dir=None):
  """Read and parse the META/misc_info.txt key/value pairs from the
  input target files and return a dict."""

  data = input_file.read("VENDOR/build.prop")
  data += input_file.read("VENDOR/default.prop")

  vendor_prop = common.LoadDictionaryFromLines(data.split("\n"))
  info_dict["vendor.prop"] = common.PartitionBuildProps.FromDictionary(
      "vendor", vendor_prop)

  print("--- *************** ---")
  common.DumpInfoDict(info_dict)

  return True

def GetBuildProp(prop, info_dict):
  """Return the fingerprint of the build of a given target-files info_dict."""

  key_list = ["build.prop", "vendor.prop"]
  for key in key_list:
    build_props = info_dict.get(key)
    if build_props is not None:
      prop_val = build_props.GetProp(prop)
      if prop_val is not None:
        return prop_val
    print "couldn't find {} in {}".format(prop, key)

  raise common.ExternalError("couldn't find {} in {}".format(
      prop, ','.join(key_list)))

def HasTargetImage(target_files_zip, image_path):
  try:
    target_files_zip.getinfo(image_path)
    return True
  except KeyError:
    return False

def ZipOtherImage(which, tmpdir, output):
  """Returns an image object from IMAGES.

  'which' partition eg "logo", "dtb". A prebuilt image and file
  map must already exist in tmpdir.
  """

  amlogic_img_path = os.path.join(tmpdir, "IMAGES", which + ".img")
  if os.path.exists(amlogic_img_path):
    f = open(amlogic_img_path, "rb")
    data = f.read()
    f.close()
    common.ZipWriteStr(output, which + ".img", data)

def GetImage(which, tmpdir):
  """Returns an image object suitable for passing to BlockImageDiff.

  'which' partition must be "system" or "vendor". A prebuilt image and file
  map must already exist in tmpdir.
  """

  #assert which in ("system", "vendor", "odm", "product")

  path = os.path.join(tmpdir, "IMAGES", which + ".img")
  mappath = os.path.join(tmpdir, "IMAGES", which + ".map")

  # The image and map files must have been created prior to calling
  # ota_from_target_files.py (since LMP).
  assert os.path.exists(path) and os.path.exists(mappath)

  # Bug: http://b/20939131
  # In ext4 filesystems, block 0 might be changed even being mounted
  # R/O. We add it to clobbered_blocks so that it will be written to the
  # target unconditionally. Note that they are still part of care_map.
  clobbered_blocks = "0"

  return sparse_img.SparseImage(path)

def AddCustomerImage(info, tmpdir):
  file_list = os.listdir(tmpdir + "/IMAGES")
  for file in file_list:
    if os.path.splitext(file)[1] == '.map':
      of = file.rfind('.')
      name = file[:of]
      if name not in ["system", "vendor", "odm", "product", "system_ext"]:
          tmp_tgt = GetImage(name, OPTIONS.input_tmp)
          tmp_tgt.ResetFileMap()
          tmp_diff = common.BlockDifference(name, tmp_tgt)
          tmp_diff.WriteScript(info.script, info.output_zip)

def FullOTA_Assertions(info):
  print "amlogic extensions:FullOTA_Assertions"
  OPTIONS.skip_compatibility_check = True
  try:
    bootloader_img = info.input_zip.read("RADIO/bootloader.img")
  except KeyError:
    OPTIONS.ota_partition_change = False
    print "no bootloader.img in target_files; skipping install"
  else:
    OPTIONS.ota_partition_change = True
    common.ZipWriteStr(info.output_zip, "bootloader.img", bootloader_img)
  try:
    attestation_file = info.input_zip.read("RADIO/id_attestation.xml")
  except KeyError:
    OPTIONS.ota_update_id_attestation = False
    print "no id_attestation.xml in target_files; skipping install"
  else:
    OPTIONS.ota_update_id_attestation = True
    common.ZipWriteStr(info.output_zip, "id_attestation.xml", attestation_file)

  try:
    vendor_boot_img = info.input_zip.read("IMAGES/vendor_boot.img")
  except KeyError:
    OPTIONS.ota_vendor_boot = False
    print "no vendor_boot.img in target_files; skipping install"
  else:
    OPTIONS.ota_vendor_boot = True

  if OPTIONS.ota_zip_check:
    info.script.AppendExtra('if ota_zip_check() == "1" then')
    info.script.AppendExtra('ui_print("ota_zip_check() == 1");')
    info.script.AppendExtra('if recovery_backup_exist() == "0" then')
    info.script.AppendExtra('package_extract_file("dt.img", "/cache/recovery/dtb.img");')
    info.script.AppendExtra('package_extract_file("recovery.img", "/cache/recovery/recovery.img");')
    if OPTIONS.ota_vendor_boot:
      info.script.AppendExtra('package_extract_file("vendor_boot.img", "/cache/recovery/vendor_boot.img");')
    info.script.AppendExtra('endif;')
    info.script.AppendExtra('set_bootloader_env("upgrade_step", "3");')
    if OPTIONS.ota_partition_change:
      info.script.AppendExtra('ui_print("update bootloader.img...");')
      info.script.AppendExtra('write_bootloader_image(package_extract_file("bootloader.img"));')
      info.script.AppendExtra('set_bootloader_env("recovery_from_flash", "defenv_reserv;saveenv;reset");')
    info.script.AppendExtra('write_dtb_image(package_extract_file("dt.img"));')
    info.script.WriteRawImage("/recovery", "recovery.img")
    if OPTIONS.ota_vendor_boot:
      info.script.AppendExtra('package_extract_file("vendor_boot.img", "/dev/block/vendor_boot");')
    if OPTIONS.backup_zip:
      info.script.AppendExtra('backup_update_package("/dev/block/mmcblk0", "1894");')
    info.script.AppendExtra('delete_file("/cache/recovery/dtb.img");')
    info.script.AppendExtra('delete_file("/cache/recovery/recovery.img");')
    if OPTIONS.ota_vendor_boot:
      info.script.AppendExtra('delete_file("/cache/recovery/vendor_boot.img");')
    info.script.AppendExtra('reboot_recovery();')
    info.script.AppendExtra('else')
    info.script.AppendExtra('ui_print("else case, ota_zip_check() != 1");')

def FullOTA_InstallBegin(info):
  print "amlogic extensions:FullOTA_InstallBegin"
  OPTIONS.skip_compatibility_check = True
  LoadInfoDict_amlogic(info.info_dict, info.input_zip);
  SetBootloaderEnv(info.script, "upgrade_step", "3")
  info.script.FormatPartition("/metadata")
  ZipOtherImage("super_empty_all", OPTIONS.input_tmp, info.output_zip)
  info.script.AppendExtra('if get_update_stage() == "2" then')
  info.script.AppendExtra('ui_print("DTB changed => writing super_empty_all.img to super block...");')
  info.script.AppendExtra('package_extract_file("super_empty_all.img", "/dev/block/super");')
  info.script.AppendExtra('else')
  info.script.AppendExtra('ui_print("DTB NOT changed...");')
  info.script.AppendExtra('endif;')
  info.script.AppendExtra('delete_file("/cache/recovery/dynamic_partition_metadata.UPDATED");')

def FullOTA_InstallEnd(info):
  print "amlogic extensions:FullOTA_InstallEnd"

  AddCustomerImage(info, OPTIONS.input_tmp)

  ZipOtherImage("logo", OPTIONS.input_tmp, info.output_zip)
  ZipOtherImage("dt", OPTIONS.input_tmp, info.output_zip)
  ZipOtherImage("dtbo", OPTIONS.input_tmp, info.output_zip)
  ZipOtherImage("vbmeta", OPTIONS.input_tmp, info.output_zip)
  if not OPTIONS.two_step:
    ZipOtherImage("recovery", OPTIONS.input_tmp, info.output_zip)

  ZipOtherImage("vbmeta_system", OPTIONS.input_tmp, info.output_zip)
  ZipOtherImage("vendor_boot", OPTIONS.input_tmp, info.output_zip)

  info.script.AppendExtra("""ui_print("update logo.img...");
package_extract_file("logo.img", "/dev/block/logo");
ui_print("update dtbo.img...");
package_extract_file("dtbo.img", "/dev/block/dtbo");
if recovery_backup_exist() == "0" then
backup_data_cache(dtb, /cache/recovery/);
backup_data_cache(recovery, /cache/recovery/);""")

  if OPTIONS.ota_vendor_boot:
    info.script.AppendExtra('backup_data_cache(vendor_boot, /cache/recovery/);')

  info.script.AppendExtra("""endif;
ui_print("update dtb.img...");
write_dtb_image(package_extract_file("dt.img"));
ui_print("update recovery.img...");
package_extract_file("recovery.img", "/dev/block/recovery");
ui_print("update vbmeta.img...");
package_extract_file("vbmeta.img", "/dev/block/vbmeta");""")

  try:
    vbmeta_system_img = info.input_zip.read("IMAGES/vbmeta_system.img")
  except KeyError:
    print "no vbmeta_system.img in target_files; skipping install"
  else:
    info.script.AppendExtra('ui_print("update vbmeta_system.img...");')
    info.script.AppendExtra('package_extract_file("vbmeta_system.img", "/dev/block/vbmeta_system");')

  if OPTIONS.ota_vendor_boot:
    info.script.AppendExtra('ui_print("update vendor_boot.img...");')
    info.script.AppendExtra('package_extract_file("vendor_boot.img", "/dev/block/vendor_boot");')
    info.script.AppendExtra('delete_file("/cache/recovery/vendor_boot.img");')

  info.script.AppendExtra('delete_file("/cache/recovery/dtb.img");')
  info.script.AppendExtra('delete_file("/cache/recovery/recovery.img");')

  if OPTIONS.ota_partition_change:
    info.script.AppendExtra('ui_print("update bootloader.img...");')
    info.script.AppendExtra('write_bootloader_image(package_extract_file("bootloader.img"));')

  info.script.AppendExtra('if get_update_stage() == "2" then')
  #info.script.FormatPartition("/tee")
  #info.script.AppendExtra('wipe_cache();')
  #info.script.FormatPartition("/data")
  info.script.AppendExtra('set_update_stage("0");')
  info.script.AppendExtra('endif;')

  if OPTIONS.ota_update_id_attestation:
    info.script.AppendExtra('if write_id_attestation(package_extract_file("id_attestation.xml")) == "0" then')
    info.script.AppendExtra('ui_print("write id_attestation OK");')
    info.script.AppendExtra('endif;')

  SetBootloaderEnv(info.script, "upgrade_step", "1")
  SetBootloaderEnv(info.script, "force_auto_update", "false")

  if OPTIONS.ota_zip_check:
    info.script.AppendExtra('endif;')


def IncrementalOTA_VerifyBegin(info):
  print "amlogic extensions:IncrementalOTA_VerifyBegin"

def IncrementalOTA_VerifyEnd(info):
  print "amlogic extensions:IncrementalOTA_VerifyEnd"

def IncrementalOTA_InstallBegin(info):
  LoadInfoDict_amlogic(info.info_dict, info.target_zip);
  if OPTIONS.ota_zip_check:
    info.script.AppendExtra('if ota_zip_check() == "1" then')
    info.script.AppendExtra('abort("partition table changes, cannot update");')
    info.script.AppendExtra('endif;')

  SetBootloaderEnv(info.script, "upgrade_step", "3")
  print "amlogic extensions:IncrementalOTA_InstallBegin"

def IncrementalOTA_ImageCheck(info, name):
  source_image = False; target_image = False; updating_image = False;

  image_path = "IMAGES/" + name + ".img"
  image_name = name + ".img"

  if HasTargetImage(info.source_zip, image_path):
    source_image = common.File(image_name, info.source_zip.read(image_path));

  if HasTargetImage(info.target_zip, image_path):
    target_image = common.File(image_name, info.target_zip.read(image_path));

  if target_image:
    if source_image:
      updating_image = (source_image.data != target_image.data);
    else:
      updating_image = 1;

  if updating_image:
    message_process = "install " + name + " image..."
    info.script.Print(message_process);
    common.ZipWriteStr(info.output_zip, image_name, target_image.data)
    if name == "dt":
      info.script.AppendExtra('write_dtb_image(package_extract_file("dt.img"));')
    else:
      if name == "bootloader":
        info.script.AppendExtra('write_bootloader_image(package_extract_file("bootloader.img"));')
      else:
        info.script.WriteRawImage("/" + name, image_name)

  if name == "bootloader":
    if updating_image:
      SetBootloaderEnv(info.script, "upgrade_step", "1")
    else:
      SetBootloaderEnv(info.script, "upgrade_step", "2")


def IncrementalOTA_InstallEnd(info):
  print "amlogic extensions:IncrementalOTA_InstallEnd"
  IncrementalOTA_ImageCheck(info, "logo");
  IncrementalOTA_ImageCheck(info, "dt");
  IncrementalOTA_ImageCheck(info, "recovery");
  IncrementalOTA_ImageCheck(info, "vbmeta");
  info.script.FormatPartition("/metadata")
  IncrementalOTA_ImageCheck(info, "bootloader");
