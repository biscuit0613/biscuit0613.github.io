---
title: 模式识别与机器学习：非线性分类-距离分类器
published: 2026-05-21
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
draft: false 
lang: ''
---

# 距离分类器

:::tip
常见的非线性分类方法包括：

1. 最近邻分类器（K-Nearest Neighbors, KNN）：KNN是一种基于实例的学习方法，通过计算测试样本与训练样本之间的距离来进行分类。它不需要显式地构建模型，而是直接使用训练数据进行预测。
2. 神经网络
3. 核方法

:::

基本思想：基于待识别样本与已知样本（或原型）之间的距离来判定类别。距离越小，相似度越高，类别归属越可能相同。

## 距离函数

所有的距离分类器都需要定义一个距离函数来度量样本之间的相似度。常用的距离函数包括：

| 距离函数       | 公式                                                                                              |
| -------------- | ------------------------------------------------------------------------------------------------- |
| 欧氏距离       | $d(\mathbf{x}, \mathbf{y}) = \sqrt{\sum_{i=1}^n (\mathbf{x}_i - \mathbf{y}_i)^2}$                 |
| 曼哈顿距离     | $d(\mathbf{x}, \mathbf{y}) = \sum_{i=1}^n\|\mathbf{x}_i - \mathbf{y}_i\|$                         |
| 切比雪夫距离   | $d(\mathbf{x}, \mathbf{y}) = \max_{i=1}^n\|\mathbf{x}_i - \mathbf{y}_i\|$                         |
| 闵可夫斯基距离 | $d(\mathbf{x}, \mathbf{y}) = \left( \sum_{i=1}^n\|\mathbf{x}_i - \mathbf{y}_i\| ^p \right)^{1/p}$ |

## 平均样本法

对于 $c$ 个类别 $\omega_1, \omega_2, \ldots, \omega_c$，每个类别有一个**标准样本** $T_i$，对于待识别样本 $\mathbf{x}$，计算其与每个标准样本的距离，取最小作为分类结果。

$$
i_0 = \arg\min_{1 \leq i \leq c} d(\mathbf{x}, T_i)
$$

则判别样本 $\mathbf{x}$ 属于类别 $\omega_{i_0}$。

## 最近邻法

规则：找与待测样本 $\mathbf{x}$ 距离最近的单个训练样本 $\mathbf{x}'$，以这个最近样本 $\mathbf{x}'$ 的类别作为待测样本 $\mathbf{x}$ 的预测类别。

最近邻规则相当于k=1的k-近邻分类，其分类界面可以用Voronoi网格表示

理论保证：渐近误差不超过贝叶斯误差的2倍。

缺点：对噪声敏感，决策边界复杂（Voronoi图）。

## K-近邻法（K-Nearest Neighbors, KNN）

:::tip

这个也是贝叶斯分类器的一种非参数估计方法，直接从数据中“拼凑”出密度函数。

:::

规则：找与待测样本 $\mathbf{x}$ 距离最近的 $K$ 个训练样本，根据这 $K$ 个样本的类别进行投票，选择出现频率最高的类别作为预测结果。

算法步骤：

1. 计算待测样本 $\mathbf{x}$ 与所有训练样本的距离。
2. 找出距离最近的 $K$ 个训练样本。
3. 根据这 $K$ 个样本中各类样本的出现次数 $N_i$。
4. 如果 $i_0 = \arg\max_{1 \leq i \leq c} N_i$ 是唯一的，则判别样本 $\mathbf{x}$ 属于类别 $\omega_{i_0}$。

## 马氏距离测度学习

马氏距离：

$$
d(\mathbf{x}, \mathbf{y}) = \sqrt{(\mathbf{x} - \mathbf{y})^T \Sigma^{-1} (\mathbf{x} - \mathbf{y})}
$$

其中 $\Sigma$ 是一个数据的协方差矩阵。它的作用是消除特征量纲和相关性影响(正定矩阵)。

通过学习 $\Sigma$，可以使得同类样本之间的距离更小，不同类样本之间的距离更大，从而提高分类性能
模型：

$$
\min_M \mathcal{l}(M,\mathcal{D},\mathcal{S},\mathcal{R}) + \lambda R(M)
$$
