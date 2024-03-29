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

include(CMakeParseArguments)  # cmake_parse_arguments()

include(cmr_printers)

function(cmr_lib_cmaker_main)
  cmake_minimum_required(VERSION ${cmr_CMAKE_MIN_VER})

  set(options
    # Optional args.
    CONFIGURE BUILD BUILD_HOST_TOOLS INSTALL
  )
  # Useful vars for BUILD_HOST_TOOLS:
  # HOST_TOOLS_CMAKE_TOOLCHAIN_FILE
  # HOST_TOOLS_CMAKE_GENERATOR
  # HOST_TOOLS_CMAKE_GENERATOR_PLATFORM
  # HOST_TOOLS_CMAKE_GENERATOR_TOOLSET
  # HOST_TOOLS_CMAKE_MAKE_PROGRAM

  set(oneValueArgs
    # Required args.
    LibCMaker_DIR
    NAME
    VERSION
    BASE_DIR
    BUILD_DIR
    # Optional args.
    DOWNLOAD_DIR
    UNPACKED_DIR
  )

  set(multiValueArgs
    # Required args.
    LANGUAGES
    # Optional args.
    COMPONENTS CMAKE_ARGS
  )

  cmake_parse_arguments(lib
      "${options}" "${oneValueArgs}" "${multiValueArgs}" "${ARGN}")
  # -> lib_VERSION
  # -> lib_COMPONENTS
  # -> lib_* ...

  cmr_print_value(lib_LibCMaker_DIR)

  cmr_print_value(lib_NAME)
  cmr_print_value(lib_VERSION)
  cmr_print_value(lib_COMPONENTS)
  cmr_print_value(lib_LANGUAGES)

  cmr_print_value(lib_BASE_DIR)
  cmr_print_value(lib_DOWNLOAD_DIR)
  cmr_print_value(lib_UNPACKED_DIR)
  cmr_print_value(lib_BUILD_DIR)

  cmr_print_value(lib_CONFIGURE)
  cmr_print_value(lib_BUILD)
  cmr_print_value(lib_BUILD_HOST_TOOLS)
  cmr_print_value(lib_INSTALL)

  cmr_print_value(lib_CMAKE_ARGS)

  # Required args.
  if(NOT lib_LibCMaker_DIR)
    cmr_print_error("Argument LibCMaker_DIR is not defined.")
  endif()
  if(NOT lib_NAME)
    cmr_print_error("Argument NAME is not defined.")
  endif()
  if(NOT lib_VERSION)
    cmr_print_error("Argument VERSION is not defined.")
  endif()
  if(NOT lib_LANGUAGES)
    cmr_print_error("Argument LANGUAGES is not defined.")
  endif()
  if(NOT lib_BASE_DIR)
    cmr_print_error("Argument BASE_DIR is not defined.")
  endif()
  if(NOT lib_BUILD_DIR)
    cmr_print_error("Argument BUILD_DIR is not defined.")
  endif()
  if(lib_UNPARSED_ARGUMENTS)
    cmr_print_error("There are unparsed arguments: ${lib_UNPARSED_ARGUMENTS}")
  endif()

  if(lib_INSTALL)
    set(lib_BUILD ON)
  endif()
  if(lib_BUILD)
    set(lib_CONFIGURE ON)
  endif()
  if(NOT lib_CONFIGURE)
    cmr_print_error(
      "There are not defined one of CONFIGURE, BUILD or INSTALL.")
  endif()

  # To prevent the list expansion on an argument with ';'.
  # See also:
  # http://stackoverflow.com/a/20989991
  # http://stackoverflow.com/a/20985057
  if(lib_LANGUAGES)
    string(REPLACE ";" " " lib_LANGUAGES "${lib_LANGUAGES}")
  endif()
  if(lib_COMPONENTS)
    string(REPLACE ";" " " lib_COMPONENTS "${lib_COMPONENTS}")
  endif()
  if(CMAKE_FIND_ROOT_PATH)
    string(REPLACE ";" " " CMAKE_FIND_ROOT_PATH "${CMAKE_FIND_ROOT_PATH}")
  endif()
  if(CMAKE_PREFIX_PATH)
    string(REPLACE ";" " " CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
  endif()
  if(CMAKE_INCLUDE_PATH)
    string(REPLACE ";" " " CMAKE_INCLUDE_PATH "${CMAKE_INCLUDE_PATH}")
  endif()
  if(CMAKE_LIBRARY_PATH)
    string(REPLACE ";" " " CMAKE_LIBRARY_PATH "${CMAKE_LIBRARY_PATH}")
  endif()
  if(CMAKE_PROGRAM_PATH)
    string(REPLACE ";" " " CMAKE_PROGRAM_PATH "${CMAKE_PROGRAM_PATH}")
  endif()
  if(CMAKE_INSTALL_RPATH)
    string(REPLACE ";" " " CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}")
  endif()


  #-----------------------------------------------------------------------
  # Build args
  #-----------------------------------------------------------------------

  unset(cmr_CMAKE_ARGS)

  # Lib specific args.
  if(DEFINED lib_CMAKE_ARGS)
    list(APPEND cmr_CMAKE_ARGS
      ${lib_CMAKE_ARGS}
    )
  endif()

  # Prevent the host tools building with the cross platform tools.
  if(NOT lib_BUILD_HOST_TOOLS)
    cmr_print_value(CMAKE_TOOLCHAIN_FILE)
    cmr_print_value(CMAKE_GENERATOR)
    cmr_print_value(CMAKE_GENERATOR_PLATFORM)
    cmr_print_value(CMAKE_GENERATOR_TOOLSET)
    cmr_print_value(CMAKE_MAKE_PROGRAM)

    set(cmr_LIB_VARS
      CMAKE_TOOLCHAIN_FILE
      CMAKE_GENERATOR
      CMAKE_GENERATOR_PLATFORM
      CMAKE_GENERATOR_TOOLSET
      CMAKE_MAKE_PROGRAM
    )

    foreach(d ${cmr_LIB_VARS})
      if(DEFINED ${d})
        list(APPEND cmr_CMAKE_ARGS
          -D${d}=${${d}}
        )
      endif()
    endforeach()

  else() # if(lib_BUILD_HOST_TOOLS)
    cmr_print_value(HOST_TOOLS_CMAKE_TOOLCHAIN_FILE)
    cmr_print_value(HOST_TOOLS_CMAKE_GENERATOR)
    cmr_print_value(HOST_TOOLS_CMAKE_GENERATOR_PLATFORM)
    cmr_print_value(HOST_TOOLS_CMAKE_GENERATOR_TOOLSET)
    cmr_print_value(HOST_TOOLS_CMAKE_MAKE_PROGRAM)

    set(cmr_LIB_VARS
      HOST_TOOLS_CMAKE_TOOLCHAIN_FILE
      HOST_TOOLS_CMAKE_GENERATOR
      HOST_TOOLS_CMAKE_GENERATOR_PLATFORM
      HOST_TOOLS_CMAKE_GENERATOR_TOOLSET
      HOST_TOOLS_CMAKE_MAKE_PROGRAM
    )

    foreach(d ${cmr_LIB_VARS})
      string(REPLACE "HOST_TOOLS_" "" out_d ${d})
      if(DEFINED ${d})
        list(APPEND cmr_CMAKE_ARGS
          -D${out_d}=${${d}}
        )
      elseif(DEFINED ${out_d})
        list(APPEND cmr_CMAKE_ARGS
          -D${out_d}=${${out_d}}
        )
      endif()
    endforeach()
  endif()

  if(NOT lib_BUILD_HOST_TOOLS)
    # Android specifics.
    include(cmr_vars_android)
    # iOS specifics.
    include(cmr_vars_ios)
  endif()

  if(lib_BUILD)
    set(tool_options "")

    if(NOT DEFINED cmr_BUILD_MULTIPROC)
      set(cmr_BUILD_MULTIPROC ON)
    endif()

    if(cmr_BUILD_MULTIPROC)
      if(NOT cmr_BUILD_MULTIPROC_CNT)
        set(cmr_BUILD_MULTIPROC_CNT "")
        include(ProcessorCount)  # ProcessorCount()
        ProcessorCount(CPU_CNT)
        if(CPU_CNT GREATER 0)
          set(cmr_BUILD_MULTIPROC_CNT ${CPU_CNT})
        endif()
      endif()

      # Enable /MP flag for Visual Studio 2008 and greater.
      if(MSVC AND MSVC_VERSION GREATER 1400)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MP${cmr_BUILD_MULTIPROC_CNT}")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP${cmr_BUILD_MULTIPROC_CNT}")
      endif()

      if(CMAKE_MAKE_PROGRAM MATCHES "make"
          OR CMAKE_MAKE_PROGRAM MATCHES "ninja")
        set(tool_options "-j${cmr_BUILD_MULTIPROC_CNT}")
        if(CMAKE_MAKE_PROGRAM MATCHES "ninja" AND NOT cmr_BUILD_MULTIPROC_CNT)
          set(tool_options "")
        endif()
      elseif(CMAKE_MAKE_PROGRAM MATCHES "xcodebuild")
        set(tool_options -jobs ${cmr_BUILD_MULTIPROC_CNT})
      endif()

    else()  # if(NOT cmr_BUILD_MULTIPROC)
      if(CMAKE_MAKE_PROGRAM MATCHES "make"
          OR CMAKE_MAKE_PROGRAM MATCHES "ninja")
        set(tool_options "-j1")
      endif()
    endif()

    if(CMAKE_GENERATOR MATCHES "Visual Studio.*"
        AND cmr_VS_GENERATOR_VERBOSITY_LEVEL)
      # See:
      # https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2019
      # q[uiet], m[inimal], n[ormal] (default), d[etailed], and diag[nostic]
      set(tool_options "/verbosity:${cmr_VS_GENERATOR_VERBOSITY_LEVEL}")
    endif()

    if(CMAKE_GENERATOR MATCHES "Xcode"
        AND cmr_XCODE_GENERATOR_VERBOSITY_LEVEL)
      # See:
      # xcodebuild --help
      # -quiet    Do not print any output except for warnings and errors.
      # -verbose  Provide additional status output.
      set(tool_options "${cmr_XCODE_GENERATOR_VERBOSITY_LEVEL}")
    endif()

  endif()

  set(cmr_LIB_VARS
    # Args for cmr_lib_cmaker_main().
    lib_LibCMaker_DIR
    cmr_CMAKE_MIN_VER

    lib_NAME
    lib_VERSION
    lib_COMPONENTS
    lib_LANGUAGES

    lib_BASE_DIR      # Library's LibCMaker dir.
    lib_DOWNLOAD_DIR  # Download dir for lib sources.
    lib_UNPACKED_DIR  # Common unpacked dir.
    lib_BUILD_DIR     # Library's build dir.

    lib_CONFIGURE
    lib_BUILD
    lib_BUILD_HOST_TOOLS
    lib_INSTALL

    cmr_PRINT_DEBUG
    cmr_BUILD_MULTIPROC
    cmr_BUILD_MULTIPROC_CNT
    cmr_USE_STATIC_RUNTIME
    cmr_VS_GENERATOR_VERBOSITY_LEVEL
    cmr_XCODE_GENERATOR_VERBOSITY_LEVEL

    SKIP_INSTALL_ALL
    SKIP_INSTALL_BINARIES
    SKIP_INSTALL_HEADERS
    SKIP_INSTALL_LIBRARIES
    SKIP_INSTALL_TOOLS
    SKIP_INSTALL_UTILITIES

    # Standard CMake vars.
    CMAKE_COLOR_MAKEFILE
    CMAKE_VERBOSE_MAKEFILE

    BUILD_SHARED_LIBS
    CMAKE_BUILD_TYPE
    CMAKE_CFG_INTDIR
    CMAKE_CONFIGURATION_TYPES

    CMAKE_PREFIX_PATH

    CMAKE_INCLUDE_PATH
    CMAKE_LIBRARY_PATH
    CMAKE_PROGRAM_PATH

    CMAKE_C_STANDARD
    CMAKE_C_STANDARD_REQUIRED
    CMAKE_CXX_STANDARD
    CMAKE_CXX_STANDARD_REQUIRED

    CMAKE_C_COMPILER_LAUNCHER
    CMAKE_CXX_COMPILER_LAUNCHER
    CMAKE_ASM_COMPILER_LAUNCHER

    CMAKE_INTERPROCEDURAL_OPTIMIZATION

    CMAKE_SYSTEM_VERSION
    CMAKE_MSVC_RUNTIME_LIBRARY

    cmr_VS_TOOLSET_DIR
    cmr_VS_TOOLSET_VERSION
    cmr_WINDOWS_KITS_DIR
    cmr_WINDOWS_KITS_VERSION

    CMAKE_USER_MAKE_RULES_OVERRIDE
    TARGETING_XP_64
    TARGETING_XP

    CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM
    CMAKE_XCODE_GENERATE_TOP_LEVEL_PROJECT_ONLY

    CMAKE_MACOSX_BUNDLE
    CMAKE_FRAMEWORK
    CMAKE_BUILD_WITH_INSTALL_RPATH
    CMAKE_INSTALL_RPATH
    CMAKE_INSTALL_RPATH_USE_LINK_PATH
  )

  if(NOT IOS)
    list(APPEND cmr_LIB_VARS
      CMAKE_OSX_SYSROOT
    )
  endif()

  if(NOT DEFINED cmr_INSTALL_DIR)
    list(APPEND cmr_LIB_VARS
      CMAKE_INSTALL_PREFIX
    )
  endif()

  if(NOT lib_BUILD_HOST_TOOLS)
    list(APPEND cmr_LIB_VARS
      # Standard CMake vars.
      CMAKE_FIND_ROOT_PATH

      # Compiler flags.
      CMAKE_ASM_COMPILER
      CMAKE_C_COMPILER
      CMAKE_C_COMPILER_TARGET
      CMAKE_CXX_COMPILER
      CMAKE_CXX_COMPILER_TARGET

      CMAKE_C_FLAGS
      CMAKE_C_FLAGS_DEBUG
      CMAKE_C_FLAGS_RELEASE

      CMAKE_CXX_FLAGS
      CMAKE_CXX_FLAGS_DEBUG
      CMAKE_CXX_FLAGS_RELEASE

      CMAKE_ASM_FLAGS
      CMAKE_ASM_FLAGS_DEBUG
      CMAKE_ASM_FLAGS_RELEASE

      CMAKE_SHARED_LINKER_FLAGS
      CMAKE_MODULE_LINKER_FLAGS
      CMAKE_EXE_LINKER_FLAGS

      CMAKE_C_LINK_FLAGS
      CMAKE_CXX_LINK_FLAGS
      CMAKE_ASM_LINK_FLAGS

      # TODO:
      #CMAKE_C_FLAGS_MINSIZEREL
      #CMAKE_C_FLAGS_RELWITHDEBINFO
      #CMAKE_CXX_FLAGS_MINSIZEREL
      #CMAKE_CXX_FLAGS_RELWITHDEBINFO
    )

    if(ANDROID)
      list(APPEND cmr_LIB_VARS
        CMAKE_FIND_ROOT_PATH_MODE_INCLUDE
        CMAKE_FIND_ROOT_PATH_MODE_LIBRARY
        CMAKE_FIND_ROOT_PATH_MODE_PACKAGE
        CMAKE_FIND_ROOT_PATH_MODE_PROGRAM
      )
    endif()
  endif()

  foreach(d ${cmr_LIB_VARS})
    if(DEFINED ${d})
      list(APPEND cmr_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()

  if(DEFINED cmr_INSTALL_DIR)
    list(APPEND cmr_CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${cmr_INSTALL_DIR}
    )
  endif()

  if(CMAKE_INTERPROCEDURAL_OPTIMIZATION)
    list(APPEND cmr_CMAKE_ARGS
      -DCMAKE_POLICY_DEFAULT_CMP0069=NEW
    )
  endif()


  #-----------------------------------------------------------------------
  # Building
  #-----------------------------------------------------------------------

# env [--unset=NAME]... [NAME=VALUE]... COMMAND [ARG]...
#     Run command in a modified environment.
# environment
#     Display the current environment variables.

  cmr_print_value(cmr_CMAKE_ARGS)

  if(lib_CONFIGURE)
    # Configure lib.
    file(MAKE_DIRECTORY ${lib_BUILD_DIR})
    execute_process(
      COMMAND ${CMAKE_COMMAND} ${lib_LibCMaker_DIR} ${cmr_CMAKE_ARGS}
      WORKING_DIRECTORY ${lib_BUILD_DIR}
      RESULT_VARIABLE configure_RESULT
    )

    if(configure_RESULT)
      cmr_print_value(configure_RESULT)
      cmr_print_error("cmr_lib_cmaker_main() ended with errors at configure time.")
    endif()

    if(lib_BUILD)
      # Build lib.

      set(config_options "")
      if(NOT CMAKE_CFG_INTDIR STREQUAL ".")
        list(LENGTH CMAKE_CONFIGURATION_TYPES config_cnt)
        if(config_cnt GREATER 1)
          cmr_print_error(
            "Please set only one configuration in CMAKE_CONFIGURATION_TYPES. Debug or Release are supported."
          )
        endif()
        list(GET CMAKE_CONFIGURATION_TYPES 0 config_type)
        set(config_options "--config" ${config_type})
      endif()

      set(target_options "")
      if(lib_INSTALL)
        set(target_options "--target" install)
      endif()

      execute_process(
        COMMAND ${CMAKE_COMMAND} --build .
          ${config_options} ${target_options} -- ${tool_options}
        WORKING_DIRECTORY ${lib_BUILD_DIR}
        RESULT_VARIABLE build_RESULT
      )

      if(build_RESULT)
        cmr_print_value(build_RESULT)
        cmr_print_error("cmr_lib_cmaker_main() ended with errors at build time.")
      endif()
    endif()
  endif()


# TODO: http://stackoverflow.com/a/8200645
# To remove untracked files / directories do:
# git clean -fdx
# -f - force
# -d - directories too
# -x - remove ignored files too ( don't use this if you don't want to remove ignored files)
# Add -n to preview first so you don't accidentally remove stuff

endfunction()
