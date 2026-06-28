---
title: kPCA-核主成分分析 (Kernel Principal Component Analysis)
published: 2026-06-19
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 15
draft: false 
lang: ''
---

KPCA（核主成分分析，Kernel PCA） 是PCA的非线性扩展，本质是“先升维，后降维”——通过核函数将数据隐式映射到高维（甚至无穷维）特征空间，再在该空间里做标准的线性PCA，从而在原始空间中捕捉非线性主成分。

经典的PCA方法假设数据 $\mathbf{x}$ 服从多变量高斯分布，但实际应用中这一假设可能不成立基于核方法，我们可以将数据从原始空间 $\mathbf{x}$ 转换为特征空间 $\Phi(\mathbf{x})$，如果 $\Phi(\mathbf{x})$ 服从高斯分布的话，我们可在特征空间下做PCA，即核PCA.

## 数学推导

特征空间中的数据已经中心化

原始空间中的数据 $\mathbf{x}$ 通过核函数 $k(\mathbf{x}, \mathbf{y}) = \langle \Phi(\mathbf{x}), \Phi(\mathbf{y}) \rangle$ 映射到特征空间 $\mathcal{F}$ 中的点 $\Phi(\mathbf{x})$。

在特征空间中，协方差矩阵（散度矩阵）$C$：

$$
C =  \sum_{i=1}^n \Phi(\mathbf{x}_i) \Phi(\mathbf{x}_i)^T
$$

由于特征空间可能是高维甚至无穷维的，直接对 $C$ 特征值分解是不可行的。KPCA 的核心思想是利用核函数来避免显式地计算 $\Phi(\mathbf{x})$。

需要求解特征值问题：

$$
C \mathbf{v} = \lambda \mathbf{v}
$$

我们可以将特征向量 $\mathbf{v}$ 表示为训练样本的线性组合：（特征向量可以表示成列向量的线性组合）

$$
\mathbf{v} = \sum_{i=1}^n \alpha_i \Phi(\mathbf{x}_i)
$$

将 $\mathbf{v}$ 代入特征值问题中：

$$
( \sum_{i=1}^n \Phi(\mathbf{x}_i) \Phi(\mathbf{x}_i)^T) \sum_{j=1}^n \alpha_j \Phi(\mathbf{x}_j) = \lambda \sum_{j=1}^n \alpha_j \Phi(\mathbf{x}_j)\\[1em]
\Rightarrow  \sum_{i=1}^n \sum_{j=1}^n \alpha_j \Phi(\mathbf{x}_i)\Phi(\mathbf{x}_i)^T \Phi(\mathbf{x}_j) = \lambda \sum_{j=1}^n \alpha_j \Phi(\mathbf{x}_j)
$$

利用核函数 $k(\mathbf{x}_i, \mathbf{x}_j) = \Phi(\mathbf{x}_i)^T \Phi(\mathbf{x}_j)$，两边同时乘以 $\Phi(\mathbf{x}_k)^T,k=1,2,\ldots,n$ 可以将上述方程转化为：

$$
 \sum_{i=1}^n \sum_{j=1}^n \alpha_j k(\mathbf{x}_i, \mathbf{x}_j) k(\mathbf{x}_i, \mathbf{x}_k) = \lambda \sum_{j=1}^n \alpha_j k(\mathbf{x}_j, \mathbf{x}_k)
$$

定义核矩阵（Gram 矩阵.） $K$，其中 $K_{ij} = k(\mathbf{x}_i, \mathbf{x}_j)$，上述方程可以写成矩阵形式：

$$
K^2 \boldsymbol{\alpha} = \lambda K \boldsymbol{\alpha}
$$

进一步简化为：

$$
K \boldsymbol{\alpha} = \lambda \boldsymbol{\alpha}
$$
