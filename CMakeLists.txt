
cmake_minimum_required(VERSION 2.8)

set (CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "-Wall -fno-rtti")

set (LLVM_DIR "/usr/local/llvm-3.7/share/llvm/cmake/")


find_package(LLVM REQUIRED CONFIG)

add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})

add_subdirectory(src)
