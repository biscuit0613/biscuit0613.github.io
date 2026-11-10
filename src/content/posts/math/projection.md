---
title: 向量投影
published: 2026-04-07
description: ' 向量投影的定义、计算方法以及一些注意事项。'
image: ''
tags: []
category: '线性代数'
draft: false 
lang: ''
---

## 几何直观

有两个向量 $\mathbf{a}$ 和 $\mathbf{b}$。从 $\mathbf{b}$ 的终点向 $\mathbf{a}$ 所在的直线做一条垂线，垂足与原点之间的这段向量，就是 $\mathbf{b}$ 在 $\mathbf{a}$ 方向上的投影向量（记作 $\text{proj}_{\mathbf{a}} \mathbf{b}$）。

- 投影的长度（标量）：即 $\mathbf{b}$ 在 $\mathbf{a}$ 方向上的“影子”长度。

- 投影的性质：投影向量与被投向的向量 $\mathbf{a}$ 是共线的。

## 关于二维投影的计算

:::tip
$$
\begin{aligned}
  \langle \mathbf{a}, \mathbf{b} \rangle &= \mathbf{a} \cdot \mathbf{b} \\
  &= a_1b_1 + a_2b_2 + \dots + a_nb_n \\
&= \mathbf{a}^T \mathbf{b}=\mathbf{b}^T \mathbf{a}  
\end{aligned}
$$
:::

投影的长度 $d$ 为：

$$
d = \|\mathbf{b}\| \cos \theta
$$

根据点积定义 $\mathbf{a} \cdot \mathbf{b} = \|\mathbf{a}\| \|\mathbf{b}\| \cos \theta$，可以写出：

$$
d = \frac{\mathbf{a} \cdot \mathbf{b}}{\|\mathbf{a}\|}
$$

投影向量的方向和 $\mathbf{a}$ 一致，所以用长度 $d$ 乘以 $\mathbf{a}$ 的单位向量 $\frac{\mathbf{a}}{\|\mathbf{a}\|}$：

$$
\text{proj}_{\mathbf{a}} \mathbf{b} = \left( \frac{\mathbf{a} \cdot \mathbf{b}}{\|\mathbf{a}\|} \right) \frac{\mathbf{a}}{\|\mathbf{a}\|} = \frac{\mathbf{a} \cdot \mathbf{b}}{\|\mathbf{a}\|^2} \mathbf{a}
$$

由于 $\|\mathbf{a}\|^2 = \mathbf{a}^T \mathbf{a}$ 且 $\mathbf{a} \cdot \mathbf{b} = \mathbf{a}^T \mathbf{b}$，我们可以重写公式：

$$
\text{proj}_{\mathbf{a}} \mathbf{b} = \frac{\mathbf{a} \mathbf{a}^T}{\mathbf{a}^T \mathbf{a}} \mathbf{b}
$$

这里 $P = \frac{\mathbf{a} \mathbf{a}^T}{\mathbf{a}^T \mathbf{a}}$ 被称为投影矩阵。

## 投影到子空间

有一个 $k$ 维子空间 $W$，由 $k$ 个线性无关的向量 $\{\mathbf{w}_1, \mathbf{w}_2, \dots, \mathbf{w}_k\}$ 生成，记作 $A=[\mathbf{w}_1, \mathbf{w}_2, \dots, \mathbf{w}_k]$。对于任意向量 $\mathbf{b}$，我们想找到它在 $W$ 上的投影 $\text{proj}_W \mathbf{b}$。

也就是说，我们要找到 $W$ 中的一个向量 $\mathbf{p}=A\mathbf{x}$，使得 $\mathbf{p}$ 与 $\mathbf{b}$ 之间的距离最小：

$$
\text{proj}_W \mathbf{b} = \argmin_{\mathbf{p} \in W} \|\mathbf{b} -A \mathbf{x}\|_2^2
$$

这是关于变量 $\mathbf{x}$ 的无约束优化问题。通过求导并设为零，我们可以得到：

$$
\begin{aligned}
\frac{\partial}{\partial \mathbf{x}} \|\mathbf{b} - A \mathbf{x}\|_2^2
&= \frac{\partial}{\partial \mathbf{x}} (\mathbf{b} - A \mathbf{x})^T (\mathbf{b} - A \mathbf{x}) \\
&= \frac{\partial }{\partial \mathbf{x}} \left( \mathbf{b}^T \mathbf{b} - 2 \mathbf{b}^T A \mathbf{x} + \mathbf{x}^T A^T A \mathbf{x} \right) \\
&= -2 A^T \mathbf{b} + 2 A^T A \mathbf{x} \\
&= 0
\end{aligned}
$$

得到：（就是正规方程）因为 $A$ 的列向量线性无关，所以 $A^T A$ 可逆(是一个gram矩阵)：

