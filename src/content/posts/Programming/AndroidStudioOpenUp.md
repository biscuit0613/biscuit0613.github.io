---
title: AndroidStudio启动失败
published: 2026-06-22
description: ''
image: ''
tags: []
category: '疑难杂症'
draft: false 
lang: ''
---

## 问题描述

鼠鼠更新系统之后，AndroidStudio就无法启动了，点击图标没有任何反应。

## 解决方法

```bash
# 全杀（一定要干净）
pkill -9 -f android-studio

#  清配置（关键）
rm -rf ~/.config/Google/AndroidStudio*
rm -rf ~/.cache/Google/AndroidStudio*
```

然后再启动，会像第一次安装一样，重新配置环境，之后就能正常使用了。

给出鼠鼠的fish配置，供参考：

```bash
# Java 配置
set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk
fish_add_path $JAVA_HOME/bin

function studio
    set -x GDK_BACKEND x11
    set -x _JAVA_AWT_WM_NONREPARENTING 1
    # 下面这个如果用studio进行编译的话，就是17的环境，如果用普通终端编译就是21的环境，目前没发现问题，应该能用
    set -x JAVA_HOME /usr/lib/jvm/java-17-openjdk

    android-studio $argv
end
```
