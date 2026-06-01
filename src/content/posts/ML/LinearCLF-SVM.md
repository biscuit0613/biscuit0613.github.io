---
title: 模式识别与机器学习：线性分类器-支持向量机
published: 2026-05-28
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
draft: false 
lang: ''
---

针对普通感知机的三个问题：

实际上当样本可分时，会有无穷多种线性分类器

- (P1): 哪一个才是**最优线性分类器**
- (P2): 如何学习？
- (P3): 如何推广到线性不可分情形？

## 最优线性分类器-最优在哪

定义1：点到超平面的欧氏距离：

对于一个线性分类器 $g(\mathbf{x})=\mathbf{w}^T \mathbf{x}+b$，点 $\mathbf{x}_0$ 到超平面的距离定义为：

$$
d(\mathbf{x}_0) = \frac{|g(\mathbf{x}_0)|}{\|\mathbf{w}\|}=\frac{|\mathbf{w}^T \mathbf{x}_0 + b|}{\sqrt{w_1^2 + w_2^2 + \ldots + w_d^2}}
$$

定义2：**分类间隔/几何距离/几何间隔/间隔**：对于一个线性分类器 $g(\mathbf{x})=\mathbf{w}^T \mathbf{x}+b$，分类间隔定义为：

$$
\gamma = \min_{i} \frac{y_i g(\mathbf{x}_i)}{\|\mathbf{w}\|} = \min_{i} \frac{y_i (\mathbf{w}^T \mathbf{x}_i + b)}{\sqrt{w_1^2 + w_2^2 + \ldots + w_d^2}}
$$

- 间隔 $\gamma$ 是所有训练样本点到超平面的距离的最小值。
- 其中 $y_i$ 是样本 $\mathbf{x}_i$ 的类别标签（通常为+1或-1）
- $\|\mathbf{w}\|$ 是权重向量的欧几里得范数。
- 分类间隔有正负，正数表示分类正确，负数表示分类错误。

## 线性可分时的SVM=极小极大问题=最大化分类间隔

支持向量机（SVM）的核心思想是找到一个线性分类器，使得分类间隔 $\gamma$ 最大化。换句话说，SVM 试图找到一个超平面，使得离它最近的训练样本点（即支持向量）与超平面的距离最大。

数学上，SVM 的优化问题可以表述为一个最大化分类间隔的**极小极大问题**：

$$
\begin{aligned}
& \underset{\mathbf{w}, b}{\text{maximize}} \quad \gamma = \min_{\mathbf{x}_i\in \mathcal{D}} \frac{y_i (\mathbf{w}^T \mathbf{x}_i + b)}{\|\mathbf{w}\|_2} \\
& \text{subject to} \quad y_i (\mathbf{w}^T \mathbf{x}_i + b) \geq 0, \quad \forall i
\end{aligned}
$$

- 注意这里是对所有训练样本 ($\mathbf{x}_i\in \mathcal{D}$) 的约束条件
- subject to 确保每个样本点都被正确分类。

但是这个式子不满足缩放不变性，即如果我们将 $\mathbf{w}$ 和 $b$ 同时乘以一个正数 $\alpha$，分类结果不变，但 $\gamma$ 会被放大 $\alpha$ 倍。为了消除这个问题，我们认为规定一个尺度：令最小的那个值等于 1：

$$
\text{subject to} \quad y_i (\mathbf{w}^T \mathbf{x}_i + b) \geq 1, \quad \forall i
$$

这时候最大化 $\gamma$ 就等价于最小化 $\|\mathbf{w}\|$，因为 $\gamma = \frac{1}{\|\mathbf{w}\|}$。因此，我们可以将优化问题转化为：

$$
\begin{aligned}
& \underset{\mathbf{w}, b}{\text{minimize}} \quad \frac{1}{2} \|\mathbf{w}\|_2^2=\sum_{i=1}^{n} w_i^2 \\
& \text{subject to} \quad y_i (\mathbf{w}^T \mathbf{x}_i + b) \geq 1, \quad \forall i
\end{aligned}
$$

- 写成平方还有系数 $\frac{1}{2}$ 是为了方便后续求导。

这是一个**凸二次优化问题** (QP: 目标函数是二次函数，约束是线性等式或
不等式)，可以通过拉格朗日乘子法求解。

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

原问题中，需要对每个数据 $x_i\in \mathcal{D}$ 都有一个约束条件，导致求解困难。我们引入拉格朗日乘子 $\alpha_i$ 来将约束条件合并到目标函数中：

### SVM的拉格朗日对偶函数和对偶问题

对每个约束写成 $y_i (\mathbf{w}^T \mathbf{x}_i + b)-1 \geq 0$，引入拉格朗日乘子 $\alpha_i \geq 0$，构造拉格朗日函数：

$$
\begin{aligned}
L(\mathbf{w}, b, \boldsymbol{\alpha}) &= \frac{1}{2} \|\mathbf{w}\|_2^2 + \sum_{i=1}^{n} \alpha_i [y_i (\mathbf{w}^T \mathbf{x}_i + b) - 1] \\
&= \frac{1}{2} \|\mathbf{w}\|_2^2 - \sum_{i=1}^{n} \alpha_i + \sum_{i=1}^{n} \alpha_i y_i (\mathbf{w}^T \mathbf{x}_i + b)
\end{aligned}
$$

