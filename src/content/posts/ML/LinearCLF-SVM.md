---
title: 模式识别与机器学习：线性分类器-支持向量机
published: 2026-05-28
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 5
draft: false 
lang: ''
---

针对普通感知机的三个问题：

实际上当样本可分时，会有无穷多种线性分类器

- (P1): 哪一个才是**最优线性分类器**
- (P2): 如何学习？
- (P3): 如何推广到线性不可分情形？

## 最优线性分类器-基本概念

定义1：**超平面**：

在 $d$ 维空间中，超平面是一个 $d-1$ 维的子空间，可以用一个线性方程来表示：$\mathbf{w}^T \mathbf{x} + b = 0$，其中 $\mathbf{w}$ 是法向量，$b$ 是偏置项。

定义2：点到超平面的**欧氏距离**：

对于一个线性分类器 $g(\mathbf{x})=\mathbf{w}^T \mathbf{x}+b$，点 $\mathbf{x}_0$ 到超平面的距离定义为：

$$
d(\mathbf{x}_0) = \frac{|g(\mathbf{x}_0)|}{\|\mathbf{w}\|}=\frac{|\mathbf{w}^T \mathbf{x}_0 + b|}{\sqrt{w_1^2 + w_2^2 + \ldots + w_d^2}}
$$

定义3：**分类间隔/几何距离/几何间隔/间隔**：对于一个线性分类器 $g(\mathbf{x})=\mathbf{w}^T \mathbf{x}+b$，分类间隔定义为：

$$
\gamma = \min_{i} \frac{y_i g(\mathbf{x}_i)}{\|\mathbf{w}\|} = \min_{i} \frac{y_i (\mathbf{w}^T \mathbf{x}_i + b)}{\sqrt{w_1^2 + w_2^2 + \ldots + w_d^2}}
$$

- 间隔 $\gamma$ 是所有训练样本点到超平面的距离的最小值。
- 其中 $y_i$ 是样本 $\mathbf{x}_i$ 的类别标签（通常为+1或-1）乘上去就是对样本做规范化。
- $\|\mathbf{w}\|$ 是权重向量的欧几里得范数。
- 分类间隔有正负，正数表示分类正确，负数表示分类错误。（对于规范化后的样本）

## 线性可分时的SVM=极小极大问题=最大化分类间隔

支持向量机（SVM）的核心思想是找到一个线性分类器，使得分类间隔 $\gamma$ 最大化。SVM 试图找到一个超平面，使得离它最近的训练样本点（即支持向量）与超平面的距离最大。

SVM 的优化问题可以表述为一个最大化分类间隔的**极小极大问题**：

$$
\begin{aligned}
& \underset{\mathbf{w}, b}{\text{maximize}} \quad \gamma = \min_{\mathbf{x}_i\in \mathcal{D}} \frac{y_i (\mathbf{w}^T \mathbf{x}_i + b)}{\|\mathbf{w}\|_2} \\
& \text{subject to} \quad y_i (\mathbf{w}^T \mathbf{x}_i + b) \geq 0, \quad \forall i
\end{aligned}
$$

- 注意这里是对所有训练样本 ($\mathbf{x}_i\in \mathcal{D}$) 的约束条件
- subject to 确保每个样本点都被正确分类。

做两点变换，等价但更易求解：

### 1. 让式子满足缩放不变性

即如果我们将 $\mathbf{w}$ 和 $b$ 同时乘以一个正数 $\alpha$，分类结果不变，但 $\gamma$ 会被放大 $\alpha$ 倍。为了消除这个问题，我们认为规定一个尺度：令最小的那个值等于 1：

$$
\text{subject to} \quad y_i (\mathbf{w}^T \mathbf{x}_i + b) \geq 1, \quad \forall i
$$

### 2. 方便求导

因为 $\gamma = \frac{1}{\|\mathbf{w}\|}$，这时候最大化 $\gamma$ 就等价于最小化 $\|\mathbf{w}\|$。因此，我们可以将优化问题转化为 $\frac{1}{2} \|\mathbf{w}\|_2^2$ 的形式，方便后续求导。

### 线性可分时的SVM原问题

