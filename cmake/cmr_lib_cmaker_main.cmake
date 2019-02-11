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
  # Useful parameters for BUILD_HOST_TOOLS:
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
    # Optional args for cross compilation.
    HOST_TOOLS_CMAKE_TOOLCHAIN_FILE
    HOST_TOOLS_CMAKE_GENERATOR
    HOST_TOOLS_CMAKE_GENERATOR_PLATFORM
    HOST_TOOLS_CMAKE_GENERATOR_TOOLSET
    HOST_TOOLS_CMAKE_MAKE_PROGRAM
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
    cmr_print_value(lib_HOST_TOOLS_CMAKE_TOOLCHAIN_FILE)
    cmr_print_value(lib_HOST_TOOLS_CMAKE_GENERATOR)
    cmr_print_value(lib_HOST_TOOLS_CMAKE_GENERATOR_PLATFORM)
    cmr_print_value(lib_HOST_TOOLS_CMAKE_GENERATOR_TOOLSET)
    cmr_print_value(lib_HOST_TOOLS_CMAKE_MAKE_PROGRAM)

    set(cmr_LIB_VARS
      lib_HOST_TOOLS_CMAKE_TOOLCHAIN_FILE
      lib_HOST_TOOLS_CMAKE_GENERATOR
      lib_HOST_TOOLS_CMAKE_GENERATOR_PLATFORM
      lib_HOST_TOOLS_CMAKE_GENERATOR_TOOLSET
      lib_HOST_TOOLS_CMAKE_MAKE_PROGRAM
    )

    foreach(d ${cmr_LIB_VARS})
      if(DEFINED ${d})
        string(REPLACE "lib_HOST_TOOLS_" "" out_d ${d})
        list(APPEND cmr_CMAKE_ARGS
          -D${out_d}=${${d}}
        )
      endif()
    endforeach()
  endif()

  # Android specifics.
  if(NOT lib_BUILD_HOST_TOOLS)
    include(cmr_android_vars)
    cmr_android_vars()
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
      endif()

    else()  # if(NOT cmr_BUILD_MULTIPROC)
      if(CMAKE_MAKE_PROGRAM MATCHES "make"
          OR CMAKE_MAKE_PROGRAM MATCHES "ninja")
        set(tool_options "-j1")
      endif()
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
    cmr_USE_MSVC_STATIC_RUNTIME

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

    CMAKE_INSTALL_PREFIX
    CMAKE_PREFIX_PATH
    CMAKE_INCLUDE_PATH
    CMAKE_LIBRARY_PATH
    CMAKE_PROGRAM_PATH

    CMAKE_C_STANDARD
    CMAKE_C_STANDARD_REQUIRED
    CMAKE_CXX_STANDARD
    CMAKE_CXX_STANDARD_REQUIRED
  )

  if(NOT lib_BUILD_HOST_TOOLS)
    list(APPEND cmr_LIB_VARS

      # Standard CMake vars.
      CMAKE_FIND_ROOT_PATH

      # Compiler flags.
      CMAKE_C_FLAGS
      CMAKE_CXX_FLAGS
      CMAKE_ASM_FLAGS
      CMAKE_C_FLAGS_DEBUG
      CMAKE_CXX_FLAGS_DEBUG
      CMAKE_ASM_FLAGS_DEBUG
      CMAKE_C_FLAGS_RELEASE
      CMAKE_CXX_FLAGS_RELEASE
      CMAKE_ASM_FLAGS_RELEASE
      CMAKE_SHARED_LINKER_FLAGS
      CMAKE_MODULE_LINKER_FLAGS
      CMAKE_EXE_LINKER_FLAGS
    )
  endif()

  foreach(d ${cmr_LIB_VARS})
    if(DEFINED ${d})
      list(APPEND cmr_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()


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
            "Please set only one configuration (Debug, Release, ...) in CMAKE_CONFIGURATION_TYPES."
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
