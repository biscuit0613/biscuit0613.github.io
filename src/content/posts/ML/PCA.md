---
title: PCA主成分分析 (Principal Component Analysis)
published: 2026-04-07
description: 'PCA（Principal Component Analysis）是一种常用的降维技术，旨在通过线性变换将高维数据映射到低维空间，同时尽可能保留原始数据的方差信息。本文将介绍PCA的基本概念、数学原理以及应用场景。'
image: ''
tags: []
category: '模式识别与机器学习'
order: 9
draft: false 
lang: ''
---

## 一些线性代数知识点

我们可以把 PCA 想象成一个寻找最佳观察角度的过程。

:::tip

想象给一个长条形的橄榄球拍照：

- 角度 A（沿长轴拍）能清晰地看到球的长短、轮廓。数据的方差很大，点与点之间分得很开，信息量足。

- 角度 B（从正顶端往下拍）球看起来就像一个圆点。数据的方差极小，所有信息都重叠在一起了，根本看不出这原本是个长条球。

:::

主要思想是寻找到数据的主轴方向：方差最大的方向，由主轴构成一个新的坐标系（维数可以比原维数低），然后数据由原坐标系向新的坐标系投影。

### 方差 (Variance)

在统计学中，方差衡量的是一组数据的离散程度。数学公式： $Var(X) = \frac{1}{n-1} \sum_{i=1}^{n} (x_i - \bar{x})^2$

⽆偏还是有偏⽆所谓，因为特征值/奇异值⼤⼩关系不变

方差越大，代表数据在这个方向上“铺得越开”。在降维时，我们最怕把原本分得很开的点压到一起（丢失区分度）。PCA 的第一目标就是寻找方差最大的方向，因为那里保留了最原始、最丰富的信息。

### 协方差 (Covariance)

方差看一个维度，协方差看两个维度之间的“互动”。

如果 $X$ 变大时 $Y$ 也变大，协方差为正；反之为负；如果不相关，则接近 0。

PCA 中的直觉： 如果身高和体重的协方差很高，说明它们携带了大量重复信息。

协方差矩阵 (Covariance Matrix) 是一个表，记录了所有维度两两之间的相关性。PCA 的任务就是通过这个矩阵，找出哪些维度是冗余的，并把它们合并成互不相关的“新轴”。

$\Sigma = \frac{1}{n} X^T X$ 是数据的协方差矩阵。

- 协方差矩阵 $\Sigma$ 是一个 $d \times d$ 的实对称矩阵

- 对角线元素 $\Sigma_{ii}$：第 $i$ 个维度的方差。

- 非对角线元素 $\Sigma_{ij}$：维度 $i$ 与维度 $j$ 的相关性。

:::tip

PCA 的本质就是通过线性变换，将 $\Sigma$ 变成对角矩阵（消除维度间的相关性），并取对角线上最大的值（保留最大方差）。

:::

### 特征值与特征向量

对于协方差矩阵 $\Sigma$：

$$
\Sigma \mathbf{v} = \lambda \mathbf{v}
$$

特征向量 $\mathbf{v}$ (Direction)： 当协方差矩阵作用于向量 $\mathbf{v}$ 时，它只伸缩，不旋转。这意味着 $\mathbf{v}$ 指向的是数据分布中最自然、最核心的轴线。

在 PCA 中，这些向量就是我们寻找的“主成分方向”。特征值 $\lambda$ (Magnitude)： 它代表了数据在对应的特征向量方向上的离散程度（即方差的大小）。$\lambda$ 越大，说明这个方向越重要。

## 数学推导

假设我们有 $n$ 个样本 $\mathbf{x}_1, \mathbf{x}_2, \dots, \mathbf{x}_n$，每个样本有 $d$ 维特征，组成数据矩阵 $X \in \mathbb{R}^{n \times d}$（已进行中心化处理，即每一列均值为 0）。

### 核心目标：投影后方差最大化

我们的目标是找到一个单位投影方向向量 $\mathbf{w}$ ($\|\mathbf{w}\|=1$)，使得投影后的数据方差最大。

对于每个样本 $\mathbf{x}_i$，投影后的坐标为：$\mathbf{z}_i = \mathbf{x}_i^T \mathbf{w}$

投影后的方差为：

$$
Var(Z) = \frac{1}{n} \sum_{i=1}^{n} (\mathbf{x}_i^T \mathbf{w})^2 = \frac{1}{n} (\mathbf{w}^T X^T X \mathbf{w}) = \mathbf{w}^T \Sigma \mathbf{w}
$$

