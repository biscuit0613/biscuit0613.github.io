---
title: 概率论：一维随机变量函数及其分布
published: 2025-10-27
description: '一维随机变量函数的概率密度和分布函数'
image: ''
tags: [随机变量函数]
category: '概率论'
draft: false 
lang: ''
---

## 随机变量函数Y=g(X)的概率密度和分布函数

- 核心思想：**变量代换**

如何通过 $X$ 的概率密度 $f_X(x)$ 和分布函数 $F_X(X)$ ，来获得 $Y=g(X)$ 的概率密度 $f_Y(y)$ 和分布函数 $F_Y(y)$ 。

1. 通过 $Y=g(X)$ ，找到对应 $\{Y≤y\}$ 的 $x$ 区间 $I$。

2. 在区间 $I$ 上， $\int_I f(x)dx$ ，获得 $P(Y≤y)$ ，也就是  $F_Y(y)$
3. 求导 $F_Y(y)$，获得密度函数 $f_Y(y)$。

$$
F_Y(y)=P(Y\leq y)=P(g(X)\leq y)\\
\text{解出来$x$的范围（含$y$），假设是$y_1\leq x\leq y_2$}\\
\begin{align*}
  F_Y(y)&=F_X(y_2)-F_X(y_1)\\
  \text{或}
F_Y(y)&=\int_{y_1}^{y_2}f_X(x)\\
f_Y(y)&=F_Y^\prime(y)\\
\end{align*}
$$

对于连续型随机变量，直接公式法：

若 $y=g(x)$ 是严格**单调**的且**反函数 $h(y)$ 可导**时, 则随机变量 $Y$ 仍为连续型随机变量, 且有概率密度函数

$$
f_Y(y)=\left\{\begin{matrix}
  \begin{align*}
    &f_X(h(y))\cdot|h^\prime(y)|&&A <y<B\\
    &0 &&others
  \end{align*}
\end{matrix}\right.\\
\text{其中}A=\min\{g(a),g(b)\},B=\max\{g(a),g(b)\}
 $$

- 推论：正态变量的线性变换依然是正态变量，即 $Y=aX+b,X\sim N(\mu,\sigma^2)$，则 $Y\sim N(a\mu+b,a^2\sigma^2)$

例如：

$X\sim E(2),Y=1-e^{-2X}$，求Y的分布

### 分布函数法

$$
F_Y(y)=P(Y\leq y)=P(1-e^{-2X}\leq y)\\
\text{当y<0时}\\
F_Y(y)=0\\
\text{当y>1时}\\
F_Y(y)=1\\
\text{当0<y<1时}\\
F_Y(y)=P(X\leq -\frac{1}{2}\ln (1-y))\\
=F_X(-\frac{1}{2}\ln (1-y))\\
=1-e^{-2(-\frac{1}{2}\ln (1-y))}\\
=y
$$

### 公式法

y的反函数是 $h(y)=-\frac{1}{2}\ln (1-y)$