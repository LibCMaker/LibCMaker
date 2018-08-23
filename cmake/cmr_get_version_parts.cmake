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

include(cmr_print_error)

function(cmr_get_version_parts version out_MAJOR out_MINOR out_PATCH out_TWEAK)
  set(version_REGEX "^[0-9]+(\\.[0-9]+)?(\\.[0-9]+)?(\\.[0-9]+)?$")
  set(version_REGEX_1 "^[0-9]+$")
  set(version_REGEX_2 "^[0-9]+\\.[0-9]+$")
  set(version_REGEX_3 "^[0-9]+\\.[0-9]+\\.[0-9]+$")
  set(version_REGEX_4 "^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$")

  if(NOT version MATCHES ${version_REGEX})
    cmr_print_error("Problem parsing version string.")
  endif()

  if(version MATCHES ${version_REGEX_1})
    set(count 1)
  elseif(version MATCHES ${version_REGEX_2})
    set(count 2)
  elseif(version MATCHES ${version_REGEX_3})
    set(count 3)
  elseif(version MATCHES ${version_REGEX_4})
    set(count 4)
  endif()

  string(REGEX REPLACE "^([0-9]+)(\\.[0-9]+)?(\\.[0-9]+)?(\\.[0-9]+)?"
      "\\1" major "${version}")

  if(NOT count LESS 2)
    string(REGEX REPLACE "^[0-9]+\\.([0-9]+)(\\.[0-9]+)?(\\.[0-9]+)?"
        "\\1" minor "${version}")
  else()
    set(minor "0")
  endif()

  if(NOT count LESS 3)
    string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+)(\\.[0-9]+)?"
        "\\1" patch "${version}")
  else()
    set(patch "0")
  endif()

  if(NOT count LESS 4)
    string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.[0-9]+\\.([0-9]+)"
        "\\1" tweak "${version}")
  else()
    set(tweak "0")
  endif()

  set(${out_MAJOR} "${major}" PARENT_SCOPE)
  set(${out_MINOR} "${minor}" PARENT_SCOPE)
  set(${out_PATCH} "${patch}" PARENT_SCOPE)
  set(${out_TWEAK} "${tweak}" PARENT_SCOPE)
endfunction()
