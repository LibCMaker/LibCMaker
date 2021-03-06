# ****************************************************************************
#  Project:  LibCMaker
#  Purpose:  A CMake build scripts for build libraries with CMake
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2020 NikitaFeodonit
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

if(NOT lib_NAME)
  message(FATAL_ERROR
    "Please set lib_NAME with name of the library.")
endif()
if(NOT lib_BASE_DIR)
  message(FATAL_ERROR
    "Please set lib_BASE_DIR with path to LibCMaker_${lib_NAME} project root.")
endif()
if(NOT cmr_CMAKE_MIN_VER)
  message(FATAL_ERROR
    "Please set cmr_CMAKE_MIN_VER with CMake minimum required version.")
endif()

string(TOLOWER ${lib_NAME} lower_lib_NAME)

if(NOT lib_LANGUAGES)
  message(FATAL_ERROR
    "Please set lib_LANGUAGES with library used languages.")
endif()
string(REPLACE " " ";" lib_LANGUAGES "${lib_LANGUAGES}")

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
if(CMAKE_PREFIX_PATH)
  string(REPLACE " " ";" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
endif()
if(CMAKE_INCLUDE_PATH)
  string(REPLACE " " ";" CMAKE_INCLUDE_PATH "${CMAKE_INCLUDE_PATH}")
endif()
if(CMAKE_LIBRARY_PATH)
  string(REPLACE " " ";" CMAKE_LIBRARY_PATH "${CMAKE_LIBRARY_PATH}")
endif()
if(CMAKE_PROGRAM_PATH)
  string(REPLACE " " ";" CMAKE_PROGRAM_PATH "${CMAKE_PROGRAM_PATH}")
endif()
if(CMAKE_INSTALL_RPATH)
  string(REPLACE " " ";" CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}")
endif()

set(cmr_main_CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH})

cmake_minimum_required(VERSION ${cmr_CMAKE_MIN_VER})
# If not defined lib_LANGUAGES then default languages (C and CXX).
project(LibCMaker_${lib_NAME} ${lib_LANGUAGES})

if(ANDROID OR IOS)
  # android.toolchain.cmake resets CMAKE_FIND_ROOT_PATH.
  list(APPEND CMAKE_FIND_ROOT_PATH "${cmr_main_CMAKE_FIND_ROOT_PATH}")
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
list(APPEND CMAKE_MODULE_PATH "${lib_BASE_DIR}/cmake")

include(cmr_print_system_info)
cmr_print_system_info()

include(cmr_build_rules)
cmr_build_rules()
