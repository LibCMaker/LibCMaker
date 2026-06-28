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

# TODO: invoke to cmr_common_sample_1_part.

function(get_vs_toolset_dir_ver)
  set(cmr_VS_TOOLSET_DIR "${CMAKE_GENERATOR_INSTANCE}/VC" CACHE PATH "cmr_VS_TOOLSET_DIR")

  if(CMAKE_CXX_COMPILER)
    set(_compiler "${CMAKE_CXX_COMPILER}")
  elseif(CMAKE_C_COMPILER)
    set(_compiler "${CMAKE_C_COMPILER}")
  endif()

  cmake_path(RELATIVE_PATH _compiler
    BASE_DIRECTORY "${cmr_VS_TOOLSET_DIR}/Tools/MSVC"
    OUTPUT_VARIABLE _toolset_ver
  )

  set(_has_not_ver true)
  while(_has_not_ver)
    cmake_path(GET _toolset_ver PARENT_PATH _toolset_ver)
    cmake_path(HAS_PARENT_PATH _toolset_ver _has_not_ver)
  endwhile()

  set(cmr_VS_TOOLSET_VERSION "${_toolset_ver}" CACHE STRING "cmr_VS_TOOLSET_VERSION")
endfunction()


function(get_windows_kits_dir_ver)
  if(MSVC_CXX_ARCHITECTURE_ID)
    string(TOLOWER "${MSVC_CXX_ARCHITECTURE_ID}" _msvc_arch)
  elseif(MSVC_C_ARCHITECTURE_ID)
    string(TOLOWER "${MSVC_C_ARCHITECTURE_ID}" _msvc_arch)
  else()
    set(_msvc_arch "x86")
  endif()

  # Find the Windows Kits directory.
  get_filename_component(_win_kits_dir
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot10]"
    ABSOLUTE
  )

  if(";${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION};$ENV{UCRTVersion};$ENV{WindowsSDKVersion};"
      MATCHES [=[;(10\.[0-9.]+)[;\]]=])
    set(cmr_WINDOWS_KITS_VERSION "${CMAKE_MATCH_1}" CACHE STRING "cmr_WINDOWS_KITS_VERSION")
    set(_win_kit_ver_slash "${cmr_WINDOWS_KITS_VERSION}/")
  endif()

  set(_program_files_x86 "ProgramFiles(x86)")

  find_path(cmr_WINDOWS_KITS_DIR
    NAMES
      "Redist/${_win_kit_ver_slash}ucrt/DLLs/${_msvc_arch}/ucrtbase.dll"
      "Redist/ucrt/DLLs/${_msvc_arch}/ucrtbase.dll"
    PATHS
      "$ENV{CMAKE_WINDOWS_KITS_10_DIR}"
      "${_win_kits_dir}"
      "$ENV{ProgramFiles}/Windows Kits/10"
      "$ENV{${_program_files_x86}}/Windows Kits/10"
  )
endfunction()


function(get_windows_kits_include_dirs _win_kit_dir _win_kit_ver _out_var)
  # Based on the 'FindWindowsSDK.cmake' module.

  set(_subdirs "shared" "um" "winrt" "ucrt" "cppwinrt")

  foreach(_dir ${_subdirs})
    list(APPEND _suffixes "Include/${_win_kit_ver}/${_dir}")
  endforeach()

  foreach(_suffix ${_suffixes})
    # Check to see if a header file actually exists here.
    if(_suffix STREQUAL "cppwinrt")
      set(_winrt "/winrt")
    endif()
    file(GLOB _headers "${_win_kit_dir}/${_suffix}${_winrt}/*.h")

    if(_headers)
      list(APPEND _dirs "${_win_kit_dir}/${_suffix}")
    endif()
  endforeach()

  if(_dirs)
    list(REMOVE_DUPLICATES _dirs)
  else()
    set(_dirs NOTFOUND)
  endif()

  set(${_out_var} ${_dirs} PARENT_SCOPE)
endfunction()


function(get_windows_kits_library_dirs _win_kit_dir _win_kit_ver _win_kit_arch _out_var)
  # Based on the 'FindWindowsSDK.cmake' module.

  # Look for WDF libraries in Win10+ SDK.
  foreach(_mode "umdf" "kmdf")
    file(GLOB _wdfdirs RELATIVE "${_win_kit_dir}" "${_win_kit_dir}/lib/wdf/${_mode}/${_win_kit_arch}/*")
    if(_wdfdirs)
      list(APPEND _suffixes ${_wdfdirs})
    endif()
  endforeach()

  set(_subdirs "um" "ucrt" "ucrt_enclave")

  # Look in each Win10+ SDK version for the components.
  foreach(_dir ${_subdirs})
    list(APPEND _suffixes "Lib/${_win_kit_ver}/${_dir}/${_win_kit_arch}")
  endforeach()

  foreach(_suffix ${_suffixes})
    # Check to see if a library actually exists here.
    file(GLOB _libs "${_win_kit_dir}/${_suffix}/*.lib")
    if(_libs)
      list(APPEND _dirs "${_win_kit_dir}/${_suffix}")
    endif()
  endforeach()

  if(_dirs)
    list(REMOVE_DUPLICATES _dirs)
  else()
    set(_dirs NOTFOUND)
  endif()

  set(${_out_var} ${_dirs} PARENT_SCOPE)
endfunction()
