---
title: 点估计：矩估计,极大似然估计与估计量的鉴定
published: 2025-12-09
description: '点估计的基本方法，包括矩估计和极大似然估计的原理与应用，以及估计量的有效性鉴定'
image: ''
tags: [统计量, 点估计, 矩估计, 极大似然估计]
category: '概率论与数理统计'
draft: false 
lang: ''
---

前置知识：统计量，矩

## 矩估计

一句话：用样本矩去估计总体矩，从而得到参数的估计值。

注意样本的二阶矩不是样本方差。

方法：

1. 求总体的一阶矩和二阶矩，带参数的。
    $$
    \alpha_1 = \mathbb{E}(X)
    $$
    $$
    \alpha_2 = \mathbb{E}(X^2) \\
    \mathrm{D}(X) = \alpha_2 - (\alpha_1)^2 \\
    $$

2. 求样本的一阶矩和二阶矩，带样本数据的。
    样本一阶矩：
    $$
    M_1' = \overline{X} = \frac{1}{n} \sum_{i=1}^n X_i
    $$
    样本二阶矩：
    $$
    M_2' = \frac{1}{n} \sum_{i=1}^n X_i^2
    $$
3. 令样本矩等于总体矩，解方程组，得到参数的估计值。
    $$
    \hat{\alpha_1}= M_1' \\
    \hat{\alpha_2}= M_2' \\
    $$

## 极大似然估计MLE

一句话：找到使得样本出现的概率最大的参数值。

对于一个样本 $X_1, X_2, \ldots, X_n$，假设它们来自于一个参数为 $\theta$ 的总体，其概率密度函数为 $f(x; \theta)$。则样本的联合概率密度函数（或联合概率质量函数）为：

$$
L(\theta) = \prod_{i=1}^{n} f(x_i; \theta)
$$

这个函数 $L(\theta)$ 被称为**似然函数**。这个越大，说明在参数 $\theta$ 下，观察到当前样本的可能性越大。

极大似然估计的目标是找到使得似然函数 $L(\theta)$ 最大化的参数值 $\hat{\theta}_{MLE}$，即：

$$
\hat{\theta}_{MLE} = \underset{\theta}{\arg\max} \; L(\theta)
$$

有时候求导发现不得0，就需要结合单调性取样本的特值。
对极大似然函数求导有时候不方便，可以对**似然函数取对数**，得到对数似然函数：

$$
\ell(\theta) = \ln L(\theta) = \sum_{i=1}^{n} \ln f(X_i; \theta)
$$

然后求偏导数并令其为零，解方程得到参数的估计值：
$$
\frac{\partial \ell(\theta)}{\partial \theta} = 0
$$

所以说重点还是在搞清楚样**本的概率密度函数是啥**。

:::note  
这里的参数求偏导时应当被视为一个整体，例如，正态分布的参数是 $(\mu, \sigma^2)$，应对 $\sigma^2$ 求偏导，而不是对 $\sigma$ 求偏导。  
:::

### 正态分布的极大似然估计

设样本 $X_1, X_2, \ldots, X_n$ 来自于一个正态分布 $N(\mu, \sigma^2)$，其概率密度函数为：

$$
f(x; \mu, \sigma^2) = \frac{1}{\sqrt{2\pi \sigma^2}} \exp\left(-\frac{(x - \mu)^2}{2\sigma^2}\right)
$$

则样本的似然函数为：

$$
\begin{aligned}
    L(\mu, \sigma^2) &= \prod_{i=1}^{n} f(X_i; \mu, \sigma^2)\\
    &= \left(\frac{1}{\sqrt{2\pi \sigma^2}}\right)^n \exp\left(-\frac{1}{2\sigma^2} \sum_{i=1}^{n} (X_i - \mu)^2\right)
\end{aligned}
$$

对数似然函数为：(取ln)

$$
\begin{aligned}
    \ell(\mu, \sigma^2) &= \ln L(\mu, \sigma^2) \\
    &= -\frac{n}{2} \ln(2\pi \sigma^2) - \frac{1}{2\sigma^2} \sum_{i=1}^{n} (X_i - \mu)^2
\end{aligned}
$$

对 $\mu$ 和 $\sigma^2$ 分别求偏导并令其为零：

