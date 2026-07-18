---
title: ubuntu22 同时装ros1和ros2
published: 2025-12-15
description: '因为要用ros1bridge，所以需要在ubuntu22上同时安装ros1和ros2'
image: ''
tags: [RM,ROS]
category: '机器人'
draft: false 
lang: ''
---

## ubuntu22装ros1

在已经有`ros2-humble`的基础上装`ros1-noetic`，参考了[社区](https://fishros.org.cn/forum/topic/2864/ros1-on-ubuntu-22-04-%E5%9C%A8ubuntu-22-04%E7%9B%B4%E6%8E%A5%E4%BD%BF%E7%94%A8ros1%E7%9A%84%E6%96%B0%E6%96%B9%E6%A1%88/6?_=1765794475297)

```bash
sudo add-apt-repository ppa:ros-for-jammy/noble
sudo apt update
sudo apt install ros-noetic-desktop-full
```

## ros1bridge使用

参考了这篇[官方文档]（<http://docs.ros.org/en/humble/p/ros1_bridge/user_guide.html）>

ros1bridge需要在ros2的工作空间下编译，也就是说之前的ros1不用装bridge。

:::warning
下面注意source的顺序
:::

先到ros2的工作空间

```bash
source /opt/ros/humble/setup.zsh
```

这一步之前不要source ros1的环境，不然会添一些奇奇怪怪的链接。

然后编译**除了**bridge之外的所有东西：

```bash
colcon build --symlink-install --packages-skip ros1_bridge
```

编译好了之后再source ros1的环境：

```bash
source /opt/ros/noetic/setup.zsh
```

最后编译bridge：

```bash
colcon build --symlink-install --packages-select ros1_bridge --cmake-force-configure
```

这个bridge的编译过程巨几把慢，耐心等待。编译过程中ros12都需要用到。

## 使用ros1bridge

这里老的ros1作为talker,listener用ros2。

先开ros1容器，打开一个终端A：

```bash
source /opt/ros/noetic/setup.zsh

roscore
```

再打开一个终端B：

```bash
# Shell B (ROS 1 + ROS 2):
# Source ROS 1 first:
source /opt/ros/noetic/setup.zsh

source install/setup.zsh

export ROS_MASTER_URI=http://localhost:11311
ros2 run ros1_bridge dynamic_bridge
```

如果出现

```bash
failed to create 2to1 bridge for topic '/rosout' with ROS 2 type 'rcl_interfaces/msg/Log' and ROS 1 type 'rosgraph_msgs/Log': No template specialization for the pair
check the list of supported pairs with the `--print-pairs` option
```

正常，不用管

打开终端C：

```bash
# Shell C (ROS 1 Talker):
source /opt/ros/noetic/setup.zsh

# 这里可以直接用rosbag play
rosbag play <your-ros1-bag-file>.bag
```

再打开终端D：

```bash
# Shell D (ROS 2 Listener):
source /opt/ros/humble/setup.zsh
source install/setup.zsh
ros2 luanch sentry_decision sentry_decision_launch.py
```
