@@ TEMPLATE ARGUMENTS:
@@ %1$s = lib_name
@@ %2$s = cxx_std
cmake_minimum_required(VERSION 3.28)
project(%1$s CXX)

set(CMAKE_CXX_STANDARD %2$s)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_library(%1$s INTERFACE)
add_library(%1$s::%1$s ALIAS %1$s)

target_compile_features(%1$s INTERFACE cxx_std_%2$s)

target_include_directories(%1$s INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)


if(PROJECT_IS_TOP_LEVEL)
    enable_testing()
    add_subdirectory(tests)
endif()
