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
export PATH=${cmr_INSTALL_DIR}/bin:${cmr_INSTALL_DIR}/bin64:${cmr_INSTALL_DIR}/lib:${PATH}

# ==== Set up compiler ====
export cmr_CMAKE_GENERATOR="Visual Studio 15 2017"

if [[ ${cmr_PLATFORM} == "x64" ]] ; then
  export cmr_CMAKE_GENERATOR_PLATFORM="x64"
  export cmr_CMAKE_GENERATOR_TOOLSET="v141,host=x64"
elif [[ ${cmr_PLATFORM} == "Win32" ]] ; then
  export cmr_CMAKE_GENERATOR_PLATFORM="Win32"
  export cmr_CMAKE_GENERATOR_TOOLSET="v141,host=x64"
elif [[ ${cmr_PLATFORM} == "WinXP" ]] ; then
  export cmr_CMAKE_GENERATOR_PLATFORM="Win32"
  export cmr_CMAKE_GENERATOR_TOOLSET="v141_xp,host=x64"
else
  echo "Error: cmr_PLATFORM is not set correctly."
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
    -DCMAKE_GENERATOR_PLATFORM:STRING="${cmr_CMAKE_GENERATOR_PLATFORM}" \
    -DCMAKE_GENERATOR_TOOLSET:STRING="${cmr_CMAKE_GENERATOR_TOOLSET}" \
    -DCMAKE_CONFIGURATION_TYPES:STRING="${cmr_CMAKE_BUILD_TYPE}" \
  -Dcmr_VS_GENERATOR_VERBOSITY_LEVEL:STRING="normal" \
  "${cmr_LIB_CMAKE_CONFIG_PARAMS[@]}" \

#    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION:BOOL=${cmr_CMAKE_INTERPROCEDURAL_OPTIMIZATION} \

echo "${cmr_ECHO_PREFIX} Build Project"
${cmr_CMAKE_CMD} --build . --parallel ${cmr_JOBS_CNT} --config ${cmr_CMAKE_BUILD_TYPE}

if [[ ${cmr_BUILD_TESTING} == "ON" ]] ; then
  echo "${cmr_ECHO_PREFIX} Run tests"
  ${cmr_CTEST_CMD} --output-on-failure --build-config ${cmr_CMAKE_BUILD_TYPE}
fi