$$
\begin{aligned}
& \underset{\mathbf{w}, b}{\text{minimize}} \quad \frac{1}{2} \|\mathbf{w}\|_2^2=\frac{1}{2} \sum_{i=1}^{n} w_i^2 \\
& \text{subject to}\quad 1- y_i (\mathbf{w}^T \mathbf{x}_i + b) \leq 0, \quad \forall i
\end{aligned}
$$

- 约束写成 $1- y_i (\mathbf{w}^T \mathbf{x}_i + b) \leq 0$ 是为了符合拉格朗日乘子法的标准形式。

:::tip

二次优化标准型：

$$
\begin{aligned}
& \underset{\mathbf{x}}{\text{minimize}} \quad \frac{1}{2} \mathbf{x}^T Q \mathbf{x} + \mathbf{c}^T \mathbf{x} \\
& \text{subject to} \quad A \mathbf{x} \leq \mathbf{b}
\end{aligned}
$$

:::

## 线性可分时SVM的求解

原问题中，需要对每个数据 $\mathbf{x}_i\in \mathcal{D}$ 都有一个约束条件，导致求解困难。我们引入拉格朗日乘子 $\alpha_i$ 来将约束条件合并到目标函数中：

### 线性可分SVM的拉格朗日函数

引入拉格朗日乘子 $\alpha_i \geq 0$，构造 **拉格朗日函数**：

$$
\begin{aligned}
L(\mathbf{w}, b, \boldsymbol{\alpha}) &= \frac{1}{2} \|\mathbf{w}\|_2^2 + \sum_{i=1}^{n} \alpha_i [1-y_i (\mathbf{w}^T \mathbf{x}_i + b)] \\
&= \frac{1}{2} \|\mathbf{w}\|_2^2 + \sum_{i=1}^{n} \alpha_i - \sum_{i=1}^{n} \alpha_i y_i (\mathbf{w}^T \mathbf{x}_i + b)
\end{aligned}
$$

### 线性可分SVM的对偶问题

得到原问题的 **对偶问题**，即对于 **拉格朗日函数** 的 **最大最小问题**：

- 先对 $\mathbf{w}$ 和 $b$ 求最小化
- 再对 $\boldsymbol{\alpha}$ 求最大化：

$$
\begin{aligned}
& \underset{\boldsymbol{\alpha} \geq 0}{\text{max}} \quad \underset{\mathbf{w}, b}{\text{min}} \quad L(\mathbf{w}, b, \boldsymbol{\alpha})\\
& \underset{\boldsymbol{\alpha} \geq 0}{\text{max}} \quad \underset{\mathbf{w}, b}{\text{min}} \quad \left( \frac{1}{2} \|\mathbf{w}\|_2^2 + \sum_{i=1}^{n} \alpha_i - \sum_{i=1}^{n} \alpha_i y_i (\mathbf{w}^T \mathbf{x}_i + b) \right)
\end{aligned}
$$

### 线性可分SVM的目标函数

对 $\mathbf{w}$ 和 $b$ 求导并令其为零：

$$
\begin{aligned}
&\frac{\partial L(\mathbf{w}, b, \boldsymbol{\alpha})}{\partial \mathbf{w}} = \mathbf{w} - \sum_{i=1}^{n} \alpha_i y_i \mathbf{x}_i = 0 &\Rightarrow  \mathbf{w} = \sum_{i=1}^{n} \alpha_i y_i \mathbf{x}_i \\
&\frac{\partial L(\mathbf{w}, b, \boldsymbol{\alpha})}{\partial b} = -\sum_{i=1}^{n} \alpha_i y_i = 0  &\Rightarrow \sum_{i=1}^{n} \alpha_i y_i = 0
\end{aligned}
$$

加上TTK条件，代入拉格朗日函数中，得到对偶问题的 **目标函数**：

$$
\boxed{
\begin{aligned}
& \underset{\boldsymbol{\alpha} \geq 0}{\text{max}} \quad L(\boldsymbol{\alpha}) = \sum_{i=1}^{n} \alpha_i - \frac{1}{2} \sum_{i=1}^{n} \sum_{j=1}^{n} \alpha_i \alpha_j y_i y_j \mathbf{x}_i^T \mathbf{x}_j \\
& \text{subject to} \quad \sum_{i=1}^{n} \alpha_i y_i = 0, \quad \alpha_i \geq 0, \quad \forall i
\end{aligned}
}
$$

