---
title: QR分解
published: 2026-05-15
description: ''
image: ''
tags: []
category: '线性代数'
draft: false 
lang: ''
---

对于一个矩阵 $A$，我们可以将其分解为一个正交矩阵 $Q$ 和一个上三角矩阵 $R$ 的乘积，即 $A = QR$。这种分解被称为**QR分解**。

$Q$ : 是一个正交矩阵，满足 $Q^T Q = I$，其中 $I$ 是单位矩阵。列向量是 $Col(A)$ 的一组**标准正交基** (正交+模长为1)。

$R$ : 是一个上三角矩阵，包含了 $A$ 的列向量在 $Q$ 的列向量上的坐标。对角线元素 $R_{ii}$ 是 $A$ 的第 $i$ 列向量在 $Q$ 的第 $i$ 列向量上的投影（标量投影，**可正可负**）。$R_{ii} = Proj_{q_i} a_i=\langle \mathbf{a}_i, \mathbf{q}_i \rangle=q_i^T \mathbf{a}_i$。

存在性(恒成立)：对于任何实矩阵 $A$，都存在一个正交矩阵 $Q$ 和一个上三角矩阵 $R$ 使得 $A = QR$。

唯一性条件：如果 $A$ 是一个满秩矩阵，那么 QR分解是唯一的。

QR分解不唯一：若允许R的对角元为负，可通过右乘对角矩阵 $\pm 1$ 改变符号。

对于满足唯一性的矩阵 $A$，有如下等价条件：

1. $A$ 的列向量线性无关。
2. $A$ 的秩等于列数。
3. $R$ 的对角线元素全非零**且为正**。
4. $R$ 可逆

## QR分解的计算方法

QR分解的计算方法主要有两种：**Gram-Schmidt正交化**和**Householder变换**。

### Gram-Schmidt正交化

Gram-Schmidt正交化是一种逐步构造正交矩阵 $Q$ 的方法。对于矩阵 $A$ 的列向量 $\mathbf{a}_1, \mathbf{a}_2, \ldots, \mathbf{a}_n$，我们可以通过以下步骤构造 $Q$：

1. 初始化 $Q$ 的第一列为 $\mathbf{q}_1 = \frac{\mathbf{a}_1}{\|\mathbf{a}_1\|}$。
2. 对于 $k = 2, 3, \ldots, n$，计算Q的第 $k$ 列 $\mathbf{q}_k$：
   - 计算 $\mathbf{u}_k = \mathbf{a}_k - \sum_{j=1}^{k-1} \langle \mathbf{a}_k, \mathbf{q}_j \rangle \mathbf{q}_j$。
   - 将 $\mathbf{u}_k$ 归一化得到 $\mathbf{q}_k = \frac{\mathbf{u}_k}{\|\mathbf{u}_k\|}$。

对于 $R$ 的计算，我们可以通过以下步骤得到：

1. 对于 $i = 1, 2, \ldots, n$，计算 $R_{ii} = \langle \mathbf{a}_i, \mathbf{q}_i \rangle$。
2. 对于 $i < j$，计算 $R_{ij} = \langle \mathbf{a}_j, \mathbf{q}_i \rangle$。
3. 对于 $i > j$，设置 $R_{ij} = 0$。

### Householder变换

Householder变换是一种通过反射来构造正交矩阵 $Q$ 的方法。对于矩阵 $A$ 的列向量 $\mathbf{a}_1, \mathbf{a}_2, \ldots, \mathbf{a}_n$，我们可以通过以下步骤构造 $Q$：

1. 对于 $k = 1, 2, \ldots, n$，计算 Householder矩阵 $H_k$：
   - 计算 $\mathbf{v}_k = \mathbf{a}_k - \|\mathbf{a}_k\| \mathbf{e}_k$，其中 $\mathbf{e}_k$ 是第 $k$ 个标准基向量。
   - 计算 $H_k = I - 2 \frac{\mathbf{v}_k \mathbf{v}_k^T}{\mathbf{v}_k^T \mathbf{v}_k}$。

2. 将 $A$ 乘以 $H_k$ 得到新的矩阵 $A_k = H_k A$。
3. 重复步骤 1 和 2，直到得到一个上三角矩阵 $R$。

对于 $R$ 的计算，我们可以通过以下步骤得到：

1. 对于 $i = 1, 2, \ldots, n$，计算 $R_{ii} = \langle \mathbf{a}_i, \mathbf{q}_i \rangle$。
2. 对于 $i < j$，计算 $R_{ij} = \langle \mathbf{a}_j, \mathbf{q}_i \rangle$。
3. 对于 $i > j$，设置 $R_{ij} = 0$。

## QR分解的应用

### 1.迭代求解特征值和特征向量

参考[特征值和特征向量](./EigenValueAndEigennVector.md)中的QR算法部分。