$$
A^T A \mathbf{x} = A^T \mathbf{b} \Rightarrow \mathbf{x} = (A^T A)^{-1} A^T \mathbf{b}
$$

所以：

$$
\text{proj}_W \mathbf{b} = A \mathbf{x} = A (A^T A)^{-1} A^T \mathbf{b}
$$

投影矩阵为：

$$
P = A (A^T A)^{-1} A^T
$$

### 核心性质

投影矩阵不是随便一个方阵都能叫的，它必须满足这些性质：

#### 1. 幂等性

$$
P^2 = P
$$

#### 2. 正交投影是对称的

$$
P^T = P
$$

如果投影的方向是正交于目标子空间的（也就是我们一直在做的“垂直线”投影），那么投影矩阵还是对称矩阵。

#### 3. 特征值只能是 0 或 1

由于 $P^2 = P$，对于任何特征向量 $\mathbf{v}$ 和对应的特征值 $\lambda$，我们有：

$$
P^2 \mathbf{v} = P \mathbf{v} \Rightarrow P (P \mathbf{v}) = P \mathbf{v} \Rightarrow P (\lambda \mathbf{v}) = \lambda \mathbf{v} \Rightarrow \lambda^2 \mathbf{v} = \lambda \mathbf{v}
$$

特征值 1 对应的特征向量是子空间本身的向量（投影后不变）。

特征值 0 对应的特征向量是被“消灭”的方向（与子空间正交的方向）。

#### 4. 秩等于迹，等于子空间的维数

因为特征值只有 1 和 0，矩阵的迹就是特征值 1 的个数，也就是投影到的子空间的维数。

$$
\text{rank}(P) = \text{trace}(P) = k
$$

#### 5. 互补关系

如果 $P$ 是投影矩阵，那么 $I - P$ 也是一个投影矩阵，且它投影到的子空间与 $P$ 投影到的子空间是互补的（也就是正交的）。换句话说，如果 $P$ 投影到子空间 $W$，那么 $I - P$ 就投影到 $W$ 的正交补空间。

#### 6. 几何分解

对于任意向量 $\mathbf{b}$，我们可以将它分解为两部分：一部分是它在子空间 $W$ 上的投影 $\text{proj}_W \mathbf{b}$，另一部分是它与子空间 $W$ 正交的部分 $\mathbf{b} - \text{proj}_W \mathbf{b}$：

$$
\mathbf{b} = \text{proj}_W \mathbf{b} + (\mathbf{b} - \text{proj}_W \mathbf{b})
$$

## 一些注意事项

**正交性**：向量 $\mathbf{b}$ 与其投影向量之差 $(\mathbf{b} - \text{proj}_{\mathbf{a}} \mathbf{b})$ 必然与 $\mathbf{a}$ 正交（垂直）。这是线性代数中最重要的误差处理逻辑。

**从优化角度看投影**：如果想把向量投影到一个仿射空间，寻找平面内距离原始向量最近的点。这可以看作一个有约束的优化问题，用拉格朗日乘数法求解：

$$
x,y \in \mathbb{R}^n, \text{则点y到集合} S= \{x|Ax = b , \quad A\in \mathbb{R}^{m \times n},rank(A)=m<n\} \text{的投影是什么？}\\[1em]
\text{投影点} p \text{是集合} S \text{中距离} y \text{最近的点，即：}\\[1em]
p= \argmin_{x \in S} \|y-x\|_2^2,\quad s.t. Ax=b\\[1em]
\text{使用拉格朗日乘数法求解：}\\[1em]
\mathcal{L}(x,\lambda) = \|y-x\|_2^2 + \lambda^T (Ax - b)\\[1em]
\text{对} x \text{求导并设为零：}\\[1em]
\frac{\partial \mathcal{L}}{\partial x} = -2(y-x) + A^T \lambda = 0 \Rightarrow x = y + \frac{1}{2} A^T \lambda\\[1em]
\text{将} x \text{代入约束条件} Ax = b \text{中：}\\[1em]
A(y + \frac{1}{2} A^T \lambda) = b \Rightarrow \lambda = 2(A A^T)^{-1} (b - A y)\\[1em]
\text{最终得到投影点} p \text{的表达式：}\\[1em]
p = y - A^T (A A^T)^{-1} (Ay - b)\\[1em]
p = (I - A^T (A A^T)^{-1} A) y + A^T (A A^T)^{-1} b
$$

从结果看出，投影矩阵 $P =I - A^T (A A^T)^{-1} A$

**单位向量简化**：如果 $\mathbf{a}$ 是单位向量（长度为 1），那么公式直接简化为:

$$
\text{proj}_{\mathbf{a}} \mathbf{b} = (\mathbf{a} \cdot \mathbf{b}) \mathbf{a}= (\mathbf{a}^T \mathbf{b}) \mathbf{a}
$$
