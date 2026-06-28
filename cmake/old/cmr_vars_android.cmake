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

# Some variables are defined in <NDK>/build/cmake/android.toolchain.cmake
# and may be used after it. See 'android.toolchain.cmake'.
#  ANDROID_NDK_REVISION
#  ANDROID_PLATFORM_LEVEL
#  ANDROID_SYSROOT_ABI # arch

if(ANDROID)
  # TODO: get new vars from NDK's toolchain.

  set(cmr_LIB_VARS_ANDROID
    ANDROID
    ANDROID_NDK

    # Configurable variables from
    # android-sdk/cmake/3.6.3155560/android.toolchain.cmake
    # (package version 3.6.3155560)
    # and from 'android-sdk/ndk-bundle/build/cmake/android.toolchain.cmake'.
    # Modeled after the ndk-build system.
    # For any variables defined in:
    #         https://developer.android.com/ndk/guides/android_mk.html
    #         https://developer.android.com/ndk/guides/application_mk.html
    # if it makes sense for CMake, then replace LOCAL, APP,
    # or NDK with ANDROID, and we have that variable below.
    # The exception is ANDROID_TOOLCHAIN vs NDK_TOOLCHAIN_VERSION.
    # Since we only have one version of each gcc and clang,
    # specifying a version doesn't make much sense.
    ANDROID_TOOLCHAIN
    ANDROID_ABI
    ANDROID_PLATFORM
    ANDROID_STL
    ANDROID_PIE
    ANDROID_CPP_FEATURES
    ANDROID_ALLOW_UNDEFINED_SYMBOLS
#    ANDROID_ARM_MODE  # Error from CMake: "Android: CMAKE_ANDROID_ARM_MODE is set but is valid only for 'armeabi' architectures."
    ANDROID_ARM_NEON
    ANDROID_DISABLE_NO_EXECUTE
    ANDROID_DISABLE_RELRO
    ANDROID_DISABLE_FORMAT_STRING_CHECKS
    ANDROID_CCACHE

    # The variables are only for compatibility.
    ANDROID_NATIVE_API_LEVEL
    ANDROID_TOOLCHAIN_NAME
    ANDROID_UNIFIED_HEADERS

    # From CMake 3.7+
    CMAKE_ANDROID_ANT_ADDITIONAL_OPTIONS
    CMAKE_ANDROID_API
    CMAKE_ANDROID_API_MIN
    CMAKE_ANDROID_ARCH
    CMAKE_ANDROID_ARCH_ABI
    CMAKE_ANDROID_ARM_MODE
    CMAKE_ANDROID_ARM_NEON
    CMAKE_ANDROID_ASSETS_DIRECTORIES
    CMAKE_ANDROID_GUI
    CMAKE_ANDROID_JAR_DEPENDENCIES
    CMAKE_ANDROID_JAR_DIRECTORIES
    CMAKE_ANDROID_JAVA_SOURCE_DIR
    CMAKE_ANDROID_NATIVE_LIB_DEPENDENCIES
    CMAKE_ANDROID_NATIVE_LIB_DIRECTORIES
    CMAKE_ANDROID_NDK
    CMAKE_ANDROID_NDK_DEPRECATED_HEADERS
    CMAKE_ANDROID_NDK_TOOLCHAIN_HOST_TAG
    CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION
    CMAKE_ANDROID_PROCESS_MAX
    CMAKE_ANDROID_PROGUARD
    CMAKE_ANDROID_PROGUARD_CONFIG_PATH
    CMAKE_ANDROID_SECURE_PROPS_PATH
    CMAKE_ANDROID_SKIP_ANT_STEP
    CMAKE_ANDROID_STANDALONE_TOOLCHAIN
    CMAKE_ANDROID_STL_TYPE
    CMAKE_C_ANDROID_TOOLCHAIN_MACHINE
    CMAKE_C_ANDROID_TOOLCHAIN_PREFIX
    CMAKE_C_ANDROID_TOOLCHAIN_SUFFIX
    CMAKE_CXX_ANDROID_TOOLCHAIN_MACHINE
    CMAKE_CXX_ANDROID_TOOLCHAIN_PREFIX
    CMAKE_CXX_ANDROID_TOOLCHAIN_SUFFIX
    CMAKE_ASM_ANDROID_TOOLCHAIN_MACHINE
    CMAKE_ASM_ANDROID_TOOLCHAIN_PREFIX
    CMAKE_ASM_ANDROID_TOOLCHAIN_SUFFIX
  )

  foreach(d ${cmr_LIB_VARS_ANDROID})
    if(DEFINED ${d})
      list(APPEND cmr_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()
endif()
