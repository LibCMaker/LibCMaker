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

cmake_minimum_required(VERSION ${cmr_CMAKE_MIN_VER})
# If not defined lib_LANGUAGES then default languages (C and CXX).
project(LibCMaker_${lib_NAME} ${lib_LANGUAGES})

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
list(APPEND CMAKE_MODULE_PATH "${lib_BASE_DIR}/cmake")

include(cmr_build_rules)
cmr_build_rules()
