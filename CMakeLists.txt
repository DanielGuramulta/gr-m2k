# Copyright 2011,2012 Free Software Foundation, Inc.
#
# This file is part of GNU Radio
#
# GNU Radio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# GNU Radio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Radio; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.

########################################################################
# Project setup
########################################################################
cmake_minimum_required(VERSION 3.8)
project(gr-m2k CXX C)
enable_testing()

# Set the version information here
set(VERSION_INFO_MAJOR_VERSION 0)
set(VERSION_INFO_API_COMPAT 0)
set(VERSION_INFO_MINOR_VERSION 1)
set(VERSION_INFO_MAINT_VERSION git)
set(GR_M2K_VERSION_MAJOR ${VERSION_INFO_MAJOR_VERSION})
set(GR_M2K_VERSION_MINOR ${VERSION_INFO_MINOR_VERSION})
set(VERSION_INFO_VERSION ${GR_M2K_VERSION_MAJOR}.${GR_M2K_VERSION_MINOR})
set(GR_M2K_VERSION ${VERSION_INFO_VERSION})

# build digital interfaces
option(DIGITAL "Build the digital interfaces" OFF)

#install to PyBOMBS target prefix if defined
if (DEFINED ENV{PYBOMBS_PREFIX})
    set(CMAKE_INSTALL_PREFIX $ENV{PYBOMBS_PREFIX})
    message(STATUS "PyBOMBS installed GNU Radio. Setting CMAKE_INSTALL_PREFIX to $ENV{PYBOMBS_PREFIX}")
endif ()

#select the release build type by default to get optimization flags
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
    message(STATUS "Build type not specified: defaulting to release.")
endif (NOT CMAKE_BUILD_TYPE)
set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE} CACHE STRING "")

#make sure our local CMake Modules path comes first
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_SOURCE_DIR}/cmake/Modules)

# Set cmake policies.
cmake_policy(SET CMP0011 NEW)

# Enable generation of compile_commands.json for code completion engines
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

########################################################################
# Compiler specific setup
########################################################################
if ((CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR
        CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        AND NOT WIN32)
    #http://gcc.gnu.org/wiki/Visibility
    add_definitions(-fvisibility=hidden)
endif ()

IF (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    SET(CMAKE_CXX_STANDARD 11)
ELSEIF (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    SET(CMAKE_CXX_STANDARD 11)
ELSEIF (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    SET(CMAKE_CXX_STANDARD 11)
ELSE ()
    message(WARNING "C++ standard could not be set because compiler is not GNU, Clang or MSVC.")
ENDIF ()

IF (CMAKE_C_COMPILER_ID STREQUAL "GNU")
    SET(CMAKE_C_STANDARD 11)
ELSEIF (CMAKE_C_COMPILER_ID MATCHES "Clang")
    SET(CMAKE_C_STANDARD 11)
ELSEIF (CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    SET(CMAKE_C_STANDARD 11)
ELSE ()
    message(WARNING "C standard could not be set because compiler is not GNU, Clang or MSVC.")
ENDIF ()

########################################################################
# Find packages
########################################################################
set(GR_COMPONENTS blocks)
find_package(Gnuradio "3.8" COMPONENTS ${GR_COMPONENTS})
if(NOT Gnuradio_FOUND)
    find_package(Gnuradio "3.9" COMPONENTS ${GR_COMPONENTS})
    if(NOT Gnuradio_FOUND)
        message(FATAL_ERROR "Unable to find GNURadio")
    endif(NOT Gnuradio_FOUND)
endif(NOT Gnuradio_FOUND)
include(GrVersion)
include(GrPlatform) #define LIB_SUFFIX

########################################################################
# Install directories
########################################################################
if (NOT CMAKE_MODULES_DIR)
    set(CMAKE_MODULES_DIR lib${LIB_SUFFIX}/cmake)
endif (NOT CMAKE_MODULES_DIR)

set(GR_INCLUDE_DIR include/m2k)
set(GR_CMAKE_DIR ${CMAKE_MODULES_DIR}/m2k)
set(GR_PKG_DATA_DIR ${GR_DATA_DIR}/${CMAKE_PROJECT_NAME})
set(GR_PKG_DOC_DIR ${GR_DOC_DIR}/${CMAKE_PROJECT_NAME})
set(GR_PKG_CONF_DIR ${GR_CONF_DIR}/${CMAKE_PROJECT_NAME}/conf.d)
set(GR_PKG_LIBEXEC_DIR ${GR_LIBEXEC_DIR}/${CMAKE_PROJECT_NAME})

########################################################################
# Find gnuradio build dependencies
########################################################################
if(WIN32)
  find_package(Gnuradio PATHS "c:/Program Files/gnuradio/lib/cmake/gnuradio" REQUIRED)
endif()

find_library(IIO_LIBRARIES iio)
find_path(IIO_INCLUDE_DIRS iio.h)

find_library(M2K_LIBRARIES m2k)
find_path(M2K_INCLUDE_DIRS m2k.hpp)
#pkg_check_modules(LIBM2K REQUIRED libm2k)

########################################################################
# On Apple only, set install name and use rpath correctly, if not already set
########################################################################
if (APPLE)
    if (NOT CMAKE_INSTALL_NAME_DIR)
        set(CMAKE_INSTALL_NAME_DIR
                ${CMAKE_INSTALL_PREFIX}/${GR_LIBRARY_DIR} CACHE
                PATH "Library Install Name Destination Directory" FORCE)
    endif (NOT CMAKE_INSTALL_NAME_DIR)
    if (NOT CMAKE_INSTALL_RPATH)
        set(CMAKE_INSTALL_RPATH
                ${CMAKE_INSTALL_PREFIX}/${GR_LIBRARY_DIR} CACHE
                PATH "Library Install RPath" FORCE)
    endif (NOT CMAKE_INSTALL_RPATH)
    if (NOT CMAKE_BUILD_WITH_INSTALL_RPATH)
        set(CMAKE_BUILD_WITH_INSTALL_RPATH ON CACHE
                BOOL "Do Build Using Library Install RPath" FORCE)
    endif (NOT CMAKE_BUILD_WITH_INSTALL_RPATH)
endif (APPLE)

########################################################################
# Setup doxygen option
########################################################################
find_package(Doxygen)
if (DOXYGEN_FOUND)
    option(ENABLE_DOXYGEN "Build docs using Doxygen" ON)
else (DOXYGEN_FOUND)
    option(ENABLE_DOXYGEN "Build docs using Doxygen" OFF)
endif (DOXYGEN_FOUND)

########################################################################
# Create uninstall target
########################################################################
configure_file(
        ${CMAKE_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
        @ONLY)

add_custom_target(uninstall
        ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
        )


########################################################################
# Install pkg-config file
########################################################################
configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/gnuradio-m2k.pc.in
        ${CMAKE_CURRENT_BINARY_DIR}/gnuradio-m2k.pc
        @ONLY)

install(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/gnuradio-m2k.pc
        DESTINATION ${GR_LIBRARY_DIR}/pkgconfig
)

########################################################################
# Add subdirectories
########################################################################
add_subdirectory(include/m2k)
add_subdirectory(lib)
add_subdirectory(swig)
add_subdirectory(python)

# if GNURadio Companion not found, do not add grc blocks
if (GRC_BLOCKS_DIR)
	add_subdirectory(grc)
endif (GRC_BLOCKS_DIR)

########################################################################
# Install cmake search helper for this library
########################################################################
install(FILES cmake/Modules/m2kConfig.cmake
        DESTINATION ${CMAKE_MODULES_DIR}/m2k
        )
