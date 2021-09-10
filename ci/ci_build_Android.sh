#!/bin/bash

# ****************************************************************************
#  Project:  LibCMaker
#  Purpose:  A CMake build scripts for build libraries with CMake
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2021 NikitaFeodonit
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

if [[ ${cmr_CI} == "ON" ]]; then
  set -v
fi


# ==== Set variables ====

#export cmr_CMAKE_GENERATOR="Ninja"


export cmr_ANDROID_CMD_TOOLS_VERSION="7583922"

if [[ ${cmr_HOST_OS} == "Linux" ]] ; then
  export cmr_ANDROID_CMD_TOOLS_FILE_NAME="commandlinetools-linux-${cmr_ANDROID_CMD_TOOLS_VERSION}_latest.zip"

  export cmr_ANDROID_NDK_VERSION="r23"
  export cmr_ANDROID_NDK_NAME="android-ndk-${cmr_ANDROID_NDK_VERSION}"
  export cmr_ANDROID_NDK_PLATFORM="${cmr_ANDROID_NDK_NAME}-linux"

elif [[ ${cmr_HOST_OS} == "Windows" ]] ; then
  export cmr_ANDROID_CMD_TOOLS_FILE_NAME="commandlinetools-win-${cmr_ANDROID_CMD_TOOLS_VERSION}_latest.zip"

  export cmr_ANDROID_NDK_VERSION="r22b"  # With NDK r23 on Windows, CMake can not find a compiler.
  export cmr_ANDROID_NDK_NAME="android-ndk-${cmr_ANDROID_NDK_VERSION}"
  #export cmr_ANDROID_NDK_PLATFORM="${cmr_ANDROID_NDK_NAME}-windows"  # From r23.
  export cmr_ANDROID_NDK_PLATFORM="${cmr_ANDROID_NDK_NAME}-windows-x86_64"  # r22 and before.

  export cmr_WIN_CMD="cmd //c"

else
  echo "Error: cmr_HOST_OS is not set correctly."
  exit 1
fi

# https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip
# https://dl.google.com/android/repository/commandlinetools-win-7583922_latest.zip
export cmr_ANDROID_CMD_TOOLS_URL="https://dl.google.com/android/repository/${cmr_ANDROID_CMD_TOOLS_FILE_NAME}"

# https://dl.google.com/android/repository/android-ndk-r23-linux.zip
# https://dl.google.com/android/repository/android-ndk-r23-windows.zip
# https://dl.google.com/android/repository/android-ndk-r22b-windows-x86_64.zip
export cmr_ANDROID_NDK_FILE_NAME="${cmr_ANDROID_NDK_PLATFORM}.zip"
export cmr_ANDROID_NDK_URL="https://dl.google.com/android/repository/${cmr_ANDROID_NDK_FILE_NAME}"


if [[ -z "${cmr_ANDROID_SDK}" ]]; then
  export cmr_ANDROID_SDK="${cmr_INSTALL_DIR}/android-sdk-${cmr_ANDROID_CMD_TOOLS_VERSION}"
fi
if [[ -z "${cmr_ANDROID_NDK}" ]]; then
  export cmr_ANDROID_NDK="${cmr_INSTALL_DIR}/${cmr_ANDROID_NDK_NAME}"
fi
if [[ -z "${cmr_ANDROID_NDK_INSTALL_DIR}" ]]; then
  export cmr_ANDROID_NDK_INSTALL_DIR="${cmr_INSTALL_DIR}"
fi

export cmr_CMAKE_TOOLCHAIN_FILE="${cmr_ANDROID_NDK}/build/cmake/android.toolchain.cmake"

export cmr_ANDROID_CPP_FEATURES="rtti exceptions"
export cmr_ANDROID_TOOLCHAIN="clang"

export ANDROID_HOME=${cmr_ANDROID_SDK}
export ANDROID_SDK_ROOT=${cmr_ANDROID_SDK}
export ANDROID_NDK_HOME=${cmr_ANDROID_NDK}
export ANDROID_NDK_ROOT=${cmr_ANDROID_NDK}

# https://stackoverflow.com/a/65262939
# cmdline-tools must be under directory "cmdline-tools".
export PATH=${cmr_ANDROID_SDK}/cmdline-tools/cmdline-tools/bin:${cmr_ANDROID_SDK}/platform-tools:${cmr_ANDROID_SDK}/emulator:${PATH}


if [[ ${cmr_BUILD_SHARED_LIBS} == "ON" ]] ; then
  export cmr_ANDROID_STL="c++_shared"
