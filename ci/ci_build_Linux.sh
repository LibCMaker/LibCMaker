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


# ==== Set up compiler ====
if [[ ${cmr_COMPILER} == "GCC" ]] ; then
  if [[ -z "${cmr_GCC_VER}" ]]; then
    export cmr_GCC_VER="11"
  fi

  export CC="gcc-${cmr_GCC_VER}"
  export CXX="g++-${cmr_GCC_VER}"

  if [[ ${cmr_CI} == "ON" ]]; then
    sudo add-apt-repository ppa:ubuntu-toolchain-r/test
    sudo apt-get update
    sudo apt-get install gcc-${cmr_GCC_VER} g++-${cmr_GCC_VER}
  fi

elif [[ ${cmr_COMPILER} == "Clang" ]] ; then
  export cmr_GLANG_VER="12"
  export CC="clang-${cmr_GLANG_VER}"
  export CXX="clang++-${cmr_GLANG_VER}"

  if [[ ${cmr_CI} == "ON" ]]; then
    echo "${cmr_ECHO_PREFIX} Install Clang"
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
    sudo add-apt-repository "deb http://apt.llvm.org/bionic/  llvm-toolchain-bionic-${cmr_GLANG_VER}  main"
    sudo apt-get update
    sudo apt-get install clang-${cmr_GLANG_VER}
  fi

else
  echo "Error: cmr_COMPILER is not set correctly."
  exit 1
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
