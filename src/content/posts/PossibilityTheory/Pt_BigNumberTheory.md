---
title: 大数定律
published: 2025-12-08
description: '依概率收敛理解大数定律'
image: ''
tags: [大数定律]
category: '概率论与数理统计'
draft: false 
lang: ''
---

前置知识：依概率收敛，两个重要不等式（马尔可夫不等式与切比雪夫不等式）

## 大数定律

大数定律描述了大量独立同分布随机变量的样本均值趋近于其期望值的性质。

### 伯努利大数定律

设随机变量序列 $\{X_n\}$ 独立同分布，且每个 $X_i$ 服从伯努利分布 $B(1,p)$，即 $P(X_i=1)=p, P(X_i=0)=1-p$。设成功的次数是 $Y_n$ ，则样本均值(成功率) $\dfrac{Y_n}{n}$ 依概率收敛于 $p$：

$$
P\left(\left|\frac{Y_n}{n}-p\right| \geq \varepsilon\right) =0
$$

这是典型的频率收敛于概率的例子。

### 伯努利大数定律推导

用切比雪夫不等式：

$$
\begin{aligned}
    P\left(\left|\frac{Y_n}{n}-p\right| \ge \varepsilon\right) &\leq \frac{\mathbb{D}\left(\frac{Y_n}{n}\right)}{\varepsilon^2}
    = \frac{1}{n^2} \cdot \frac{np(1-p)}{\varepsilon^2} = \frac{p(1-p)}{n\varepsilon^2}\\
    \lim_{n \to \infty} P\left(\left|\frac{Y_n}{n}-p\right| \ge \varepsilon\right) &= \lim_{n \to \infty} \frac{p(1-p)}{n\varepsilon^2} = 0
\end{aligned}
$$

其中，$\mathbb{E}(X_i)=p, \mathbb{D}(X_i)=p(1-p), \mathbb{D}\left(\dfrac{Y_n}{n}\right) = \dfrac{p(1-p)}{n}$

### 切比雪夫大数定律

设随机变量序列 $\{X_n\}$ 独立同分布，且每个 $X_i$ 的期望值 $\mathbb{E}(X_i)$ 和方差 $\mathbb{D}(X_i)$ 存在，且方差有上界。则样本均值 $\overline{X}_n = \dfrac{1}{n} \sum_{i=1}^{n} X_i$ 依概率收敛于 **期望的平均值**：

$$
P\left(\left|\frac{\sum_{i=1}^nX_i}{n} - \frac{\sum_{i=1}^n\mathbb{E}(X_i)}{n}\right| \geq \varepsilon\right) =0
$$

记作
$$
\frac{\sum_{i=1}^nX_i}{n} \xrightarrow{P} \frac{\sum_{i=1}^n\mathbb{E}(X_i)}{n}
$$

### 辛钦大数定律（切比雪夫的推广）

对于切比雪夫大数定律的特例，$X_i$ 的期望相同。

当随机变量序列 $\{X_n\}$ 独立同分布，且每个 $X_i$ 的期望值 $\mathbb{E}(X_i)=\mu$ 和方差 $\mathbb{D}(X_i)=\sigma^2$ 存在时，样本均值 $\overline{X}_n = \dfrac{1}{n} \sum_{i=1}^{n} X_i$ 依概率收敛于 **期望值** $\mu$：

$$
P\left(\left|\frac{\sum_{i=1}^nX_i}{n} - \mu\right| \geq \varepsilon\right) =0
$$

记作
$$
\frac{\sum_{i=1}^nX_i}{n} \xrightarrow{P} \mu
$$

:::tip  
在题目里可以简单理解成算样本均值=期望  
:::

## 中心极限定理

前置知识：依分布收敛

设随机变量序列 $\{X_n\}$ 独立同分布，且每个 $X_i$ 的期望值 $\mathbb{E}(X_i)=\mu$ 和方差 $\mathbb{D}(X_i)=\sigma^2$ 存在。把样本均值 $\overline{X}=\dfrac{\sum_{i=1}^n X_i}{n}$ 给标准化：

$$
\mathbb{E}(\overline{X}) = \mu, \quad \mathbb{D}(\overline{X}) = \frac{\sigma^2}{n}\\[10pt]
Z_n = \frac{\overline{X}-\mathbb{E}(\overline{X})}{\sqrt{\mathbb{D}(\overline{X})}} =\frac{\sum_{i=1}^n X_i - n\mu}{\sigma \sqrt{n}}
$$

则当 $n \to \infty$ 时，$Z_n$ 依分布收敛于 $Z$, $Z$ 服从**标准**正态分布 $N(0,1)$

等价地，$\overline{X}_n$ 的分布趋近于正态分布 $N\left(\mu, \dfrac{\sigma^2}{n}\right)$

简单来说就是大量独立同分布随机变量的**标准化**的**样本均值**趋近于**标准正态分布**。

这个很重要的一点就是无论是啥分布，只要满足独立同分布且期望方差存在，样本均值的分布就会趋近于正态分布。

所以考试时要记住的还是各种基本分布的期望和方差。
