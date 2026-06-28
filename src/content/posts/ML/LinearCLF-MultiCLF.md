---
title: 模式识别与机器学习：线性分类器-多分类问题
published: 2026-05-28
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 8
draft: false 
lang: ''
---

前面的二分类器（感知机、逻辑回归、SVM）只能区分两类。实际中更常见的是 $C > 2$ 类的问题。处理多分类有两种思路：将多分类拆成多个二分类，或者直接构造多类模型。

## 基本概念

在进入具体方法之前，统一几个术语：

| 术语 | 符号 | 含义 |
|------|------|------|
| **判别函数** | $g_j(\mathbf{x})$ | 第 $j$ 类的打分函数，值越大表示模型越倾向于将该样本判为第 $j$ 类 |
| **决策准则** | $\hat{y} = \arg\max_j g_j(\mathbf{x})$ | 从判别函数到类别的映射规则 |
| **决策边界** | $g_i(\mathbf{x}) = g_j(\mathbf{x})$ | 类别 $i$ 和 $j$ 之间的分界面，两侧各判一类 |
| **拒识** | — | 当最大判别值低于某个阈值 $T$ 时放弃分类，避免高风险错误 |

本章沿用 Bayes 章的符号约定：$\mathbf{x}$ 是加粗的特征向量，$\omega_j$ 是第 $j$ 个类别，$P(\cdot)$ 表示概率。分类器统一表示为：

$$
g_j(\mathbf{x}) = \mathbf{w}_j^T \mathbf{x} + b_j
$$

多类决策准则统一为 $\hat{\omega} = \arg\max_j g_j(\mathbf{x})$，不同方法的不同之处在于如何训练得到 $\mathbf{w}_j$ 和 $b_j$。

## 一对多（One-vs-Rest, OvR）

对每个类别 $\omega_k$ 训练一个二分类器 $g_k(\mathbf{x})$，将该类视为正类（$+1$），其余所有类视为负类（$-1$）。总共训练 $C$ 个分类器。

**决策准则**：计算所有 $g_k(\mathbf{x})$，若存在唯一 $k$ 使得 $g_k(\mathbf{x}) > 0$ 且所有其他 $g_j(\mathbf{x}) < 0$，则判为 $\omega_k$。若多个分类器输出正类或全部输出负类，可设拒识。

**实用变体**：用 $\hat{\omega} = \arg\max_k g_k(\mathbf{x})$ 替代硬阈值，此时 OvR 退化为一个直接的多类决策。但这个做法要求不同分类器的输出值可比——逻辑回归和 SVM 的输出尺度不同，不能直接混用。

**优点**：分类器数量少（$C$ 个），预测速度快。
**缺点**：每类的负类样本是其他所有类之和，类别不平衡严重；不同分类器输出不可比。

## 一对一（One-vs-One, OvO）

每对类别 $(\omega_i, \omega_j)$ 之间训练一个二分类器 $g_{ij}(\mathbf{x})$，共 $C(C-1)/2$ 个。训练时只使用 $\omega_i$ 和 $\omega_j$ 的样本，其他类不参与。

**决策准则**：每个分类器 $g_{ij}$ 投一票给 $\omega_i$ 或 $\omega_j$，统计所有分类器的投票结果，得票最多的类别获胜：

$$
\hat{\omega} = \arg\max_k \sum_{j \neq k} \mathbb{I}[g_{kj}(\mathbf{x}) > 0]
$$

其中 $\mathbb{I}[\cdot]$ 是指示函数。表示为 $\mathbb{I}[g_{kj}(\mathbf{x}) > 0] = 1$ 表示 $g_{kj}$ 投票给 $\omega_k$，否则投给 $\omega_j$。

**优点**：每个分类器只接触两类数据，训练快；无类别不平衡问题。
**缺点**：分类器数量随 $C$ 平方增长，预测时需运行 $C(C-1)/2$ 个分类器，速度慢。

## Softmax 回归（多项逻辑回归）

前两种方法将多分类拆成多个二分类，Softmax 回归则直接构造一个多类模型。

### 模型定义

将逻辑回归的 Sigmoid 替换为 Softmax 函数：

$$
P(\omega_k \mid \mathbf{x}) = \frac{\exp(\mathbf{w}_k^T \mathbf{x} + b_k)}{\sum_{j=1}^C \exp(\mathbf{w}_j^T \mathbf{x} + b_j)},\quad k = 1, 2, \dots, C
$$

