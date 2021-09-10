# ****************************************************************************
#  Project:  LibCMaker
#  Purpose:  A CMake build scripts for build libraries with CMake
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2020 NikitaFeodonit
#
#    This file is part of the LibCMaker project.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published
#    by the Free Software Foundation, either version 3 of the License,
#    or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program. If not, see <http://www.gnu.org/licenses/>.
# ****************************************************************************

set -e


# === Define script directories ===

#cmr_CURRENTT_WORK_DIR=$(pwd)
#cmr_SCRIPT_FILE_PATH="$( builtin cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
cmr_SCRIPT_FILE_DIR="$( builtin cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cmr_PARENT_DIR_1=$(builtin cd "$( dirname "${cmr_SCRIPT_FILE_DIR}" )"; pwd)
cmr_PARENT_DIR_2=$(builtin cd "$( dirname "${cmr_PARENT_DIR_1}" )"; pwd)
cmr_PARENT_DIR_3=$(builtin cd "$( dirname "${cmr_PARENT_DIR_2}" )"; pwd)


# === Define script variables ===

export cmr_ECHO_PREFIX="==== [LibCMaker CI] ==== "

export cmr_LibCMaker_DIR_NAME="LibCMaker"


# === Targets ===

# === Android on Linux ===
export cmr_TARGET="Android_Linux"
export cmr_PLATFORM="armeabi-v7a"
export cmr_HOST_OS="Linux"

## === Android, on Windows ===
#export cmr_TARGET="Android_Windows"
#export cmr_PLATFORM="arm64-v8a"
#export cmr_HOST_OS="Windows"


# === Common variables ===

export cmr_ANDROID_ABI=${cmr_PLATFORM}

## armeabi-v7a
export cmr_ANDROID_EMULATOR_API_LEVEL="24"
## arm64-v8a
#export cmr_ANDROID_EMULATOR_API_LEVEL="24"
## x86
#export cmr_ANDROID_EMULATOR_API_LEVEL="23"
## x86_64
#export cmr_ANDROID_EMULATOR_API_LEVEL="24"


#export cmr_LibCMaker_REPO_DIR=="${cmr_PARENT_DIR_1}"
export cmr_LibCMaker_REPO_DIR="${cmr_PARENT_DIR_2}/${cmr_LibCMaker_DIR_NAME}"

export cmr_DOWNLOAD_DIR="${cmr_PARENT_DIR_3}/.downloads"

export cmr_ANDROID_CMD_TOOLS_VERSION="7583922"
export cmr_ANDROID_SDK="${cmr_DOWNLOAD_DIR}/android-sdk-${cmr_ANDROID_CMD_TOOLS_VERSION}"

export ANDROID_HOME=${cmr_ANDROID_SDK}
export ANDROID_SDK_ROOT=${cmr_ANDROID_SDK}
export ANDROID_AVD_HOME="${cmr_DOWNLOAD_DIR}/android-avd"

export PATH=${cmr_ANDROID_SDK}/cmdline-tools/cmdline-tools/bin:${cmr_ANDROID_SDK}/platform-tools:${cmr_ANDROID_SDK}/emulator:${PATH}

if [[ ${cmr_HOST_OS} == "Windows" ]] ; then
  export cmr_WIN_CMD="cmd //c"
fi


# === Create and start Android emulator ===

# https://github.com/ReactiveCircus/android-emulator-runner/issues/46#issuecomment-784914743
# It is important to use the "default" emulator images rather than "google_apis"
# because the Google apps seem to slow down the boot process a lot.
# Also, it seems the android-22 through android-27 system images
# seem to require less resources than the newer ones.

# "default", "google_apis", "google_apis_playstore"
export cmr_ANDROID_EMULATOR_API_TYPE="default"

#echo "${cmr_ECHO_PREFIX} Install Android system-images"
#${cmr_WIN_CMD} sdkmanager "system-images;android-${cmr_ANDROID_EMULATOR_API_LEVEL};${cmr_ANDROID_EMULATOR_API_TYPE};${cmr_ANDROID_ABI}"

echo "${cmr_ECHO_PREFIX} Create Android emulator"
#echo | ${cmr_WIN_CMD} avdmanager create avd -f -n fg_test -c 1024M -k "system-images;android-${cmr_ANDROID_EMULATOR_API_LEVEL};${cmr_ANDROID_EMULATOR_API_TYPE};${cmr_ANDROID_ABI}"
echo | ${cmr_WIN_CMD} avdmanager create avd -f -n fg_test -k "system-images;android-${cmr_ANDROID_EMULATOR_API_LEVEL};${cmr_ANDROID_EMULATOR_API_TYPE};${cmr_ANDROID_ABI}"


echo "${cmr_ECHO_PREFIX} Start Android emulator"
emulator -avd fg_test -memory 1024 -no-window -gpu auto -no-accel -no-snapshot -no-audio -camera-back none -camera-front none &
source ${cmr_LibCMaker_REPO_DIR}/ci/android-wait-for-emulator.sh
adb shell input keyevent 82 &

# -gpu swiftshader_indirect
