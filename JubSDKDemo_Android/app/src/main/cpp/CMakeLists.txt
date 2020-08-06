project(coreNDK)

cmake_minimum_required(VERSION 3.6.0)

message(">>>> ndk")


#link_libraries(JUB_SDK)

# **************************************************************************************************
#                               引入相关头文件
# 注：因为是分开编译且涉及相互调用，所以需要引入其他库模块中的头文件
# **************************************************************************************************

# 引入外部库路径
set(OUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../../../../../)
message(">>>外部目录： ${OUT_DIRECTORY}")


include_directories(${OUT_DIRECTORY}/deps)
include_directories(${OUT_DIRECTORY}/deps/jsoncpp/include)
include_directories(${OUT_DIRECTORY}/include)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/jni)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/jni/utils)


# **************************************************************************************************
#                      查找指定目录下的所有源文件，并将其存入指定变量中
# **************************************************************************************************

aux_source_directory(${OUT_DIRECTORY}/deps/jsoncpp/src/lib_json SRC_LIST)
aux_source_directory(${OUT_DIRECTORY}/deps/bleTransmit SRC_LIST)

aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/jni SRC_LIST)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/jni/utils SRC_LIST)


# **************************************************************************************************
#                                添加其他预构建库（第三方库）
# **************************************************************************************************

find_library(libLog
             log
)


# 需要改成平台自适应的宏
if(CMAKE_BUILD_TYPE MATCHES "Debug"
        OR CMAKE_BUILD_TYPE MATCHES "None")
    message(">>>> link debug library")
    link_directories(${OUT_DIRECTORY}/deps/bleTransmit/android/${ANDROID_ABI}/debug)
elseif(CMAKE_BUILD_TYPE MATCHES "Release")
    message(">>>> link release library")
    link_directories(${OUT_DIRECTORY}/deps/bleTransmit/android/${ANDROID_ABI}/release)
endif()


# **************************************************************************************************
#                                        生成动态库
# **************************************************************************************************

add_library(
            coreNDK
            SHARED
            ${SRC_LIST}
)


# **************************************************************************************************
#                                        链接所有相关库
# 切记链接日志库，否则编译报错 undefined reference to '__android_log_print'
# **************************************************************************************************

target_link_libraries(
                      coreNDK
                      JUB_SDK
                      BTSDK
                      ${libLog}
)