- 这是一个**凸二次优化问题**

极大化目标函数 $L(\boldsymbol{\alpha})$ 等价于极小化 $-\sum_{i=1}^{n} \alpha_i + \frac{1}{2} \sum_{i=1}^{n} \sum_{j=1}^{n} \alpha_i \alpha_j y_i y_j \mathbf{x}_i^T \mathbf{x}_j$，可以用梯度下降，因此写成：

$$
\boxed{
\begin{aligned}
& \underset{\boldsymbol{\alpha} \geq 0}{\text{min}} \quad \frac{1}{2} \sum_{i=1}^{n} \sum_{j=1}^{n} \alpha_i \alpha_j y_i y_j \mathbf{x}_i^T \mathbf{x}_j - \sum_{i=1}^{n} \alpha_i \\
& \text{subject to} \quad \sum_{i=1}^{n} \alpha_i y_i = 0, \quad \alpha_i \geq 0, \quad \forall i
\end{aligned}
}
$$

### 从对偶问题的解恢复原问题的解

该优化问题的解 $\boldsymbol{\alpha}^*=(\alpha_1^*, \alpha_2^*, \ldots, \alpha_n^*)^T$ 可以用来恢复原问题的解 $\mathbf{w}^*$ 和 $b^*$：

根据KKT条件中的原问题可行性条件+互补松弛条件，定义 **支持向量**：

$$
\mathbf{x}_i \text{ 是支持向量} \iff y_i(\mathbf{w}^T \mathbf{x}_i + b)= 1 \text{ 且 } \alpha_i > 0
$$

- 支持向量是那些距离超平面 **最近** 的训练样本点。

- 支持向量 $\mathbf{x}_s$ 加上其对应的拉格朗日乘子 $\alpha_i^*$ 可以求出权重向量
  - $\mathbf{w}^*=\sum_{i=1}^{n} \alpha_i^* y_i \mathbf{x}_i$
- 偏置项 $b^*$ 用任意一个支持向量 $\mathbf{x}_s$ 来计算：
  - $b^* = y_s - \mathbf{w}^{*T} \mathbf{x}_s$

- 其他非支持向量的 $\alpha_i^*$ 都为零，对最终的分类器没有贡献。决策函数只由支持向量决定。

## 不完全线性可分时的软间隔SVM=引入松弛变量=惩罚分类错误

当训练数据不完全线性可分时，我们引入**松弛变量** $\epsilon_i \geq 0$ 来允许某些样本点违反分类约束。新的优化问题称为**软间隔SVM**：

参考线性可分的问题思路，线性不可分情况的 **原问题**：

$$
\begin{aligned}
& \underset{\mathbf{w}, b, \boldsymbol{\epsilon}}{\text{minimize}} \quad \frac{1}{2} \|\mathbf{w}\|_2^2 + C \sum_{i=1}^{n} \epsilon_i \\
& \text{subject to} \quad y_i (\mathbf{w}^T \mathbf{x}_i + b) \geq 1 - \epsilon_i, \quad \epsilon_i \geq 0, \quad \forall i\\
\end{aligned}
$$

- 其中 $C > 0$ 是一个超参数，控制分类错误的惩罚程度。
- $\epsilon_i$ 是第 $i$ 个样本的松弛变量，表示该样本点违反分类约束的程度。
- 写成 $1-\epsilon_i - y_i (\mathbf{w}^T \mathbf{x}_i + b) \leq 0$ 是为了符合拉格朗日乘子法的标准形式。

$\epsilon_i$ 的两种选择：

1. 定义为分类错误的个数，但这个定义不可导，无法使用梯度方法求解。
2. 定义为分类错误的程度，即 $\epsilon_i = \max(0, 1 - y_i (\mathbf{w}^T \mathbf{x}_i + b))$，这个定义是可导的，可以使用梯度方法求解。

:::tip

这个其实借鉴了感知机的损失函数，称为**合页损失**（Hinge Loss）：

:::

省略推导，直接给出**目标函数**：

