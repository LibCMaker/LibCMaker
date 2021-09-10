#!/bin/bash

# Originally written by Ralf Kistner <ralf@embarkmobile.com>, but placed in the public domain

set +e

bootanim=""
failcounter=0
step_sec=10
timeout_in_sec=600  # 10 minutes
timeout_in_sec_for_arm64=300  # 5 minutes

until [[ "${bootanim}" =~ "stopped" ]]; do
  bootanim=$(adb -e shell getprop init.svc.bootanim 2>&1 &)
  echo "Waiting for emulator to start, ${failcounter} seconds, 'bootanim' status: '${bootanim}'"

  if [[ ( ${cmr_ANDROID_ABI} == "arm64-v8a" )
      && ( ${failcounter} -gt ${timeout_in_sec_for_arm64} ) ]] ; then
    echo "WARNING: 'arm64-v8a' emulator (any API level) does not start on Linux and Windows with success, boot animation is not ending."
    exit 0
  fi

  if [[ ${failcounter} -gt ${timeout_in_sec} ]]; then
    echo "Timeout (${timeout_in_sec} seconds) reached; failed to start emulator"
    exit 1
  fi

  failcounter=$(( failcounter + step_sec ))
  sleep ${step_sec}
done

# After the end of the boot animation, the emulator is fully ready after
# at least 6 minutes. We make an extra time reserve in one minute.
#for i in {1..42}  # 42 * 10 sec = 7 minutes
#do
#  bootanim=$(adb -e shell getprop init.svc.bootanim 2>&1 &)
#  echo "Waiting for emulator to start, ${failcounter} seconds, 'bootanim' status: '${bootanim}'"
#  failcounter=$(( failcounter + step_sec ))
#  sleep ${step_sec}
#done

echo "Emulator is ready"
