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


# Dependencies

# LibCMaker   GoogleTest  AGG
#
#                         Dirent      FontConfig
#                         Expat       FontConfig
#
#                         HarfBuzz    FreeType    FontConfig
#
#                         ICU         Boost
#                                     SQLite3     SQLiteModernCPP
#
#                         Pixman                    Cairo
#                         STLCache
#                         wxWidgets
#                         zlib        libpng      Cairo


set -e


# ==== Set variables ====

if [[ -z "${cmr_ECHO_PREFIX}" ]]; then
  export cmr_ECHO_PREFIX="==== [LibCMaker CI] ==== "
fi

if [[ -z "${cmr_CI}" && ${CI} == "true" ]]; then
  export cmr_CI="ON"
fi

if [[ ${cmr_CI} == "ON" ]]; then
  set -v
fi


if [[ -z "${cmr_BUILD_TESTING}" ]]; then
  export cmr_BUILD_TESTING="ON"
fi
if [[ -z "${cmr_JOBS_CNT}" ]]; then
  export cmr_JOBS_CNT="4"
fi

if [[ -z "${cmr_HOST_OS}" ]]; then
  # Possible values are "Linux", "Windows", or "macOS" for cmr_HOST_OS.
  export cmr_HOST_OS=${RUNNER_OS}
fi

if [[ -z "${cmr_LibCMaker_DIR_NAME}" ]]; then
  export cmr_LibCMaker_DIR_NAME="LibCMaker"
fi
if [[ -z "${cmr_LibCMaker_Lib_DIR_NAME}" ]]; then
  export cmr_LibCMaker_Lib_DIR_NAME="LibCMaker_Lib"
fi
if [[ -z "${cmr_WORK_DIR}" ]]; then
  export cmr_WORK_DIR=${GITHUB_WORKSPACE}
fi
if [[ -z "${cmr_LibCMaker_REPO_DIR}" ]]; then
  export cmr_LibCMaker_REPO_DIR=${cmr_WORK_DIR}/${cmr_LibCMaker_DIR_NAME}
fi
if [[ -z "${cmr_REPO_DIR}" ]]; then
  export cmr_REPO_DIR=${cmr_WORK_DIR}/${cmr_LibCMaker_Lib_DIR_NAME}
fi

#export cmr_SAMPLE_SRC_DIR="${cmr_REPO_DIR}/samples/ci_sample"
#export cmr_SAMPLE_DIR="${cmr_WORK_DIR}/ci_sample"
export cmr_SAMPLE_DIR="${cmr_REPO_DIR}/samples/ci_sample"
export cmr_SAMPLE_LIB_DIR="${cmr_SAMPLE_DIR}/libs"

if [[ -z "${cmr_BUILD_DIR}" ]]; then
  export cmr_BUILD_DIR="${cmr_WORK_DIR}/build"
fi
if [[ -z "${cmr_INSTALL_DIR}" ]]; then
  export cmr_INSTALL_DIR="${cmr_BUILD_DIR}/install"
fi
if [[ -z "${cmr_DOWNLOAD_DIR}" ]]; then
  export cmr_DOWNLOAD_DIR="${cmr_BUILD_DIR}/download"
fi
if [[ -z "${cmr_UNPACKED_DIR}" ]]; then
  export cmr_UNPACKED_DIR="${cmr_DOWNLOAD_DIR}/unpacked"
fi

export cmr_HOST_TOOLS_PROJECT_DIR="${cmr_SAMPLE_DIR}/host_tools"

if [[ -z "${cmr_HOST_UNPACKED_DIR}" ]]; then
  export cmr_HOST_UNPACKED_DIR="${cmr_WORK_DIR}/unpacked_host_tools"
fi
if [[ -z "${cmr_HOST_BUILD_DIR}" ]]; then
  export cmr_HOST_BUILD_DIR="${cmr_WORK_DIR}/build_host_tools"
