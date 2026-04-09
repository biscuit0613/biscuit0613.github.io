---
title: RM_miniconda安装ROS2
published: 2025-09-09
description: '使用Miniconda安装ROS2 Humble的步骤'
image: ''
tags: [ROS,RM]
category: 'RM'
draft: false 
lang: ''
---

:::warning
用miniconda安装ROS2 Humble，不要指定Python版本，新建环境之后按顺序就行，一般是不会报错的。
:::

Alkaid: 09-09 17:05:30

```bash
conda config --env --add channels conda-forge
```

```bash
Alkaid: 09-09 17:05:34
conda config --env --remove channels defaults
```

Alkaid: 09-09 17:05:40

```bash
conda config --env --add channels robostack-humble
```

Alkaid: 09-09 17:05:48

```bash
conda install ros-humble-desktop
```

Alkaid: 09-09 17:06:04

```bash
conda install rosdep
```

检验方法：

```bash
rosversion -d
```

应该会输出：

```bash
humble
```

```bash
rviz2
``` 
应该会打开rviz2界面。