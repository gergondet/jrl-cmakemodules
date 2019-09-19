# Copyright (C) 2019 BIT.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# This file defines helpful macros to work with a meta CMake project, i.e. a
# CMake project that includes at least two projects

include(cmake/uninstall.cmake)

if(NOT DEFINED JRL_META_PACKAGE)
  set(JRL_META_PACKAGE FALSE)
endif()

macro(JRL_META_INIT)
  _SETUP_PROJECT_UNINSTALL()
  set(JRL_META_PACKAGE TRUE)
  set(JRL_META_PROJECTS)
  set(JRL_META_ROOTDIR "${CMAKE_CURRENT_SOURCE_DIR}")
endmacro()

macro(JRL_META_ADD_PROJECT NAME)
  list(APPEND JRL_META_PROJECTS ${NAME})
  set(${NAME}_META_DEPENDENCIES ${ARGN})
  add_subdirectory(${NAME})
endmacro()

macro(JRL_META_FINALIZE)
endmacro()
