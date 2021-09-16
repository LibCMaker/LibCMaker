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
export cmr_LibCMaker_Lib_DIR_NAME="LibCMaker_GoogleTest"


# === CMake ===
export cmr_CMAKE_DIR="/path/to/cmake"


# === Targets ===
# NOTE: Uncomment needed.

## === Linux ===
#export cmr_TARGET="Linux"
#export cmr_PLATFORM="x64"
#export cmr_COMPILER="GCC"
#export cmr_CMAKE_BUILD_TYPE="Debug"
#export cmr_LIB_LINKING="shared"
#export cmr_CMAKE_GENERATOR="Unix Makefiles"
#export cmr_HOST_OS="Linux"
#export cmr_GCC_VER="10"
#export cmr_GLANG_VER="12"


## === Windows, MSVC ===
#export cmr_TARGET="Windows_MSVC"
#export cmr_PLATFORM="x64"
#export cmr_COMPILER="MSVC"
#export cmr_CMAKE_BUILD_TYPE="Debug"
#export cmr_LIB_LINKING="shared"
#export cmr_CMAKE_GENERATOR="Visual Studio"
#export cmr_HOST_OS="Windows"


## === Windows, MinGW-w64 ===
#export cmr_TARGET="Windows_MinGW-w64"
#export cmr_PLATFORM="x86_64"
#export cmr_COMPILER="GCC"
#export cmr_CMAKE_BUILD_TYPE="Release"
#export cmr_LIB_LINKING="static"
#export cmr_CMAKE_GENERATOR="MinGW Makefiles"
#export cmr_HOST_OS="Windows"


## === Android on Linux ===
#export cmr_TARGET="Android_Linux"
#export cmr_PLATFORM="armeabi-v7a"
#export cmr_COMPILER="Clang"
#export cmr_CMAKE_BUILD_TYPE="Debug"
#export cmr_LIB_LINKING="shared"
#export cmr_CMAKE_GENERATOR="Ninja"
#export cmr_HOST_OS="Linux"


## === Android, on Windows ===
#export cmr_TARGET="Android_Windows"
#export cmr_PLATFORM="armeabi-v7a"
#export cmr_COMPILER="Clang"
#export cmr_CMAKE_BUILD_TYPE="Debug"
#export cmr_LIB_LINKING="shared"
#export cmr_CMAKE_GENERATOR="Ninja"
#export cmr_HOST_OS="Windows"


# === Common variables ===

export cmr_CI="OFF"

export cmr_BUILD_TESTING="ON"
export cmr_JOBS_CNT="4"

#export cmr_LibCMaker_REPO_DIR=="${cmr_PARENT_DIR_1}"
export cmr_LibCMaker_REPO_DIR="${cmr_PARENT_DIR_2}/${cmr_LibCMaker_DIR_NAME}"
export cmr_REPO_DIR="${cmr_PARENT_DIR_2}/${cmr_LibCMaker_Lib_DIR_NAME}"

export cmr_WORK_DIR="${cmr_REPO_DIR}/samples/ci_sample"
export cmr_BUILD_DIR="${cmr_WORK_DIR}/build"
export cmr_INSTALL_DIR="${cmr_BUILD_DIR}/install"
export cmr_DOWNLOAD_DIR="${cmr_PARENT_DIR_3}/.downloads"
export cmr_UNPACKED_DIR="${cmr_BUILD_DIR}/unpacked"

export cmr_HOST_UNPACKED_DIR="${cmr_WORK_DIR}/unpacked_host_tools"
export cmr_HOST_BUILD_DIR="${cmr_WORK_DIR}/build_host_tools"
export cmr_HOST_INSTALL_DIR="${cmr_INSTALL_DIR}/host_tools"
export cmr_HOST_TOOLS_STAMP_FILE_NAME="host_tools_stamp"

export cmr_ANDROID_CMD_TOOLS_VERSION="7583922"
export cmr_ANDROID_SDK="${cmr_DOWNLOAD_DIR}/android-sdk-${cmr_ANDROID_CMD_TOOLS_VERSION}"
export cmr_ANDROID_NDK="${cmr_DOWNLOAD_DIR}/android-ndk-r23"
export cmr_ANDROID_NDK_INSTALL_DIR="${cmr_DOWNLOAD_DIR}"

export MINGW_HOME="/path/to/mingw64"


# === Steps for Android ===
# NOTE: Uncomment if needed.
#source "${cmr_LibCMaker_REPO_DIR}/samples/run-Android-emulator.sh"


# === Run build ===
if [[ ! -d ${cmr_WORK_DIR}/libs/${cmr_LibCMaker_Lib_DIR_NAME} ]] ; then
  ln -s ${cmr_REPO_DIR} ${cmr_WORK_DIR}/libs
fi

source "${cmr_LibCMaker_REPO_DIR}/ci/ci_build.sh"
