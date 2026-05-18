### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=
do.devicecheck=1
do.cleanup=1
do.cleanuponabort=0
do.modules=1
dump_dtb=0
device.name1=chagalllte
device.name2=SM-T805
supported.versions=
'; } # end properties


### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# boot shell variables
block=/dev/block/platform/dw_mmc.0/by-name/BOOT;
is_slot_device=0;
ramdisk_compression=auto;
patch_vbmeta_flag=false;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;
# boot install
dump_boot;
write_boot;
## end boot install
