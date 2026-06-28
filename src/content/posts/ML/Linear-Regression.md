---
title: 模式识别与机器学习：线性回归
published: 2026-06-25
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 4
draft: false 
lang: ''
---

至此，我们看到两种做分类的路径：Bayes 判别（生成式，需要建模概率密度）和线性分类器（判别式，直接找决策边界）。但在进入分类的讨论之前，有一个更基础的问题——如果输出不是类别标签，而是一个连续值呢？比如根据房屋面积预测房价、根据学习时长预测考试成绩。这类问题称为**回归**，而线性回归是其中最简单的模型。

## 问题定义

给定训练集 $\{(\mathbf{x}_i, y_i)\}_{i=1}^{N}$，其中：

- $\mathbf{x}_i = (x_{i1}, x_{i2}, \dots, x_{id})^T \in \mathbb{R}^d$ 是第 $i$ 个样本的特征向量
- $y_i \in \mathbb{R}$ 是第 $i$ 个样本的**连续值标签**（不同于分类的离散标签）

线性回归假设输出与特征之间存在线性关系：

$$
\hat{y}_i = \mathbf{w}^T \mathbf{x}_i + b,\quad i = 1, 2, \dots, N
$$

为了符号简洁，通常将偏置 $b$ 吸收进权重向量：扩展 $\mathbf{w}' = (w_1, \dots, w_d, b)^T$，$\mathbf{x}'_i = (x_{i1}, \dots, x_{id}, 1)^T$，则模型简化为：

$$
\hat{y}_i = \mathbf{w}^T \mathbf{x}_i
$$

（下文中 $\mathbf{w}$ 和 $\mathbf{x}_i$ 均指增广后的形式。）

## 最小二乘估计（Ordinary Least Squares）

### 损失函数

衡量预测值 $\hat{y}_i$ 与真实值 $y_i$ 之间的差距，最常用的指标是**均方误差（MSE）**。写成矩阵形式更简洁——将所有训练样本堆叠为一个矩阵 $\mathbf{X} \in \mathbb{R}^{N \times (d+1)}$（每行一个样本），标签记为向量 $\mathbf{y} \in \mathbb{R}^N$：

$$
J(\mathbf{w}) = \frac{1}{2} \sum_{i=1}^{N} (\mathbf{w}^T \mathbf{x}_i - y_i)^2 = \frac{1}{2} \| \mathbf{X} \mathbf{w} - \mathbf{y} \|_2^2
$$

前面的系数 $\frac{1}{2}$ 是为后续求导方便添加的，不影响最优解。

### 闭式解推导

$J(\mathbf{w})$ 是关于 $\mathbf{w}$ 的凸二次函数，最小值在梯度为零处取得：

$$
\nabla J(\mathbf{w}) = \mathbf{X}^T (\mathbf{X} \mathbf{w} - \mathbf{y}) = \mathbf{0}
$$

展开：

$$
\mathbf{X}^T \mathbf{X} \mathbf{w} = \mathbf{X}^T \mathbf{y}
$$

这称为**正规方程（normal equation）**。当 $\mathbf{X}^T \mathbf{X}$ 可逆时，有唯一的闭式解：

$$
\hat{\mathbf{w}}_{\text{OLS}} = (\mathbf{X}^T \mathbf{X})^{-1} \mathbf{X}^T \mathbf{y}
$$

$\mathbf{X}^T \mathbf{X}$ 可逆的条件是特征之间不共线且样本数 $N$ 大于特征维数 $d$。不满足时，解不唯一。

### 几何意义

从几何角度看，$\mathbf{X} \hat{\mathbf{w}}$ 是 $\mathbf{y}$ 在 $\mathbf{X}$ 的列空间上的正交投影，OLS 解使残差向量 $\mathbf{y} - \mathbf{X} \hat{\mathbf{w}}$ 与所有特征列正交。这也是"最小二乘"名称的来源——它在所有线性模型中使预测误差的欧几里得范数最小。

## Ridge 回归（L2 正则化）

OLS 在特征维数较高或样本较少时容易过拟合——参数 $\mathbf{w}$ 的取值会变得很大，对噪声极度敏感。**Ridge 回归**在损失函数中加入 L2 惩罚项 $\|\mathbf{w}\|_2^2$：

$$
J(\mathbf{w}) = \frac{1}{2} \| \mathbf{X} \mathbf{w} - \mathbf{y} \|_2^2 + \frac{\lambda}{2} \| \mathbf{w} \|_2^2
$$

其中 $\lambda > 0$ 是正则化系数，控制惩罚强度。

**闭式解推导**：

