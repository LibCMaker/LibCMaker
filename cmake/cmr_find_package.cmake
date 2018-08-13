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

include(CMakeParseArguments)  # cmake_parse_arguments()

include(cmr_print_status)

function(cmr_find_package lib_NAME lib_VERSION cmlib_SRC_DIR)
  # Parse args.
  set(options
    # Optional args.
    EXACT QUIET MODULE CONFIG NO_MODULE REQUIRED
  )
  set(oneValueArgs
    # Optional args.
    FIND_MODULE_NAME
  )
  set(multiValueArgs
    # Optional args.
    COMPONENTS
  )
  cmake_parse_arguments(find
      "${options}" "${oneValueArgs}" "${multiValueArgs}" "${ARGN}")
  # -> find_EXACT
  # -> find_* ...

  if(find_EXACT)
    list(APPEND find_args EXACT)
  endif()
  if(find_QUIET)
    list(APPEND find_args QUIET)
  endif()
  if(find_MODULE)
    list(APPEND find_args MODULE)
  endif()
  if(find_CONFIG)
    list(APPEND find_args CONFIG)
  endif()
  if(find_NO_MODULE)
    list(APPEND find_args NO_MODULE)
  endif()
  if(find_COMPONENTS)
    list(APPEND find_args COMPONENTS ${find_COMPONENTS})
    list(APPEND lib_cmaker_args COMPONENTS ${find_COMPONENTS})
  endif()

  # Set vars and dirs.
  string(TOUPPER ${lib_NAME} lib_NAME_UPPER)
  string(TOLOWER ${lib_NAME} lib_NAME_LOWER)
  set(cmr_NAME "LibCMaker_${lib_NAME}")

  set(module_NAME ${lib_NAME})
  if(find_FIND_MODULE_NAME)
    set(module_NAME ${find_FIND_MODULE_NAME})
  endif()

  if(NOT cmr_DOWNLOAD_DIR)
    set(cmr_DOWNLOAD_DIR ${CMAKE_BINARY_DIR}/download)
  endif()
  if(NOT cmr_UNPACKED_DIR)
    set(cmr_UNPACKED_DIR ${cmr_DOWNLOAD_DIR}/unpacked)
  endif()
  if(NOT cmr_BUILD_DIR)
    set(cmr_BUILD_DIR ${CMAKE_BINARY_DIR}/build_LibCMaker)
  endif()
  set(lib_BUILD_DIR ${cmr_BUILD_DIR}/build_${lib_NAME})

  # Try to find already installed lib.
  find_package(${module_NAME} ${lib_VERSION} QUIET ${find_args})

  if(NOT ${lib_NAME}_FOUND AND NOT ${lib_NAME_UPPER}_FOUND)
    cmr_print_status("${lib_NAME} is not installed, build and install it.")

    include(${cmlib_SRC_DIR}/lib_cmaker_${lib_NAME_LOWER}.cmake)
    lib_cmaker_${lib_NAME_LOWER}(
      VERSION       ${lib_VERSION}
      DOWNLOAD_DIR  ${cmr_DOWNLOAD_DIR}
      UNPACKED_DIR  ${cmr_UNPACKED_DIR}
      BUILD_DIR     ${lib_BUILD_DIR}
      ${lib_cmaker_args}
    )

    if(find_REQUIRED)
      list(APPEND find_args REQUIRED)
    endif()
    find_package(${module_NAME} ${lib_VERSION} ${find_args})

  else()
    cmr_print_status(
      "${lib_NAME} is installed, skip building and installing it."
    )
  endif()
endfunction()
