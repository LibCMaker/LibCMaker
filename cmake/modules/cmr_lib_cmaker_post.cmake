# ****************************************************************************
#  Project:  LibCMaker
#  Purpose:  A CMake build scripts for build libraries with CMake
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017 NikitaFeodonit
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

if(NOT LIBCMAKER_SRC_DIR)
  message(FATAL_ERROR
    "Please set LIBCMAKER_SRC_DIR with path to LibCMaker root")
endif()
# TODO: prevent multiply includes for CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")

include(cmr_print_fatal_error)
include(cmr_print_debug_message)
include(cmr_print_var_value)

function(cmr_lib_cmaker_post)
  cmake_minimum_required(VERSION 2.8.12)

  # To prevent the list expansion on an argument with ';'.
  # See also
  # http://stackoverflow.com/a/20989991
  # http://stackoverflow.com/a/20985057
  if(lib_COMPONENTS)
    string (REPLACE " " ";" lib_COMPONENTS "${lib_COMPONENTS}")
    set(lib_COMPONENTS ${lib_COMPONENTS} PARENT_SCOPE)
  endif()
  if(CMAKE_FIND_ROOT_PATH)
    string (REPLACE " " ";" CMAKE_FIND_ROOT_PATH "${CMAKE_FIND_ROOT_PATH}")
    set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH} PARENT_SCOPE)
  endif()

endfunction()
