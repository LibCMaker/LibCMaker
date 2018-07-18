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

cmake_minimum_required(VERSION ${cmr_CMAKE_MIN_VER})
project(LibCMaker_${lib_NAME})

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")
list(APPEND CMAKE_MODULE_PATH "${lib_BASE_DIR}/cmake/modules")

include(cmr_build_rules)
cmr_build_rules()
