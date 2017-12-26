# ****************************************************************************
#  Project:  LibCMaker
#  Purpose:  A CMake build scripts for build libraries with CMake
#  Author:   NikitaFeodonit, nfeodonit@yandex.com
# ****************************************************************************
#    Copyright (c) 2017 NikitaFeodonit
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

if(NOT LIBCMAKER_SRC_DIR)
  message(FATAL_ERROR
    "Please set LIBCMAKER_SRC_DIR with path to LibCMaker root")
endif()
# TODO: prevent multiply includes for CMAKE_MODULE_PATH
list(APPEND CMAKE_MODULE_PATH "${LIBCMAKER_SRC_DIR}/cmake/modules")

include(cmr_print_fatal_error)
include(cmr_print_debug_message)
include(cmr_print_var_value)

function(cmr_lib_cmaker)
  cmake_minimum_required(VERSION 2.8.12)

  set(options
    # optional args
    CONFIGURE BUILD BUILD_HOST_TOOLS INSTALL
  )
  # Useful params for BUILD_HOST_TOOLS:
  # HOST_TOOLS_CMAKE_TOOLCHAIN_FILE
  # HOST_TOOLS_CMAKE_GENERATOR
  # HOST_TOOLS_CMAKE_MAKE_PROGRAM
  
  set(oneValueArgs
    # required args
    PROJECT_DIR BUILD_DIR
    # optional args
    NAME VERSION DOWNLOAD_DIR UNPACKED_SRC_DIR
    HOST_TOOLS_CMAKE_TOOLCHAIN_FILE HOST_TOOLS_CMAKE_GENERATOR
    HOST_TOOLS_CMAKE_MAKE_PROGRAM
  )

  set(multiValueArgs
    # optional args
    COMPONENTS CMAKE_ARGS
  )

  cmake_parse_arguments(lib
      "${options}" "${oneValueArgs}" "${multiValueArgs}" "${ARGN}")
  # -> lib_VERSION
  # -> lib_COMPONENTS
  # -> lib_* ...

  cmr_print_var_value(LIBCMAKER_SRC_DIR)

  cmr_print_var_value(lib_CONFIGURE)
  cmr_print_var_value(lib_BUILD)
  cmr_print_var_value(lib_BUILD_HOST_TOOLS)
  cmr_print_var_value(lib_INSTALL)

  cmr_print_var_value(lib_PROJECT_DIR)
  cmr_print_var_value(lib_BUILD_DIR)

  cmr_print_var_value(lib_NAME)
  cmr_print_var_value(lib_VERSION)
  cmr_print_var_value(lib_DOWNLOAD_DIR)
  cmr_print_var_value(lib_UNPACKED_SRC_DIR)
  cmr_print_var_value(lib_HOST_TOOLS_CMAKE_TOOLCHAIN_FILE)
  cmr_print_var_value(lib_HOST_TOOLS_CMAKE_GENERATOR)
  cmr_print_var_value(lib_HOST_TOOLS_CMAKE_MAKE_PROGRAM)

  cmr_print_var_value(lib_COMPONENTS)
  cmr_print_var_value(lib_CMAKE_ARGS)

  # Required args
  if(NOT lib_PROJECT_DIR)
    cmr_print_fatal_error("Argument PROJECT_DIR is not defined.")
  endif()
  if(NOT lib_BUILD_DIR)
    cmr_print_fatal_error("Argument BUILD_DIR is not defined.")
  endif()
  if(lib_UNPARSED_ARGUMENTS)
    cmr_print_fatal_error(
      "There are unparsed arguments: ${lib_UNPARSED_ARGUMENTS}")
  endif()
  
  if(lib_INSTALL)
    set(lib_BUILD ON)
  endif()
  if(lib_BUILD)
    set(lib_CONFIGURE ON)
  endif()
  
  # To prevent the list expansion on an argument with ';'.
  # See also:
  # http://stackoverflow.com/a/20989991
  # http://stackoverflow.com/a/20985057
  if(lib_COMPONENTS)
    string(REPLACE ";" " " lib_COMPONENTS "${lib_COMPONENTS}")
  endif()
  if(CMAKE_FIND_ROOT_PATH)
    string(REPLACE ";" " " CMAKE_FIND_ROOT_PATH "${CMAKE_FIND_ROOT_PATH}")
  endif()


  #-----------------------------------------------------------------------
  # Build args
  #-----------------------------------------------------------------------

  set(cmr_CMAKE_ARGS)

  # Lib specific args
  if(DEFINED lib_CMAKE_ARGS)
    list(APPEND cmr_CMAKE_ARGS
      ${lib_CMAKE_ARGS} # TODO: check list to list adding
    )
  endif()

  # Prevent the host tools building with the cross platform tools.
  if(NOT lib_BUILD_HOST_TOOLS)
    if(DEFINED CMAKE_TOOLCHAIN_FILE)
      list(APPEND cmr_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
      )
    endif()
    if(DEFINED CMAKE_GENERATOR)
      list(APPEND cmr_CMAKE_ARGS
        -G "${CMAKE_GENERATOR}" # TODO: check it with debug message
      )
    endif()
    if(DEFINED CMAKE_MAKE_PROGRAM)
      list(APPEND cmr_CMAKE_ARGS
        -DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
      )
    endif()
  else() # if(lib_BUILD_HOST_TOOLS)
    if(DEFINED lib_HOST_TOOLS_CMAKE_TOOLCHAIN_FILE)
      list(APPEND cmr_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${lib_HOST_TOOLS_CMAKE_TOOLCHAIN_FILE}
      )
    endif()
    if(DEFINED lib_HOST_TOOLS_CMAKE_GENERATOR)
      list(APPEND cmr_CMAKE_ARGS
        -G "${lib_HOST_TOOLS_CMAKE_GENERATOR}" # TODO: check it with debug message
      )
    endif()
    if(DEFINED lib_HOST_TOOLS_CMAKE_MAKE_PROGRAM)
      list(APPEND cmr_CMAKE_ARGS
        -DCMAKE_MAKE_PROGRAM=${lib_HOST_TOOLS_CMAKE_MAKE_PROGRAM}
      )
    endif()
  endif()

  # Android specifics
  if(NOT lib_BUILD_HOST_TOOLS)
    include(cmr_android_vars)
    cmr_android_vars()
  endif()
  
  # Use /MP flag in command line. Just specify /MP by itself to have
  # VS's build system automatically select how many threads to compile on
  # (which usually is the maximum number of threads available):
  # cmake ..\ -DCMAKE_CXX_FLAGS="/MP" -DCMAKE_C_FLAGS="/MP" -DCMAKE_BUILD_TYPE=Release ^
  # && cmake --build . --config Release
  #
  # Enable /MP flag for Visual Studio 2008 and greater
  #if(MSVC AND MSVC_VERSION GREATER 1400 AND cmr_ADD_MSVC_MP_FLAG)
  #  include(ProcessorCount) # ProcessorCount
  #  ProcessorCount(CPU_CNT)
  #  if(CPU_CNT GREATER 0)
  #    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP${CPU_CNT}")
  #    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MP${CPU_CNT}")
  #  endif()
  #endif()
  

  set(cmr_LIB_VARS

    # Args for cmr_lib_cmaker().
    LIBCMAKER_SRC_DIR
    lib_BUILD_HOST_TOOLS
    lib_PROJECT_DIR
    lib_BUILD_DIR
    lib_NAME
    lib_VERSION
    lib_DOWNLOAD_DIR # Download dir for lib sources.
    lib_UNPACKED_SRC_DIR
    lib_COMPONENTS
    cmr_PRINT_DEBUG
    
    # Standard CMake vars.
    BUILD_SHARED_LIBS
    CMAKE_BUILD_TYPE
    CMAKE_CFG_INTDIR
    CMAKE_COLOR_MAKEFILE
    CMAKE_INSTALL_PREFIX
    CMAKE_VERBOSE_MAKEFILE
    SKIP_INSTALL_ALL
    SKIP_INSTALL_BINARIES
    SKIP_INSTALL_HEADERS
    SKIP_INSTALL_LIBRARIES
    SKIP_INSTALL_TOOLS
    SKIP_INSTALL_UTILITIES
    
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

  foreach(d ${cmr_LIB_VARS})
    if(DEFINED ${d})
      list(APPEND cmr_CMAKE_ARGS
        -D${d}=${${d}}
      )
    endif()
  endforeach()

  
  #-----------------------------------------------------------------------
  # BUILDING
  #-----------------------------------------------------------------------

# env [--unset=NAME]... [NAME=VALUE]... COMMAND [ARG]...
#     Run command in a modified environment.
# environment
#     Display the current environment variables.

  cmr_print_var_value(cmr_CMAKE_ARGS)

  if(lib_CONFIGURE)
    # Configure lib
    file(MAKE_DIRECTORY ${lib_BUILD_DIR})
    execute_process(
      COMMAND
        ${CMAKE_COMMAND} ${lib_PROJECT_DIR} ${cmr_CMAKE_ARGS}
      WORKING_DIRECTORY ${lib_BUILD_DIR}
      RESULT_VARIABLE configure_RESULT
    )
    
    if(configure_RESULT)
      cmr_print_var_value(configure_RESULT)
      cmr_print_fatal_error("cmr_lib_cmaker() ended with errors at configure time.")
    endif()
  
    if(lib_BUILD)
      # Build lib
      set(install_options "")
      if(lib_INSTALL)
        set(install_options "--target" "install")
      endif()
      execute_process(
        COMMAND ${CMAKE_COMMAND} --build . ${install_options}
        # For development.
        # WARNING: LibCMaker_Boost can not be builded with -j6 ! It need fix.
        #COMMAND ${CMAKE_COMMAND} --build . ${install_options} -- -j6
        WORKING_DIRECTORY ${lib_BUILD_DIR}
        RESULT_VARIABLE build_RESULT
      )
    
      if(build_RESULT)
        cmr_print_var_value(build_RESULT)
        cmr_print_fatal_error("cmr_lib_cmaker() ended with errors at build time.")
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