fi
if [[ -z "${cmr_HOST_INSTALL_DIR}" ]]; then
  export cmr_HOST_INSTALL_DIR="${cmr_INSTALL_DIR}/host_tools"
fi
if [[ -z "${cmr_HOST_TOOLS_STAMP_FILE_NAME}" ]]; then
  export cmr_HOST_TOOLS_STAMP_FILE_NAME="host_tools_stamp"
fi

export cmr_GIT_CLONE_CMD="git clone --depth 1 https://github.com/LibCMaker"

if [[ ${cmr_LIB_LINKING} == "shared" ]] ; then
  export cmr_BUILD_SHARED_LIBS="ON"
elif [[ ${cmr_LIB_LINKING} == "static" ]] ; then
  export cmr_BUILD_SHARED_LIBS="OFF"
else
  echo "Error: cmr_LIB_LINKING is not set correctly."
  exit 1
fi

# See also CMake module "CheckIPOSupported".
if [[ ${cmr_CMAKE_BUILD_TYPE} == "Debug" ]] ; then
  export cmr_CMAKE_INTERPROCEDURAL_OPTIMIZATION="OFF"
elif [[ ${cmr_CMAKE_BUILD_TYPE} == "Release" ]] ; then
  export cmr_CMAKE_INTERPROCEDURAL_OPTIMIZATION="ON"
else
  echo "Error: cmr_CMAKE_BUILD_TYPE is not set correctly."
  exit 1
fi


# === CMake ===

export cmr_CMAKE_MAJOR_VER="3"
export cmr_CMAKE_MINOR_VER="23"
export cmr_CMAKE_PATCH_VER="1"

if [[ ${cmr_HOST_OS} == "Linux" ]] ; then
#  export cmr_CMAKE_HOST="Linux-x86_64"
  export cmr_CMAKE_HOST="linux-x86_64"
  export cmr_CMAKE_AR_EXT="tar.gz"
elif [[ ${cmr_HOST_OS} == "macOS" ]] ; then
#  export cmr_CMAKE_HOST="Darwin-x86_64"
  export cmr_CMAKE_HOST="macos-universal"
  export cmr_CMAKE_AR_EXT="tar.gz"
elif [[ ${cmr_HOST_OS} == "Windows" ]] ; then
#  export cmr_CMAKE_HOST="win64-x64"
  export cmr_CMAKE_HOST="windows-x86_64"
  export cmr_CMAKE_AR_EXT="zip"
else
  echo "Error: cmr_HOST_OS is not set correctly."
  exit 1
fi

export cmr_CMAKE_RELEASE="cmake-${cmr_CMAKE_MAJOR_VER}.${cmr_CMAKE_MINOR_VER}.${cmr_CMAKE_PATCH_VER}-${cmr_CMAKE_HOST}"
export cmr_CMAKE_AR_FILE_NAME="${cmr_CMAKE_RELEASE}.${cmr_CMAKE_AR_EXT}"
#export cmr_CMAKE_BASE_URL="https://cmake.org/files/v${cmr_CMAKE_MAJOR_VER}.${cmr_CMAKE_MINOR_VER}"
export cmr_CMAKE_BASE_URL="https://github.com/Kitware/CMake/releases/download/v${cmr_CMAKE_MAJOR_VER}.${cmr_CMAKE_MINOR_VER}.${cmr_CMAKE_PATCH_VER}"

if [[ -z "${cmr_CMAKE_DIR}" ]]; then
  if [[ ( ${cmr_HOST_OS} == "Linux" ) || ( ${cmr_HOST_OS} == "Windows" ) ]] ; then
    export cmr_CMAKE_DIR="${cmr_INSTALL_DIR}/${cmr_CMAKE_RELEASE}"
  elif [[ ${cmr_HOST_OS} == "macOS" ]] ; then
    export cmr_CMAKE_DIR="${cmr_INSTALL_DIR}/${cmr_CMAKE_RELEASE}/CMake.app/Contents"
  fi
