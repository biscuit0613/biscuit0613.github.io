---
title: 向量的投影
published: 2026-04-07
description: ''
image: ''
tags: [投影]
category: '线性代数'
draft: false 
lang: ''
---

## 几何直观

有两个向量 $\mathbf{a}$ 和 $\mathbf{b}$。从 $\mathbf{b}$ 的终点向 $\mathbf{a}$ 所在的直线做一条垂线，垂足与原点之间的这段向量，就是 $\mathbf{b}$ 在 $\mathbf{a}$ 方向上的投影向量（记作 $\text{proj}_{\mathbf{a}} \mathbf{b}$）。

- 投影的长度（标量）：即 $\mathbf{b}$ 在 $\mathbf{a}$ 方向上的“影子”长度。

- 投影的性质：投影向量与被投向的向量 $\mathbf{a}$ 是共线的。

## 关于计算

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

## 一些注意事项

**正交性**：向量 $\mathbf{b}$ 与其投影向量之差 $(\mathbf{b} - \text{proj}_{\mathbf{a}} \mathbf{b})$ 必然与 $\mathbf{a}$ 正交（垂直）。这是线性代数中最重要的误差处理逻辑。

**投影到平面**：如果想把向量投影到一个平面（子空间），公式会演变成 $P = A(A^T A)^{-1} A^T$。这就是最小二乘法的本质：寻找平面内距离原始向量最近的点。

**单位向量简化**：如果 $\mathbf{a}$ 是单位向量（长度为 1），那么公式直接简化为：

$$
\text{proj}_{\mathbf{a}} \mathbf{b} = (\mathbf{a} \cdot \mathbf{b}) \mathbf{a}= (\mathbf{a}^T \mathbf{b}) \mathbf{a}
$$
