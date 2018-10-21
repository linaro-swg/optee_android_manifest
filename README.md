# OP-TEE Based Keymaster/Gatekeeper HIDL HAL Modules - Release 3.3.0

## Build (this assumes all dependencies for building AOSP are met!) 

```
git clone https://github.com/linaro-swg/optee_android_manifest -b 3.3.0
cd optee_android_manifest
./sync.sh -v p -bm pinned-manifest-stable_kmgk_3.3.0.xml 
./build-p.sh
```

## Flash

* Put board in recovery mode by connecting jumpers 1-2 and 3-4
* Run command

```
cp -a out/target/product/hikey/*.img device/linaro/hikey/installer/hikey/
sudo ./device/linaro/hikey/installer/hikey/flash-all.sh /dev/ttyUSB<x>
# x = device number that appears after rebooting with the 3-4 jumper connected
# e.g.
sudo ./device/linaro/hikey/installer/hikey/flash-all.sh /dev/ttyUSB0
```

* Power off board
* Remove jumper 3-4
* Power on board
 
## Test (from terminal, NOT console)

* Test outputs quite verbose logs and can take up to an hour to complete

```
adb root
adb remount

# temporary workaround to disable non-OP-TEE related error messages from
# cluttering up the console
adb shell rm -f /vendor/etc/init/android.hardware.graphics.composer@2.1-service.rc
adb reboot
# wait until board reboots to prompt
adb root
adb remount

# run VTS Gtest unit for Gatekeeper and Keymaster
adb shell /data/nativetest64/VtsHalGatekeeperV1_0TargetTest/VtsHalGatekeeperV1_0TargetTest
adb shell /data/nativetest64/VtsHalKeymasterV3_0TargetTest/VtsHalKeymasterV3_0TargetTest

# help
adb shell /data/nativetest64/VtsHalGatekeeperV1_0TargetTest/VtsHalGatekeeperV1_0TargetTest --help
adb shell /data/nativetest64/VtsHalKeymasterV3_0TargetTest/VtsHalKeymasterV3_0TargetTest --help

```

## Pre-built binaries

[Download][1]

## Sample test output

```
[==========] Running 9 tests from 1 test case.
[----------] Global test environment set-up.
[----------] 9 tests from GatekeeperHidlTest
[ RUN      ] GatekeeperHidlTest.EnrollSuccess
[       OK ] GatekeeperHidlTest.EnrollSuccess (22 ms)
[ RUN      ] GatekeeperHidlTest.EnrollNoPassword
[       OK ] GatekeeperHidlTest.EnrollNoPassword (3 ms)
[ RUN      ] GatekeeperHidlTest.VerifySuccess
[       OK ] GatekeeperHidlTest.VerifySuccess (85 ms)
[ RUN      ] GatekeeperHidlTest.TrustedReenroll
[       OK ] GatekeeperHidlTest.TrustedReenroll (163 ms)
[ RUN      ] GatekeeperHidlTest.UntrustedReenroll
[       OK ] GatekeeperHidlTest.UntrustedReenroll (162 ms)
[ RUN      ] GatekeeperHidlTest.VerifyNoData
[       OK ] GatekeeperHidlTest.VerifyNoData (23 ms)
[ RUN      ] GatekeeperHidlTest.DeleteUserTest
[       OK ] GatekeeperHidlTest.DeleteUserTest (83 ms)
[ RUN      ] GatekeeperHidlTest.DeleteInvalidUserTest
[       OK ] GatekeeperHidlTest.DeleteInvalidUserTest (81 ms)
[ RUN      ] GatekeeperHidlTest.DeleteAllUsersTest
[       OK ] GatekeeperHidlTest.DeleteAllUsersTest (238 ms)
[----------] 9 tests from GatekeeperHidlTest (862 ms total)

[----------] Global test environment tear-down
[==========] 9 tests from 1 test case ran. (862 ms total)
[  PASSED  ] 9 tests.
``` 

```
[==========] Running 108 tests from 12 test cases.
[----------] Global test environment set-up.
[----------] 1 test from KeymasterVersionTest
[ RUN      ] KeymasterVersionTest.SensibleFeatures
[       OK ] KeymasterVersionTest.SensibleFeatures (0 ms)
[----------] 1 test from KeymasterVersionTest (0 ms total)

<snip>

[----------] 3 tests from KeyDeletionTest
[ RUN      ] KeyDeletionTest.DeleteKey
[       OK ] KeyDeletionTest.DeleteKey (23518 ms)
[ RUN      ] KeyDeletionTest.DeleteInvalidKey
[       OK ] KeyDeletionTest.DeleteInvalidKey (5472 ms)
[ RUN      ] KeyDeletionTest.DeleteAllKeys
[       OK ] KeyDeletionTest.DeleteAllKeys (0 ms)
[----------] 3 tests from KeyDeletionTest (28991 ms total)

[----------] Global test environment tear-down
[==========] 108 tests from 12 test cases ran. (3522945 ms total)
[  PASSED  ] 108 tests.
```

[1]: http://people.linaro.org/~victor.chong/prebuilt/pie/330
