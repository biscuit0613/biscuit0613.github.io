---
title: 互信息量和互信息
published: 2026-04-22
description: ''
image: ''
tags: []
category: '信息论'
draft: false 
lang: ''
---


## 互信息量的定义

一句话：互信息量（Transinformation）看事件y能够削减掉事件x的不确定性有多少。

互信息量定义为：

$$
I(x; y) = I(x) - I(x|y)
$$

互信息量=原有不确定性-剩余不确定性

继续化简定义式：

$$
I(x; y) = I(x) - I(x|y) = -\log P(x) + \log P(x|y) = \log \frac{P(x|y)}{P(x)}\\
= \log \frac{P(x, y)}{P(x) P(y)}=-\log P(x) - \log P(y) + \log P(x, y) \\
= I(x) + I(y) - I(xy)
$$

类似自信息量，定义条件互信息量：

$$
I(x; y|z) = I(x|z) - I(x|yz)= -\log P(x|z) + \log P(x|yz) = \log \frac{P(x|yz)}{P(x|z)} = \log \frac{P(x, y|z)}{P(x|z) P(y|z)} = I(x|z) + I(y|z) - I(xy|z)
$$

## 互信息量的性质

- 互信息量是对称的：$I(x; y) = I(y; x)$。即由事件 $x$ 提供的信息量与由事件 $y$ 提供的信息量是相同的。

- 上界：互信息量的最大值为 $I(x; y) \leq \min(I(x), I(y))$。当 $x$ 和 $y$ 完全相关时，互信息量达到最大值。从一个事件所提取的另一个事件的信息量不可能超过另一个事件本身包含的信息量。
- 可正可负：互信息量可以是正数、零或负数。取决于概率比值和1

## 互信息

互信息（mutual information）是**互信息量**的**期望值**。它衡量了两个**随机变量**之间的依赖关系。

$$
I(X; Y) =\mathbb{E}I(x;y) = \sum_{x \in X} \sum_{y \in Y} P(x, y) \log \frac{P(x, y)}{P(x) P(y)}
$$

若 $X$ 和 $Y$ 是独立的，则 $P(x, y) = P(x) P(y)$，互信息为零，说明两个变量之间没有任何依赖关系。