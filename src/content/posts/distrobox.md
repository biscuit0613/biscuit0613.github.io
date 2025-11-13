---
title: distrobox的安装与使用
published: 2025-11-05
description: ''
image: ''
tags: [Linux, Distrobox, 容器]
category: 'Linux'
draft: false 
lang: ''
---

主包的kubuntu版本：22.04

事情是这样的，主包需要ros1跑通远古代码，之前装的ros2是装在conda虚拟环境里的，这次也想如法炮制，但是ros1的依赖实在太多了，conda装起来太麻烦了，搞不好要重装系统，在友人的帮助下于用distrobox。

## 安装distrobox

朋友推荐的方法：

```bash
sudo apt install distrobox
```

但是我这边装不上去，提示找不到包，于是改手动安装：

```bash
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
```

装完再下个podman：

```bash
sudo apt install podman
```

## 创建distrobox容器

然后就可以用了，创建一个ubuntu20.04的容器：

```bash
distrobox create --image ubuntu:focal --name ubuntu20
```

进入容器：

```bash
distrobox enter ubuntu20
```

进入之后会有一个漫长的等待过程，第一次进入会自动安装一些东西。

如果没有问题的话就能进入容器的zsh环境了。主包这里用的是zsh，会显示：

![distrobox进入成功](distroboxin.png)

有关更多命令：

```bash
distrobox list
distrobox exit ubuntu20
distrobox rm ubuntu20
distrobox stop ubuntu20
```

## 配套vscode插件

Dev Containers插件可以让vscode直接连接到distrobox容器中，非常方便。

注意改一下设置:

`Dev › Containers: Docker Path`
改成

```bash
podman
```

`Dev › Containers: Docker Socket Path`改成

```bash
/var/run/podman.sock
```

然后点击左下角的绿色按钮，选择"Dev Containers: Attach to Running Container..."，选择对应的容器就可以了。

这样会自动在容器内打开一个vscode窗口，非常方便进行开发。

## 容器内安装ros1

全装

```bash
sudo apt install ros-noetic-desktop-full
```

装的有点慢，稍等一下，装好之后

```bash
sudo apt install -y python3-rosdep

sudo rosdep init
rosdep update
```

如果不想每次进入容器都要source ros的环境变量，可以把下面这行加到`~/.zshrc`里：

```bash
echo "source /opt/ros/noetic/setup.zsh" >> ~/.zshrc
source ~/.zshrc
```

或者

```bash
source /opt/ros/noetic/setup.zsh
```

这样就可以愉快地使用ros1了。

主包这里出了点小问题：

```bash
ERROR: ld.so: object '/usr/NX/lib/libnxegl.so' from LD_PRELOAD cannot be preloaded (cannot open shared object file): ignored.
```

不影响任何使用，但是弹的烦人，用下面这行命令在当前终端禁用LD_PRELOAD：

```bash
unset LD_PRELOAD
```
