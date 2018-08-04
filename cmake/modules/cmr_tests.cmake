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

#include(cmr_print_error)
#cmr_print_error("Test cmr_print_error()")

include(cmr_print_debug)
cmr_print_debug("Test cmr_print_debug(), cmr_PRINT_DEBUG OFF")
set(cmr_PRINT_DEBUG ON)
cmr_print_debug("Test cmr_print_debug(), cmr_PRINT_DEBUG ON")

include(cmr_print_value)
set(TEST_VAR "test value")
cmr_print_value(TEST_VAR)

include(cmr_get_version_parts)
# Test correct version string
set(test_VERSION "12.23.34.45")
cmr_print_value(test_VERSION)
cmr_get_version_parts(${test_VERSION} test_MAJOR test_MINOR test_PATCH test_TWEAK)
cmr_print_value(test_MAJOR)
cmr_print_value(test_MINOR)
cmr_print_value(test_PATCH)
cmr_print_value(test_TWEAK)

# Test bad version string
#set(test_VERSION "aa12.23.34.45aa")
#cmr_print_value(test_VERSION)
#cmr_get_version_parts(${test_VERSION} test_MAJOR test_MINOR test_PATCH test_TWEAK)
