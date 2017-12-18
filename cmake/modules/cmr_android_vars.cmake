# Some variables are defined in <NDK>/build/cmake/android.toolchain.cmake
# and may be used after it. See android.toolchain.cmake.
#  ANDROID_NDK_REVISION
#  ANDROID_PLATFORM_LEVEL
#  ANDROID_SYSROOT_ABI # arch

macro(cmr_android_vars)
  if(ANDROID)
    # TODO: get new vars from NDK's toolchain
    
    set(cmr_LIB_VARS_ANDROID
      ANDROID
      ANDROID_NDK
      
      # Configurable variables from
      # android-sdk/cmake/3.6.3155560/android.toolchain.cmake
      # (package version 3.6.3155560)
      # and from android-sdk/ndk-bundle/build/cmake/android.toolchain.cmake
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
      ANDROID_ARM_MODE
      ANDROID_ARM_NEON
      ANDROID_DISABLE_NO_EXECUTE
      ANDROID_DISABLE_RELRO
      ANDROID_DISABLE_FORMAT_STRING_CHECKS
      ANDROID_CCACHE
      
      CMAKE_FIND_ROOT_PATH
      
      # Allow users to override these values
      # in case they want more strict behaviors.
      # For example, they may want to prevent the NDK's libz
      # from being picked up so they can use their own.
      # https://github.com/android-ndk/ndk/issues/517
      CMAKE_FIND_ROOT_PATH_MODE_PROGRAM
      CMAKE_FIND_ROOT_PATH_MODE_LIBRARY
      CMAKE_FIND_ROOT_PATH_MODE_INCLUDE
      CMAKE_FIND_ROOT_PATH_MODE_PACKAGE

      # The variables are only for compatibility.
      ANDROID_NATIVE_API_LEVEL
      ANDROID_TOOLCHAIN_NAME
      ANDROID_UNIFIED_HEADERS
    )
  
    foreach(d ${cmr_LIB_VARS_ANDROID})
      if(DEFINED ${d})
        list(APPEND cmr_CMAKE_ARGS
          -D${d}=${${d}}
        )
      endif()
    endforeach()
  endif()
endmacro()
