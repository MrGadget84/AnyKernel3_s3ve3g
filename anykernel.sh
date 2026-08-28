### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=a32
device.name2=SM-A325F
device.name3=SM-A325M
device.name4=SM-A325N
device.name5=a32xxx
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# boot shell variables
BLOCK=/dev/block/by-name/boot;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
dump_boot; # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk

# init.rc
backup_file init.rc;
replace_string init.rc "cpuctl cpu,timer_slack" "mount cgroup none /dev/cpuctl cpu" "mount cgroup none /dev/cpuctl cpu,timer_slack";

# init.tuna.rc
backup_file init.tuna.rc;
insert_line init.tuna.rc "nodiratime barrier=0" after "mount_all /fstab.tuna" "\tmount ext4 /dev/block/platform/omap/omap_hsmmc.0/by-name/userdata /data remount nosuid nodev noatime nodiratime barrier=0";
append_file init.tuna.rc "bootscript" init.tuna;

# fstab.tuna
backup_file fstab.tuna;
patch_fstab fstab.tuna /system ext4 options "noatime,barrier=1" "noatime,nodiratime,barrier=0";
patch_fstab fstab.tuna /cache ext4 options "barrier=1" "barrier=0,nomblk_io_submit";
patch_fstab fstab.tuna /data ext4 options "data=ordered" "nomblk_io_submit,data=writeback";
append_file fstab.tuna "usbdisk" fstab;

ui_print " ";
ui_print " Samsung Logo Patching:";

mkdir -p /tmp/samsung_patch/tarparam
cp -rf $home/samsung_patch/* /tmp/samsung_patch/
cd /tmp/samsung_patch/
chmod 755 tar

cp -f /tmp/recovery.log /tmp/samsung_patch/recovery.log.bak
if [ ! -z "$(grep '720 x ' /tmp/samsung_patch/recovery.log.bak)" ]; then
	ui_print "Screen resolution: 720p"
	cp -f /tmp/samsung_patch/booting_warning/HD/booting_warning.jpg /tmp/samsung_patch/booting_warning.jpg
elif [ ! -z "$(grep '1080 x ' /tmp/samsung_patch/recovery.log.bak)" ]; then
	ui_print " Screen resolution: 1080p"
	cp -f /tmp/samsung_patch/booting_warning/FHD/booting_warning.jpg /tmp/samsung_patch/booting_warning.jpg
elif [ ! -z "$(grep '1440 x ' /tmp/samsung_patch/recovery.log.bak)" ]; then
	ui_print " Screen resolution: 1440p"
	cp -f /tmp/samsung_patch/booting_warning/QHD/booting_warning.jpg /tmp/samsung_patch/booting_warning.jpg
else
	ui_print " Unable to determine resolution, set FHD as default"
	cp -f /tmp/samsung_patch/booting_warning/FHD/booting_warning.jpg /tmp/samsung_patch/booting_warning.jpg
fi
rm -f /tmp/samsung_patch/recovery.log.bak

for param_name in param PARAM up_param UP_PARAM; do
	PARAM_BLOCK="/dev/block/by-name/$param_name"
	if [ -b "$PARAM_BLOCK" ]; then
		ui_print " Section: $param_name"
		
		rm -rf /tmp/samsung_patch/tarparam
		mkdir -p /tmp/samsung_patch/tarparam
		cd /tmp/samsung_patch/tarparam
		
		/tmp/samsung_patch/tar -xf $PARAM_BLOCK
		
		if [ -f logo.jpg ]; then
			ui_print " Backup $param_name"
			if [ ! -e /data/media/0/${param_name}.bak ]; then
				cat $PARAM_BLOCK > /data/media/0/${param_name}.bak
				chown 1023:1023 /data/media/0/${param_name}.bak
				chmod 664 /data/media/0/${param_name}.bak
			fi
			
			cp /tmp/samsung_patch/logo.jpg .
			if [ -f svb_orange.jpg ]; then
				cp /tmp/samsung_patch/logo.jpg ./svb_orange.jpg
				chmod 444 svb_orange.jpg
			fi
			if [ -f booting_warning.jpg ]; then
				cp /tmp/samsung_patch/booting_warning.jpg .
				chmod 444 booting_warning.jpg
			fi
			
			chown root:root *
			chmod 444 logo.jpg
			touch *
			
			/tmp/samsung_patch/tar -pcvf ../new.tar *
			cd ..
			cat new.tar > $PARAM_BLOCK
		fi
	fi
done

cd /
rm -rf /tmp/samsung_patch
find /data/media/0/ -name '*.bak' -size 0c -exec rm -rf {} \;
sync
ui_print " White Kernel Project Setup Finished!";
ui_print " ";

write_boot; # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
## end boot install


## init_boot files attributes
#init_boot_attributes() {
#set_perm_recursive 0 0 755 644 $RAMDISK/*;
#set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
#} # end attributes

# init_boot shell variables
#BLOCK=init_boot;
#IS_SLOT_DEVICE=1;
#RAMDISK_COMPRESSION=auto;
#PATCH_VBMETA_FLAG=auto;

# reset for init_boot patching
#reset_ak;

# init_boot install
#dump_boot; # unpack ramdisk since it is the new first stage init ramdisk where overlay.d must go

#write_boot;
## end init_boot install


## vendor_kernel_boot shell variables
#BLOCK=vendor_kernel_boot;
#IS_SLOT_DEVICE=1;
#RAMDISK_COMPRESSION=auto;
#PATCH_VBMETA_FLAG=auto;

# reset for vendor_kernel_boot patching
#reset_ak;

# vendor_kernel_boot install
#split_boot; # skip unpack/repack ramdisk, e.g. for dtb on devices with hdr v4 and vendor_kernel_boot

#flash_boot;
## end vendor_kernel_boot install


## vendor_boot files attributes
#vendor_boot_attributes() {
#set_perm_recursive 0 0 755 644 $RAMDISK/*;
#set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
#} # end attributes

# vendor_boot shell variables
#BLOCK=vendor_boot;
#IS_SLOT_DEVICE=1;
#RAMDISK_COMPRESSION=auto;
#PATCH_VBMETA_FLAG=auto;

# reset for vendor_boot patching
#reset_ak;

# vendor_boot install
#dump_boot; # use split_boot to skip ramdisk unpack, e.g. for dtb on devices with hdr v4 but no vendor_kernel_boot

#write_boot; # use flash_boot to skip ramdisk repack, e.g. for dtb on devices with hdr v4 but no vendor_kernel_boot
## end vendor_boot install
