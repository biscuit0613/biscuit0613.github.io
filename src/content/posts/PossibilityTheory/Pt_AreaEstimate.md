---
title: 区间估计：单个及两个正态总体参数估计
published: 2025-12-09
description: '区间估计的原理'
image: ''
tags: [概率论, 区间估计]
category: '概率论与数理统计'
draft: false 
lang: ''
---

目的：给出估计参数的一个区间，而不是一个点。

点估计产生的是一个点，尽管可以通过估计量的检验来判断其有效性，但无法反映估计值的精确程度。而区间估计通过提供一个区间，可以更好地反映估计值的不确定性。

## 理论依据：正态总体下统计量的分布

在正态总体下，样本均值和样本方差的分布性质为区间估计提供了理论基础。

$$
\begin{aligned}
Z = \frac{\overline{X} - \mu}{\sigma/\sqrt{n}} &\sim N(0,1) \\[10pt]
\frac{(n-1)S^2}{\sigma^2} &\sim \chi^2(n-1) \\[10pt]
\frac{\overline{X}-\mu}{\sqrt{S^2/n}} &\sim t(n-1) \\
\end{aligned}
$$

## 置信区间的构造

对于一个来自参数空间 $\mathrm{H}$ 的参数 $\theta$ ，$x_1\dotsb x_i$ 为来自总体的样本。给定一个数 $\alpha$ ，$\alpha$ 取0.01，0.05，0.1等常用值。

有两个统计量：$\hat{\theta}_U(x_1\dotsb x_i)$ 和 $\hat{\theta}_L(x_1\dotsb x_i)$。若对任意 $\theta \in \mathrm{H}$ ，都有

$$
P\left(\hat{\theta}_L < \theta < \hat{\theta}_U\right) \geq 1 - \alpha
$$

则称区间 $\left(\hat{\theta}_L, \hat{\theta}_U\right)$ 为参数 $\theta$ 的**置信区间**，**置信度**为 $1-\alpha$ 。

## 计算置信区间：枢轴量法

构造一个和样本，参数有关的函数 $G(x_1, \dots, x_n; \theta)$，满足：

1. $G$ 的分布不依赖于参数 $\theta$ 。

2. $G$ 关于 $\theta$ 单调递增或递减。
3. 已知 $G$ 的分布，可以求出其分位点。

称 $G$ 为**枢轴量**。

这里以正态总体参数的置信区间为例：（主要考这一块）

### 已知总体方差 $\sigma^2$ 时总体均值 $\mu$ 的置信区间

已知总体方差 $\sigma^2$ 时，样本均值的标准化变量作为枢轴量：

$$
G = \frac{\overline{X} - \mu}{\sigma/\sqrt{n}} \sim N(0,1)\\[10pt]
P(c < G < d) = 1 - \alpha
$$

根据标准正态分布的对称性，有：

$$
P\left(-u_{1-\alpha/2} < G < u_{1-\alpha/2}\right) = 1 - \alpha
$$

$u$ 可以查表或者题目给，这里面只有 $\mu$ 是未知的，解不等式：

$$
P\left(\overline{X} - u_{1-\alpha/2} \frac{\sigma}{\sqrt{n}} < \mu < \overline{X} + u_{1-\alpha/2} \frac{\sigma}{\sqrt{n}}\right) = 1 - \alpha
$$

所以，$\mu$ 置信度为 $1-\alpha$ 的置信区间为：

$$
\left(\overline{X} - u_{1-\alpha/2} \frac{\sigma}{\sqrt{n}}, \; \overline{X} + u_{1-\alpha/2} \frac{\sigma}{\sqrt{n}}\right)
$$

记住就行了喵。

### 未知总体方差 $\sigma^2$ 时总体均值 $\mu$ 的置信区间

总体方差未知时，用样本方差作为无偏估计，用含t分布的那个式子：

$$
G = \frac{\overline{X} - \mu}{\sqrt{S^2/n}} \sim t(n-1)\\[10pt]
P(c < G < d) = 1 - \alpha
$$

根据t分布的对称性，有：

$$
P\left(-t_{1-\alpha/2}(n-1) < G < t_{1-\alpha/2}(n-1)\right) = 1 - \alpha
$$

解不等式：

$$
P\left(\overline{X} - t_{1-\alpha/2}(n-1) \frac{S}{\sqrt{n}} < \mu < \overline{X} + t_{1-\alpha/2}(n-1) \frac{S}{\sqrt{n}}\right) = 1 - \alpha
$$

所以，$\mu$ 置信度为 $1-\alpha$ 的置信区间为：

