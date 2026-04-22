---
title: 线性代数：矩阵相关的知识点
published: 2025-09-14
description: '矩阵的计算，性质，分解等，基于主包的笔记'
image: ''
tags: [矩阵]
category: '线性代数'
draft: true
lang: ''
---

## 反对称矩阵 (Skew-symmetric Matrix)

反对称矩阵是指满足 $A^T = -A$ 的方阵 $A$。这意味着矩阵的转置等于其负值。
这是将“叉乘”转化为“矩阵乘法”的关键工具。

对于向量 $\mathbf{a} = [a_1, a_2, a_3]^T$，其反对称矩阵表示为：
$$
[\mathbf{a}]_{\times} = \begin{bmatrix}
0 & -a_3 & a_2 \\
a_3 & 0 & -a_1 \\
-a_2 & a_1 & 0
\end{bmatrix}
$$

**对角线**:全是 0因为向量自己叉乘自己等于 0。

$$
\mathbf{a} \times \mathbf{a} = [\mathbf{a}]_{\times} \mathbf{a} = \mathbf{0}
$$

**反对称性**：$[\mathbf{a}]_{\times}^T = -[\mathbf{a}]_{\times}$。也就是说，把矩阵转置（行列互换），结果正好符号相反。

**自由度**：虽然它是一个 $3 \times 3$ 的矩阵（9个元素），但它其实只由 3 个参数（$a_1, a_2, a_3$）控制。

**公式特性**：$\mathbf{a} \times \mathbf{b} = [\mathbf{a}]_{\times} \mathbf{b}$。

## 速度和位置的导数关系

在不同坐标系下，位置向量的微小变化（速度）可以相互转换

对于任何坐标系 $\mathcal{A}$，位置向量 $_\mathcal{A}\mathbf{r}_{AB}$ 和速度向量 $_\mathcal{A}\mathbf{V}_{AB}$ 满足：
$$
_\mathcal{A}\mathbf{V}_{AB} = \frac{d_\mathcal{A}\mathbf{r}_{AB}}{dt}= _\mathcal{A}\dot{\mathbf{r}}_{AB}
$$

而速度$\dot{r}$和当前**表示形式**下**位置**的导数$\chi_P$之间存在线性映射关系：
$$
\dot{r}=\mathbf{E}_P(\chi_P)\,\dot{\chi}_P
$$

### 柱坐标系下的映射

用$\chi_{Pz}$来表示柱坐标系下位置的堆积参数,建立柱坐标 $(\rho, \theta, z)$ 与笛卡尔坐标 $(x, y, z)$ 之间的位置关系$\mathbf{r}$：
$$x = \rho \cos \theta$$
$$y = \rho \sin \theta$$
$$z = z$$

写成向量式
$$
\mathbf{r}(\chi_{Pz}) = \begin{pmatrix} \rho \cos \theta \\ \rho \sin \theta \\ z \end{pmatrix}
$$

根据微积分的链式法则，速度 $\mathbf{\dot{r}}$（即笛卡尔坐标下的速度 $(\dot{x}, \dot{y}, \dot{z})^T$）可以表示为位置向量对时间的导数：
$$
\mathbf{\dot{r}} = \frac{d\mathbf{r}}{dt} = \frac{\partial \mathbf{r}}{\partial \chi_{Pz}} \frac{d\chi_{Pz}}{dt} = \mathbf{E}_{Pz}(\chi_{Pz}) \boldsymbol{\dot{\chi}}_{Pz}
$$

其中，$\mathbf{E}_{Pz}(\chi_{Pz})$ 就是雅可比矩阵，它的每一列分别是 $\mathbf{r}$ 对各个柱坐标变量的偏导数。

我们将 $\mathbf{r}$ 分别对 $\rho, \theta, z$ 求偏导：

对 $\rho$ 求偏导： $\frac{\partial \mathbf{r}}{\partial \rho} = \begin{pmatrix} \cos \theta \\ \sin \theta \\ 0 \end{pmatrix}$

对 $\theta$ 求偏导： $\frac{\partial \mathbf{r}}{\partial \theta} = \begin{pmatrix} -\rho \sin \theta \\ \rho \cos \theta \\ 0 \end{pmatrix}$

对 $z$ 求偏导： $\frac{\partial \mathbf{r}}{\partial z} = \begin{pmatrix} 0 \\ 0 \\ 1 \end{pmatrix}$

将这三列组合起来，就得到了映射矩阵 $\mathbf{E}_{Pz}$：

$$
\mathbf{E}_{Pz} = \begin{bmatrix} \cos \theta & -\rho \sin \theta & 0 \\ \sin \theta & \rho \cos \theta & 0 \\ 0 & 0 & 1 \end{bmatrix}
$$

这本质上是把笛卡尔坐标看作柱坐标的函数，然后求全微分

### 球坐标系下的映射

用$\chi_{Ps}$来表示球坐标系下位置的堆积参数,建立球坐标 $(r, \theta, \phi)$ 与笛卡尔坐标 $(x, y, z)$ 之间的位置关系$\mathbf{r}$：

$$x = r \sin \theta \cos \phi$$
$$y = r \sin \theta \sin \phi$$
$$z = r \cos \phi$$

写成向量式
$$
\mathbf{r}(\chi_{Ps}) = \begin{pmatrix} r \sin \theta \cos \phi \\ r \sin \theta \sin \phi \\ r \cos \phi \end{pmatrix}
$$

根据微积分的链式法则，速度 $\mathbf{\dot{r}}$（即笛卡尔坐标下的速度 $(\dot{x}, \dot{y}, \dot{z})^T$）可以表示为位置向量对时间的导数：
$$
\mathbf{\dot{r}} = \frac{d\mathbf{r}}{dt} = \frac{\partial \mathbf{r}}{\partial \chi_{Ps}} \frac{d\chi_{Ps}}{dt} = \mathbf{E}_{Ps}(\chi_{Ps}) \boldsymbol{\dot{\chi}}_{Ps}
$$

其中，$\mathbf{E}_{Ps}(\chi_{Ps})$ 就是雅可比矩阵，它的每一列分别是 $\mathbf{r}$ 对各个球坐标变量的偏导数。

我们将 $\mathbf{r}$ 分别对 $r, \theta, \phi$ 求偏导：

对 $r$ 求偏导： $\frac{\partial \mathbf{r}}{\partial r} = \begin{pmatrix} \sin \theta \cos \phi \\ \sin \theta \sin \phi \\ \cos \phi \end{pmatrix}$

对 $\theta$ 求偏导： $\frac{\partial \mathbf{r}}{\partial \theta} = \begin{pmatrix} r \cos \theta \cos \phi \\ r \cos \theta \sin \phi \\ 0 \end{pmatrix}$

对 $\phi$ 求偏导： $\frac{\partial \mathbf{r}}{\partial \phi} = \begin{pmatrix} -r \sin \theta \sin \phi \\ r \sin \theta \cos \phi \\ -r \sin \phi \end{pmatrix}$

将这三列组合起来，就得到了映射矩阵 $\mathbf{E}_{Ps}$：

$$
\mathbf{E}_{Ps} = \begin{bmatrix} \sin \theta \cos \phi & r \cos \theta \cos \phi & -r \sin \theta \sin \phi \\ \sin \theta \sin \phi & r \cos \theta \sin \phi & r \sin \theta \cos \phi \\ \cos \phi & 0 & -r \sin \phi \end{bmatrix}
$$