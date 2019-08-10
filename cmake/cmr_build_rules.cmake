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

  # Required vars.
  if(NOT lib_VERSION)
    cmr_print_error("Variable lib_VERSION is not defined.")
  endif()
  if(NOT lib_DOWNLOAD_DIR)
    cmr_print_error("Variable lib_DOWNLOAD_DIR is not defined.")
  endif()
  if(NOT lib_UNPACKED_DIR)
    cmr_print_error("Variable lib_UNPACKED_DIR is not defined.")
  endif()
  if(NOT lib_BUILD_DIR)
    cmr_print_error("Variable lib_BUILD_DIR is not defined.")
  endif()

  cmr_get_download_params(
    ${lib_VERSION} ${lib_DOWNLOAD_DIR} ${lib_UNPACKED_DIR} ${lib_BUILD_DIR}
    lib_URL lib_ARCH_FILE lib_SHA lib_SHA_ALG
    lib_UNPACK_TO_DIR lib_SRC_DIR lib_VERSION_BUILD_DIR)

  if(NOT lib_SHA)
    cmr_print_error(
      "${cmr_lib_NAME} library version ${version} is not supported."
    )
  endif()

  # Download tar file.
  if(NOT EXISTS "${lib_ARCH_FILE}")
    cmr_print_status(
      "Download\n  '${lib_URL}'\nto\n  '${lib_ARCH_FILE}'"
    )
    file(
      DOWNLOAD "${lib_URL}" "${lib_ARCH_FILE}"
      EXPECTED_HASH ${lib_SHA_ALG}=${lib_SHA}
      SHOW_PROGRESS
    )
  endif()

  # Extract tar file.
  if(NOT EXISTS "${lib_SRC_DIR}")
    cmr_print_status(
      "Extract\n  '${lib_ARCH_FILE}'\nto\n  '${lib_UNPACK_TO_DIR}'"
    )
    file(MAKE_DIRECTORY ${lib_UNPACK_TO_DIR})
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xf ${lib_ARCH_FILE} # TODO: arch opts (z, j, ...)
      WORKING_DIRECTORY ${lib_UNPACK_TO_DIR}
    )
  endif()

  # Set compile flags.
  if(cmr_USE_MSVC_STATIC_RUNTIME AND MSVC AND NOT BUILD_SHARED_LIBS)
    # Set MSVC static runtime flags for all configurations.
    # See:
    # https://stackoverflow.com/a/20804336
    # https://stackoverflow.com/a/14172871
    foreach(cfg "" ${CMAKE_CONFIGURATION_TYPES})
      set(c_flag_var   CMAKE_C_FLAGS)
      set(cxx_flag_var CMAKE_CXX_FLAGS)
      if(cfg)
        string(TOUPPER ${cfg} cfg_upper)
        set(c_flag_var   "${c_flag_var}_${cfg_upper}")
        set(cxx_flag_var "${cxx_flag_var}_${cfg_upper}")
      endif()
      if(${c_flag_var} MATCHES "/MD")
        string(REPLACE "/MD" "/MT" ${c_flag_var} "${${c_flag_var}}")
        set(${c_flag_var} ${${c_flag_var}} CACHE STRING
          "Flags used by the C compiler during ${cfg_upper} builds." FORCE
        )
      endif()
      if(${cxx_flag_var} MATCHES "/MD")
        string(REPLACE "/MD" "/MT" ${cxx_flag_var} "${${cxx_flag_var}}")
        set(${cxx_flag_var} ${${cxx_flag_var}} CACHE STRING
          "Flags used by the CXX compiler during ${cfg_upper} builds." FORCE
        )
      endif()
    endforeach()
  endif()

  # Configure, build and install rules.
  include(cmr_build_rules_${lower_lib_NAME})

endfunction()
