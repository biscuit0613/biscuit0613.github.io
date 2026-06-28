---
title: 模式识别与机器学习：核方法与核支持向量机
published: 2026-06-25
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 9
draft: false 
lang: ''
---

线性 SVM 在特征空间中找到最大间隔超平面，但它仍然是线性的——如果数据本身不是线性可分的，即使引入软间隔也无济于事。核方法（kernel methods）通过一个巧妙的数学技巧，让线性模型在**不显式计算高维特征**的情况下具备非线性能力。

## 从线性到非线性

对于线性不可分的数据，一个经典思路是将原始特征映射到高维空间，使数据在高维空间中变得线性可分。记这个映射为 $\phi(\mathbf{x})$，线性模型变为：

$$
f(\mathbf{x}) = \mathbf{w}^T \phi(\mathbf{x}) + b
$$

$\phi(\mathbf{x})$ 的维度通常远高于 $\mathbf{x}$（甚至无穷维），直接计算 $\phi(\mathbf{x})$ 和 $\mathbf{w}$ 的代价极高。核技巧的核心是：许多算法的优化和预测过程只依赖于**样本之间的内积** $\langle \phi(\mathbf{x}_i), \phi(\mathbf{x}_j) \rangle$，而非 $\phi(\mathbf{x})$ 本身。

## 核函数与核技巧

**核函数**定义为两个样本在映射空间中的内积：

$$
K(\mathbf{x}_i, \mathbf{x}_j) = \langle \phi(\mathbf{x}_i), \phi(\mathbf{x}_j) \rangle
$$

核技巧（kernel trick）指：**不显式定义 $\phi$，直接设计 $K$ 函数**。只要 $K$ 满足 Mercer 条件（对称且半正定），它就对应某个映射空间中的内积。这意味着我们可以：

- 使用一个 $d$ 维空间中的简单核函数计算，等价于在某个高维（甚至无穷维）空间中做内积
- 完全不必知道 $\phi$ 具体是什么

### 常见核函数

| 核函数 | 公式 | 特点 |
|--------|------|------|
| **线性核** | $K(\mathbf{x}_i, \mathbf{x}_j) = \mathbf{x}_i^T \mathbf{x}_j$ | 退化为原始线性模型，不升维 |
| **多项式核** | $K(\mathbf{x}_i, \mathbf{x}_j) = (\mathbf{x}_i^T \mathbf{x}_j + c)^d$ | 引入特征交互，$d$ 控制复杂度 |
| **高斯核（RBF）** | $K(\mathbf{x}_i, \mathbf{x}_j) = \exp\left(-\dfrac{\|\mathbf{x}_i - \mathbf{x}_j\|^2}{2\sigma^2}\right)$ | 最常用，对应无穷维映射，$\sigma$ 控制径向作用范围 |
| **Sigmoid 核** | $K(\mathbf{x}_i, \mathbf{x}_j) = \tanh(\alpha \mathbf{x}_i^T \mathbf{x}_j + c)$ | 来自神经网络，满足 Mercer 条件仅对部分参数成立 |

其中 RBF 核是最通用的选择——它的映射空间维度无穷，且只有一个超参数 $\sigma$ 需要调节。

### 核函数的构造规则

已知合法核函数可以通过以下运算组合出新核：

- 数乘：$cK$（$c > 0$）
- 加法：$K_1 + K_2$
- 乘法：$K_1 \cdot K_2$
- 多项式：$p(K)$（$p$ 是正系数多项式）

这使得从简单核构建复杂核成为可能。

## 核支持向量机

### 对偶问题的核化

回顾线性 SVM 的对偶问题：

$$
\max_{\boldsymbol{\alpha}} \sum_{i=1}^n \alpha_i - \frac{1}{2} \sum_{i=1}^n \sum_{j=1}^n \alpha_i \alpha_j y_i y_j \, \mathbf{x}_i^T \mathbf{x}_j
$$

目标函数中所有样本都以内积 $\mathbf{x}_i^T \mathbf{x}_j$ 的形式出现。将内积替换为核函数，即得到核 SVM：

$$
\boxed{
\max_{\boldsymbol{\alpha}} \sum_{i=1}^n \alpha_i - \frac{1}{2} \sum_{i=1}^n \sum_{j=1}^n \alpha_i \alpha_j y_i y_j \, K(\mathbf{x}_i, \mathbf{x}_j)
}
$$

$$
\text{s.t.} \quad \sum_{i=1}^n \alpha_i y_i = 0, \quad 0 \leq \alpha_i \leq C, \; \forall i
$$

约束条件与线性 SVM 完全相同——约束中不涉及内积，因此不需要修改。

### 决策函数

核 SVM 的决策函数也随之改变：

$$
f(\mathbf{x}) = \sum_{i=1}^n \alpha_i y_i K(\mathbf{x}_i, \mathbf{x}) + b
$$

预测时只需计算新样本 $\mathbf{x}$ 与所有支持向量的核函数值。不需要显式计算映射 $\phi(\mathbf{x})$。

### 支持向量的角色不变

KKT 条件与线性 SVM 一致：

- $\alpha_i = 0$：样本 $i$ 被正确分类且远离边界，不参与决策
- $0 < \alpha_i < C$：样本 $i$ 恰好在边界上，是真正的支持向量
- $\alpha_i = C$：样本 $i$ 在边界内侧或被错分（软间隔）

核 SVM 的决策函数**只依赖于支持向量**（$\alpha_i > 0$ 的样本），这与线性 SVM 完全相同。

## 超参数选择

核 SVM 有两个关键超参数：

**$C$（来自软间隔）**：控制对错分的惩罚力度。
- $C$ 大 → 更关注训练集准确率，可能过拟合
- $C$ 小 → 允许更多错分，间隔更宽，泛化更好

**$\sigma$ 或 $\gamma$（来自 RBF 核，通常记 $\gamma = 1/2\sigma^2$）**：控制单个样本的影响范围。
- $\sigma$ 小（$\gamma$ 大）→ 每个样本只影响近邻，决策边界复杂，易过拟合
- $\sigma$ 大（$\gamma$ 小）→ 每个样本影响范围广，决策边界平滑，易欠拟合

这两个参数的组合需要交叉验证调优。经验做法是在对数尺度上搜索（如 $C \in \{2^{-5}, 2^{-3}, \dots, 2^{15}\}$，$\gamma \in \{2^{-15}, 2^{-13}, \dots, 2^{3}\}$）。

## 核方法的更广泛应用

核技巧不限于 SVM。**任何可以写成样本间内积形式的算法都可以核化**。典型例子包括：

- **核 PCA（kPCA）**：对核矩阵 $\mathbf{K}$（其中 $K_{ij} = K(\mathbf{x}_i, \mathbf{x}_j)$）做特征分解，得到高维空间中的主成分。已有单独文章介绍。
- **核 Fisher 判别（KFD）**：将 LDA 核化，在高维空间中寻找最大可分方向。
- **核岭回归（KRR）**：将 Ridge 回归核化。

核方法在深度学习兴起前是处理非线性问题的主流工具。它的优势是数学优雅、有凸优化保证，缺点是需要设计/选择核函数，且核矩阵 $\mathbf{K}$ 的规模为 $O(n^2)$，大样本时计算和存储成本高。

## 小结

核方法通过一个简洁的数学变换，将线性模型的适用范围扩展到非线性：
- **核技巧** = 用核函数隐式计算高维内积，避免显式映射
- **核 SVM** = 将线性 SVM 对偶中的内积替换为核函数
- **任何内积形式的算法都可以核化**，核 SVM 只是其中一个应用
