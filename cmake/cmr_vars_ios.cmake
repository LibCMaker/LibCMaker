# ****************************************************************************
#  Project:  LibCMaker
#  Purpose:  A CMake build scripts for build libraries with CMake
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2019 NikitaFeodonit
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

# See 'ios.toolchain.cmake'.

if(IOS)
  set(cmr_LIB_VARS_IOS
    # From 'ios.toolchain.cmake'.

    PLATFORM
    #CMAKE_OSX_SYSROOT
    CMAKE_DEVELOPER_ROOT
    DEPLOYMENT_TARGET
    NAMED_LANGUAGE_SUPPORT
    ENABLE_BITCODE
    ENABLE_ARC
    ENABLE_VISIBILITY

    ENABLE_STRICT_TRY_COMPILE
    ARCHS

    SDK_VERSION
    XCODE_VERSION_INT
    CMAKE_OSX_SYSROOT_INT

    BUILD_LIBTOOL
    CMAKE_INSTALL_NAME_TOOL
  )

  foreach(d ${cmr_LIB_VARS_IOS})
    if(DEFINED ${d})
      list(APPEND cmr_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()
endif()
