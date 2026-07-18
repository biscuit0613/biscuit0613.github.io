---
title: 两个重要不等式
published: 2025-12-08
description: '马尔可夫不等式与切比雪夫不等式'
image: ''
tags: [概率论,马尔可夫不等式, 切比雪夫不等式]
category: '概率论与数理统计'
draft: false 
lang: ''
---

## 马尔可夫不等式

马尔可夫不等式是切比雪夫不等式他爹

马尔可夫不等式用来估计**非负**随机变量大于某个**正数**的概率**上界**

$$
P(X \geq a) \leq \frac{\mathbb{E}(X)}{a} \quad (a>0)
$$

### 马尔可夫不等式推导

用期望的定义：

$$
\begin{aligned}
    \mathbb{E}(X) &= \int_{0}^{+\infty} x f(x) dx\\
    &=\underbrace{\int_{0}^{a} x f(x) dx}_{>0} + \int_{a}^{+\infty} x f(x) dx\\[15pt]
    &\geq \int_{a}^{+\infty} x f(x) dx,\;\;plus \;\;x \geq a\\
    &\geq \int_{a}^{+\infty} a f(x) dx\\
    \iff&\geq a \int_{a}^{+\infty} f(x) dx\\
\end{aligned}
$$

## 切比雪夫不等式

切比雪夫不等式用来估计随机变量偏离其**均值**超过某个**正数**的概率**上界**，就是 $X$ 不能偏离期望太多

$$
P(|X - \mathbb{E}(X)| \geq k) \leq \frac{\mathbb{D}(X)}{k^2} \quad (k>0)
$$

或

$$
P(|X - \mathbb{E}(X)| < k) \geq 1 - \frac{\mathbb{D}(X)}{k^2} \quad (k>0)
$$

### 切比雪夫不等式推导

对左式两边平方：

$$
P((X - \mathbb{E}(X))^2 \geq k^2) \leq \frac{\mathbb{E}[(X - \mathbb{E}(X))^2]}{k^2}
$$

用一下方差的定义：

$$
P((X - \mathbb{E}(X))^2 \geq k^2) \leq \frac{\mathbb{D}(X)}{k^2}
$$