### 拉格朗日乘子法求解

我们要最大化 $f(\mathbf{w}) = \mathbf{w}^T \Sigma \mathbf{w}$，约束条件为 $\mathbf{w}^T \mathbf{w} = 1$。引入拉格朗日乘子 $\lambda$：

$$
L(\mathbf{w}, \lambda) = \mathbf{w}^T \Sigma \mathbf{w} + \lambda (1 - \mathbf{w}^T \mathbf{w})
$$

对 $\mathbf{w}$ 求导并令其为 0：

$$
\frac{\partial L}{\partial \mathbf{w}} = 2\Sigma \mathbf{w} - 2\lambda \mathbf{w} = 0
$$

从而得到：

$$
\Sigma \mathbf{w} = \lambda \mathbf{w}
$$

结果正是**特征值分解**的定义式：

- 投影方向 $\mathbf{w}$：是协方差矩阵 $\Sigma$ 的特征向量。

- 投影后方差大小：将 $\Sigma \mathbf{w} = \lambda \mathbf{w}$ 代回方差公式：投影后的方差正好等于对应的特征值。

$$
Var(Z) = \mathbf{w}^T (\Sigma \mathbf{w}) = \mathbf{w}^T (\lambda \mathbf{w}) = \lambda \|\mathbf{w}\|^2 = \lambda
$$

为了降维，只需将特征值从大到小排序，取前 $k$ 个特征向量构成投影矩阵即可（等价于对协方差矩阵做特征值分解（EVD），或对数据矩阵做奇异值分解（SVD），后者数值稳定性更好）。

## 算法流程 (The Pipeline)

1. 预处理：数据中心化 , 减去均值 $X \leftarrow X - \mu$。

2. 算矩阵：计算协方差矩阵（有的地方叫散度矩阵） $\Sigma = \frac{1}{n} X^T X$。

3. 求特征：求解 $\Sigma$ 的特征值 $\lambda_j$ 和对应的特征向量 $\mathbf{v}_j$。

4. 选主成分：将 $\lambda_j$ 从大到小排列，取前 $k$ 个对应的特征向量构成投影矩阵：（依据累计方差贡献率/方差解释率）

    $W = [\mathbf{v}_1, \mathbf{v}_2, \dots, \mathbf{v}_k]$。

5. 训练和识别时，对于每个样本 $\mathbf{x}$（对于批量的矩阵，只需要把x换成矩阵即可），将其投影到新空间：

- 投影： $\mathbf{z} = W^T \mathbf{x}$
- 重构（可选）： $\hat{\mathbf{x}} = W \mathbf{z}$

## 算法的评价策略：方差解释率

原始数据的协方差矩阵 $\Sigma$，维度为 $d \times d$。总方差就是该矩阵主对角线元素之和，也就是协方差矩阵的 **迹 (Trace)**：

$$
 \text{tr}(\Sigma) = \sum_{i=1}^{d} \sigma_{ii}^2
$$

其中 $\sigma_{ii}^2$ 是 $\Sigma$ 的对角线元素。是原始坐标系中第 $i$ 个维度的方差。

结合线代中迹的两个性质：

1. 迹等于特征值之和：$\text{tr}(\Sigma) = \sum_{i=1}^{d} \lambda_i$，其中 $\lambda_i$ 是 $\Sigma$ 的特征值。

    $$
    \sum_{i=1}^{d} \lambda_i = \text{数据总方差} = \text{tr}(\Sigma)
    $$

2. 相似变换不改变迹：PCA 的核心步骤是对协方差矩阵 $\Sigma$ 进行特征值分解（相似变换），得到一个对角矩阵 $\Lambda$，其中对角线元素就是特征值 $\lambda_i$。

    $$
    \text{tr}(\Sigma) = \text{tr}(\Lambda) = \sum_{i=1}^{d} \lambda_i
    $$

数据的总能量（总方差）在旋转坐标轴的过程中并没有消失，只是被重新分配了。

第 $i$ 个主成分的方差解释率：

$$
Ratio_i = \frac{\lambda_i}{\sum_{j=1}^{d} \lambda_j}
$$

累计方差解释率：如果保留前 $k$ 个主成分，那么：

$$
Cumulative\_Ratio = \frac{\sum_{i=1}^{k} \lambda_i}{\sum_{j=1}^{d} \lambda_j}
$$

通常以此设置一个阈值（比如 95%），来决定保留多少个主成分。

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
