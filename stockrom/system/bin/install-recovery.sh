#!/system/bin/sh
if [ -f /system/etc/recovery-transform.sh ]; then
  exec sh /system/etc/recovery-transform.sh 9793536 a3d09149d477eda3e3d9fd9ea58f09a5418f9037 7378944 e929d3ed2ce3f3960fd23758e703f51dcb4c1ced
fi

if ! applypatch -c EMMC:/dev/block/platform/msm_sdcc.1/by-name/recovery:9793536:a3d09149d477eda3e3d9fd9ea58f09a5418f9037; then
  applypatch -b /system/etc/recovery-resource.dat EMMC:/dev/block/platform/msm_sdcc.1/by-name/boot:7378944:e929d3ed2ce3f3960fd23758e703f51dcb4c1ced EMMC:/dev/block/platform/msm_sdcc.1/by-name/recovery a3d09149d477eda3e3d9fd9ea58f09a5418f9037 9793536 e929d3ed2ce3f3960fd23758e703f51dcb4c1ced:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