拉格朗日对偶问题，对于拉格朗日函数的最大最小问题：

$$
\begin{aligned}
& \underset{\boldsymbol{\alpha} \geq 0}{\text{max}} \quad \underset{\mathbf{w}, b}{\text{min}} \quad L(\mathbf{w}, b, \boldsymbol{\alpha})\\
& \underset{\boldsymbol{\alpha} \geq 0}{\text{max}} \quad \underset{\mathbf{w}, b}{\text{min}} \quad \left( \frac{1}{2} \|\mathbf{w}\|_2^2 - \sum_{i=1}^{n} \alpha_i + \sum_{i=1}^{n} \alpha_i y_i (\mathbf{w}^T \mathbf{x}_i + b) \right)
\end{aligned}
$$

### 求解对偶问题

对 $\mathbf{w}$ 和 $b$ 求导并令其为零：

$$
\begin{aligned}
& \frac{\partial L(\mathbf{w}, b, \boldsymbol{\alpha})}{\partial \mathbf{w}} = \mathbf{w} - \sum_{i=1}^{n} \alpha_i y_i \mathbf{x}_i = 0 \quad \Rightarrow \quad \mathbf{w} = \sum_{i=1}^{n} \alpha_i y_i \mathbf{x}_i \\
& \frac{\partial L(\mathbf{w}, b, \boldsymbol{\alpha})}{\partial b} = \sum_{i=1}^{n} \alpha_i y_i = 0
\end{aligned}
$$

加上TTK条件，代入拉格朗日函数中，得到对偶问题的目标函数：

$$
\begin{aligned}
& \underset{\boldsymbol{\alpha} \geq 0}{\text{max}} \quad L(\boldsymbol{\alpha}) = \sum_{i=1}^{n} \alpha_i - \frac{1}{2} \sum_{i=1}^{n} \sum_{j=1}^{n} \alpha_i \alpha_j y_i y_j \mathbf{x}_i^T \mathbf{x}_j \\
& \text{subject to} \quad \sum_{i=1}^{n} \alpha_i y_i = 0, \quad \alpha_i \geq 0, \quad \forall i
\end{aligned}
$$

- 这是一个**凸二次优化问题**，可以通过标准的QP求解器求解。

### 从对偶问题的解恢复原问题的解

之前的大于等于1的约束可以分成大于约束和等于约束两部分：

$$
\begin{aligned}
& y_i (\mathbf{w}^T \mathbf{x}_i + b) > 1 \quad \text{（非支持向量）} \\
& y_i (\mathbf{w}^T \mathbf{x}_i + b) = 1 \quad \text{（支持向量）}
\end{aligned}
$$

根据KKT条件中的原问题可行性条件+互补松弛条件，定义 **支持向量**：

$$
\mathbf{x}_i \text{ 是支持向量} \iff y_i(\mathbf{w}^T \mathbf{x}_i + b)= 1 \text{ 且 } \alpha_i > 0
$$

- 支持向量是那些距离超平面最近的训练样本点。

- 支持向量 $\mathbf{x}_i$ 加上其对应的拉格朗日乘子 $\alpha_i$ 可以求出权重向量 $\mathbf{w}=\sum_{i=1}^{n} \alpha_i y_i \mathbf{x}_i$
- 偏置项 $b$ 用任意一个支持向量 $\mathbf{x}_s$ 来计算：$b = y_s - \mathbf{w}^T \mathbf{x}_s$

- 其他非支持向量的 $\alpha_i$ 都为零，对最终的分类器没有贡献。决策函数只由支持向量决定。

## 线性不可分时的软间隔SVM=引入松弛变量=惩罚分类错误

当训练数据线性不可分时，我们引入**松弛变量** $\epsilon_i \geq 0$ 来允许某些样本点违反分类约束。新的优化问题称为**软间隔SVM**：

参考线性可分的问题转化思路，线性不可分问题最终是优化

$$
\begin{aligned}
& \underset{\mathbf{w}, b, \boldsymbol{\epsilon}}{\text{minimize}} \quad \frac{1}{2} \|\mathbf{w}\|_2^2 + C \sum_{i=1}^{n} \epsilon_i \\
& \text{subject to} \quad y_i (\mathbf{w}^T \mathbf{x}_i + b) \geq 1 - \epsilon_i, \quad \epsilon_i \geq 0, \quad \forall i
\end{aligned}
$$

- 其中 $C > 0$ 是一个超参数，控制分类错误的惩罚程度。
- $\epsilon_i$ 是第 $i$ 个样本的松弛变量，表示该样本点违反分类约束的程度。

$\epsilon_i$ 的两种选择：

1. 定义为分类错误的个数，但这个定义不可导，无法使用梯度方法求解。
2. 定义为分类错误的程度，即 $\epsilon_i = \max(0, 1 - y_i (\mathbf{w}^T \mathbf{x}_i + b))$，这个定义是可导的，可以使用梯度方法求解。

:::tip

这个其实借鉴了感知机的损失函数，称为**合页损失**（Hinge Loss）：

:::

然后引入拉格朗日乘子 $\alpha_i$ 和 $\mu_i$ 来构造拉格朗日函数，求解对偶问题，最终得到软间隔SVM的决策函数和支持向量的定义。
