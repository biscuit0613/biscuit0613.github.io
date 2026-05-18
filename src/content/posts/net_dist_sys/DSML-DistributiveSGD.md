---
title: 分布式机器学习：同步和异步随机梯度下降（SGD）
published: 2026-05-17
description: ''
image: ''
tags: []
category: '网络与分布式系统'
draft: false 
lang: ''
---

SGD可以把大规模数据通过D分成小块来计算，适合分布式计算。分布式SGD有两种主要模式：同步SGD和异步SGD。

## 同步SGD

分布式同步 SGD 的更新公式，在数学上完全等价于一个 mini-batch 大小为 $m×b$ 的标准 SGD 更新。

其中：$m$ = 工作节点数量,$b$ = 每个工作节点本地的 mini-batch 大小

初始化：数据 $D$ 被分成 $m$ 块，每块大小为 $N/m$，每个工作节点 $i$ 负责其中一块数据 $D_i$.

每轮迭代：

1. 参数服务器对所有 $m$ 发送当前的参数向量 $\mathbf{w}^{(t)}$.

2. 每个工作节点计算本地 mini-batch 的平均梯度 $\nabla E_i(\mathbf{w}^{(t)})=\frac{1}{b}\sum_{x\in S_i} \nabla E_i(x)$.(本地的全局数据集是 $D_i$，本地的 mini-batch 是 $S_i$，大小为 $b$)
3. 参数服务器收集所有工作节点的梯度，并计算全局平均梯度:$\nabla E(\mathbf{w}^{(t)}) = \frac{1}{m} \sum_{i=1}^m \nabla E_i(\mathbf{w}^{(t)})=\frac{1}{m}\sum_{i=1}^m \frac{1}{b}\sum_{x\in S_i} \nabla E_i(x)$.
4. 参数服务器更新参数向量 $\mathbf{w}^{(t+1)}$.

### 性能这一块-单次迭代时间

**同步** SGD 要等所有 worker 都算完。

所以，一次迭代的时间 = 最慢的那个 worker 的计算时间。

假设每一个worker计算梯度的时间是一个随机变量 $X$

一次迭代的时间 = $T = \max(X_1, X_2, ..., X_m)$，太长了，用 **顺序统计量** 的知识表示：$T = E[X_{m:m}]$

- 随着 worker 数量 $m$ 的增加，迭代时间会增加。
- X 的变异性越高，迭代时间越长。

特别地，如果 $X$ 是指数分布，$E[X_{m:m}] = \frac{H_m}{\lambda}\approx \frac{\log m}{\mu}$，其中 $H_m$ 是第 $m$ 个调和数。所以迭代时间随着 worker 数量的增加而增加，且增长速度接近对数级别。

### 性能这一块-收敛性

当工作节点m增多时，收敛性更佳

### 优化：K-同步SGD

思想：不等所有woker,收集到前K个worker的梯度就更新参数

等价于全局batch size = Kb 的mini-batch SGD

迭代时间：$T_{K-sync} = E[X_{K:m}]\sim\frac{1}{\mu}\log\frac{m}{m-K}$，比同步SGD的迭代时间更短。

误差：当K减小时，有效小批量尺寸Kb随之缩小，导致更高的误差下限

### 优化：K-批次同步SGD

更激进：快的worker不闲着，可以在同一模型版本上连续计算多个梯度，直到凑齐K个梯度（可来自同一个worker的多次计算）。

仍然等价于 batch size = Kb 的mini-batch SGD

迭代时间：$T_{K-batch} = \frac{K}{m\mu}$，迭代时间更短了。并且m增大时迭代时间会更短了。

:::tip

关于T的推导：根据指数分布无记忆性，参数服务器接收相邻两个梯度的时间间隔也是指数分布的，平均时间为 $\frac{1}{m\mu}$，所以收到K个梯度的平均时间为 $T_{K-batch} = \frac{K}{m\mu}$.

:::

收敛性和误差：与K-同步SGD相同，K-批次同步SGD的误差下限也随着K的减小而增加。

## 异步SGD

同步的缺点：

1. 慢的工作节点计算的梯度如果不在K中会被丢弃，资源浪费。
2. 更快的工作节点可能会有空闲的时间（除非K批次）

异步：完全不用等