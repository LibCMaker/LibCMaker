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

function(lib_cmaker_init)
  set(cmr_CMAKE_MIN_VER 3.3)
  cmake_minimum_required(VERSION ${cmr_CMAKE_MIN_VER})

  if(NOT cmr_lib_NAME)
    message(FATAL_ERROR "Please set cmr_lib_NAME with library name.")
  endif()
  if(NOT LIBCMAKER_SRC_DIR)
    message(FATAL_ERROR
      "Please set LIBCMAKER_SRC_DIR with path to LibCMaker root.")
  endif()

  string(TOLOWER ${cmr_lib_NAME} lower_lib_NAME)

  # Append LibCMaker modules dir to CMake module path.
  set(LIBCMAKER_MODULES_DIR "${LIBCMAKER_SRC_DIR}/cmake/modules")
  list(FIND CMAKE_MODULE_PATH ${LIBCMAKER_MODULES_DIR} has_MODULES_DIR)
  if(has_MODULES_DIR EQUAL -1)
    list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_MODULES_DIR}")
    set(changed_CMAKE_MODULE_PATH ON)
  endif()

  # Append library's LibCMaker modules dir to CMake module path.
  set(lcm_${cmr_lib_NAME}_MODULES_DIR "${lcm_${cmr_lib_NAME}_SRC_DIR}/cmake/modules")
  list(FIND CMAKE_MODULE_PATH ${lcm_${cmr_lib_NAME}_MODULES_DIR} has_MODULES_DIR)
  if(has_MODULES_DIR EQUAL -1)
    list(APPEND CMAKE_MODULE_PATH "${lcm_${cmr_lib_NAME}_MODULES_DIR}")
    set(changed_CMAKE_MODULE_PATH ON)
  endif()

  # Required includes.
  include(cmr_lib_cmaker_main RESULT_VARIABLE cmr_lib_cmaker_main_PATH)
  include(cmr_printers RESULT_VARIABLE cmr_printers_PATH)

  # Parse args.
  set(options
    # Optional args.
  )
  set(oneValueArgs
    # Required args.
    VERSION BUILD_DIR
    # Optional args.
    DOWNLOAD_DIR UNPACKED_DIR
  )
  set(multiValueArgs
    # Optional args.
    COMPONENTS
  )
  cmake_parse_arguments(arg
      "${options}" "${oneValueArgs}" "${multiValueArgs}" "${ARGN}")
  # -> arg_VERSION
  # -> arg_BUILD_DIR
  # -> arg_* ...

  cmr_print_status("======== Build library: ${cmr_lib_NAME} ${arg_VERSION} ========")

  # Debug printers.
  cmr_print_value(LIBCMAKER_SRC_DIR)

  cmr_print_value(arg_VERSION)
  cmr_print_value(arg_COMPONENTS)
  cmr_print_value(arg_DOWNLOAD_DIR)
  cmr_print_value(arg_UNPACKED_DIR)
  cmr_print_value(arg_BUILD_DIR)

  # Required args.
  if(NOT arg_VERSION)
    cmr_print_error("Argument VERSION is not defined.")
  endif()
  if(NOT arg_BUILD_DIR)
    cmr_print_error("Argument BUILD_DIR is not defined.")
  endif()
  if(arg_UNPARSED_ARGUMENTS)
    cmr_print_error("There are unparsed arguments: ${arg_UNPARSED_ARGUMENTS}")
  endif()

  # Set vars to PARENT_SCOPE.
  set(cmr_lib_cmaker_main_PATH ${cmr_lib_cmaker_main_PATH} PARENT_SCOPE)
  set(cmr_printers_PATH ${cmr_printers_PATH} PARENT_SCOPE)

  set(cmr_CMAKE_MIN_VER ${cmr_CMAKE_MIN_VER} PARENT_SCOPE)
  if(changed_CMAKE_MODULE_PATH)
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
  endif()

  set(lower_lib_NAME ${lower_lib_NAME} PARENT_SCOPE)

  set(arg_VERSION ${arg_VERSION} PARENT_SCOPE)
  set(arg_COMPONENTS ${arg_COMPONENTS} PARENT_SCOPE)
  set(arg_DOWNLOAD_DIR ${arg_DOWNLOAD_DIR} PARENT_SCOPE)
  set(arg_UNPACKED_DIR ${arg_UNPACKED_DIR} PARENT_SCOPE)
  set(arg_BUILD_DIR ${arg_BUILD_DIR} PARENT_SCOPE)

  unset(lcm_CMAKE_ARGS PARENT_SCOPE)

endfunction()
