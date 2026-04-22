---
title: PCA主成分分析 (Principal Component Analysis)
published: 2026-04-07
description: 'PCA（Principal Component Analysis）是一种常用的降维技术，旨在通过线性变换将高维数据映射到低维空间，同时尽可能保留原始数据的方差信息。本文将介绍PCA的基本概念、数学原理以及应用场景。'
image: ''
tags: []
category: '线性代数'
draft: false 
lang: ''
---

:::tip

在尽量减少信息损失的前提下，把高维数据“压扁”到低维空间。

將原空間中的任一向量投影到某低維子空間，事實上就是在線性地降低其維度。

:::

## 几何直观

我们可以把 PCA 想象成一个寻找最佳观察角度的过程。

### 方差 (Variance)

在统计学中，方差衡量的是一组数据的离散程度。数学公式： $Var(X) = \frac{1}{n-1} \sum_{i=1}^{n} (x_i - \bar{x})^2$

PCA 中的直观理解： 方差越大，代表数据在这个方向上“铺得越开”。在降维时，我们最怕把原本分得很开的点压到一起（丢失区分度）。所以，PCA 的第一目标就是寻找方差最大的方向，因为那里保留了最原始、最丰富的信息。

### 协方差 (Covariance)

如果方差是看一个维度自己，协方差就是看两个维度之间的“互动”。

数学本质： 如果 $X$ 变大时 $Y$ 也变大，协方差为正；反之为负；如果不相关，则接近 0。

PCA 中的直觉： 如果身高和体重的协方差很高，说明它们携带了大量重复信息。

协方差矩阵 (Covariance Matrix) 是一个表，记录了所有维度两两之间的相关性。PCA 的任务就是通过这个矩阵，找出哪些维度是冗余的，并把它们合并成互不相关的“新轴”。

### 特征值与特征向量：矩阵的“筋骨”

这是线性代数最精华的部分。对于协方差矩阵 $\Sigma$：

$$
\Sigma \mathbf{v} = \lambda \mathbf{v}
$$

特征向量 $\mathbf{v}$ (Direction)： 当协方差矩阵作用于向量 $\mathbf{v}$ 时，它只伸缩，不旋转。这意味着 $\mathbf{v}$ 指向的是数据分布中最自然、最核心的轴线。

在 PCA 中，这些向量就是我们寻找的“主成分方向”。特征值 $\lambda$ (Magnitude)： 它代表了数据在对应的特征向量方向上的离散程度（即方差的大小）。$\lambda$ 越大，说明这个方向越重要。

## 数学推导

核心目标：方差最大化

假设我们有 $n$ 个样本，每个样本有 $d$ 维特征，组成矩阵 $X \in \mathbb{R}^{n \times d}$（已进行中心化处理，即每一列均值为 0）。我们的目标是找到一个单位投影方向向量 $\mathbf{w}$ ($\|\mathbf{w}\|=1$)，使得投影后的数据方差最大。

投影后的坐标为：$z_i = \mathbf{x}_i^\top \mathbf{w}$

投影后的方差为：

$$
Var(Z) = \frac{1}{n} \sum_{i=1}^{n} (\mathbf{x}_i^\top \mathbf{w})^2 = \frac{1}{n} (\mathbf{w}^\top X^\top X \mathbf{w}) = \mathbf{w}^\top \Sigma \mathbf{w}
$$

其中 $\Sigma = \frac{1}{n} X^\top X$ 是数据的协方差矩阵。

协方差矩阵 (Covariance Matrix) 的物理意义

- 协方差矩阵 $\Sigma$ 是一个 $d \times d$ 的实对称矩阵：

- 对角线元素 $\Sigma_{ii}$：第 $i$ 个维度的方差。

- 非对角线元素 $\Sigma_{ij}$：维度 $i$ 与维度 $j$ 的相关性。

:::tip

PCA 的本质就是通过线性变换，将 $\Sigma$ 变成对角矩阵（消除维度间的相关性），并取对角线上最大的值（保留最大方差）。

:::

拉格朗日乘子法求解 (Constrained Optimization)

我们要最大化 $f(\mathbf{w}) = \mathbf{w}^\top \Sigma \mathbf{w}$，约束条件为 $\mathbf{w}^\top \mathbf{w} = 1$。引入拉格朗日乘子 $\lambda$：

$$
L(\mathbf{w}, \lambda) = \mathbf{w}^\top \Sigma \mathbf{w} + \lambda (1 - \mathbf{w}^\top \mathbf{w})
$$

对 $\mathbf{w}$ 求导并令其为 0：

$$
\frac{\partial L}{\partial \mathbf{w}} = 2\Sigma \mathbf{w} - 2\lambda \mathbf{w} = 0
$$

从而得到：

$$
\Sigma \mathbf{w} = \lambda \mathbf{w}
$$

