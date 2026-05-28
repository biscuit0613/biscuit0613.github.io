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

- 其中 $y_i$ 是样本 $\mathbf{x}_i$ 的类别标签（通常为+1或-1）
- $\|\mathbf{w}\|$ 是权重向量的欧几里得范数。
- 分类间隔有正负，正数表示分类正确，负数表示分类错误。

## SVM=极小极大问题=最大化分类间隔

支持向量机（SVM）的核心思想是找到一个线性分类器，使得分类间隔 $\gamma$ 最大化。换句话说，SVM 试图找到一个超平面，使得离它最近的训练样本点（即支持向量）与超平面的距离最大。

数学上，SVM 的优化问题可以表述为：

$$
\begin{aligned}
& \underset{\mathbf{w}, b}{\text{maximize}} \quad \gamma = \min_{i} \frac{y_i (\mathbf{w}^T \mathbf{x}_i + b)}{\|\mathbf{w}\|} \\
& \text{subject to} \quad y_i (\mathbf{w}^T \mathbf{x}_i + b) \geq 1, \quad \forall i
\end{aligned}
$$

注意这里是对所有训练样本的约束条件，确保每个样本点都被正确分类，并且距离超平面至少为1。

此时简化为：

$$
\begin{aligned}
& \underset{\mathbf{w}, b}{\text{minimize}} \quad \frac{1}{2} \|\mathbf{w}\|^2=\sum_{i=1}^{n} w_i^2 \\
& \text{subject to} \quad y_i (\mathbf{w}^T \mathbf{x}_i + b) \geq 1, \quad \forall i
\end{aligned}
$$
