---
title: CNN-BatchNorm
published: 2026-06-28
description: ''
image: ''
tags: []
category: '03-卷积神经网络'
order: 18
draft: false 
lang: ''
---

这一部分单独拿出来讲讲，因为后面和 Transformer 的 Layer Normalization 有些类似。

→ 卷积层 → 激活函数 → 池化层 → 归一化层（多用batch norm实现）

## 关于norm

一般norm都遵循下面的计算公式：

$$
\hat{x} = \frac{x - \mu}{\sqrt{\sigma^2 + \epsilon}} \quad y = \gamma\hat{x} + \beta
$$

## Batch Normalization

输入特征图 $X\in\mathbb{R}^{B, C, H, W}$，其中 $B$ 是 batch size，表示喂了多少样本（特征图数量），$C$ 是特征维度（通常指通道数），$H$ 是高度，$W$ 是宽度。

对于每个特征维度 $c$，跨batch计算均值和方差：
$$
\mu_c = \frac{1}{BHW} \sum_{i=1}^{B} \sum_{j=1}^{H} \sum_{k=1}^{W} X_{i,c,j,k}, \quad \sigma_c^2 = \frac{1}{BHW} \sum_{i=1}^{B} \sum_{j=1}^{H} \sum_{k=1}^{W} (X_{i,c,j,k} - \mu_c)^2
$$

得到两个 $C$ 维向量 $\mu\in\mathbb{R}^{C}$ 和 $\sigma^2\in\mathbb{R}^{C}$，然后广播成 $B\times C\times H\times W$ 的矩阵，进行归一化：

$$
\hat{X}_{i,c,j,k} = \frac{X_{i,c,j,k} - \mu_c}{\sqrt{\sigma_c^2 + \epsilon}} \quad Y_{i,c,j,k} = \gamma_c\hat{X}_{i,c,j,k} + \beta_c
$$

### Batchsize

BN强依赖 Batch 中其他样本（跨样本统计）。一般来说，Batch size 越大，BN 的效果越好。Batch size 太小，BN 的效果会变差，甚至可能不收敛。
