---
title: Android 构建失败之 jlink 路径灵异事件
published: 2026-04-09
description: ''
image: ''
tags: []
category: '编程语言'
draft: false 
lang: ''
---

## 现象

在 CachyOS (Arch-based) 环境下，使用 VS Code 开发 Android 项目。后来用android studio执行构建任务 `:app:compileDebugJavaWithJavac` 时，突然报出如下错误：

```bash
Execution failed for JdkImageTransform: /.../android-36/core-for-system-modules.jar.
    > jlink executable /home/biscuit/.vscode/extensions/redhat.java-1.53.0-linux-x64/jre/21.0.10-linux-x86_64/bin/jlink does not exist.
```

报错指向的是 VS Code 扩展内部的 JRE 路径。

明明系统环境变量 `$JAVA_HOME` 和 `archlinux-java` 都指向了系统的 OpenJDK 21。

jlink 工具无法定位，导致 Android SDK 无法完成 core-for-system-modules.jar 的转换。

## ai 诊断

IDE 环境污染：VS Code 的 Java 扩展（Language Support for Java™ by RedHat）自带了一个内嵌的、精简版的 JRE。当配置文件中的 ` "java.jdt.ls.java.home": "" ` 为空时，插件会激活这个内嵌环境。

Gradle Daemon 缓存：Gradle 的守护进程（Daemon）在启动时会继承启动环境。如果第一次是在 VS Code 内部触发的构建，Gradle 可能会“记住”那个错误的路径，并一直缓存。

内嵌 JRE 的缺陷：VS Code 自带的 JRE 通常只够跑 Language Server。它可能缺少 jlink（Java 模块化工具），而 Android API 30+ 的构建过程必须依赖 jlink 来处理系统模块镜像。

## 解决方案

最简单的临时方案：kill掉所有 Gradle Daemon 进程，清除 Gradle 的缓存：

```bash
./gradlew --stop
./gradlew clean
# clean等于手动删除build和.gradle目录
```

但是这只是暂时的，下一次在 VS Code 内部触发构建时可能又会出现同样的问题。

进入 VS Code 设置，搜索 java.jdt.ls.java.home，手动设置为系统 JDK 的路径，

```bash
ls /usr/lib/jvm/
#找到可用的 JDK 版本

```

```json
"java.jdt.ls.java.home": "/usr/lib/jvm/java-21-openjdk",
"java.import.gradle.java.home": "/usr/lib/jvm/java-21-openjdk"
```

并且编译的时候用

```bash
./gradlew compileDebugJavaWithJavac --no-daemon
```

来避免 Gradle Daemon 的缓存问题。
