---
title: 依概率收敛和依分布收敛
published: 2025-12-08
description: '依概率收敛和依分布收敛'
image: ''
tags: [收敛]
category: '概率论与数理统计'
draft: false 
lang: ''
---

## 依概率收敛的定义

对于一个随机序列 $\{X_n\}$，如果对于任意的 $\varepsilon >0$，都有

$$
\lim_{n \to \infty} P(|X_n - a| < \varepsilon) = 1
$$

或
$$
\lim_{n \to \infty} P(|X_n - a| \geq \varepsilon) = 0
$$

则称随机变量序列 $\{X_n\}$ **依概率**收敛于常数 $a$，记作 $X_n \xrightarrow{P} a$, 或 $\lim_{n \to \infty} X_n \overset{P}{=} a$

P表示依概率收敛（Convergence in Probability）

## 依分布收敛的定义

对于一个随机序列 $\{X_n\}$，他们各自的**分布函数**存在且记为 $F_{n}(x)$，如果对于任意的实数 $x$，都有

$$
\lim_{n \to \infty} F_{n}(x) = F(x)
$$

其中 $F(x)$ 是某个随机变量 $X$ 的分布函数。

则称随机变量序列 $\{X_n\}$ **依分布**收敛于随机变量 $X$，记作 $X_n \xrightarrow{F} X$, 或 $\lim_{n \to \infty} X_n \overset{F}{=} X$
