cmake_minimum_required(VERSION 3.6.0)

message("===============================>>> root SDK")


# **************************************************************************************************
#                                     相关变量设置
#  当需要对同一变量追加值时，不要直接使用 set(variable "new value"),这是值覆盖而不是追加。
#  例如：build.gradle 中已经存在 cppFlags 的值，现在需要在脚本中追加值 “-w”时，采用如下写法:
#        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")
# **************************************************************************************************

# 不生成任何警告信息
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")

#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=return")


# 编译器编译时产生调试信息(保证 RELEASE 版中没有 -g，否则会让最终的库变大)
#set(CMAKE_CXX_FLAGS_DEBUG "-g")


# 只有在 RELEASE 版时才有效
# 代码优化级别 0~3，0为不优化，值越大级别越高。为了安全起见，建议使用默认值2
# -DNDEBUG 不DEBUG
# -s 移除符号表（减小 .so 体积）
# -fvisibility=hidden 隐藏符号表（与‘-s’有何区别？是否有冲突）
#set(CMAKE_CXX_FLAGS_RELEASE "-Os -DNDEBUG -s -fvisibility=hidden")

# 修改生成的so位置， libs/armeabi/libNDK.so
#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${ANDROID_ABI}/libs)


# **************************************************************************************************
#                            引入外部子目录（包含 CMakeLists.txt 的目录）
# 注意：子目录中编译库时一定要注意各个模块之间的依赖关系，如果出错，插起来会很麻烦。
#      add_subdirectory 必须要保证是子目录
# **************************************************************************************************

# test.out 自定义值，引入外部目录时传入
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../../ thirdParty.out)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/src/main/cpp)