$$
\boxed{
\begin{aligned}
& \underset{\boldsymbol{\alpha}}{\text{min}} \quad L(\boldsymbol{\alpha}) =  \frac{1}{2} \sum_{i=1}^{n} \sum_{j=1}^{n} \alpha_i \alpha_j y_i y_j \mathbf{x}_i^T \mathbf{x}_j -\sum_{i=1}^{n} \alpha_i \\
& \text{subject to} \quad \sum_{i=1}^{n} \alpha_i y_i = 0, \quad 0 \leq \alpha_i \leq C, \quad \forall i
\end{aligned}
}
$$

- 软间隔SVM的对偶问题与线性可分时的SVM非常相似，唯一的区别是 $\alpha_i$ 的约束从 $\alpha_i \geq 0$ 变为 $0 \leq \alpha_i \leq C$。

设 $\alpha_i^*=(\alpha_1^*, \alpha_2^*, \ldots, \alpha_n^*)^T$ 是软间隔SVM对偶问题的最优解，那么原问题的解 $\mathbf{w}^*$ 和 $b^*$ 可以通过以下方式恢复：

$$
\begin{aligned}
& \mathbf{w}^* = \sum_{i=1}^{n} \alpha_i^* y_i \mathbf{x}_i \\
& b^* = y_s - \mathbf{w}^{*T} \mathbf{x}_s \quad \text{（任意一个满足 $0 < \alpha_s^* < C$ 的样本点 $\mathbf{x}_s$）}
\end{aligned}
$$

由于 $b^*$ 的值可能不唯一，实际可以通过所有满足 $0 < \alpha_i^* < C$ 的样本点来计算 $b^*$，然后取平均值。

## 线性不可分时的SVM=引入核函数隐式映射到高维空间

线性不可分时的SVM可以通过引入 **核函数** 来实现非线性分类。核函数 $K(\mathbf{x}_i, \mathbf{x}_j)$ 定义了输入空间中的两个样本点 $\mathbf{x}_i$ 和 $\mathbf{x}_j$ 在某个隐式映射到 **高维特征空间** 后的内积。

还是省略对偶问题的推导细节，直接给出引入核函数后的对偶问题目标函数：

$$
\boxed{
\begin{aligned}
& \underset{\boldsymbol{\alpha}}{\text{min}} \quad L(\boldsymbol{\alpha}) = \frac{1}{2} \sum_{i=1}^{n} \sum_{j=1}^{n} \alpha_i \alpha_j y_i y_j K(\mathbf{x}_i, \mathbf{x}_j)-\sum_{i=1}^{n} \alpha_i  \\
& \text{subject to} \quad \sum_{i=1}^{n} \alpha_i y_i = 0, \quad 0 \leq \alpha_i \leq C, \quad \forall i
\end{aligned}
}
$$

$$
K(\mathbf{x}_i, \mathbf{x}_j) = \phi(\mathbf{x}_i)^T \phi(\mathbf{x}_j)
$$

- 其中 $\phi(\cdot)$ 是一个隐式映射函数，将输入空间中的样本点映射到一个高维特征空间。

常用的核函数包括：

- 多项式核：$K(\mathbf{x}_i, \mathbf{x}_j) = (\mathbf{x}_i^T \mathbf{x}_j + c)^d$

- 高斯核（RBF）：$K(\mathbf{x}_i, \mathbf{x}_j) = \exp(-\dfrac{\|\mathbf{x}_i - \mathbf{x}_j\|_2^2}{2\sigma^2} )$

## SVM不用增广

偏置项 $b$ 不能吸收进权重向量 $\mathbf{w}$

如果使用增广的权重向量 $\mathbf{w}' = [\mathbf{w}; b]$，那么目标函数 $\min\frac{1}{2} \|\mathbf{w}'\|_2^2 = \frac{1}{2} (\|\mathbf{w}\|_2^2 + b^2)$ 会导致偏置项 $b$ 也被最小化。

并且后面拉格朗日函数没法对 $b$ 求导，因为 $b$ 也被包含在 $\mathbf{w}'$ 中了。直接少了对 $b$ 的约束条件 $\sum_{i=1}^{n} \alpha_i y_i = 0$，导致求解的结果不正确。
