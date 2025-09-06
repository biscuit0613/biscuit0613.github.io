---
title: cmake
published: 2025-09-06
description: 'cmake介绍，c++程序的编译这一块'
image: ''
tags: [cpp,c++]
category: 'cpp'
draft: false 
lang: ''
---

## C++程序从写完代码到可执行的步骤

### 1. 写源码(.cpp或者.h)

```cpp
#include <iostream>
#define MSG "Hello, C++!"

int main() {
    std::cout << MSG << std::endl;
    return 0;
}
```

### 2.预处理（-E）

命令：

```bash
g++ -E hello.cpp -o hello.i
```

展开 `#include`，替换 `#define`，处理 `#if/#ifdef` 等。条件编译

通常得到一个巨大的依托（展开 `#include`）

```cpp
int main() {
    std::cout << "Hello, C++!" << std::endl;   // MSG 宏已被替换
    return 0;
}
```

### 3.编译（生成汇编）

命令：

```bash
g++ -S hello.i -o hello.s
```

把预处理后的代码翻译成汇编（目标架构指令）。产物部分展示如下：

```cpp
main:
    pushq   %rbp
    movq    %rsp, %rbp
    leaq    .LC0(%rip), %rdi   # 加载字符串地址 "Hello, C++!"
    call    _ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc
    movl    $0, %eax
    popq    %rbp
    ret

```

### 4.汇编（生成目标文件.o）

命令

```bash
g++ -c hello.s -o hello.o
```

把汇编转成目标文件（machine code 的片段，.o），包含重定位信息和符号表。

### 5. 链接

命令

```bash
g++ hello.o -o hello
```

把多个 .o 和库（静态 .a 或动态 .so/.dll）合并，解析符号引用，生成最终可执行文件或动态库。

### 6. 运行

命令

```bash
./hello
```

操作系统把 ELF/PE/Mach-O 映射到内存，动态链接器处理共享库重定位，执行运行时初始化（CRT），然后进入 main()。

## cmake干了啥

CMake 本身并不参与代码翻译，而是一个**构建系统生成器**。它的作用主要是用来写“规则”，生成适合本平台的构建指令（Makefile、Ninja、Visual Studio 工程），然后调用真正的编译器（gcc/clang/msvc）去执行编译/链接。

## cmake配置文件

CMakeLists.txt 文件： CMake 的配置文件，用于定义项目的构建规则、依赖关系、编译选项等。每个 CMake 项目通常包含一个或多个 CMakeLists.txt 文件。

常见语句及参数：

### 工程初始化

```cmake
cmake_minimum_required(VERSION <version>)  #指定cmake的最低版本
project(<projectName> <LANGUAGE> )  #定义工程名和语言,语言可以有多个，用空格隔开
```

### 添加可执行文件/库(声明target)

:::note

在 CMake 官方文档里，target 的定义是：

>A target is an executable or library to be built, or a custom entity representing an output of the build system.

浏览器翻译说“target”是构建系统要生成的“产物”或“构建对象”，它可以是：

+ 可执行文件 target：由 add_executable 定义

+ 库文件 target：由 add_library 定义（静态库 / 动态库 / 模块库）

+ 自定义 target：由 add_custom_target 定义（本文未介绍）

+ 接口 target：由 add_library(... INTERFACE) 定义，仅用来传递编译参数/头文件路径，不会生成文件

所以 target = 构建单位的抽象。
CMake 一切围绕 target 进行管理

:::

1. 声明（一组）可执行文件为可执行文件target

    ```cmake
    add_executable(<target> <source_file1> <source_file2>...)
    ```

    `<source_file1>...`是源文件列表，用空格隔开，这个语句生成**可执行文件target**。其中`<target>`参数是**可执行文件target**的名称。

2. 把（一组）源文件编译成库target（静态库或动态库）

    ```cmake
    add_library(<target> <修饰符> <source_file1> <source_file2>...)
    #例如
    add_library(mylib STATIC lib.cpp)
    add_library(mylib SHARED lib.cpp)
    add_library(mylib OBJECT lib.cpp)
    ```

    所谓库，就是打包好的目标文件，这里把`lib.cpp`源文件编译成库（Linux下生成库文件`libmylib.a`，库文件命名规则：lib+target.name+.a），同时生成一个名叫mylib的**库target**