$$
\left(\overline{X} - t_{1-\alpha/2}(n-1) \frac{S}{\sqrt{n}}, \; \overline{X} + t_{1-\alpha/2}(n-1) \frac{S}{\sqrt{n}}\right)
$$

### 总体方差 $\sigma^2$ 的置信区间

一般来说不会有 $\mu$ 已知 $\sigma^2$ 未知的情况，所以直接看 $\sigma^2$ 的置信区间。（默认 $\mu$ 是未知的）

所以这时候用不含有 $\mu$ 的那个式子：

$$
G = \frac{(n-1)S^2}{\sigma^2} \sim \chi^2(n-1)\\[10pt]
P(c < G < d) = 1 - \alpha
$$

注意卡方分布不对称：

$$
P\left(\chi^2_{\alpha/2}(n-1) < G < \chi^2_{1-\alpha/2}(n-1)\right) = 1 - \alpha
$$

解不等式：

$$
P\left(\frac{(n-1)S^2}{\chi^2_{1-\alpha/2}(n-1)} < \sigma^2 < \frac{(n-1)S^2}{\chi^2_{\alpha/2}(n-1)}\right) = 1 - \alpha
$$

所以，$\sigma^2$ 置信度为 $1-\alpha$ 的置信区间为：

$$
\left(\frac{(n-1)S^2}{\chi^2_{1-\alpha/2}(n-1)}, \; \frac{(n-1)S^2}{\chi^2_{\alpha/2}(n-1)}\right)
$$

记住就行了喵。

## 两个独立正态总体统计量的分布

两个独立的正态总体 $X\sim N(\mu_1, \sigma_1^2)$ 和 $Y\sim N(\mu_2, \sigma_2^2)$

对于X(或Y)每一个样本均值和方差：
$$
\begin{aligned}
\overline{X} &\sim N\left(\mu_1, \frac{\sigma_1^2}{n_1}\right) \\[10pt]
\overline{Y} &\sim N\left(\mu_2, \frac{\sigma_2^2}{n_2}\right) \\[10pt]
\frac{(n_1-1)S_1^2}{\sigma_1^2} &\sim \chi^2(n_1-1) \\[10pt]
\frac{(n_2-1)S_2^2}{\sigma_2^2} &\sim \chi^2(n_2-1) \\[10pt]
\end{aligned}
$$

如果 $\sigma_1^2 = \sigma_2^2 = \sigma^2$，则有：

$$
\dfrac{\overline{X}-\overline{Y}-(\mu_1 - \mu_2)}{S_w \sqrt{\dfrac{1}{n_1}+\dfrac{1}{n_2}}} \sim t(n_1+n_2-2)\\[10pt]
\text{其中}\;\; S_w^2 = \frac{(n_1-1)S_1^2 + (n_2-1)S_2^2}{n_1 + n_2 - 2}
$$

利用了t分布的定义构造，上面是 $\overline{X}-\overline{Y}$ 标准化，下面的卡方分布利用X,Y样本方差和卡方分布的可加性构造。

推导，在已知 $\sigma_1^2 = \sigma_2^2 = \sigma^2$ 时：

$$
T=\frac{Z}{\sqrt{H/n}}\sim t(n)\\[10pt]
\overline{X}-\overline{Y}\sim N\left(\mu_1 - \mu_2, \sigma^2\left(\dfrac{1}{n_1}+\dfrac{1}{n_2}\right)\right)\\[10pt]
$$

其中

$$
Z=\frac{\overline{X}-\overline{Y}-(\mu_1 - \mu_2)}{\sigma\sqrt{\dfrac{1}{n_1}+\dfrac{1}{n_2}}}\sim N(0,1)\\[10pt]
H=\frac{(n_1-1)S_1^2+(n_2-1)S_2^2}{\sigma^2}\sim \chi^2(n_1+n_2-2)\\[10pt]
$$

对于样本方差 $S_1^2$ 和 $S_2^2$ ，有：

$$
\dfrac{S_1^2/\sigma_1^2}{S_2^2/\sigma_2^2} \sim F(n_1-1, n_2-2)
$$

## 两个独立正态总体参数的区间估计

### 已知总体方差 $\sigma_1^2，\sigma_2^2$ 时总体均值差 $\mu_1 - \mu_2$ 的置信区间

用标准正态分布的那个式子：

$$
Z=\frac{\overline{X}-\overline{Y}-(\mu_1 - \mu_2)}{\sqrt{\dfrac{\sigma_1^2}{n_1}+\dfrac{\sigma_2^2}{n_2}}}\sim N(0,1)\\[10pt]
P(c < Z < d) = 1 - \alpha
$$

