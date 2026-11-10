---
title: 模式识别与机器学习：逻辑回归
published: 2026-06-25
description: ''
image: ''
tags: []
category: '01-深度学习基础'
order: 5
draft: false 
lang: ''
---

线性回归做回归，但如果我们把分类问题当回归来做——把标签 $y_i \in \{0, 1\}$ 作为连续值拟合——会出问题：预测值可能落在 $[0, 1]$ 区间之外，失去概率意义。逻辑回归（Logistic Regression）在保持线性模型框架的同时，通过一个简单的非线性变换解决了这个问题。

## 从回归到分类

线性回归的输出是 $\mathbf{w}^T \mathbf{x}$，值域 $(-\infty, +\infty)$。要把它映射到概率 $[0, 1]$，需要一个单调可微的**链接函数**。最常用的选择是 **Sigmoid 函数**：

$$
\sigma(z) = \frac{1}{1 + e^{-z}}
$$

Sigmoid 将实数映射到 $(0, 1)$，且 $\sigma(0) = 0.5$，$z \to +\infty$ 时趋近 $1$，$z \to -\infty$ 时趋近 $0$。

逻辑回归的模型由此定义为：

$$
P(y = 1 \mid \mathbf{x}) = \sigma(\mathbf{w}^T \mathbf{x}) = \frac{1}{1 + e^{-\mathbf{w}^T \mathbf{x}}}
$$

$$
P(y = 0 \mid \mathbf{x}) = 1 - \sigma(\mathbf{w}^T \mathbf{x}) = \frac{e^{-\mathbf{w}^T \mathbf{x}}}{1 + e^{-\mathbf{w}^T \mathbf{x}}}
$$

:::tip

对比 Bayes 分类器：Bayes 先建模 $p(\mathbf{x} \mid \omega_i)$ 再反推 $P(\omega_i \mid \mathbf{x})$（生成式）；逻辑回归直接建模 $P(y \mid \mathbf{x})$（判别式）。前者需要对特征分布做假设，后者只需要找到一组 $\mathbf{w}$。

:::

## 损失函数：从 MLE 到交叉熵

参数 $\mathbf{w}$ 的估计沿用 Estimation 章的最大似然框架。对于数据集 $\{(\mathbf{x}_i, y_i)\}_{i=1}^N$，$y_i \in \{0, 1\}$，似然函数为：

$$
L(\mathbf{w}) = \prod_{i=1}^N P(y_i \mid \mathbf{x}_i) = \prod_{i=1}^N \sigma(\mathbf{w}^T \mathbf{x}_i)^{y_i} \left[1 - \sigma(\mathbf{w}^T \mathbf{x}_i)\right]^{1 - y_i}
$$

取负对数（习惯上最小化负对数似然）：

$$
J(\mathbf{w}) = -\ln L(\mathbf{w}) = -\sum_{i=1}^N \Big[ y_i \ln \sigma(\mathbf{w}^T \mathbf{x}_i) + (1 - y_i) \ln \left(1 - \sigma(\mathbf{w}^T \mathbf{x}_i)\right) \Big]
$$

这称为**交叉熵损失（cross-entropy loss）**。它的形式与 MLE 估计高斯分布时的均方误差不同——对于伯努利分布，MLE 自然导出交叉熵。

:::tip

对比 MLE 在不同分布下的损失函数：

| 分布 | MLE 导出的损失 | 适用场景 |
|------|---------------|---------|
| 高斯分布 $\mathcal{N}(\mu, \sigma^2)$ | 均方误差 $\frac{1}{2}(y - \hat{y})^2$ | 回归 |
| 伯努利分布 $\text{Bern}(p)$ | 交叉熵 $-y\ln p - (1-y)\ln(1-p)$ | 二分类 |

这说明选择损失函数不是任意的——它应该由数据的分布假设决定。

:::

## 梯度下降求解

逻辑回归没有闭式解，需要用梯度下降迭代求解。先对单个样本的损失求梯度：

记 $p_i = \sigma(\mathbf{w}^T \mathbf{x}_i)$。利用 Sigmoid 的导数性质 $\sigma'(z) = \sigma(z)(1 - \sigma(z))$：