Softmax 将 $C$ 个实数得分 $\{\mathbf{w}_j^T \mathbf{x} + b_j\}$ 归一化为一个概率分布——所有输出在 $[0, 1]$ 之间且和为 $1$。当 $C = 2$ 时，Softmax 退化为逻辑回归。

### 损失函数

沿用逻辑回归的 MLE 框架。对于数据集 $\{(\mathbf{x}_i, y_i)\}_{i=1}^N$，$y_i \in \{1, \dots, C\}$，记 $p_{ik} = P(\omega_k \mid \mathbf{x}_i)$，负对数似然为：

$$
J(\{\mathbf{w}_j, b_j\}) = -\sum_{i=1}^N \ln p_{i, y_i}
= -\sum_{i=1}^N \left( \mathbf{w}_{y_i}^T \mathbf{x}_i + b_{y_i} - \ln \sum_{j=1}^C \exp(\mathbf{w}_j^T \mathbf{x}_i + b_j) \right)
$$

这称为**多类交叉熵损失（categorical cross-entropy）**。

### 梯度推导

对第 $k$ 类的权重向量 $\mathbf{w}_k$ 求梯度。利用 Softmax 的导数 $\partial p_{ik} / \partial (\mathbf{w}_k^T \mathbf{x}_i) = p_{ik} (1 - p_{ik})$ 以及 $\partial p_{ij} / \partial (\mathbf{w}_k^T \mathbf{x}_i) = -p_{ik} p_{ij}$（$j \neq k$），可得：

$$
\frac{\partial J}{\partial \mathbf{w}_k} = \sum_{i=1}^N (p_{ik} - \mathbb{I}[y_i = k]) \, \mathbf{x}_i
$$

这个形式与二分类逻辑回归的梯度 $(p_i - y_i) \mathbf{x}_i$ 完全一致——唯一的区别是现在对每个类别 $k$ 独立计算，每个样本对梯度的贡献取决于它是否属于该类。

### 与 MLE 的对应

Softmax + 交叉熵 = MLE for 多项分布（categorical distribution），正如：
- 线性回归 + 均方误差 = MLE for 高斯分布
- 逻辑回归 + 二分类交叉熵 = MLE for 伯努利分布

三种模型的损失函数都可以统一到"MLE + 数据分布假设"的框架下。

## 多类感知机 / 多类SVM（Crammer-Singer）

直接构造 $C$ 个权重向量 $\mathbf{w}_1, \dots, \mathbf{w}_C$，决策函数为 $g_k(\mathbf{x}) = \mathbf{w}_k^T \mathbf{x} + b_k$，预测类别 $\arg\max_k g_k(\mathbf{x})$。

训练时要求正确类别的得分比其他类别至少大一个间隔（通常取 $1$），损失函数为：

$$
\min_{\{\mathbf{w}_j, b_j\}} \sum_{i=1}^N \left[ \max_{k \neq y_i} \big( \mathbf{w}_k^T \mathbf{x}_i + b_k - (\mathbf{w}_{y_i}^T \mathbf{x}_i + b_{y_i}) + 1 \big) \right]_+
$$

其中 $[\cdot]_+ = \max(0, \cdot)$ 是合页损失（hinge loss）。这个损失鼓励正确类的得分高出所有错误类至少 1，对不满足约束的样本惩罚，满足的样本不产生损失。

多类 SVM 直接优化多类目标，理论上比 OvR/OvO 更一致，但变量数量为 $C \times (d + 1)$，优化更复杂。

## 方法对比

| 方法 | 分类器数量 | 输出形式 | 训练复杂度 | 适用场景 |
|------|-----------|---------|-----------|---------|
| OvR | $C$ | 得分（不可比） | 低 | 类别多、追求速度 |
| OvO | $C(C-1)/2$ | 投票数 | 中 | 类别少、样本量大 |
| Softmax | $1$ | 概率 | 中 | 需要概率输出、类别数中等 |
| 多类SVM | $1$ | 得分 | 高 | 追求精度、计算资源充足 |

选择策略没有绝对最优：类别数少且需要概率时 Softmax 是自然选择；类别数很多（如 >100）时 OvR 更实用；类别数很少（如 3-5）且追求精度时 OvO 值得一试。
