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

include(cmr_print_debug)

function(cmr_print_value in_var)
  if(${in_var})
    list(LENGTH ${in_var} _list_len)
    if(_list_len GREATER 1)
      cmr_print_debug("Var: ${in_var} ==")
      foreach(val IN LISTS ${in_var})
        cmr_print_debug("    == ${val}")
      endforeach()
      return()
    endif()
  endif()

  cmr_print_debug("Var: ${in_var} == ${${in_var}}")
endfunction()
