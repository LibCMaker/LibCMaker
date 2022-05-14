# ****************************************************************************
#  Project:  LibCMaker
#  Purpose:  A CMake build scripts for build libraries with CMake
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2022 NikitaFeodonit
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

if(WIN32 AND MSVC AND (TARGETING_XP_64 OR TARGETING_XP))
  # NOTE: TARGETING_XP: _ATL_XP_TARGETING and '/SUBSYSTEM:CONSOLE,5.01'.

  # Based on the article:
  # http://wenqiangwang.blogspot.com/2014/02/targeting-windows-xp-with-visual-c-2013.html

  # See also:
  # https://docs.microsoft.com/en-us/cpp/build/reference/subsystem?view=msvc-170
  # https://docs.microsoft.com/en-us/cpp/build/reference/subsystem-specify-subsystem?view=msvc-170#remarks
  # https://tedwvc.wordpress.com/2014/01/01/how-to-target-xp-with-vc2012-or-vc2013-and-continue-to-use-the-windows-8-x-sdk/
  # https://github.com/mxpham/mixxx/blob/master/CMakeLists.txt
  # https://stackoverflow.com/questions/68074930/controlling-flags-passed-to-the-generator
  # https://gitlab.kitware.com/cmake/cmake/-/issues/21300

  # Restrict ATL to WinXP-compatible SDK functions.
  string(APPEND CMAKE_CXX_FLAGS_INIT " /D_ATL_XP_TARGETING")
  string(APPEND CMAKE_C_FLAGS_INIT " /D_ATL_XP_TARGETING")
  # Switch to Windows SDK v7.1A with toolset v141.
  #string(APPEND CMAKE_CXX_FLAGS_INIT " /D_USING_V110_SDK71_")
  #string(APPEND CMAKE_C_FLAGS_INIT " /D_USING_V110_SDK71_")

  # NOTE: On CMake 3.23+ 'CMAKE_CXX_CREATE_CONSOLE_EXE' is not working,
  # '/SUBSYSTEM:CONSOLE,5.01' work only with 'target_link_options':
  #if(WIN32 AND MSVC AND (TARGETING_XP_64 OR TARGETING_XP))
  #  if(TARGETING_XP_64)
  #    set(_EXE_SUBSYSTEM_VER "5.02")
  #  elseif(TARGETING_XP)
  #    set(_EXE_SUBSYSTEM_VER "5.01")
  #  endif()
  #
  #  # See docs for add_executable() and WIN32_EXECUTABLE.
  #  #set_property(TARGET ${PROJECT_NAME} PROPERTY WIN32_EXECUTABLE ON)
  #  get_target_property(_WIN32_EXECUTABLE ${PROJECT_NAME} WIN32_EXECUTABLE)
  #  if(_WIN32_EXECUTABLE)
  #    set(_EXE_SUBSYSTEM "WINDOWS")
  #  else()
  #    set(_EXE_SUBSYSTEM "CONSOLE")
  #  endif()
  #
  #  target_link_options(${PROJECT_NAME} PRIVATE
  #    "/SUBSYSTEM:${_EXE_SUBSYSTEM},${_EXE_SUBSYSTEM_VER}"
  #  )
  #endif()

  if(TARGETING_XP_64)
    set(EXE_SUBSYSTEM_VER "5.02")
  elseif(TARGETING_XP)
    set(EXE_SUBSYSTEM_VER "5.01")
  endif()

  # The CMake versions until to CMake 3.20 use the
  # 'CMAKE_CREATE_CONSOLE_EXE' variable instead of
  # 'CMAKE_CXX_CREATE_CONSOLE_EXE' and 'CMAKE_C_CREATE_CONSOLE_EXE',
  # in 'Windows-MSVC.cmake' see
  # CMAKE_${lang}_CREATE_WIN32_EXE and CMAKE_${lang}_CREATE_CONSOLE_EXE
  # or CMAKE_CREATE_WIN32_EXE and CMAKE_CREATE_CONSOLE_EXE.

  if(CMAKE_VERSION VERSION_LESS 3.21)
    set(CMAKE_CREATE_WIN32_EXE   "/SUBSYSTEM:WINDOWS,${EXE_SUBSYSTEM_VER}")
    set(CMAKE_CREATE_CONSOLE_EXE "/SUBSYSTEM:CONSOLE,${EXE_SUBSYSTEM_VER}")
  else()
    set(CMAKE_CXX_CREATE_WIN32_EXE   "/SUBSYSTEM:WINDOWS,${EXE_SUBSYSTEM_VER}")
    set(CMAKE_C_CREATE_WIN32_EXE     "/SUBSYSTEM:WINDOWS,${EXE_SUBSYSTEM_VER}")
    set(CMAKE_CXX_CREATE_CONSOLE_EXE "/SUBSYSTEM:CONSOLE,${EXE_SUBSYSTEM_VER}")
    set(CMAKE_C_CREATE_CONSOLE_EXE   "/SUBSYSTEM:CONSOLE,${EXE_SUBSYSTEM_VER}")
  endif()
endif()
