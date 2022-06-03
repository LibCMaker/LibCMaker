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
    -DCMAKE_GENERATOR:STRING="${cmr_CMAKE_GENERATOR}" \
      -DCMAKE_CONFIGURATION_TYPES:STRING=Release \
    -DLibCMaker_LIB_DIR:PATH=${cmr_SAMPLE_LIB_DIR} \
      -DHOST_TOOLS_STAMP_FILE_NAME:STRING=${cmr_HOST_TOOLS_STAMP_FILE_NAME} \
    "${cmr_LIB_HOST_TOOLS_CMAKE_CONFIG_PARAMS[@]}" \

  #-Dcmr_XCODE_GENERATOR_VERBOSITY_LEVEL:STRING="-quiet" \

  echo "${cmr_ECHO_PREFIX} Build Host Tools Project"
  ${cmr_CMAKE_CMD} --build . --parallel ${cmr_JOBS_CNT} --config Release
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
    -DCMAKE_CONFIGURATION_TYPES:STRING="${cmr_CMAKE_BUILD_TYPE}" \
  -DCMAKE_TOOLCHAIN_FILE:PATH=${cmr_SAMPLE_LIB_DIR}/LibCMaker/cmake/ios.toolchain.cmake \
    -DPLATFORM:STRING=${cmr_PLATFORM} \
    -DDEPLOYMENT_TARGET:STRING="11.0" \
    -DARCHS:STRING="x86_64" \
    -DENABLE_VISIBILITY:BOOL=${cmr_BUILD_SHARED_LIBS} \
  -Dcmr_HOST_BUILD_DIR:PATH=${cmr_HOST_BUILD_DIR} \
  "${cmr_LIB_CMAKE_CONFIG_PARAMS[@]}" \

#  -Dcmr_XCODE_GENERATOR_VERBOSITY_LEVEL:STRING="-quiet" \
#    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION:BOOL=${cmr_CMAKE_INTERPROCEDURAL_OPTIMIZATION} \

echo "${cmr_ECHO_PREFIX} Build Project"
${cmr_CMAKE_CMD} --build . --parallel ${cmr_JOBS_CNT} --config ${cmr_CMAKE_BUILD_TYPE}

if [[ ${cmr_BUILD_TESTING} == "ON" ]] ; then
  echo "${cmr_ECHO_PREFIX} Start iOS simulator"
  xcrun simctl boot "iPhone 11"

  # For open the running simulator run:
  #open -a Simulator

  # View app bundle dir in simulator:
  # ~/Library/Developer/CoreSimulator/Devices/<SIMULATOR_ID>/data/Containers/Bundle/Application/<APPLICATION_ID>/Example_test.app
  # View work dir in simulator:
  # ~/Library/Developer/CoreSimulator/Devices/<SIMULATOR_ID>/data/Containers/Data/Application/<APPLICATION_ID>/Documents

  echo "${cmr_ECHO_PREFIX} Run tests"
  ${cmr_CTEST_CMD} --output-on-failure --build-config ${cmr_CMAKE_BUILD_TYPE}
fi
