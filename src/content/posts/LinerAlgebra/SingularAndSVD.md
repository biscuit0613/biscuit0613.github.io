---
title: 奇异值和奇异值分解 (Singular Value Decomposition, SVD)
published: 2026-04-22
description: '矩阵的奇异值分解（SVD）是一种重要的矩阵分解方法，它将一个矩阵分解为三个矩阵的乘积：一个正交矩阵、一个对角矩阵和另一个正交矩阵。本文将介绍SVD的定义、计算方法以及在数据分析和机器学习中的应用。'
image: ''
tags: []
category: '线性代数'
draft: false 
lang: ''
---

- 特征值研究的是 $\mathbf{A}: \mathbb{R}^n \to \mathbb{R}^n$。向量在变换后还在原来的空间里。
- 奇异值研究的是 $\mathbf{A}: \mathbb{R}^n \to \mathbb{R}^m$。它描述的是把一个空间的向量“搬运”到另一个空间时发生了什么。

## 定义

对于任何 $m \times n$ 的矩阵 $\mathbf{A}$，都可以分解为：
$$
\mathbf{A} = \mathbf{U} \mathbf{\Sigma} \mathbf{V}^T
$$

- $\mathbf{V}$ (右奇异向量)：输入空间的一组标准正交基， $n \times n$ 的正交矩阵，是 $\mathbf{A}^T\mathbf{A}$ 的**特征向量矩阵**，定义了**输入空间**里对输入数据的“旋转”。
- $\mathbf{\Sigma}$ (奇异值)：和矩阵 $A$ 同型，对角线上就是奇异值。对角线上元素 $\sigma_i$ 是 $\mathbf{A}^T\mathbf{A}$ 特征值的平方根，按**从大到小**排列，对应在 $\mathbf{V}$ 定义的那些方向上，空间被拉伸了多少倍。
- $\mathbf{U}$ (左奇异向量)：输出空间的一组标准正交基，$m \times m$ 的正交矩阵，是 $\mathbf{A}\mathbf{A}^T$ 的**特征向量矩阵**，把拉伸后的数据**映射到输出空间**。

:::note

矩阵 $A$ 的 $n$ 个特征值 $\lambda_1, \lambda_2, \dots, \lambda_n$ 及其对应的特征向量 $\mathbf{v}_1, \mathbf{v}_2, \dots, \mathbf{v}_n$，那么把这些向量按列排在一起构成的矩阵 $P$，就是特征向量矩阵

:::

:::tip

如果 $m > n$（样本数远大于特征数），$\Sigma$ 矩阵的下半部分全是 $0$。乘法计算时，这些 $0$ 会抹杀掉 $U$ 矩阵的后 $m-n$ 列。因此，我们可以只取 $U$ 的前 $n$ 列，得到一个 $m \times n$ 的矩阵 $\tilde{U}$，这样就能保持矩阵乘法的正确性，同时节省计算资源。

:::

### 几何直观：把球拉成椭球

想象输入空间里有一个单位球：

旋转：$\mathbf{V}^T$ 对球进行旋转，找到最适合拉伸的方向。

拉伸：$\mathbf{\Sigma}$ 在这些方向上进行缩放。原本的单位球变成了椭球。

再旋转：$\mathbf{U}$ 对拉伸后的椭球进行最后的角度调整。

奇异值 $\sigma_i$ 就是这个椭球各个半轴的长度。 如果某个奇异值非常大，说明矩阵在那个方向上的“投影”非常强；如果接近 0，说明那个维度几乎不包含有效信息。
