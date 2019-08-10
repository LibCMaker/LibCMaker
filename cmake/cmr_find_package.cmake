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

function(cmr_find_package)
  set(cmr_CMAKE_MIN_VER 3.4)
  if(APPLE)
    set(cmr_CMAKE_MIN_VER 3.8)
  endif()
  if(IOS AND CMAKE_GENERATOR MATCHES "Xcode")
    set(cmr_CMAKE_MIN_VER 3.15)
  endif()
  cmake_minimum_required(VERSION ${cmr_CMAKE_MIN_VER})


  # Parse args.
  set(options
    # Optional args.
    EXACT QUIET MODULE CONFIG NO_MODULE REQUIRED NOT_USE_VERSION_IN_FIND_PACKAGE
    BUILD_HOST_TOOLS
  )
  set(oneValueArgs
  # Required args.
    LibCMaker_DIR NAME VERSION LIB_DIR
    # Optional args.
    FIND_MODULE_NAME CUSTOM_LOGIC_FILE
    DOWNLOAD_DIR UNPACKED_DIR BUILD_DIR
  )
  set(multiValueArgs
    # Optional args.
    COMPONENTS
  )
  cmake_parse_arguments(find
      "${options}" "${oneValueArgs}" "${multiValueArgs}" "${ARGN}")
  # -> find_EXACT
  # -> find_* ...

  # Required args.
  if(NOT find_LibCMaker_DIR)
    message(FATAL_ERROR "Argument LibCMaker_DIR is not defined.")
  endif()
  if(NOT find_NAME)
    message(FATAL_ERROR "Argument NAME is not defined.")
  endif()
  if(NOT find_VERSION)
    message(FATAL_ERROR "Argument VERSION is not defined.")
  endif()
  if(NOT find_LIB_DIR)
    message(FATAL_ERROR "Argument LIB_DIR is not defined.")
  endif()
  if(find_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR
      "There are unparsed arguments: ${find_UNPARSED_ARGUMENTS}"
    )
  endif()


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
  endif()

  set(module_version ${find_VERSION})
  if(find_NOT_USE_VERSION_IN_FIND_PACKAGE)
    unset(module_version)
  endif()


  # Set vars and dirs.
  string(TOUPPER ${find_NAME} lib_NAME_UPPER)
  string(TOLOWER ${find_NAME} lib_NAME_LOWER)
  set(cmr_lib_NAME "LibCMaker_${find_NAME}")

  set(module_NAME ${find_NAME})
  if(find_FIND_MODULE_NAME)
    set(module_NAME ${find_FIND_MODULE_NAME})
  endif()

  # Append LibCMaker function dir to CMake module path.
  set(cmr_func_DIR "${find_LibCMaker_DIR}/cmake")
  list(FIND CMAKE_MODULE_PATH ${cmr_func_DIR} has_func_dir)
  if(has_func_dir EQUAL -1)
    list(APPEND CMAKE_MODULE_PATH "${cmr_func_DIR}")
  endif()

  # Append library's function dir to CMake module path.
  set(lib_func_DIR "${find_LIB_DIR}/cmake")
  list(FIND CMAKE_MODULE_PATH ${lib_func_DIR} has_func_dir)
  if(has_func_dir EQUAL -1)
    list(APPEND CMAKE_MODULE_PATH "${lib_func_DIR}")
  endif()

  if(find_DOWNLOAD_DIR)
    set(cmr_DOWNLOAD_DIR ${find_DOWNLOAD_DIR})
  else()
    if(NOT cmr_DOWNLOAD_DIR)
      set(cmr_DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}/download)
    endif()
  endif()

  if(find_UNPACKED_DIR)
    set(cmr_UNPACKED_DIR ${find_UNPACKED_DIR})
  else()
    if(NOT cmr_UNPACKED_DIR)
      set(cmr_UNPACKED_DIR ${cmr_DOWNLOAD_DIR}/unpacked)
    endif()
  endif()

  if(find_BUILD_DIR)
    set(cmr_BUILD_DIR ${find_BUILD_DIR})
  else()
    if(NOT cmr_BUILD_DIR)
      set(cmr_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/build_LibCMaker)
    endif()
  endif()

  set(lib_BUILD_DIR ${cmr_BUILD_DIR}/build_${find_NAME})


  include(cmr_lib_cmaker_main)
  include(cmr_printers)


  if(NOT find_QUIET)
    cmr_print_status(
      "======== Build library: ${find_NAME} ${find_VERSION} ========"
    )

    # Debug printers.
    cmr_print_value(find_LibCMaker_DIR)

    cmr_print_value(find_NAME)
    cmr_print_value(find_VERSION)
    cmr_print_value(find_COMPONENTS)

    cmr_print_value(find_LIB_DIR)
    cmr_print_value(cmr_DOWNLOAD_DIR)
    cmr_print_value(cmr_UNPACKED_DIR)
    cmr_print_value(cmr_BUILD_DIR)

    cmr_print_value(find_NOT_USE_VERSION_IN_FIND_PACKAGE)
    cmr_print_value(find_FIND_MODULE_NAME)
    cmr_print_value(find_CUSTOM_LOGIC_FILE)
  endif()

  string(TOUPPER ${module_NAME} module_NAME_UPPER)

  if(find_CUSTOM_LOGIC_FILE AND EXISTS ${find_CUSTOM_LOGIC_FILE})
    include(${find_CUSTOM_LOGIC_FILE})
  else()
    # Try to find already installed lib.
    find_package(${module_NAME} ${module_version} QUIET ${find_args})

    if(NOT ${module_NAME}_FOUND AND NOT ${module_NAME_UPPER}_FOUND)
      cmr_print_status("${find_NAME} is not built, build it.")

      include(cmr_find_package_${lib_NAME_LOWER})

      if(find_REQUIRED)
        list(APPEND find_args REQUIRED)
      endif()
      find_package(${module_NAME} ${module_version} ${find_args})

    else()
      cmr_print_status("${find_NAME} is built, skip its building.")
    endif()
  endif()
endfunction()
