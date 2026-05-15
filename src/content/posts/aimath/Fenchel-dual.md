---
title: Fenchel-dual
published: 2026-05-15
description: ''
image: ''
tags: []
category: ''
draft: false 
lang: ''
---


## 核心出装：共轭函数（Fenchel Conjugate）

给定一个函数 $f: \mathbb{R}^n \to \mathbb{R}$，其共轭函数 $f^*$ 定义为：

$$
f^*(y) = \sup_{x \in \text{dom } f} (y^T x - f(x))
$$

- $y^T x$ ：向量 $y$ 和 $x$ 的内积,**线性函数**

- $f(x)$ ：原函数的值
- sup ：取上确界（supremum），即在 $x$ 的定义域内找到使 $y^T x - f(x)$ 最大的值

ps:对于二维情况，x,y 都是实数。y就是斜率。

### 计算共轭函数

1. 按照定义写出 $f^*(y)$ 的表达式

2. 对 $x$ 求导，找到使 $y^T x - f(x)$ 最大的 $x$（即求解 $\nabla_x (y^T x - f(x)) = 0$）
3. 将求得的 $x$ 代入 $y^T x - f(x)$ 中，得到 $f^*(y)$ 的表达式

举个例子：$f(x) = x\log x$，求其共轭函数。

$$
f^*(y) = \sup_{x > 0} (yx - x\log x)\\[1ex]
\nabla_x (yx - x\log x) = y - \log x - 1 = 0 \Rightarrow x = e^{y-1} \\[1ex]
f^*(y) = y e^{y-1} - e^{y-1} \log e^{y-1} = e^{y-1}
$$

## Fenchel对偶

Fenchel对偶是一个更一般的框架，可以处理更广泛的优化问题，包括非凸问题。拉格朗日对偶可以看作是Fenchel对偶在特定约束条件下的一个特例。

原问题形式一般长这样：

$$
\min_{x} f(x) + g(Ax)
$$

Fenchel对偶问题的形式是：

$$
\max_{y} -f^*(-A^T y) - g^*(y)
$$

这里 $f^*$ 是 $f$ 的共轭函数，$f^*(-A^T y)=\sup_{x} (-y^T A x - f(x))$；$g^*$ 是 $g$ 的共轭函数，$g^*(y)=\sup_{z} (y^T z - g(z))$。

$g(Ax)$ 是什么？代表了约束条件，是约束条件的**指示函数**（indicator function），当 $Ax$ 满足约束条件时 $g(Ax)=0$，否则 $g(Ax)=+\infty$。因此，原问题中的约束条件被隐含在 $g(Ax)$ 中。

例如线性规划标准形式中的约束条件 $Ax = b$ 可以通过定义 $g(z) = 0$ if $z = b$ else $+\infty$ 来表示。