elif [[ ${cmr_BUILD_SHARED_LIBS} == "OFF" ]] ; then
  export cmr_ANDROID_STL="c++_static"
else
  echo "Error: cmr_BUILD_SHARED_LIBS is not set correctly."
  exit 1
fi


export cmr_ANDROID_ABI=${cmr_PLATFORM}

# https://github.com/ReactiveCircus/android-emulator-runner/issues/46#issuecomment-784914743
# It is important to use the "default" emulator images rather than "google_apis"
# because the Google apps seem to slow down the boot process a lot.
# Also, it seems the android-22 through android-27 system images
# seem to require less resources than the newer ones.

# "default", "google_apis", "google_apis_playstore"
export cmr_ANDROID_EMULATOR_API_TYPE="default"

if [[ ${cmr_ANDROID_ABI} == "armeabi-v7a" ]] ; then
  export cmr_ANDROID_NATIVE_API_LEVEL="16"
elif [[ ${cmr_ANDROID_ABI} == "arm64-v8a" ]] ; then
  export cmr_ANDROID_NATIVE_API_LEVEL="21"
elif [[ ${cmr_ANDROID_ABI} == "x86" ]] ; then
  export cmr_ANDROID_NATIVE_API_LEVEL="16"
elif [[ ${cmr_ANDROID_ABI} == "x86_64" ]] ; then
  export cmr_ANDROID_NATIVE_API_LEVEL="21"
else
  echo "Error: cmr_ANDROID_ABI is not set correctly."
  exit 1
fi

if [[ ${cmr_HOST_OS} == "Linux" ]] ; then
  if [[ ${cmr_ANDROID_ABI} == "armeabi-v7a" ]] ; then
    # NOTE: 'armeabi-v7a' API 16 emulator on Linux executes programs regularly
    #       with "Illegal instruction". API 24 on Linux works fine.
    export cmr_ANDROID_EMULATOR_API_LEVEL="24"
  elif [[ ${cmr_ANDROID_ABI} == "arm64-v8a" ]] ; then
    # NOTE: 'arm64-v8a' emulator (any API level) does not start on Linux
    #       with success, boot animation is not ending.
    export cmr_ANDROID_EMULATOR_API_LEVEL="24"
  elif [[ ${cmr_ANDROID_ABI} == "x86" ]] ; then
    # NOTE: 'x86' API 24 emulator does not start on Linux with success.
    #       API 23 on Linux works fine.
    export cmr_ANDROID_EMULATOR_API_LEVEL="23"
  elif [[ ${cmr_ANDROID_ABI} == "x86_64" ]] ; then
    export cmr_ANDROID_EMULATOR_API_LEVEL="24"
  else
    echo "Error: cmr_ANDROID_ABI is not set correctly."
    exit 1
  fi
elif [[ ${cmr_HOST_OS} == "Windows" ]] ; then
  if [[ ${cmr_ANDROID_ABI} == "armeabi-v7a" ]] ; then
    export cmr_ANDROID_EMULATOR_API_LEVEL="24"
  elif [[ ${cmr_ANDROID_ABI} == "arm64-v8a" ]] ; then
    export cmr_ANDROID_EMULATOR_API_LEVEL="24"
  elif [[ ${cmr_ANDROID_ABI} == "x86" ]] ; then
    export cmr_ANDROID_EMULATOR_API_LEVEL="23"
  elif [[ ${cmr_ANDROID_ABI} == "x86_64" ]] ; then
    export cmr_ANDROID_EMULATOR_API_LEVEL="24"
  else
    echo "Error: cmr_ANDROID_ABI is not set correctly."
    exit 1
  fi
else
  echo "Error: cmr_HOST_OS is not set correctly."
  exit 1
fi


# ==== Install Android SDK with emulator and NDK ====

if [[ ( ${cmr_CI} == "ON" ) && ( ! -x "$(command -v ninja)" ) ]]; then
  echo "${cmr_ECHO_PREFIX} Install Ninja"

  if [[ ${cmr_HOST_OS} == "Linux" ]] ; then
    sudo apt-get update
    sudo apt-get install ninja-build
  elif [[ ${cmr_HOST_OS} == "Windows" ]] ; then
    choco install ninja --no-progress
  else
    echo "Error: cmr_HOST_OS is not set correctly."
    exit 1
  fi
fi

