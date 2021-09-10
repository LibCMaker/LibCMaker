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

# For running test, 1st build all:
#   cmake .. -DBUILD_TESTING=ON
#   cmake --build .
# Then run test with this command:
#   cmake -E env CTEST_OUTPUT_ON_FAILURE=1 cmake --build . --target test
# Or with this command:
#   ctest --verbose
# Env var CTEST_OUTPUT_ON_FAILURE or key --verbose are for show test outputs,
# see
# https://stackoverflow.com/a/37123943
# https://stackoverflow.com/a/38386596

# For Visual Studio:
# https://stackoverflow.com/a/31124523
# https://stackoverflow.com/a/37123943
# cmake -E env CTEST_OUTPUT_ON_FAILURE=1 cmake --build . --target RUN_TESTS

macro(cmr_common_sample_1st_part)
  option(CMAKE_VERBOSE_MAKEFILE "CMAKE_VERBOSE_MAKEFILE" OFF)
  option(cmr_PRINT_DEBUG "cmr_PRINT_DEBUG" OFF)

  option(IOS_DISABLE_CODESIGN "IOS_DISABLE_CODESIGN" ON)
  option(BUILD_TESTING "Build the testing tree." OFF)
  option(cmr_USE_STATIC_RUNTIME "cmr_USE_STATIC_RUNTIME" ON)


  #-----------------------------------------------------------------------
  # Settigs for iOS Bundle
  #-----------------------------------------------------------------------

  if(IOS)
    # https://help.apple.com/xcode/mac/8.0/#/itcaec37c2a6
    # Build settings reference
    # google search string: "build setting reference" site:developer.apple.com
    #
    # https://stackoverflow.com/questions/6910901/how-do-i-print-a-list-of-build-settings-in-xcode-project
    # "How do I print a list of .Build Settings. in Xcode project?"
    #
    # $ xcodebuild -project myProj.xcodeproj -target "myTarg" -showBuildSettings

    # "Building iOS applications using xcodebuild without codesign"
    # https://stackoverflow.com/a/58451900
    # https://stackoverflow.com/a/11647504
    # https://stackoverflow.com/a/39901677
    #
    # CODE_SIGN_IDENTITY=""
    # CODE_SIGNING_REQUIRED="NO"
    # CODE_SIGN_ENTITLEMENTS=""
    # CODE_SIGNING_ALLOWED="NO"


    # From https://github.com/ruslo/sugar
    #set(CMAKE_MACOSX_BUNDLE YES)
    #set(CMAKE_OSX_SYSROOT "iphoneos")
    #set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer")
    #set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos;-iphonesimulator")
    #set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.example.sugar.iOSGTest")

    # From https://stackoverflow.com/a/972579
    #set(CMAKE_OSX_SYSROOT iphoneos2.2.1)
    #set(CMAKE_OSX_ARCHITECTURES $(ARCHS_STANDARD_32_BIT))
    #set(CMAKE_CXX_FLAGS "-x objective-c++")
    #set(CMAKE_EXE_LINKER_FLAGS "-framework AudioToolbox -framework CoreGraphics -framework QuartzCore -framework UIKit")
    #link_directories(\${HOME}/\${SDKROOT}/lib)
    #set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.mycompany.\${PRODUCT_NAME:identifier}")
    #set(APP_TYPE MACOSX_BUNDLE)


    set(IOS_MACOSX_BUNDLE MACOSX_BUNDLE)

    set(DEVELOPMENT_TEAM_ID "TODO")  # Team ID from Apple.
    set(IOS_APP_BUNDLE_IDENTIFIER "ru.libcmaker.testapp")
    set(IOS_CODE_SIGN_IDENTITY "iPhone Developer")
    if(IOS_DISABLE_CODESIGN)
      set(IOS_CODE_SIGN_IDENTITY "")
    endif()

    # NOTE:
    # Link error:
    # "targeted OS version does not support use of thread local variables".
    # C++11 concept not supported all iOS platforms,
    # thread_local is allowed beginning with iOS 9 for Xcode 10.
    # Xcode 9 + iOS 8 compiles OK.
    set(IOS_DEPLOYMENT_TARGET "9.0")  # Deployment target version of iOS.

    # Set to "1" to target iPhone, "2" to target iPad, "1,2" to target both.
    set(IOS_DEVICE_FAMILY "1")

    # See CMake's docs for MACOSX_BUNDLE_INFO_PLIST target property for these vars.
    # See the file MacOSXBundleInfo.plist.in for MACOSX_BUNDLE_EXECUTABLE_NAME.
    set(MACOSX_BUNDLE_EXECUTABLE_NAME ${CMAKE_PROJECT_NAME})
    #set(MACOSX_BUNDLE_INFO_STRING ${IOS_APP_BUNDLE_IDENTIFIER})
    #set(MACOSX_BUNDLE_GUI_IDENTIFIER ${IOS_APP_BUNDLE_IDENTIFIER})
    #set(MACOSX_BUNDLE_BUNDLE_NAME ${IOS_APP_BUNDLE_IDENTIFIER})
    set(MACOSX_BUNDLE_ICON_FILE "")
    set(MACOSX_BUNDLE_LONG_VERSION_STRING "1.0")
    set(MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0")
    set(MACOSX_BUNDLE_BUNDLE_VERSION "1.0")
    set(MACOSX_BUNDLE_COPYRIGHT "Copyright (c) 2017-2020 NikitaFeodonit")
    set(MACOSX_DEPLOYMENT_TARGET ${IOS_DEPLOYMENT_TARGET})

    #set(CMAKE_MACOSX_BUNDLE ON)
    #set(CMAKE_FRAMEWORK ON)
    set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)
    #set(CMAKE_INSTALL_RPATH "@executable_path/Frameworks" "@loader_path/Frameworks")
    set(CMAKE_INSTALL_RPATH "@executable_path/lib" "@loader_path/lib")
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
  endif()


  #-----------------------------------------------------------------------
  # Compiler flags
  #-----------------------------------------------------------------------

  if(cmr_USE_STATIC_RUNTIME AND MSVC AND NOT BUILD_SHARED_LIBS)
    # Set MSVC static runtime flags for all configurations.
    # See:
    # https://stackoverflow.com/a/20804336
    # https://stackoverflow.com/a/14172871
    foreach(cfg "" ${CMAKE_CONFIGURATION_TYPES})
      set(c_flag_var   CMAKE_C_FLAGS)
      set(cxx_flag_var CMAKE_CXX_FLAGS)
      if(cfg)
        string(TOUPPER ${cfg} cfg_upper)
        set(c_flag_var   "${c_flag_var}_${cfg_upper}")
        set(cxx_flag_var "${cxx_flag_var}_${cfg_upper}")
      endif()
      if(${c_flag_var} MATCHES "/MD")
        string(REPLACE "/MD" "/MT" ${c_flag_var} "${${c_flag_var}}")
        set(${c_flag_var} ${${c_flag_var}} CACHE STRING
          "Flags used by the C compiler during ${cfg_upper} builds." FORCE
        )
      endif()
      if(${cxx_flag_var} MATCHES "/MD")
        string(REPLACE "/MD" "/MT" ${cxx_flag_var} "${${cxx_flag_var}}")
        set(${cxx_flag_var} ${${cxx_flag_var}} CACHE STRING
          "Flags used by the CXX compiler during ${cfg_upper} builds." FORCE
        )
      endif()
    endforeach()
  endif()


  #-----------------------------------------------------------------------
  # Set path vars
  #-----------------------------------------------------------------------

  #set(LibCMaker_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/libs")
  set(cmr_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}")

  if(NOT cmr_UNPACKED_DIR)
    set(cmr_UNPACKED_DIR "${PROJECT_BINARY_DIR}/download/unpacked")
  endif()


  #-----------------------------------------------------------------------
  # Configure for find_package()
  #-----------------------------------------------------------------------

  # Set CMake's search path for find_*() commands.
  list(APPEND CMAKE_PREFIX_PATH "${cmr_INSTALL_DIR}")

  if(ANDROID OR IOS)
    list(APPEND CMAKE_FIND_ROOT_PATH "${cmr_INSTALL_DIR}")
  endif()


  #-----------------------------------------------------------------------
  # LibCMaker settings
  #-----------------------------------------------------------------------

  #set(LibCMaker_DIR "${LibCMaker_LIB_DIR}/LibCMaker")
  list(APPEND CMAKE_MODULE_PATH "${LibCMaker_DIR}/cmake")
  include(cmr_find_package)


  #-----------------------------------------------------------------------
  # Download, configure, build, install and find the required libraries
  #-----------------------------------------------------------------------

  if(BUILD_TESTING)
    enable_testing()
    include(${LibCMaker_LIB_DIR}/LibCMaker_GoogleTest/cmr_build_googletest.cmake)
  endif()

  #-----------------------------------------------------------------------
  # Build the executable of the example
  #-----------------------------------------------------------------------

  if(NOT PROJECT_NAME STREQUAL "LibCMaker_GoogleTest_Compile_Test")
    add_executable(${PROJECT_NAME} ${IOS_MACOSX_BUNDLE} "")
  endif()
