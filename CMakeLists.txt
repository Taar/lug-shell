cmake_minimum_required(VERSION 3.30)

project(lug-shell LANGUAGES C)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/modules/")

add_executable(lug-shell src/lugshell.c)

if(USE_READLINE)
    find_package(Readline)
    target_link_libraries(lug-shell readline)
    target_compile_definitions(lug-shell PRIVATE USE_READLINE=1)
endif(USE_READLINE)
