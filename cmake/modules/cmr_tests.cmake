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

#include(cmr_print_fatal_error)
#cmr_print_fatal_error("Test cmr_print_fatal_error()")

include(cmr_print_debug_message)
cmr_print_debug_message("Test cmr_print_debug_message(), cmr_PRINT_DEBUG OFF")
set(cmr_PRINT_DEBUG ON)
cmr_print_debug_message("Test cmr_print_debug_message(), cmr_PRINT_DEBUG ON")

include(cmr_print_var_value)
set(TEST_VAR "test value")
cmr_print_var_value(TEST_VAR)
