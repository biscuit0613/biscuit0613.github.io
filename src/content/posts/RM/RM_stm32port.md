---
title: 关于stm32串口跳变的问题
published: 2026-03-27
description: ''
image: ''
tags: [RM]
category: ''
draft: false 
lang: ''
---

## 问题描述

当电控重新换板子插入时，如果电控的串口没有被正确识别，可能会出现串口跳变的问题。这种情况通常是由于电控的串口驱动程序不兼容或者配置错误引起的。

## 解决方案

锁定目标stm32使用的串口

```bash
lsusb
```

输出类似

```bash
Bus 001 Device 004: ID 1a86:7523 QinHeng Electronics HL-340 USB-Serial adapter
```

其中id前四位是0483: 这是 Vendor ID (VID)，代表生产商。0483 固定指向 STMicroelectronics (意法半导体)。

后四位是5740: 这是 Product ID (PID)，代表具体的设备型号。5740 通常对应 STM32 系列芯片在配置为 USB CDC (Virtual Com Port) 模式时的默认 ID。

锁定目标串口序列号：

```bash
udevadm info -a -n /dev/ttyACM0 | grep '{serial}'
```

输出应该是

```bash
ATTRS{serial}=="356834513437"
```

编写一个udev规则文件：

```bash
sudo nano /etc/udev/rules.d/99-stm32.rules
```

```bash
# 绑定 STM32 串口并命名为 stm32_port
KERNEL=="ttyACM*", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", ATTRS{serial}=="356834513437", SYMLINK+="stm32_A", MODE="0666"
```

别名是`SYMLINK`字段定义的，这里是stm32_A，可以根据需要修改。

`MODE="0666"`设置设备文件的权限，使所有用户都可以访问。

然后重新加载udev规则：

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

现在，当插入电控时，系统会自动创建一个符号链接`/dev/stm32_A`，指向正确的串口设备。可以使用这个链接来访问电控的串口，而不必担心设备名称的变化。

再次检查：

```bash
ls -l /dev/stm32_A
# 应该输出
lrwxrwxrwx 1 root root 7 Jun  5 12:34 /dev/stm32_A -> ttyACM0
```

以后串口名就可以用`/dev/stm32_A`来访问了，无论它实际是ttyACM0还是ttyACM1等。
