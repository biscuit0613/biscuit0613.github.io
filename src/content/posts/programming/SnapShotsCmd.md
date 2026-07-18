---
title: 命令行管理快照
published: 2026-05-14
description: 'btrfs-assistance不知道因为什么原因挂了，但是快照多了占空间'
image: ''
tags: []
category: '编程语言'
draft: false 
lang: ''
---

```bash
#列出所有快照
sudo btrfs subvolume list /
#我用的是snapper
sudo snapper list
```

- pre / post → 软件操作前后（比如 pacman）
- single → 单点快照（通常是 timeline 自动生成）
- current (0) → 当前系统（不是快照，不能删除）

系统关键子卷，不能动：

```bash
@            ← 根系统（很关键）
@home        ← 用户数据
@root        ← /root
@var/...     ← systemd 相关
.snapshots   ← 快照容器（不是快照本身）
```

description是timeline的可以删

```bash
sudo snapper delete <start>-<end>
```
