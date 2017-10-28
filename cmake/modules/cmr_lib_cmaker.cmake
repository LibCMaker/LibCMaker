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
    INSTALL BUILD_HOST_TOOLS
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

  cmr_print_var_value(lib_INSTALL)
  cmr_print_var_value(lib_BUILD_HOST_TOOLS)

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
  
  # To prevent the list expansion on an argument with ';'.
  # See also:
  # http://stackoverflow.com/a/20989991
  # http://stackoverflow.com/a/20985057
  if(lib_COMPONENTS)
    string(REPLACE ";" " " lib_COMPONENTS "${lib_COMPONENTS}")
  endif()


  #-----------------------------------------------------------------------
  # Build args
  #-----------------------------------------------------------------------

  set(cmr_CMAKE_ARGS)

  # Args for cmr_lib_cmaker().
  if(LIBCMAKER_SRC_DIR)
    list(APPEND cmr_CMAKE_ARGS
      -DLIBCMAKER_SRC_DIR=${LIBCMAKER_SRC_DIR}
    )
  endif()
  if(lib_BUILD_HOST_TOOLS)
    list(APPEND cmr_CMAKE_ARGS
      -Dlib_BUILD_HOST_TOOLS=${lib_BUILD_HOST_TOOLS}
    )
  endif()
  if(lib_PROJECT_DIR)
    list(APPEND cmr_CMAKE_ARGS
      -Dlib_PROJECT_DIR=${lib_PROJECT_DIR}
    )
  endif()
  if(lib_BUILD_DIR)
    list(APPEND cmr_CMAKE_ARGS
      -Dlib_BUILD_DIR=${lib_BUILD_DIR}
    )
  endif()
  if(lib_NAME)
    list(APPEND cmr_CMAKE_ARGS
      -Dlib_NAME=${lib_NAME}
    )
  endif()
  if(lib_VERSION)
    list(APPEND cmr_CMAKE_ARGS
      -Dlib_VERSION=${lib_VERSION}
    )
  endif()
  # Download dir for lib sources.
  if(lib_DOWNLOAD_DIR)
    list(APPEND cmr_CMAKE_ARGS
      -Dlib_DOWNLOAD_DIR=${lib_DOWNLOAD_DIR}
    )
  endif()
  if(lib_UNPACKED_SRC_DIR)
    list(APPEND cmr_CMAKE_ARGS
      -Dlib_UNPACKED_SRC_DIR=${lib_UNPACKED_SRC_DIR}
    )
  endif()
  if(lib_COMPONENTS)
    list(APPEND cmr_CMAKE_ARGS
      -Dlib_COMPONENTS=${lib_COMPONENTS}
    )
  endif()
  # Lib specific args
  if(lib_CMAKE_ARGS)
    list(APPEND cmr_CMAKE_ARGS
      ${lib_CMAKE_ARGS} # TODO: check list to list adding
    )
  endif()

  if(cmr_PRINT_DEBUG)
    list(APPEND cmr_CMAKE_ARGS
      -Dcmr_PRINT_DEBUG=${cmr_PRINT_DEBUG}
    )
  endif()

  # Standard CMake vars
  if(CMAKE_INSTALL_PREFIX)
    list(APPEND cmr_CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
    )
  endif()
  if(CMAKE_BUILD_TYPE)
    list(APPEND cmr_CMAKE_ARGS
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    )
  endif()
  if(BUILD_SHARED_LIBS)
    list(APPEND cmr_CMAKE_ARGS
      -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
    )
  endif()


  # Prevent the host tools building with the cross platform tools.
  if(NOT lib_BUILD_HOST_TOOLS)
    if(CMAKE_TOOLCHAIN_FILE)
      list(APPEND cmr_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
      )
    endif()
    if(CMAKE_GENERATOR)
      list(APPEND cmr_CMAKE_ARGS
        -G "${CMAKE_GENERATOR}" # TODO: check it with debug message
      )
    endif()
    if(CMAKE_MAKE_PROGRAM)
      list(APPEND cmr_CMAKE_ARGS
        -DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
      )
    endif()
  else() # if(lib_BUILD_HOST_TOOLS)
    if(lib_HOST_TOOLS_CMAKE_TOOLCHAIN_FILE)
      list(APPEND cmr_CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${lib_HOST_TOOLS_CMAKE_TOOLCHAIN_FILE}
      )
    endif()
    if(lib_HOST_TOOLS_CMAKE_GENERATOR)
      list(APPEND cmr_CMAKE_ARGS
        -G "${lib_HOST_TOOLS_CMAKE_GENERATOR}" # TODO: check it with debug message
      )
    endif()
    if(lib_HOST_TOOLS_CMAKE_MAKE_PROGRAM)
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
  
  
  #-----------------------------------------------------------------------
  # BUILDING
  #-----------------------------------------------------------------------

# env [--unset=NAME]... [NAME=VALUE]... COMMAND [ARG]...
#     Run command in a modified environment.
# environment
#     Display the current environment variables.

  cmr_print_var_value(cmr_CMAKE_ARGS)

  # Configure lib
  file(MAKE_DIRECTORY ${lib_BUILD_DIR})
  execute_process(
    COMMAND
      ${CMAKE_COMMAND} ${lib_PROJECT_DIR} ${cmr_CMAKE_ARGS}
#      ${CMAKE_COMMAND} ${LIBCMAKER_SRC_DIR} ${cmr_CMAKE_ARGS} # TODO
    WORKING_DIRECTORY ${lib_BUILD_DIR}
    RESULT_VARIABLE configure_RESULT
  )
  
  if(configure_RESULT)
    cmr_print_var_value(configure_RESULT)
    cmr_fatal_error("cmr_lib_cmaker() ended with errors at configure time.")
  endif()

  # Build lib
  set(install_options "")
  if(lib_INSTALL)
    set(install_options "--target" "install")
  endif()
  execute_process(
    COMMAND ${CMAKE_COMMAND} --build . ${install_options}
    WORKING_DIRECTORY ${lib_BUILD_DIR}
    RESULT_VARIABLE build_RESULT
  )

  if(build_RESULT)
    cmr_print_var_value(build_RESULT)
    cmr_print_fatal_error("cmr_lib_cmaker() ended with errors at build time.")
  endif()


# TODO: http://stackoverflow.com/a/8200645
# To remove untracked files / directories do:
# git clean -fdx
# -f - force
# -d - directories too
# -x - remove ignored files too ( don't use this if you don't want to remove ignored files)
# Add -n to preview first so you don't accidentally remove stuff

endfunction()