if [[ ( ${cmr_CI} == "ON" ) && ( ! -x "$(command -v unzip)" ) ]]; then
  echo "${cmr_ECHO_PREFIX} Install unzip"

  if [[ ${cmr_HOST_OS} == "Windows" ]] ; then
    choco install unzip --no-progress
  else
    echo "Error: cmr_HOST_OS is not set correctly."
    exit 1
  fi
fi


# ==== Android SDK ====
# Android SDK is only needed to find the path to the 'adb'
# in 'test/CMakeLists.txt' 'find_program(adb_exec adb)'

if [[ ( ${cmr_CI} == "ON" ) && ( ! -d ${cmr_ANDROID_SDK} ) ]] ; then
  # https://stackoverflow.com/a/60598900
  # 'platforms' dir must be, at least empty.
  mkdir -p ${cmr_ANDROID_SDK}/platforms
  mkdir -p ${cmr_ANDROID_SDK}/cmdline-tools

  echo "${cmr_ECHO_PREFIX} Download Android SDK"
  wget -nv -c -N -P ${cmr_DOWNLOAD_DIR} ${cmr_ANDROID_CMD_TOOLS_URL}
  echo "${cmr_ECHO_PREFIX} Unpack Android SDK"
  unzip -q ${cmr_DOWNLOAD_DIR}/${cmr_ANDROID_CMD_TOOLS_FILE_NAME} -d ${cmr_ANDROID_SDK}/cmdline-tools

  # https://stackoverflow.com/a/60598900
  yes | ${cmr_WIN_CMD} sdkmanager --licenses

  echo "${cmr_ECHO_PREFIX} Install Android platform-tools"
  ${cmr_WIN_CMD} sdkmanager "platform-tools"

  if [[ ${cmr_BUILD_TESTING} == "ON" ]] ; then
    echo "${cmr_ECHO_PREFIX} Install Android emulator"
    ${cmr_WIN_CMD} sdkmanager "emulator"

    echo "${cmr_ECHO_PREFIX} Install Android system-images"
    ${cmr_WIN_CMD} sdkmanager "system-images;android-${cmr_ANDROID_EMULATOR_API_LEVEL};${cmr_ANDROID_EMULATOR_API_TYPE};${cmr_ANDROID_ABI}"

    echo "${cmr_ECHO_PREFIX} Create Android emulator"
    #echo | ${cmr_WIN_CMD} avdmanager create avd -f -n fg_test -c 1024M -k "system-images;android-${cmr_ANDROID_EMULATOR_API_LEVEL};${cmr_ANDROID_EMULATOR_API_TYPE};${cmr_ANDROID_ABI}"
    echo | ${cmr_WIN_CMD} avdmanager create avd -f -n fg_test -k "system-images;android-${cmr_ANDROID_EMULATOR_API_LEVEL};${cmr_ANDROID_EMULATOR_API_TYPE};${cmr_ANDROID_ABI}"
  fi
fi


# ==== Android NDK ====

if [[ ( ${cmr_CI} == "ON" ) && ( ! -d ${cmr_ANDROID_NDK} ) ]] ; then
  echo "${cmr_ECHO_PREFIX} Download Android NDK"
  wget -nv -c -N -P ${cmr_DOWNLOAD_DIR} ${cmr_ANDROID_NDK_URL}
  echo "${cmr_ECHO_PREFIX} Unpack Android NDK"
  unzip -q ${cmr_DOWNLOAD_DIR}/${cmr_ANDROID_NDK_FILE_NAME} -d ${cmr_ANDROID_NDK_INSTALL_DIR}
fi


# ==== Configure and build host tools project ====

if [[ ${cmr_BUILD_HOST_TOOLS} == "ON" ]]; then
  cd ${cmr_HOST_BUILD_DIR}

  echo "${cmr_ECHO_PREFIX} Configure Host Tools Project"
  ${cmr_CMAKE_CMD} ${cmr_HOST_TOOLS_PROJECT_DIR} \
    -Dcmr_BUILD_MULTIPROC_CNT:STRING=${cmr_JOBS_CNT} \
    -Dcmr_PRINT_DEBUG:BOOL=ON \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
    -DCMAKE_COLOR_MAKEFILE:BOOL=OFF \
    -DBUILD_TESTING:BOOL=OFF \
    -DCMAKE_INSTALL_PREFIX:PATH=${cmr_HOST_INSTALL_DIR} \
    -Dcmr_DOWNLOAD_DIR:PATH=${cmr_DOWNLOAD_DIR} \
    -Dcmr_UNPACKED_DIR:PATH=${cmr_HOST_UNPACKED_DIR} \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DBUILD_SHARED_LIBS:BOOL=OFF \
    -DCMAKE_GENERATOR:STRING="Unix Makefiles" \
    -DLibCMaker_LIB_DIR:PATH=${cmr_SAMPLE_LIB_DIR} \
      -DHOST_TOOLS_STAMP_FILE_NAME:STRING=${cmr_HOST_TOOLS_STAMP_FILE_NAME} \
    "${cmr_LIB_HOST_TOOLS_CMAKE_CONFIG_PARAMS[@]}" \

  echo "${cmr_ECHO_PREFIX} Build Host Tools Project"
  ${cmr_CMAKE_CMD} --build . --parallel ${cmr_JOBS_CNT}