fi

export cmr_CMAKE_CMD="${cmr_CMAKE_DIR}/bin/cmake"
export cmr_CTEST_CMD="${cmr_CMAKE_DIR}/bin/ctest"


# === Get lib params ===
if [[ -f ${cmr_REPO_DIR}/ci/ci_lib_params.sh ]] ; then
  source ${cmr_REPO_DIR}/ci/ci_lib_params.sh
fi


# ==== Init work dirs ====
echo "${cmr_ECHO_PREFIX} Init work dir"

#cp -r ${cmr_SAMPLE_SRC_DIR} ${cmr_WORK_DIR}
mkdir -p ${cmr_SAMPLE_LIB_DIR}
#cp -r ${cmr_REPO_DIR} ${cmr_SAMPLE_LIB_DIR}
#cp -r ${cmr_LibCMaker_REPO_DIR} ${cmr_SAMPLE_LIB_DIR}

mkdir -p ${cmr_DOWNLOAD_DIR}
mkdir -p ${cmr_UNPACKED_DIR}
mkdir -p ${cmr_BUILD_DIR}
mkdir -p ${cmr_INSTALL_DIR}

if [[ ${cmr_BUILD_HOST_TOOLS} == "ON" ]]; then
  mkdir -p ${cmr_HOST_UNPACKED_DIR}
  mkdir -p ${cmr_HOST_BUILD_DIR}
  mkdir -p ${cmr_HOST_INSTALL_DIR}
fi


# === Clone deps lib repos ===
echo "${cmr_ECHO_PREFIX} Clone deps repos"
# https://superuser.com/a/360986
# https://linuxhint.com/bash_append_array/
for cmr_LIB_DEPS_NAME in "${cmr_LIB_DEPS_NAMES[@]}" ; do
  if [[ ! -d ${cmr_SAMPLE_LIB_DIR}/${cmr_LIB_DEPS_NAME} ]] ; then
    ${cmr_GIT_CLONE_CMD}/${cmr_LIB_DEPS_NAME}.git ${cmr_SAMPLE_LIB_DIR}/${cmr_LIB_DEPS_NAME}
  fi
done


# ==== Install wget ====
if [[ ( ${cmr_CI} == "ON" ) && ( ${cmr_HOST_OS} == "Windows" ) && ( ! -x "$(command -v wget)" ) ]] ; then
  echo "${cmr_ECHO_PREFIX} Install wget"
  choco install wget --no-progress
fi


# ==== Install CMake ====
if [[ ( ${cmr_CI} == "ON" ) && ( ! -x ${cmr_CMAKE_CMD} ) ]] ; then
  echo "${cmr_ECHO_PREFIX} wget CMake"
  wget -nv -c -N -P ${cmr_DOWNLOAD_DIR} ${cmr_CMAKE_BASE_URL}/${cmr_CMAKE_AR_FILE_NAME}
  if [[ ${cmr_HOST_OS} == "Windows" ]] ; then
    echo "${cmr_ECHO_PREFIX} Unpack CMake with 7z"
    7z.exe x -aoa -o${cmr_INSTALL_DIR} ${cmr_DOWNLOAD_DIR}/${cmr_CMAKE_AR_FILE_NAME}
  else
    echo "${cmr_ECHO_PREFIX} Unpack CMake with tar"
    tar -xf ${cmr_DOWNLOAD_DIR}/${cmr_CMAKE_AR_FILE_NAME} --directory ${cmr_INSTALL_DIR}
  fi
fi

${cmr_CMAKE_CMD} --version


# === Install packages for lib ===
if [[ -f ${cmr_REPO_DIR}/ci/ci_install_packages.sh ]] ; then
  source ${cmr_REPO_DIR}/ci/ci_install_packages.sh
fi


# ==== Build project and run test ====
source ${cmr_LibCMaker_REPO_DIR}/ci/ci_build_${cmr_TARGET}.sh
