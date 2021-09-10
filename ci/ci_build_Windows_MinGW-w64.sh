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

# https://winlibs.com/

#export cmr_GCC_VER="9.3.0"
#export cmr_Clang_VER="10.0.0"
#export cmr_MinGW_w64_VER="7.0.0"
#export cmr_winlibs_VER="r4"

#export cmr_GCC_VER="10.3.0"
#export cmr_Clang_VER="11.1.0"
#export cmr_MinGW_w64_VER="8.0.0"
#export cmr_winlibs_VER="r2"

export cmr_GCC_VER="11.2.0"
export cmr_Clang_VER="12.0.1"
export cmr_MinGW_w64_VER="9.0.0"
export cmr_winlibs_VER="r1"

if [[ ${cmr_PLATFORM} == "x86_64" ]] ; then
  export cmr_EXCEPTION_HANDLING="seh"
  if [[ -z "${MINGW_HOME}" ]]; then
    export MINGW_HOME="${cmr_INSTALL_DIR}/mingw64"
  fi
elif [[ ${cmr_PLATFORM} == "i686" ]] ; then
  export cmr_EXCEPTION_HANDLING="dwarf"
  if [[ -z "${MINGW_HOME}" ]]; then
    export MINGW_HOME="${cmr_INSTALL_DIR}/mingw32"
  fi
else
  echo "Error: cmr_PLATFORM is not set correctly."
  exit 1
fi

export cmr_MINGW_ARCH_NAME="winlibs-${cmr_PLATFORM}-posix-${cmr_EXCEPTION_HANDLING}-gcc-${cmr_GCC_VER}-llvm-${cmr_Clang_VER}-mingw-w64-${cmr_MinGW_w64_VER}-${cmr_winlibs_VER}.7z"
export cmr_MINGW_URL="https://github.com/brechtsanders/winlibs_mingw/releases/download/${cmr_GCC_VER}-${cmr_Clang_VER}-${cmr_MinGW_w64_VER}-${cmr_winlibs_VER}/${cmr_MINGW_ARCH_NAME}"

export PATH=${cmr_INSTALL_DIR}/bin:${cmr_INSTALL_DIR}/bin64:${cmr_INSTALL_DIR}/lib:${cmr_CMAKE_DIR}/bin:${MINGW_HOME}/bin:${PATH}


# ==== Set up compiler ====
if [[ ${cmr_COMPILER} == "GCC" ]] ; then
  export CC="gcc"
  export CXX="g++"
elif [[ ${cmr_COMPILER} == "Clang" ]] ; then
  export CC="clang"
  export CXX="clang++"
else
  echo "Error: cmr_COMPILER is not set correctly."
  exit 1
fi


# ==== Install MinGW-w64 tools ====
if [[ ${cmr_CI} == "ON" ]]; then
  echo "${cmr_ECHO_PREFIX} Download MinGW-w64 tools"
  wget -nv -c -N -P ${cmr_DOWNLOAD_DIR}/${cmr_MINGW_ARCH_NAME} ${cmr_MINGW_URL}
  echo "${cmr_ECHO_PREFIX} Unpack MinGW-w64 tools"
  7z.exe x -aoa -o${cmr_INSTALL_DIR} ${cmr_DOWNLOAD_DIR}/${cmr_MINGW_ARCH_NAME}
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
  "${cmr_LIB_CMAKE_CONFIG_PARAMS[@]}" \

#    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION:BOOL=${cmr_CMAKE_INTERPROCEDURAL_OPTIMIZATION} \

echo "${cmr_ECHO_PREFIX} Build Project"
${cmr_CMAKE_CMD} --build . --parallel ${cmr_JOBS_CNT}

if [[ ${cmr_BUILD_TESTING} == "ON" ]] ; then
  echo "${cmr_ECHO_PREFIX} Run tests"
  ${cmr_CTEST_CMD} --output-on-failure
fi