根据标准正态分布的对称性，有：

$$
P\left(-u_{1-\alpha/2} < Z < u_{1-\alpha/2}\right) = 1 - \alpha
$$

解不等式：

$$
P\left(\overline{X}-\overline{Y} - u_{1-\alpha/2} \sqrt{\dfrac{\sigma_1^2}{n_1}+\dfrac{\sigma_2^2}{n_2}} < \mu_1 - \mu_2 < \overline{X}-\overline{Y} + u_{1-\alpha/2} \sqrt{\dfrac{\sigma_1^2}{n_1}+\dfrac{\sigma_2^2}{n_2}}\right) = 1 - \alpha
$$

所以，$\mu_1 - \mu_2$ 置信度为 $1-\alpha$ 的置信区间为：
$$
\left(\overline{X}-\overline{Y} - u_{1-\alpha/2} \sqrt{\dfrac{\sigma_1^2}{n_1}+\dfrac{\sigma_2^2}{n_2}}, \; \overline{X}-\overline{Y} + u_{1-\alpha/2} \sqrt{\dfrac{\sigma_1^2}{n_1}+\dfrac{\sigma_2^2}{n_2}}\right)
$$

### 已知总体方差 $\sigma_1^2=\sigma_2^2$ 时（不知道具体值）总体均值差 $\mu_1 - \mu_2$ 的置信区间

用t分布的那个式子：

$$
T=\frac{\overline{X}-\overline{Y}-(\mu_1 - \mu_2)}{S_w\sqrt{\dfrac{1}{n_1}+\dfrac{1}{n_2}}}\sim t(n_1+n_2-2)\\[10pt]
P(c < T < d) = 1 - \alpha
$$

根据t分布的对称性，有：

$$
P\left(-t_{1-\alpha/2}(n_1+n_2-2) < T < t_{1-\alpha/2}(n_1+n_2-2)\right) = 1 - \alpha
$$

解不等式：

$$
P\left(\overline{X}-\overline{Y} - t_{1-\alpha/2}(n_1+n_2-2) S_w \sqrt{\dfrac{1}{n_1}+\dfrac{1}{n_2}} < \mu_1 - \mu_2 < \overline{X}-\overline{Y} + t_{1-\alpha/2}(n_1+n_2-2) S_w \sqrt{\dfrac{1}{n_1}+\dfrac{1}{n_2}}\right) = 1 - \alpha
$$

所以，$\mu_1 - \mu_2$ 置信度为 $1-\alpha$ 的置信区间为：

$$
\left(\overline{X}-\overline{Y} - t_{1-\alpha/2}(n_1+n_2-2) S_w \sqrt{\dfrac{1}{n_1}+\dfrac{1}{n_2}}, \; \overline{X}-\overline{Y} + t_{1-\alpha/2}(n_1+n_2-2) S_w \sqrt{\dfrac{1}{n_1}+\dfrac{1}{n_2}}\right)
$$

### 已知总体方差比 $\sigma_1^2/\sigma_2^2=c$ 时总体均值差的置信区间

和t分布的那个类似，只不过多了系数c

### 求总体方差比 $\sigma_1^2/\sigma_2^2$ 的置信区间

用F分布的那个式子：

$$
F=\dfrac{S_1^2/\sigma_1^2}{S_2^2/\sigma_2^2} \sim F(n_1-1, n_2-2)\\[10pt]
P(c < F < d) = 1 - \alpha
$$

根据F分布的不对称性，有：

$$
P\left(F_{\alpha/2}(n_1-1, n_2-2) < F < F_{1-\alpha/2}(n_1-1, n_2-2)\right) = 1 - \alpha
$$

解不等式：

$$
P\left(\frac{S_1^2}{S_2^2} \cdot \frac{1}{F_{1-\alpha/2}(n_1-1, n_2-2)} < \frac{\sigma_1^2}{\sigma_2^2} < \frac{S_1^2}{S_2^2} \cdot \frac{1}{F_{\alpha/2}(n_1-1, n_2-2)}\right) = 1 - \alpha
$$

所以，$\sigma_1^2/\sigma_2^2$ 置信度为 $1-\alpha$ 的置信区间为：

$$
\left(\frac{S_1^2}{S_2^2} \cdot \frac{1}{F_{1-\alpha/2}(n_1-1, n_2-2)}, \; \frac{S_1^2}{S_2^2} \cdot \frac{1}{F_{\alpha/2}(n_1-1, n_2-2)}\right)
$$

:::tip
可能用到的F分布性质：
$$
\frac{1}{F_{\alpha}(m,n)} = F_{1-\alpha}(n,m)
$$
:::