fi


# ==== Configure, build project and run test ====

cd ${cmr_BUILD_DIR}

echo "${cmr_ECHO_PREFIX} Configure Project"
${cmr_CMAKE_CMD} ${cmr_SAMPLE_DIR} \
  -Dcmr_BUILD_MULTIPROC_CNT:STRING=${cmr_JOBS_CNT} \
  -Dcmr_PRINT_DEBUG:BOOL=ON \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
  -DCMAKE_COLOR_MAKEFILE:BOOL=OFF \
  -DBUILD_TESTING:BOOL=${cmr_BUILD_TESTING} \
  -DCMAKE_INSTALL_PREFIX:PATH=${cmr_INSTALL_DIR} \
  -Dcmr_DOWNLOAD_DIR:PATH=${cmr_DOWNLOAD_DIR} \
  -Dcmr_UNPACKED_DIR:PATH=${cmr_UNPACKED_DIR} \
    -DCMAKE_BUILD_TYPE:STRING=${cmr_CMAKE_BUILD_TYPE} \
    -DBUILD_SHARED_LIBS:BOOL=${cmr_BUILD_SHARED_LIBS} \
  -DCMAKE_GENERATOR:STRING="${cmr_CMAKE_GENERATOR}" \
  -DANDROID_NDK:PATH=${cmr_ANDROID_NDK} \
    -DCMAKE_TOOLCHAIN_FILE:PATH=${cmr_CMAKE_TOOLCHAIN_FILE} \
    -DANDROID_ABI:STRING="${cmr_ANDROID_ABI}" \
    -DANDROID_NATIVE_API_LEVEL:STRING=${cmr_ANDROID_NATIVE_API_LEVEL} \
    -DANDROID_TOOLCHAIN:STRING="${cmr_ANDROID_TOOLCHAIN}" \
    -DANDROID_STL:STRING="${cmr_ANDROID_STL}" \
    -DANDROID_CPP_FEATURES:STRING="${cmr_ANDROID_CPP_FEATURES}" \
  -Dcmr_HOST_BUILD_DIR:PATH=${cmr_HOST_BUILD_DIR} \
  "${cmr_LIB_CMAKE_CONFIG_PARAMS[@]}" \


echo "${cmr_ECHO_PREFIX} Build Project"
${cmr_CMAKE_CMD} --build . --parallel ${cmr_JOBS_CNT}


if [[ ${cmr_BUILD_TESTING} == "ON" ]] ; then
  # ==== Run Android emulator ====

  # http://mywiki.wooledge.org/BashSheet
  # [command] & [command]
  # Only the command before the & is executed asynchronously
  # and you must not put a ';' after the '&', the '&' replaces the ';'.

  # NOTE: 'arm64-v8a' emulator (any API level) does not start on Linux
  #       with success, boot animation is not ending.
  # NOTE: 'armeabi-v7a' API 16 emulator on Linux executes programs regularly
  #       with "Illegal instruction". API 24 on Linux works fine.
  # NOTE: 'x86' API 24 emulator does not start on Linux with success.
  #       API 23 on Linux works fine.

  #if [[ ${cmr_ANDROID_ABI} == "arm64-v8a" ]]; then travis_terminate 0 ; fi

  if [[ ${cmr_CI} == "ON" ]]; then
    echo "${cmr_ECHO_PREFIX} Start Android emulator"
    emulator -avd fg_test -memory 1024 -no-window -gpu auto -no-accel -no-snapshot -no-audio -camera-back none -camera-front none &
    source ${cmr_LibCMaker_REPO_DIR}/ci/android-wait-for-emulator.sh
    adb shell input keyevent 82 &
  fi

  echo "${cmr_ECHO_PREFIX} Run tests"
  ${cmr_CTEST_CMD} --output-on-failure
fi
