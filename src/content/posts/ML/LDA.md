---
title: LDA-线性判别分析 (Linear Discriminant Analysis)
published: 2026-06-19
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
draft: false 
order: 10
lang: ''
---

PCA将所有的样本作为一个整体对待，寻找一个均方误差最小意义下的最优线性映射，而没有考虑样本的类别属性，它所忽略的投影方向有可能恰恰包含了重要的可分性信息

LDA（或FDA，多重判别分析，MDA, Multiple Discriminant Analysis ）是在可分性最大意义下的最优线性映射，充分保留了样本的类别可分性信息

PCA无监督，LDA有监督

“高内聚，低耦合”——即降维后，同一类别的样本尽可能聚在一起，不同类别的样本尽可能离得远。

## Fisher判别准则

样本：$\{\mathbf{x}_1, \mathbf{x}_2, \ldots, \mathbf{x}_n\}$，类别标签：$\omega_i \in \{1, 2, \ldots, c\}$，类别均值：$\boldsymbol{\mu}_i = \frac{1}{n_i} \sum_{\mathbf{x} \in \omega_i} \mathbf{x}$，总体均值：$\boldsymbol{\mu} = \frac{1}{n} \sum_{i=1}^c n_i \boldsymbol{\mu}_i$。

### 类内散度矩阵 $S_W$

对于某一类 $\omega_i$ 的类内散度矩阵 $S_i$：

$$
S_i = \sum_{\mathbf{x} \in \omega_i} (\mathbf{x} - \boldsymbol{\mu}_i)(\mathbf{x} - \boldsymbol{\mu}_i)^T
$$

总体的类内散度矩阵，衡量同一类别样本的离散程度，定义为：

$$
S_W = \sum_{i=1}^c \sum_{\mathbf{x} \in \omega_i} (\mathbf{x} - \boldsymbol{\mu}_i)(\mathbf{x} - \boldsymbol{\mu}_i)^T
$$

越小，说明同一类别的样本越聚集。

### 类间散度矩阵 $S_B$

衡量不同类别样本的离散程度，定义为：

$$
S_B = \sum_{i=1}^c n_i (\boldsymbol{\mu}_i - \boldsymbol{\mu})(\boldsymbol{\mu}_i - \boldsymbol{\mu})^T
$$

越大，说明不同类别的样本越分散。

### Fisher准则

LDA依旧要找投影向量 $\mathbf{w}$，投影后 $\mathbf{z}_i = \mathbf{w}^T \mathbf{x}_i$，类内散度和类间散度分别为：

$$
S_W' = \sum_{i=1}^c \sum_{\mathbf{x} \in \omega_i} (\mathbf{w}^T \mathbf{x} - \mathbf{w}^T \boldsymbol{\mu}_i)^2 = \mathbf{w}^T S_W \mathbf{w}\\[1em]
S_B' = \sum_{i=1}^c n_i (\mathbf{w}^T \boldsymbol{\mu}_i - \mathbf{w}^T \boldsymbol{\mu})^2 = \mathbf{w}^T S_B \mathbf{w}
$$

LDA的目标是投影后最大化类间散度与类内散度的比值：

$$
J(\mathbf{w}) = \frac{\mathbf{w}^T S_B \mathbf{w}}{\mathbf{w}^T S_W \mathbf{w}}
$$

求解过程：

固定分母 $\mathbf{w}^T S_W \mathbf{w} = 1$，最大化分子 $\mathbf{w}^T S_B \mathbf{w}$，引入拉格朗日乘子 $\lambda$，构建拉格朗日函数：

$$
L(\mathbf{w}, \lambda) = \mathbf{w}^T S_B \mathbf{w} - \lambda (\mathbf{w}^T S_W \mathbf{w} - 1)
$$

对 $\mathbf{w}$ 求导并设置为零：

$$
\frac{\partial L}{\partial \mathbf{w}} = 2 S_B \mathbf{w} - 2 \lambda S_W \mathbf{w} = 0
$$

从而得到：

$$
S_B \mathbf{w} = \lambda S_W \mathbf{w}\\
\Rightarrow S_W^{-1} S_B \mathbf{w} = \lambda \mathbf{w}
$$

- 这表明 $\mathbf{w}$ 是矩阵 $S_W^{-1} S_B$ 的特征向量，对应的特征值为 $\lambda$。
- 对于 $c$ 个类别，$S_B$ 的秩最大为 $c-1$，因此最多只能找到 $c-1$ 个非零特征值对应的特征向量，这些特征向量构成了LDA的投影空间。
- 新的坐标系可能不是一个正交坐标系
- 只有样本足够多时才能保证类内散度矩阵 $S_W$ 可逆。**高维小样本问题**（Small Sample Size Problem）会导致 $S_W$ 不可逆，此时可以PCA+LDA（此时需先用PCA将数据降维至 N−C 维，再执行LDA）、Null Space LDA、VCA等方法解决。

## 算法流程 (The Pipeline)

1. 计算各类别均值与全局均值：

    - $\boldsymbol{\mu}_i=\frac{1}{n_i}\sum_{\mathbf{x} \in \omega_i} \mathbf{x}$
    - $\boldsymbol{\mu}=\frac{1}{n}\sum_{i=1}^c n_i \boldsymbol{\mu}_i$。

2. 计算散度矩阵：

   - 类内散度矩阵 $S_W=\sum_{i=1}^c \sum_{\mathbf{x} \in \omega_i} (\mathbf{x} - \boldsymbol{\mu}_i)(\mathbf{x} - \boldsymbol{\mu}_i)^T$

   - 类间散度矩阵 $S_B = \sum_{i=1}^c n_i (\boldsymbol{\mu}_i - \boldsymbol{\mu})(\boldsymbol{\mu}_i - \boldsymbol{\mu})^T$。

3. 求解广义特征值问题 $S_B \mathbf{w} = \lambda S_W \mathbf{w}$，得到特征值 $\lambda_j$ 和对应的特征向量 $\mathbf{v}_j$。
4. 选取前 $k\leq c-1$ 个特征值对应的特征向量构成投影矩阵 $W = [\mathbf{v}_1, \mathbf{v}_2, \dots, \mathbf{v}_k]$。