endmacro()


macro(cmr_common_sample_2nd_part)
  if(NOT MINGW AND NOT ANDROID AND NOT IOS
      AND NOT (APPLE AND CMAKE_GENERATOR MATCHES "Unix Makefiles"))
    set_target_properties(${PROJECT_NAME} PROPERTIES
      # Link all libraries into the target so as not to use LD_LIBRARY_PATH.
      LINK_WHAT_YOU_USE ON
    )
  endif()


  #-----------------------------------------------------------------------
  # iOS Bundle
  #-----------------------------------------------------------------------

  if(IOS)
    set(IOS_APP_BUNDLE_IDENTIFIER_MAIN "${IOS_APP_BUNDLE_IDENTIFIER}.main")
    set(IOS_MAIN_APP_BIN_DIR
      "${PROJECT_BINARY_DIR}/\${CONFIGURATION}\${EFFECTIVE_PLATFORM_NAME}/${PROJECT_NAME}.app"
    )

    set_target_properties(${PROJECT_NAME} PROPERTIES
      MACOSX_BUNDLE_INFO_STRING "${IOS_APP_BUNDLE_IDENTIFIER_MAIN}"
      MACOSX_BUNDLE_GUI_IDENTIFIER "${IOS_APP_BUNDLE_IDENTIFIER_MAIN}"
      MACOSX_BUNDLE_BUNDLE_NAME "${IOS_APP_BUNDLE_IDENTIFIER_MAIN}"

      XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "${IOS_CODE_SIGN_IDENTITY}"
      XCODE_ATTRIBUTE_DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM_ID}
      XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET ${IOS_DEPLOYMENT_TARGET}
      XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY ${IOS_DEVICE_FAMILY}
      #
      # From https://github.com/sheldonth/ios-cmake
      #
      #  RESOURCE "${RESOURCES}"
      #  XCODE_ATTRIBUTE_COMBINE_HIDPI_IMAGES NO
      #
      #  MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/plist.in
      #  XCODE_ATTRIBUTE_INSTALL_PATH "$(LOCAL_APPS_DIR)"
      #  XCODE_ATTRIBUTE_ENABLE_TESTABILITY YES
      #
      #  XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT "dwarf-with-dsym"
      #  XCODE_ATTRIBUTE_GCC_PREFIX_HEADER "${CMAKE_CURRENT_SOURCE_DIR}/Prefix.pch"
      #  XCODE_ATTRIBUTE_GCC_PRECOMPILE_PREFIX_HEADER "YES"
      #  XCODE_ATTRIBUTE_GCC_SYMBOLS_PRIVATE_EXTERN YES
      #  XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
    )

    if(BUILD_SHARED_LIBS)
      add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory
          "${IOS_MAIN_APP_BIN_DIR}/lib"
        COMMAND ${CMAKE_COMMAND} -E copy_directory
          "${cmr_INSTALL_DIR}/lib"
          "${IOS_MAIN_APP_BIN_DIR}/lib/"
      )
    endif()

    if(IOS_CODE_SIGN_IDENTITY)
      # Codesign the framework in it's new spot
      add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        #COMMAND codesign --force --verbose
        #    ${IOS_MAIN_APP_BIN_DIR}/Frameworks/${FRAMEWORK_NAME}.framework
        #    --sign ${IOS_CODE_SIGN_IDENTITY}
        #COMMAND codesign --force --verbose
        #    \${BUILT_PRODUCTS_DIR}/${PROJECT_NAME}.app/Frameworks/${FRAMEWORK_NAME}.framework
        #    --sign ${IOS_CODE_SIGN_IDENTITY}
        COMMAND codesign --force --verbose
            ${IOS_MAIN_APP_BIN_DIR}/${PROJECT_NAME}
            --sign ${IOS_CODE_SIGN_IDENTITY}
      )
    endif()
  endif()