上述结果正是**特征值分解**的定义式：

投影方向 $\mathbf{w}$：必须是协方差矩阵 $\Sigma$ 的特征向量。

方差大小：将 $\Sigma \mathbf{w} = \lambda \mathbf{w}$ 代回方差公式：

$$
Var(Z) = \mathbf{w}^\top (\Sigma \mathbf{w}) = \mathbf{w}^\top (\lambda \mathbf{w}) = \lambda \|\mathbf{w}\|^2 = \lambda
$$

投影后的方差正好等于对应的特征值。

## 算法流程 (The Pipeline)

预处理：数据中心化 $X \leftarrow X - \mu$。

算矩阵：计算协方差矩阵 $\Sigma = \frac{1}{n} X^\top X$。

求特征：求解 $\Sigma$ 的特征值 $\lambda_j$ 和对应的特征向量 $\mathbf{v}_j$。

选主成分：将 $\lambda_j$ 从大到小排列，取前 $k$ 个对应的特征向量构成投影矩阵 $W = [\mathbf{v}_1, \mathbf{v}_2, \dots, \mathbf{v}_k]$。想降到几维，就选前几个最大的 $\lambda$。至于降到多少，可以根据**方差解释率**来决定（后面会讲）。

映射：新数据 $Y = XW$。

## 算法的评价策略：方差解释率

:::tip
在 PCA 的语境下，方差 = 信息。
:::

方差解释率（Explained Variance Ratio） 就是在问：“如果把数据从 100 维砍到 3 维，我到底丢掉了多少有用的信息？”

:::tip

gemini的巧思：

想象给一个长条形的橄榄球拍照：

- 角度 A（沿长轴拍）能清晰地看到球的长短、轮廓。数据的方差很大，点与点之间分得很开，信息量足。

- 角度 B（从正顶端往下拍）球看起来就像一个圆点。数据的方差极小，所有信息都重叠在一起了，根本看不出这原本是个长条球。

:::

往某个方向投影后的方差越大，说明这个方向越能代表原始数据的特征；方差越小，说明这个方向可能只是些无关痛痒的细节（甚至只是传感器噪声）。

### 数学上的“分蛋糕”

假设原始数据的协方差矩阵为 $\Sigma$，其维度为 $d \times d$。总方差就是该矩阵主对角线元素之和，也就是协方差矩阵的 **迹 (Trace)** 数学表达式为：

$$
Total\_Variance = \text{Tr}(\Sigma) = \sum_{i=1}^{d} \sigma_{ii}^2
$$

其中 $\sigma_{ii}^2$ 是原始坐标系中第 $i$ 个维度的方差。这代表了在没有任何旋转、压缩的情况下，系统总共包含的“能量”（波动）。

在 PCA 过程中，我们对协方差矩阵进行了特征分解，得到了 $d$ 个特征值：$\lambda_1, \lambda_2, \dots, \lambda_d$ 。这些特征值有一个神奇的性质：它们的总和 $\sum \lambda$ 等于原始数据在所有维度上的总方差。这在线性代数中是一个重要的定理：PCA 的本质是对协方差矩阵进行相似变换（对角化）。线性代数中有一个核心定理：矩阵在相似变换下，迹（Trace）保持不变。

$$
\boxed{\sum_{i=1}^{d} \lambda_i = \text{Total Variance}}
$$

数据的总能量（总方差）在旋转坐标轴的过程中并没有消失，只是被重新分配了。

第 $i$ 个主成分的方差解释率：

$$
Ratio_i = \frac{\lambda_i}{\sum_{j=1}^{d} \lambda_j}
$$

这就像是在算每个主成分分到了多少比例的“信息蛋糕”。

累计方差解释率：如果保留前 $k$ 个主成分，那么：

$$
Cumulative\_Ratio = \frac{\sum_{i=1}^{k} \lambda_i}{\sum_{j=1}^{d} \lambda_j}
$$

### 它是如何评价维数的？

方差解释率是降维时的决策准则（决定砍掉多少维）

例如处理一个 10 维的数据，算完 PCA 后，发现各维度的解释率如下：

- PC1: 75%

- PC2: 15%

- PC3: 5%...

其余 7 维加起来才 5%

发现光是前两个轴（PC1 + PC2）就解释了 90% 的方差。这意味着如果把数据从 10 维压缩到 2 维，只损失了 10% 的“次要细节”，但换来了计算速度的大幅提升和数据的可视化（2D 图表谁都能看懂）。

### 两个用途：选择与去噪

1. 确定 $k$ 值：不需要盲目猜测降到几维，而是设定一个阈值（比如 95%），然后让程序自动选择能达到这个比例的最少维数。

2. 去噪：最后那几个方差解释率极低的维度，通常被认为是噪声。砍掉它们不仅是降维，更是提纯。
