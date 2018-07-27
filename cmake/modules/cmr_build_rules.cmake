# ****************************************************************************
#  Project:  LibCMaker
#  Purpose:  A CMake build scripts for build libraries with CMake
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2018 NikitaFeodonit
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

include(cmr_get_download_params)
include(cmr_printers)

function(cmr_build_rules)
  cmake_minimum_required(VERSION ${cmr_CMAKE_MIN_VER})

  # To prevent the list expansion on an argument with ';'.
  # Restoring.
  # See also:
  # http://stackoverflow.com/a/20989991
  # http://stackoverflow.com/a/20985057
  if(lib_COMPONENTS)
    string(REPLACE " " ";" lib_COMPONENTS "${lib_COMPONENTS}")
  endif()
  if(CMAKE_FIND_ROOT_PATH)
    string(REPLACE " " ";" CMAKE_FIND_ROOT_PATH "${CMAKE_FIND_ROOT_PATH}")
  endif()

  # Required vars.
  if(NOT lib_VERSION)
    cmr_print_fatal_error("Variable lib_VERSION is not defined.")
  endif()
  if(NOT lib_BUILD_DIR)
    cmr_print_fatal_error("Variable lib_BUILD_DIR is not defined.")
  endif()

  # Optional vars.
  if(NOT lib_DOWNLOAD_DIR)
    set(lib_DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif()
  if(NOT lib_UNPACKED_DIR)
    set(lib_UNPACKED_DIR "${lib_DOWNLOAD_DIR}/sources")
  endif()

  cmr_get_download_params(
    ${lib_VERSION} ${lib_DOWNLOAD_DIR} ${lib_UNPACKED_DIR} ${lib_BUILD_DIR}
    lib_URL lib_ARCH_FILE lib_SHA lib_SHA_ALG
    lib_UNPACK_TO_DIR lib_SRC_DIR lib_VERSION_BUILD_DIR)

  if(NOT lib_SHA)
    cmr_print_fatal_error(
      "${lib_NAME} library version ${version} is not supported."
    )
  endif()

  # Download tar file.
  if(NOT EXISTS "${lib_ARCH_FILE}")
    cmr_print_message("Download ${lib_URL}")
    file(
      DOWNLOAD "${lib_URL}" "${lib_ARCH_FILE}"
      EXPECTED_HASH ${lib_SHA_ALG}=${lib_SHA}
      SHOW_PROGRESS
    )
  endif()

  # Extract tar file.
  if(NOT EXISTS "${lib_SRC_DIR}")
    cmr_print_message(
      "Extract\n  '${lib_ARCH_FILE}'\nto\n  '${lib_UNPACK_TO_DIR}'"
    )
    file(MAKE_DIRECTORY ${lib_UNPACK_TO_DIR})
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xf ${lib_ARCH_FILE} # TODO: arch opts (z, j, ...)
      WORKING_DIRECTORY ${lib_UNPACK_TO_DIR}
    )
  endif()

  # Configure, build and install rules.
  include(cmr_build_rules_${lower_lib_NAME})

endfunction()