endmacro()


macro(cmr_common_sample_test_1st_part)
  find_package(GTest REQUIRED)

  set(test_NAME "Examle_test")
  add_executable(${test_NAME} ${IOS_MACOSX_BUNDLE} "")
endmacro()


macro(cmr_common_sample_test_2nd_part)
  if(NOT MINGW AND NOT ANDROID AND NOT IOS
      AND NOT (APPLE AND CMAKE_GENERATOR MATCHES "Unix Makefiles"))
    set_target_properties(${test_NAME} PROPERTIES
      # Link all libraries into the target so as not to use LD_LIBRARY_PATH.
      LINK_WHAT_YOU_USE ON
    )
  endif()

  # GTest
  target_link_libraries(${test_NAME} PRIVATE
    GTest::GTest GTest::Main
  )


  #-----------------------------------------------------------------------
  # Test for Linux, Windows, macOS
  #-----------------------------------------------------------------------

  if(NOT ANDROID AND NOT IOS)
    add_test(NAME ${test_NAME} COMMAND ${test_NAME})
  endif()


  #-----------------------------------------------------------------------
  # Test for Android
  #-----------------------------------------------------------------------

  if(ANDROID)
    find_program(adb_exec adb HINTS ENV PATH)
    if(NOT adb_exec)
      message(FATAL_ERROR "Could not find 'adb'")
    endif()

    set(TEST_WORK_DIR "/data/local/tmp/LibCMaker_test")

    add_test(NAME rm_work_dir
      COMMAND ${adb_exec} shell "if [ -d \"${TEST_WORK_DIR}\" ] ; then rm -r \"${TEST_WORK_DIR}\" ; fi"
    )

    if(PROJECT_NAME STREQUAL "LibCMaker_Boost_Compile_Test"
        OR PROJECT_NAME STREQUAL "LibCMaker_ICU_Compile_Test")
      add_test(NAME push_icu_data
        COMMAND ${adb_exec} push
          "${cmr_INSTALL_DIR}/share/icu"
          "${TEST_WORK_DIR}/share/icu"
      )
    endif()

    if(BUILD_SHARED_LIBS)
      add_test(NAME check_tar
        COMMAND ${adb_exec} shell tar --help
      )
      set_tests_properties(check_tar PROPERTIES
        PASS_REGULAR_EXPRESSION "usage: tar"
      )
      set_tests_properties(check_tar PROPERTIES
        FAIL_REGULAR_EXPRESSION "tar: not found"
      )

      # Fix for the adb error on the arm devices if use the adb push
      # for the directory with the soft symlinks:
      # adb: error: failed to copy '<soft symlink>' to '/data/local/tmp/<soft symlink>': remote symlink failed: Permission denied
      # Instead of the direct using of the adb push use tar.
      add_custom_command(TARGET ${test_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E tar cf
          "${CMAKE_CURRENT_BINARY_DIR}/lib.tar"
          "${cmr_INSTALL_DIR}/lib"
        WORKING_DIRECTORY "${cmr_INSTALL_DIR}"
      )
      add_test(NAME push_libs_tar
        COMMAND ${adb_exec} push
          "${CMAKE_CURRENT_BINARY_DIR}/lib.tar"
          "${TEST_WORK_DIR}/lib.tar"
      )
      add_test(NAME extract_libs_tar
        COMMAND ${adb_exec} shell tar --no-same-owner
          -xf "${TEST_WORK_DIR}/lib.tar"
          -C "${TEST_WORK_DIR}"
      )

      if(PROJECT_NAME STREQUAL "LibCMaker_GoogleTest_Compile_Test")
        add_test(NAME push_test_lib
          COMMAND ${adb_exec} push
            "${PROJECT_BINARY_DIR}/libLibCMaker_GoogleTest_Compile_Test.so"
            "${TEST_WORK_DIR}/lib/libLibCMaker_GoogleTest_Compile_Test.so"
        )
      endif()

      find_library(cpp_shared_LIB "c++_shared")
      if(NOT cpp_shared_LIB)
        message(FATAL_ERROR "The library 'c++_shared' can not be found.")
      endif()

      get_filename_component(cpp_shared_LIB_FILE_NAME ${cpp_shared_LIB} NAME)

      add_test(NAME push_cpp_shared
        COMMAND ${adb_exec} push
          "${cpp_shared_LIB}"
          "${TEST_WORK_DIR}/lib/${cpp_shared_LIB_FILE_NAME}"
      )
    endif()

    add_test(NAME push_${test_NAME}
      COMMAND ${adb_exec} push ${test_NAME} "${TEST_WORK_DIR}/${test_NAME}"
    )
    add_test(NAME chmod_${test_NAME}
      COMMAND ${adb_exec} shell chmod 775 "${TEST_WORK_DIR}/${test_NAME}"
    )
    # TODO: is test "cd_to_work_dir" needed?
    add_test(NAME cd_to_work_dir COMMAND ${adb_exec} shell
      cd "${TEST_WORK_DIR}"
    )
    add_test(NAME ${test_NAME} COMMAND ${adb_exec} shell
      "cd ${TEST_WORK_DIR} && "
      "LD_LIBRARY_PATH=${TEST_WORK_DIR}/lib ${TEST_WORK_DIR}/${test_NAME}"
      # :${LD_LIBRARY_PATH} || :/vendor/lib64:/system/lib64
    )
  endif()


  #-----------------------------------------------------------------------
  # Test for iOS
  #-----------------------------------------------------------------------

  if(IOS)
    set(IOS_APP_BUNDLE_IDENTIFIER_GTEST "${IOS_APP_BUNDLE_IDENTIFIER}.gtest")
    set(IOS_TEST_APP_BIN_DIR
      "${PROJECT_BINARY_DIR}/test/\${CONFIGURATION}\${EFFECTIVE_PLATFORM_NAME}/${test_NAME}.app"
    )
    set(IOS_TEST_APP_FULL_BIN_DIR
      "${PROJECT_BINARY_DIR}/test/$<CONFIG>-iphonesimulator/${test_NAME}.app"
    )

    set_target_properties(${test_NAME} PROPERTIES
      MACOSX_BUNDLE_INFO_STRING "${IOS_APP_BUNDLE_IDENTIFIER_GTEST}"
      MACOSX_BUNDLE_GUI_IDENTIFIER "${IOS_APP_BUNDLE_IDENTIFIER_GTEST}"
      MACOSX_BUNDLE_BUNDLE_NAME "${IOS_APP_BUNDLE_IDENTIFIER_GTEST}"

      XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "${IOS_CODE_SIGN_IDENTITY}"
      XCODE_ATTRIBUTE_DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM_ID}
      XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET ${IOS_DEPLOYMENT_TARGET}
      XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY ${IOS_DEVICE_FAMILY}
    )

    if(PROJECT_NAME STREQUAL "LibCMaker_Boost_Compile_Test"
        OR PROJECT_NAME STREQUAL "LibCMaker_ICU_Compile_Test")
      add_custom_command(TARGET ${test_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory
          "${IOS_TEST_APP_BIN_DIR}/share/icu"
        COMMAND ${CMAKE_COMMAND} -E copy_directory
          "${cmr_INSTALL_DIR}/share/icu"
          "${IOS_TEST_APP_BIN_DIR}/share/icu/"
      )
    endif()

    if(BUILD_SHARED_LIBS)
      add_custom_command(TARGET ${test_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory
          "${IOS_TEST_APP_BIN_DIR}/lib"
        COMMAND ${CMAKE_COMMAND} -E copy_directory
          "${cmr_INSTALL_DIR}/lib"
          "${IOS_TEST_APP_BIN_DIR}/lib/"
      )

      if(PROJECT_NAME STREQUAL "LibCMaker_GoogleTest_Compile_Test")
        add_custom_command(TARGET ${test_NAME} POST_BUILD
          COMMAND ${CMAKE_COMMAND} -E copy
            "${PROJECT_BINARY_DIR}/$<CONFIG>-iphonesimulator/libLibCMaker_GoogleTest_Compile_Test.dylib"
            "${IOS_TEST_APP_BIN_DIR}/lib/libLibCMaker_GoogleTest_Compile_Test.dylib"
        )
      endif()
    endif()

    if(IOS_CODE_SIGN_IDENTITY)
      # Codesign the framework in it's new spot
      add_custom_command(TARGET ${test_NAME} POST_BUILD
        #COMMAND codesign --force --verbose
        #    ${IOS_TEST_APP_BIN_DIR}/Frameworks/${FRAMEWORK_NAME}.framework
        #    --sign ${IOS_CODE_SIGN_IDENTITY}
        #COMMAND codesign --force --verbose
        #    \${BUILT_PRODUCTS_DIR}/${test_NAME}.app/Frameworks/${FRAMEWORK_NAME}.framework
        #    --sign ${IOS_CODE_SIGN_IDENTITY}
        COMMAND codesign --force --verbose
            ${IOS_TEST_APP_BIN_DIR}/${test_NAME}
            --sign ${IOS_CODE_SIGN_IDENTITY}
      )
    endif()

    if(PROJECT_NAME STREQUAL "LibCMaker_Boost_Compile_Test"
        OR PROJECT_NAME STREQUAL "LibCMaker_ICU_Compile_Test")
      add_test(NAME copy_icu_dat_file_of_${test_NAME}
        COMMAND bash -c
          "TEST_APP_HOME_DIR=$(xcrun simctl getenv booted HOME) && cp -R ${cmr_INSTALL_DIR}/share $TEST_APP_HOME_DIR"
      )
      add_test(NAME ${test_NAME}
        COMMAND xcrun simctl spawn booted
          ${IOS_TEST_APP_FULL_BIN_DIR}/${test_NAME}
      )

    else()  # With install app.
      add_test(NAME install_${test_NAME}
        COMMAND xcrun simctl install booted ${IOS_TEST_APP_FULL_BIN_DIR}/
      )

#      if(PROJECT_NAME STREQUAL "LibCMaker_Boost_Compile_Test"
#          OR PROJECT_NAME STREQUAL "LibCMaker_ICU_Compile_Test")
#        # Must be after the app installing
#        add_test(NAME copy_icu_dat_file_of_${test_NAME}
#          COMMAND bash -c
#            "TEST_APP_HOME_DIR=$(xcrun simctl get_app_container booted ${IOS_APP_BUNDLE_IDENTIFIER_GTEST} data) && cp -R ${cmr_INSTALL_DIR}/share $TEST_APP_HOME_DIR"
#        )
#      endif()

      add_test(NAME ${test_NAME}
        COMMAND xcrun simctl launch --console-pty booted
          ${IOS_APP_BUNDLE_IDENTIFIER_GTEST}
      )
    endif()

    # NOTE: Use '--console-pty' with 'xcrun simctl launch' for Travis CI,
    # not '--console'. With '--console' is error:
    # -----------------------------------------------------------------------
    # Unable to establish FIFO: Error 2
    # An error was encountered processing the command (domain=NSPOSIXErrorDomain, code=2):
    # The operation couldn.t be completed. No such file or directory
    # No such file or directory
    # -----------------------------------------------------------------------
  endif()


  #-----------------------------------------------------------------------
  # Common test settings
  #-----------------------------------------------------------------------

  set_tests_properties(${test_NAME} PROPERTIES
    PASS_REGULAR_EXPRESSION "PASSED"
  )
  set_tests_properties(${test_NAME} PROPERTIES
    FAIL_REGULAR_EXPRESSION "FAILED"
  )
endmacro()