$$
\begin{aligned}
\frac{\partial J_i}{\partial \mathbf{w}} &= -\frac{\partial}{\partial \mathbf{w}} \Big[ y_i \ln p_i + (1 - y_i) \ln(1 - p_i) \Big] \\[1ex]
&= -\frac{y_i}{p_i} \cdot p_i(1 - p_i) \mathbf{x}_i + \frac{1 - y_i}{1 - p_i} \cdot p_i(1 - p_i) \mathbf{x}_i \\[1ex]
&= \big[ -y_i (1 - p_i) + (1 - y_i) p_i \big] \mathbf{x}_i \\[1ex]
&= (p_i - y_i) \mathbf{x}_i
\end{aligned}
$$

全数据集的梯度是所有样本梯度之和：

$$
\nabla J(\mathbf{w}) = \sum_{i=1}^N (p_i - y_i) \mathbf{x}_i
$$

梯度下降的更新规则：

$$
\mathbf{w}^{(t+1)} = \mathbf{w}^{(t)} - \eta \sum_{i=1}^N (p_i - y_i) \mathbf{x}_i
$$

这个形式有一个非常简洁的解释：当预测 $p_i$ 大于真实 $y_i$ 时，梯度为正，$\mathbf{w}$ 向减小 $\mathbf{w}^T \mathbf{x}_i$ 的方向移动；反之亦然。

### 与感知机的对比

感知机的更新规则是 $\mathbf{w} \leftarrow \mathbf{w} + \eta \sum_{i \in \mathcal{X}} \mathbf{x}_i$（$\mathcal{X}$ 为错分样本集）。逻辑回归则对**所有**样本加权更新：

| | 感知机 | 逻辑回归 |
|--|--------|---------|
| 更新触发条件 | 仅错分样本 | 所有样本 |
| 更新幅度 | 固定 $\eta$ | 正比于预测误差 $\|p_i - y_i\|$ |
| 输出 | 硬标签 $\{+1, -1\}$ | 概率 $(0, 1)$ |
| 损失函数 | 感知机准则（错分距离和） | 交叉熵（MLE 导出） |
| 线性可分时收敛性 | 保证收敛于某个分界面 | 保证收敛于唯一的极大似然解 |

## 决策边界

逻辑回归的决策边界由 $P(y=1 \mid \mathbf{x}) = 0.5$ 定义：

$$
\sigma(\mathbf{w}^T \mathbf{x}) = 0.5 \iff \mathbf{w}^T \mathbf{x} = 0
$$

这是一个线性超平面，与 Bayes 分类器中 $\Sigma_i = \Sigma$ 时的 LDA 决策边界形式相同。但 LDA 假设了高斯类条件密度，而逻辑回归不做这个假设——它的"线性"是从 Sigmoid + 线性参数化直接导出的。

## 正则化

与线性回归一样，逻辑回归也可以加入正则化项：

- **L2 正则化**（逻辑回归的默认做法）：$J(\mathbf{w}) = -\ln L(\mathbf{w}) + \frac{\lambda}{2} \|\mathbf{w}\|_2^2$
- **L1 正则化**：$J(\mathbf{w}) = -\ln L(\mathbf{w}) + \lambda \|\mathbf{w}\|_1$

梯度更新中每一项多出一个 $-\lambda \mathbf{w}$（L2）或符号项（L1）。

## 多类推广

逻辑回归自然地推广到多类——在输出层使用 Softmax 函数替代 Sigmoid，得到 $P(\omega_k \mid \mathbf{x}) = \frac{\exp(\mathbf{w}_k^T \mathbf{x})}{\sum_{j=1}^C \exp(\mathbf{w}_j^T \mathbf{x})}$。这将在多分类一节中详细展开。

## 小结

逻辑回归是连接"概率视角"和"优化视角"的枢纽。它的损失函数来自 MLE（回连 Bayes-Estimation），而求解使用梯度下降（接线性回归的优化框架）。它的输出是概率（接 Bayes 决策），但直接建模 $P(y \mid \mathbf{x})$ 而非 $p(\mathbf{x} \mid y)$（走向判别式）。如果整个线性模型章只能留下一个模型，逻辑回归是最值得深入理解的那个。
