---
title: 对角矩阵 (Diagonal Matrix)
published: 2026-04-10
description: '对角阵是指在一个方阵中，只有主对角线上的元素可能非零，而其他位置的元素都是零的矩阵。本文将介绍对角矩阵的定义、性质以及计算方法。'
image: ''
tags: []
category: '线性代数'
draft: false 
lang: ''
---

## 定义

对角矩阵是指在一个方阵中，只有主对角线上的元素可能非零，而其他位置的元素都是零的矩阵。形式化定义如下：

$$
D = \begin{bmatrix}
d_1 & 0 & 0 & \cdots & 0 \\
0 & d_2 & 0 & \cdots & 0 \\
0 & 0 & d_3 & \cdots & 0 \\
\vdots & \vdots & \vdots & \ddots & \vdots \\
0 & 0 & 0 & \cdots & d_n
\end{bmatrix}
$$

其中 $d_1, d_2, \ldots, d_n$ 是对角线上的元素，可以是任意实数。

## 性质

如果把矩阵看作加工向量的机器，普通矩阵会把向量**旋转 + 缩放**，而对角阵非常纯粹：它 **只做缩放，不旋转** 。

- 如果 $d_1 = 2$，意味着它把向量在 $x$ 轴方向拉长 2 倍。

- 如果 $d_2 = 0.5$，意味着它把向量在 $y$ 轴方向压缩一半。
- ...
- 各轴独立：每个轴的缩放互不干扰。

## 计算

对角矩阵的计算非常简单：

- 乘法极快：
  - 两个对角阵相乘，只需要把对应的对角元素相乘即可。
  - 对角阵和向量相乘，也只需要把向量的每个分量分别乘以对应的对角元素(看作不同坐标轴上缩放程度不一样)。这大大减少了计算量，尤其在高维空间中。

$$
\begin{aligned}
D \mathbf{x} &= \begin{bmatrix}
d_1 & 0 & 0 & \cdots & 0 \\
0 & d_2 & 0 & \cdots & 0 \\
0 & 0 & d_3 & \cdots & 0 \\
\vdots & \vdots & \vdots & \ddots & \vdots \\
0 & 0 & 0 & \cdots & d_n
\end{bmatrix}
\begin{bmatrix}x_1 \\
x_2 \\
x_3 \\
\vdots \\
x_n
\end{bmatrix}=
\begin{bmatrix}
    d_1x_1\\
    d_2x_2\\
    d_3x_3\\
    \vdots\\
    d_nx_n
\end{bmatrix}
=\sum_{i=1}^{n} d_i x_i \mathbf{e}_i
\end{aligned}
$$

- 求幂简单：想求 $D^{100}$？不需要乘一百次，直接把对角线上的每个数字求 100 次方。
- 行列式好算：$\det(D)$ 就是主对角线所有元素的乘积。
- 逆矩阵秒出：只要对角线上没有 0，逆矩阵 $D^{-1}$ 就是把对角线元素全部取倒数
- 特征值：对于对角阵，对角线上的数字直接就是它的特征值。

$$
\text{特征值} = \{d_1, d_2, \ldots, d_n\}
$$