$$
\begin{aligned}
\frac{\partial \ell}{\partial \mu} &= \frac{1}{\sigma^2} \sum_{i=1}^{n} (X_i - \mu) = 0\\
\frac{\partial \ell}{\partial \sigma^2} &= -\frac{n}{2\sigma^2} + \frac{1}{2(\sigma^2)^2} \sum_{i=1}^{n} (X_i - \mu)^2 = 0
\end{aligned}
$$

解得：

$$
\begin{cases}
    \hat{\mu}_{MLE} = \overline{X} = \dfrac{1}{n} \sum_{i=1}^{n} X_i \\[10pt]
    \hat{\sigma}^2_{MLE} = \dfrac{1}{n} \sum_{i=1}^{n} (X_i - \overline{X})^2
\end{cases}
$$

注意喵，这里的 $\hat{\sigma}^2_{MLE}$ 和样本方差 $S^2$ 的定义是不一样的，样本方差的分母是 $n-1$，这里求出来的 $\hat{\sigma}^2_{MLE}$ 的分母是 $n$，是样本的二阶中心距喵。

$\hat{\mu}$ 就是样本的一阶原点矩，$\hat{\sigma}^2$ 是样本的二阶中心矩。这和矩估计法得到的结果是一致的喵。

### 均匀分布的极大似然估计

设样本 $X_1, X_2, \ldots, X_n$ 来自于一个均匀分布 $U(0, \theta)$，其概率密度函数为：

$$
f(x; \theta) = \begin{cases}
\dfrac{1}{\theta}, & 0 \leq x \leq \theta \\
0, & \text{otherwise}
\end{cases}
$$

则样本的似然函数为：

$$
L(\theta) = \prod_{i=1}^{n} f(X_i; \theta) = \begin{cases}
\dfrac{1}{\theta^n}, & 0 \leq X_i \leq \theta \text{ for all } i \\
0, & \text{otherwise}
\end{cases}
$$

为了使似然函数 $L(\theta)$ 最大化，我们需要最大化 $\dfrac{1}{\theta^n}$，这等价于最小化 $\theta$。由于所有样本 $X_i$ 都必须小于等于 $\theta$，因此 $\theta$ 的最小值为样本中的最大值：

$$
\hat{\theta}_{MLE} = \max(X_1, X_2, \ldots, X_n)
$$

## 估计量的鉴定

有时候对于同一个参数，不同的估计方法会产生多个估计量，那么我们需要对这些估计量进行鉴定，选择一个更好的估计量。

鉴定估计量的标准主要有以下几个：

1. 无偏性：估计量的**期望值**等于参数 $\theta$ 的实际值，即偏差为零：
    $$
    Bias(\hat{\theta})=\mathbb{E}(\hat{\theta}) - \theta=0
    $$
    无偏估计量在长期来看不会系统性地高估或低估参数。期望稳定。

    例如样本方差就是总体方差的无偏估计，证明的过程就是**求估计量的期望**。

2. 有效性：在估计量**无偏**的**前提**下，**方差最小**的估计量被称为有效估计量。有效估计量能够提供最精确的参数估计。
    判断方法就是求估计量的方差，方差越小越好。
    :::note
    注意有效性是有前提条件的，即估计量必须是无偏的。
    :::
3. 相合性：估计量序列 $\hat{\theta}_n$ 如果随着样本大小 $n$ 的增加，估计量**依概率收敛**于真实参数值 $\theta$。即对于任意的 $\varepsilon > 0$，都有 $P(|\hat{\theta}_n - \theta| \geq \varepsilon) \to 0$ 当 $n \to \infty$。

### 均方误差MSE

均方误差（Mean Squared Error, MSE）是评估估计量质量的一个综合指标，综合了无偏性和有效性，定义为**估计量**与**真实参数值**之间**误差**的**平方**的**期望值**：

$$
\mathrm{MSE}(\hat{\theta}) = \mathbb{E}[(\hat{\theta} - \theta)^2]
$$

展开后可以表示为：

$$
\mathrm{MSE}(\hat{\theta}) = \mathrm{Var}(\hat{\theta}) + [\mathrm{Bias}(\hat{\theta})]^2
$$  
