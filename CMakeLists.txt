cmake_minimum_required(VERSION 3.0.0)

project(JubSDK VERSION 0.1.0)

set (CMAKE_CXX_STANDARD 11)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
set (CMAKE_EXPORT_COMPILE_COMMANDS 1)

if (NOT ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang"))
    message(FATAL_ERROR "You should use clang compiler")
endif()

if ("$ENV{PREFIX}" STREQUAL "")
    set(PREFIX "${CMAKE_SOURCE_DIR}/build/local")
else()
    set(PREFIX "$ENV{PREFIX}")
endif()

add_subdirectory(src)
#add_subdirectory(test)
