macro(cmr_android_vars)
  if(ANDROID)
    # TODO: get new vars from NDK's toolchain
    
    list(APPEND cmr_CMAKE_ARGS
      -DANDROID=ON
    )
    if(DEFINED ANDROID_NDK)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_NDK=${ANDROID_NDK}
      )
    endif()
  
    # Configurable variables from
    # android-sdk/cmake/3.6.3155560/android.toolchain.cmake
    # (package version 3.6.3155560)
    # and from android-sdk/ndk-bundle/build/cmake/android.toolchain.cmake
    # Modeled after the ndk-build system.
    # For any variables defined in:
    #         https://developer.android.com/ndk/guides/android_mk.html
    #         https://developer.android.com/ndk/guides/application_mk.html
    # if it makes sense for CMake, then replace LOCAL, APP, or NDK with ANDROID,
    # and we have that variable below.
    # The exception is ANDROID_TOOLCHAIN vs NDK_TOOLCHAIN_VERSION.
    # Since we only have one version of each gcc and clang, specifying a version
    # doesn't make much sense.
    if(DEFINED ANDROID_TOOLCHAIN)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_TOOLCHAIN=${ANDROID_TOOLCHAIN}
      )
    endif()
    if(DEFINED ANDROID_ABI)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_ABI=${ANDROID_ABI}
      )
    endif()
    if(DEFINED ANDROID_PLATFORM)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_PLATFORM=${ANDROID_PLATFORM}
      )
    endif()
    if(DEFINED ANDROID_STL)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_STL=${ANDROID_STL}
      )
    endif()
    if(DEFINED ANDROID_PIE)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_PIE=${ANDROID_PIE}
      )
    endif()
    if(DEFINED ANDROID_CPP_FEATURES)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_CPP_FEATURES=${ANDROID_CPP_FEATURES}
      )
    endif()
    if(DEFINED ANDROID_ALLOW_UNDEFINED_SYMBOLS)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_ALLOW_UNDEFINED_SYMBOLS=${ANDROID_ALLOW_UNDEFINED_SYMBOLS}
      )
    endif()
    if(DEFINED ANDROID_ARM_MODE)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_ARM_MODE=${ANDROID_ARM_MODE}
      )
    endif()
    if(DEFINED ANDROID_ARM_NEON)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_ARM_NEON=${ANDROID_ARM_NEON}
      )
    endif()
    if(DEFINED ANDROID_DISABLE_NO_EXECUTE)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_DISABLE_NO_EXECUTE=${ANDROID_DISABLE_NO_EXECUTE}
      )
    endif()
    if(DEFINED ANDROID_DISABLE_RELRO)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_DISABLE_RELRO=${ANDROID_DISABLE_RELRO}
      )
    endif()
    if(DEFINED ANDROID_DISABLE_FORMAT_STRING_CHECKS)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_DISABLE_FORMAT_STRING_CHECKS=${ANDROID_DISABLE_FORMAT_STRING_CHECKS}
      )
    endif()
    if(DEFINED ANDROID_CCACHE)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_CCACHE=${ANDROID_CCACHE}
      )
    endif()
    if(DEFINED ANDROID_UNIFIED_HEADERS)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_UNIFIED_HEADERS=${ANDROID_UNIFIED_HEADERS}
      )
    endif()
  
    if(DEFINED ANDROID_SYSROOT_ABI)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_SYSROOT_ABI=${ANDROID_SYSROOT_ABI} # arch
      )
    endif()
    if(DEFINED ANDROID_PLATFORM_LEVEL)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_PLATFORM_LEVEL=${ANDROID_PLATFORM_LEVEL}
      )
    endif()
  
    # The variables are only for compatibility.
    if(DEFINED ANDROID_NATIVE_API_LEVEL)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL}
      )
    endif()
    if(DEFINED ANDROID_TOOLCHAIN_NAME)
      list(APPEND cmr_CMAKE_ARGS
        -DANDROID_TOOLCHAIN_NAME=${ANDROID_TOOLCHAIN_NAME}
      )
    endif()
  endif()
endmacro()
