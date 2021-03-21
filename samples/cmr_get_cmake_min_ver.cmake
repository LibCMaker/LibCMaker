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

macro(cmr_get_cmake_min_ver)
  if(IOS)
    set(cmr_CMAKE_MIN_VER 3.15)
  elseif(APPLE)  # macOS
    set(cmr_CMAKE_MIN_VER 3.9)
  else()
    set(cmr_CMAKE_MIN_VER 3.9)
  endif()

  if(${ARGC} GREATER 0)
    if(${ARGV0} GREATER cmr_CMAKE_MIN_VER)
      set(cmr_CMAKE_MIN_VER ${${ARGV0}})
    endif()
  endif()
endmacro()
