import common
import edify_generator

def RemoveDeviceAssert(info):
  edify = info.script
  for i in xrange(len(edify.script)):
    if "ro.product" in edify.script[i]:
      edify.script[i] = """assert(getprop("ro.product.device") == "xt1031" || getprop("ro.build.product") == "xt1031" || getprop("ro.product.device") == "xt1032" || getprop("ro.build.product") == "xt1032" || getprop("ro.product.device") == "xt1033" || getprop("ro.build.product") == "xt1033" || getprop("ro.product.device") == "xt1034" || getprop("ro.build.product") == "xt1034" || getprop("ro.product.device") == "falcon_umts" || getprop("ro.build.product") == "falcon_umts" || getprop("ro.product.device") == "falcon_umtsds" || getprop("ro.build.product") == "falcon_umtsds" || getprop("ro.product.device") == "falcon_cdma" || getprop("ro.build.product") == "falcon_cdma" || getprop("ro.product.device") == "falcon_retuaws" || getprop("ro.build.product") == "falcon_retuaws" || getprop("ro.product.device") == "falcon" || getprop("ro.build.product") == "falcon" || getprop("ro.product.device") == "falcon_gpe" || getprop("ro.build.product") == "falcon_gpe" || abort("This package is for device: xt1031,xt1032,xt1033,xt1034,falcon_umts,falcon_umtsds,falcon_cdma,falcon_retuaws,falcon,falcon_gpe; this device is " + getprop("ro.product.device") + "."););
assert(getprop("ro.bootloader") == "0x4118" || getprop("ro.bootloader") == "0x4119" || getprop("ro.bootloader") == "0x411A" || abort("This package supports bootloader(s): 0x4118, 0x4119, 0x411A; this device has bootloader " + getprop("ro.bootloader") + "."););
unmount("/data");
unmount("/system");"""
      return

def AddAssertions(info):
   edify = info.script
   for i in xrange(len(edify.script)):
    if " ||" in edify.script[i] and ("ro.product.device" in edify.script[i] or "ro.build.product" in edify.script[i]):
      edify.script[i] = edify.script[i].replace(" ||", ' ')
      return

def AddArgsForFormatSystem(info):
  edify = info.script
  for i in xrange(len(edify.script)):
    if "format(" in edify.script[i] and "/dev/block/platform/msm_sdcc.1/by-name/system" in edify.script[i]:
      edify.script[i] = 'format("ext4", "EMMC", "/dev/block/platform/msm_sdcc.1/by-name/system", "0", "/system");'
      return

def WritePolicyConfig(info):
  try:
    file_contexts = info.input_zip.read("META/file_contexts")
    common.ZipWriteStr(info.output_zip, "file_contexts", file_contexts)
  except KeyError:
    print "warning: file_context missing from target;"

def CdmaConfig(info):
  info.script.AppendExtra(("""if getprop("ro.boot.radio") == "0x3" then
delete("/system/etc/apns-conf.xml");
symlink("/system/etc/apns-conf-cdma.xml", "/system/etc/apns-conf.xml");
endif;"""))

def FullOTA_InstallEnd(info):
    WritePolicyConfig(info)
    RemoveDeviceAssert(info)
    CdmaConfig(info)

def IncrementalOTA_InstallEnd(info):
    RemoveDeviceAssert(info)