### 配置target属性

1. cmakelist之间的关系

   ```cmake
    add_subdirectory(src)#包含src目录下的子cmakelists
   ```

2. 查找并使用外部库

    ```cmake
    find_package(<packagename> REQUIRED)#REQUIRED表示找不到就报错
    #例如找opencv库：
    find_package(OpenCV REQUIRED)
    ```

    `<packagename>`就是外部库的包名。理想情况下，find_package()能把一整个依赖包的头文件包含路径、库路径、库名字、版本号等情况都获取到

    find_package找到包后，会生成一些包含**头文件路径**（比如`#include <opencv2/opencv.hpp>`里openCV的路径）的变量，例如：

    ```cmake
    find_package(OpenCV REQUIRED)
    #生成的变量
    OpenCV_INCLUDE_DIRS=/usr/local/include/opencv4 #头文件
    OpenCV_LIBS=/usr/local/lib/libopencv_core.so #库文件
    #路径放在变量里存储
    ```

    这些变量会保存在CMakeCache.txt里，就是 CMake 的缓存配置文件，有上一次找到的编译器、库路径、编译选项等信息

3. 设置target包含的头文件的搜索路径（库target的路径）

    ```cmake
    include_directories(<头文件所在目录1> <头文件所在目录2>...)#该cmakelists全局
    target_include_directories(<target> <修饰符> <头文件所在目录1> <头文件所在目录2>...)#指定target
    ```

    在编译 C++ 项目时，头文件提供了声明和接口，是源代码文件间相互引用的关键部分。为了告诉编译器去哪里查找这些头文件，通常需要指定一个或多个包含目录（include directories）。如果没有正确设置头文件**路径**，编译器会报出类似 "file not found" 的错误。

    `include_directories`会为当前CMakeLists.txt的所有**库target**，以及之后添加的所有子目录的目标添加头文件搜索路径。会影响**此cmakelist以及下游cmakelist**中所有的（全局）target。

    `target_include_directories`只会为指定**库target**设置头文件搜索路径。

    例：

    ```cmake
    add_library(math_utils STATIC math_utils.cpp)
    target_include_directories(math_utils PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/math_utils)
    ```

    :::tip

    这里面的target参数也可是**可执行文件target**，但此时这些头文件不是库的一部分，要加PRIVATE

    例

    ```cmake
    add_executable(main_exec main.cpp)
    target_include_directories(main_exec PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
    ```

    :::

    target的**修饰符**包括`PRIVARTE`：仅target用。`PUBLIC`：target以及下游依赖也能用。`INTERFACE`：自己不用，只给下游依赖用

4. 添加要链接到target的库

    ```cmake
    target_link_libraries(<target> <库1> <库2> ...)#指定target
    link_libraries(<库1> <库2> ...)#该camekelists的全局
    ```

    实现了库和库之间的关联，通常是**可执行文件target**和**库target**之间的链接

    `link_libraries`把库1234...加到当前CMakeLists.txt的所有**可执行文件target**中，以及之后添加的所有子目录的target中。会影响**此cmakelist以及下游cmakelist**中所有的（全局）target。

    `target_link_libraries`给某一个具体的**可执行文件target**添加要链接的库。

    `(target_)link_libraries`语句中的参数`<库1><库2>...`可以是**系统库的名字**，**外部库的路径**（用${存储外部库地址的变量名}来表示），也可以是由`add_library`定义的**库target的名字**

:::tip  

`find_package(第三方库名)`和`include_directory(${库名_INCLUDE_DIRS})`以及`target_link_libraries(可执行文件target ${库名_LIBS})`联合使用，就可以确定引用的第三方库的头文件路径和库文件路径

+ ${}是解析变量的语法

:::

## cmake构建目录

构建目录： 为了保持源代码的整洁，CMake 鼓励使用独立的构建目录（Out-of-source 构建）。这样，构建生成的文件与源代码分开存放。

在根目录下新建构建目录：

```bash
mkdir build
```

进入build目录

```bash
cd build
```

**运行 CMake 配置**：在构建目录中运行 CMake 命令，指定源代码目录。源代码目录是包含 CMakeLists.txt 文件的目录。

```bash
cmake ..
```

使用生成的构建文件进行编译，这里使用Makefile

```bash
make
```
