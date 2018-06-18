# AOSP+OP-TEE manifest

This repository contains a local manifest that can be used to build an
AOSP build that includes OP-TEE for the hikey board.

## 1. References

* [AOSP Hikey build instructions][1]

## 2. Prerequisites

* Should already be able to build AOSP.  Distro should have necessary
  packages installed, and the repo tool should be installed.  Note
  that AOSP needs to be built with Java.  Also make sure that
  the `mtools` package is installed, which is needed to make the hikey
  boot image.

* In addition, you will need the pre-requisites necessary to build
  optee-os.

  After following the AOSP setup instructions, the following
  additional packages are needed.

```
sudo apt-get install android-tools-adb android-tools-fastboot autoconf \
	automake bc bison build-essential cscope curl device-tree-compiler flex \
	ftp-upload gdisk iasl libattr1-dev libc6:i386 libcap-dev libfdt-dev \
	libftdi-dev libglib2.0-dev libhidapi-dev libncurses5-dev \
	libpixman-1-dev libssl-dev libstdc++6:i386 libtool libz1:i386 make \
	mtools netcat python-crypto python-serial python-wand unzip uuid-dev \
	xdg-utils xterm xz-utils zlib1g-dev python-mako openjdk-8-jdk \
	ncurses-dev realpath android-tools-fsutils dosfstools libxml2-utils
```

## 3. Build steps

```
git clone https://github.com/linaro-swg/optee_android_manifest -b lcr-ref-hikey
cd lcr-ref-hikey
./sync-o.sh
./build.sh #or `./build.sh -4g` for a 4GB board!
```

**WARNNING:** `--force-sync` is used which means you might **lose your
work** so save accordingly!

**NOTE:** You can add `-squashfs` to `build.sh` option to make
`system.img` size smaller, but this will make `/system` read-only, so
you won't be able to push files to it.

For relatively stable builds, use below instead of `./sync-o.sh`.
```
./sync.sh -v o -bm <name of a pinned manifest file in archive/> -d 2>&1 |tee logs/sync-o.log

# e.g.
./sync.sh -v o -bm pinned-manifest_20180808-0808.xml -d 2>&1 |tee logs/sync-o.log
```

For newer versions, use `./sync-p.sh` or `./sync-master.sh` instead of
`./sync-o.sh`, but these are **NOT TESTED and NOT SUPPORTED** atm so build
at your own risk!

## 4. Flashing the image

The instructions for flashing the image can be found in detail under
`device/linaro/hikey/install/README` in the tree.
1. Jumper links 1-2 and 3-4, leaving 5-6 open, and reset the board.
2. Invoke

```
cp -a out/target/product/hikey/*.img device/linaro/hikey/installer/hikey/
sudo ./device/linaro/hikey/installer/hikey/flash-all.sh /dev/ttyUSBn
sudo fastboot format userdata
```

where the ttyUSBn device is the one that appears after rebooting with
the 3-4 jumper installed.  Note that the device only remains in this
recovery mode for about 90 seconds.  If you take too long to run the
flash commands, it will need to be reset again.

## 5. Partial flashing

The last handful of lines in the `flash-all.sh` script flash various
images.  After modifying and rebuilding Android, it is only necessary
to flash *boot*, *system*, *cache*, and *userdata*.  If you aren't
modifying the kernel, *boot* is not necessary, either.

This directory contains a prebuilt trusted firmware image `fip.bin`.
If you wish to build the trusted os from source, follow the steps in the
**Build the bootloader firmware (fip.bin)** section above.

## 6. Running xtest

Please do NOT try to run `tee-supplicant` as it has already been started
automatically as a service! Once booted to the command prompt, `xtest`
can be run immediately.

## 7. Enable adb over usb

Boot the device. On serial console:

```
su setprop sys.usb.configfs 1
stop adbd
start adbd
```

[1]: https://source.android.com/source/devices.html