$$
\nabla J(\mathbf{w}) = \mathbf{X}^T (\mathbf{X} \mathbf{w} - \mathbf{y}) + \lambda \mathbf{w} = \mathbf{0}
$$

整理得：

$$
(\mathbf{X}^T \mathbf{X} + \lambda \mathbf{I}) \mathbf{w} = \mathbf{X}^T \mathbf{y}
$$

$$
\hat{\mathbf{w}}_{\text{Ridge}} = (\mathbf{X}^T \mathbf{X} + \lambda \mathbf{I})^{-1} \mathbf{X}^T \mathbf{y}
$$

与 OLS 唯一的区别是在 $\mathbf{X}^T \mathbf{X}$ 上加了一个 $\lambda \mathbf{I}$。这保证了即使 $\mathbf{X}^T \mathbf{X}$ 不可逆，$(\mathbf{X}^T \mathbf{X} + \lambda \mathbf{I})$ 也总是可逆的。

### 与 MAP 估计的联系

Ridge 回归可以解释为：对参数 $\mathbf{w}$ 引入均值为 $\mathbf{0}$、协方差为 $\frac{1}{\lambda} \mathbf{I}$ 的高斯先验 $\mathbf{w} \sim \mathcal{N}(\mathbf{0}, \frac{1}{\lambda} \mathbf{I})$，然后做最大后验估计（MAP）。这与 Estimation 章中"高斯先验 → L2 正则化"的结论一致。

## Lasso 回归（L1 正则化）

Lasso 将 L2 惩罚替换为 L1 惩罚：

$$
J(\mathbf{w}) = \frac{1}{2} \| \mathbf{X} \mathbf{w} - \mathbf{y} \|_2^2 + \lambda \| \mathbf{w} \|_1
$$

L1 惩罚的一个重要性质是：它倾向于将部分权重精确压缩到零，产生**稀疏解**。这等价于特征选择——哪些特征对应的权重非零，哪些特征就被模型保留。

Lasso 没有闭式解，通常用坐标下降或近端梯度法求解。这与 OLS 和 Ridge 不同——后两者直接代入公式就能得到答案。

从 MAP 视角看，Lasso 等价于对 $\mathbf{w}$ 引入拉普拉斯先验（Laplace prior），详见 Estimation 章的相关讨论。

## 偏差-方差视角

OLS 和 Ridge 的差异可以用回归上下文中的偏差-方差分解来理解：

对于任意估计量 $\hat{\mathbf{w}}$，新样本 $\mathbf{x}$ 上的期望测试误差可以分解为：

$$
\mathbb{E}[(\mathbf{x}^T \hat{\mathbf{w}} - \mathbf{x}^T \mathbf{w}^*)^2] = \underbrace{(\mathbb{E}[\mathbf{x}^T \hat{\mathbf{w}}] - \mathbf{x}^T \mathbf{w}^*)^2}_{\text{Bias}^2} + \underbrace{\text{Var}(\mathbf{x}^T \hat{\mathbf{w}})}_{\text{Variance}}
$$

对比 OLS 和 Ridge：

| 方法 | 偏差 | 方差 | 说明 |
|------|------|------|------|
| OLS | 无偏（$\mathbb{E}[\hat{\mathbf{w}}] = \mathbf{w}^*$） | 高 | 完全依赖训练数据，样本少时波动大 |
| Ridge | 有偏（$\hat{\mathbf{w}}$ 被拉向零） | 比 OLS 低 | 牺牲无偏性换取稳定性 |
| Lasso | 有偏 | 同量级更低（部分系数强制为零） | 稀疏性进一步降低方差 |

$\lambda$ 控制这个折中：$\lambda=0$ 退化为 OLS（无偏但高方差）；$\lambda$ 增大，偏差上升、方差下降。适当的 $\lambda$ 能使总体测试误差低于 OLS——这是正则化能够提升泛化性能的根本原因。

## 与分类的桥梁

线性回归虽然做的是回归任务，但它求解参数的思想直接衍生出了分类领域的两个方法：

- **LMSE（最小均方误差分类器）**：将分类标签视作 $\pm 1$ 的实数目标值，直接用线性回归的框架求解。其闭式解与 OLS 形式完全一致。
- **逻辑回归**：在线性回归的输出上套一个 Sigmoid 函数，将连续输出映射到概率。损失函数从均方误差改为交叉熵。

前者在下一节处理，后者在逻辑回归一节展开。

## 小结

线性回归是整个"线性模型"的基础。它的核心部件——定义模型、设计损失函数、求解闭式解/梯度下降、引入正则化——会在后续每个模型中反复出现。理解 OLS→Ridge→Lasso 这条线，也就理解了"如何通过正则化控制模型复杂度"这个贯穿机器学习的核心思想。
