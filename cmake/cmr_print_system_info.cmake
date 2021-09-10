# ****************************************************************************
#  Project:  LibCMaker
#  Purpose:  A CMake build scripts for build libraries with CMake
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017-2021 NikitaFeodonit
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

include(cmr_print_status)

function(cmr_print_system_info)
  if(UNIX AND NOT APPLE AND NOT ANDROID)
    set(system_NAME "Linux")
  elseif(APPLE AND NOT IOS)
    set(system_NAME "macOS")
  elseif(WIN32)
    set(system_NAME "Windows")
  elseif(ANDROID)
    set(system_NAME "Android")
  elseif(IOS)
    set(system_NAME "iOS")
  endif()

  if(MINGW)
    set(system_NAME "${system_NAME}_MinGW")
  endif()

  set(CXX_compiler_NAME "${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
  set(C_compiler_NAME "${CMAKE_C_COMPILER_ID} ${CMAKE_C_COMPILER_VERSION}")
  set(ASM_compiler_NAME "${CMAKE_ASM_COMPILER_ID} ${CMAKE_ASM_COMPILER_VERSION}")
  if(MSVC)
    set(CXX_compiler_NAME
      "${CXX_compiler_NAME} ${CMAKE_GENERATOR_PLATFORM} ${CMAKE_GENERATOR_TOOLSET}"
    )
    set(C_compiler_NAME
      "${C_compiler_NAME} ${CMAKE_GENERATOR_PLATFORM} ${CMAKE_GENERATOR_TOOLSET}"
    )
    set(ASM_compiler_NAME
      "${ASM_compiler_NAME} ${CMAKE_GENERATOR_PLATFORM} ${CMAKE_GENERATOR_TOOLSET}"
    )
  endif()

  cmr_print_status("============================================================")
  cmr_print_status("Host system:   ${CMAKE_HOST_SYSTEM}")
  cmr_print_status("System:        ${system_NAME}, ${CMAKE_SYSTEM}")
  cmr_print_status("C++ compiler:  ${CXX_compiler_NAME}")
  cmr_print_status("C compiler:    ${C_compiler_NAME}")
  cmr_print_status("ASM compiler:  ${ASM_compiler_NAME}")
  cmr_print_status("CMake:         ${CMAKE_VERSION}")
  cmr_print_status("Build type:    ${CMAKE_BUILD_TYPE}")
  cmr_print_status("============================================================")
endfunction()
