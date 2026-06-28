---
title: 类条件概率密度是高斯分布时的贝叶斯判别准则
published: 2026-06-16
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 3
draft: false 
lang: ''
---

考虑特征向量 $\mathbf{x} \in \mathbb{R}^d$，假设类条件概率密度是高斯分布：

$$
p(\mathbf{x}|\omega_i) = \frac{1}{(2\pi)^{d/2} |\Sigma_i|^{1/2}} \exp\left( -\frac{1}{2} (\mathbf{x} - \mu_i)^T \Sigma_i^{-1} (\mathbf{x} - \mu_i) \right)\sim \mathcal{N}(\mu_i, \Sigma_i)
$$

此时的判别函数为：

:::tip

贝叶斯判别准则就是最小错误率准则，选择后验概率最大的类别。

:::

$$
\begin{aligned}
g_i(\mathbf{x}) &= \ln p(\mathbf{x}|\omega_i) + \ln P(\omega_i) \\
&= -\frac{1}{2} (\mathbf{x} - \mu_i)^T \Sigma_i^{-1} (\mathbf{x} - \mu_i) - \frac{1}{2} \ln |\Sigma_i| + \ln P(\omega_i) - \cancel{\frac{d}{2} \ln (2\pi)}\\[1em]
i &= \arg\max_i g_i(\mathbf{x})
\end{aligned}
$$

## 情况1：$\Sigma_i = \sigma^2 I,P(\omega_i)=\frac{1}{c}$

假设每一类数据在特征空间中都长成一个正圆球体（二维是圆，三维是球），并且所有类别的球体大小（半径）完全一样。

$$
g_i(\mathbf{x}) = -\frac{1}{2\sigma^2} \|\mathbf{x} - \mu_i\|^2 + \text{constant}\propto -\|\mathbf{x} - \mu_i\|^2\\[1em]
i = \arg\max_i g_i(\mathbf{x}) \implies i = \arg\min_i \|\mathbf{x} - \mu_i\|^2
$$

此分类器称为距离分类器，判别函数可以用待识模式 $\mathbf{x}$ 与类别均值 $\mu_i$ 之间的距离表示 $g_i(\mathbf{x}) = -d(\mathbf{x}, \mu_i)$，最大化判别函数等于最小化距离，因此也称为**最小距离分类器**。

决策边界：两个球心连线的垂直平分线（超平面）。

## 情况2：$\Sigma_i = \Sigma$

假设每一类数据都长成椭球体，而且所有类别的椭球体形状、大小、朝向完全一致（比如都是东北-西南方向拉长的椭球），只是它们中心点（均值μ的位置不同。

$$
\begin{aligned}
g_i(\mathbf{x}) &= -\frac{1}{2} (\mathbf{x} - \mu_i)^T \Sigma^{-1} (\mathbf{x} - \mu_i) + \ln P(\omega_i) + \text{constant}\\
&\propto -\frac{1}{2} (\mathbf{x} - \mu_i)^T \Sigma^{-1} (\mathbf{x} - \mu_i) + \ln P(\omega_i)\\
&= -\frac{1}{2} \mathbf{x}^T \Sigma^{-1} \mathbf{x} + \mu_i^T \Sigma^{-1} \mathbf{x} - \frac{1}{2} \mu_i^T \Sigma^{-1} \mu_i + \ln P(\omega_i) \\
\end{aligned}
$$

里面的纯二次 $-\frac{1}{2} \mathbf{x}^T \Sigma^{-1} \mathbf{x}$ 对于所有类别相同，可以视为常数的一部分忽略。进一步展开：

$$
\begin{aligned}
g_i(\mathbf{x})
&= \mu_i^T \Sigma^{-1} \mathbf{x} - \frac{1}{2} \mu_i^T \Sigma^{-1} \mu_i + \ln P(\omega_i)
\end{aligned}
$$

简化成线性形式，这就是 **线性判别分析（LDA）**。

$$
g_i(\mathbf{x}) = \mathbf{w}_i^T \mathbf{x} + w_{i0}
$$

决策边界：依旧是超平面，但不再是两个球心连线的垂直平分线了，而是根据 $\Sigma$ 的形状调整过的超平面。

## 情况3：$\Sigma_i$ 不同

彻底放飞。每个类别的数据可以有自己的形状、大小和朝向。A类可以是细长的椭球，B类可以是扁平的圆盘，旋转的角度也可以完全不同。

和上面的情况2一样，纯二次项 $-\frac{1}{2} \mathbf{x}^T \Sigma_i^{-1} \mathbf{x}$ 不能视为常数了，因为 $\Sigma_i$ 不同了。忽略常数展开后：

$$
g_i(\mathbf{x}) = -\frac{1}{2} \mathbf{x}^T \Sigma_i^{-1} \mathbf{x} + \mu_i^T \Sigma_i^{-1} \mathbf{x} - \frac{1}{2} \mu_i^T \Sigma_i^{-1} \mu_i - \frac{1}{2} \ln |\Sigma_i| + \ln P(\omega_i)
$$

决策边界：不再是超平面了，而是二次曲面（比如椭圆、双曲线等）。因此也称为**二次判别分析（QDA）**。

## 问题

难估计协方差矩阵：特征的维数较高、训练样本数量较少时，无法有效估计协方差矩阵

## 朴素贝叶斯分类器

:::tip

参数估计里面的独立性假设是针对数据集中的特征向量之间而言的，而朴素贝叶斯分类器的独立性假设是针对具体特征向量的各个维度之间而言的。

:::

假设特征向量的各个维度之间条件独立，即 $p(\mathbf{x}|\omega_i) = \prod_{j=1}^d p(x_j|\omega_i)$ （第i类，第j维），每个特征单独建模为一维高斯分布：

$$
p(x_j|\omega_i) = \frac{1}{\sqrt{2\pi} \sigma_{ij}} \exp\left( -\frac{(x_j - \mu_{ij})^2}{2\sigma_{ij}^2} \right)
$$

特征向量的类条件概率密度函数为：

$$
p(\mathbf{x}|\omega_i) = \prod_{j=1}^d p(x_j|\omega_i) = \prod_{j=1}^d \frac{1}{\sqrt{2\pi} \sigma_{ij}} \exp\left( -\frac{(x_j - \mu_{ij})^2}{2\sigma_{ij}^2} \right)
$$

判别函数为：

$$
\begin{aligned}
g_i(\mathbf{x}) &= \ln p(\mathbf{x}|\omega_i) + \ln P(\omega_i) \\
&= \sum_{j=1}^d \left( -\frac{(x_j - \mu_{ij})^2}{2\sigma_{ij}^2} - \frac{1}{2} \ln (2\pi) - \ln \sigma_{ij} \right) + \ln P(\omega_i) \\
&= -\frac{1}{2} \sum_{j=1}^d \frac{(x_j - \mu_{ij})^2}{\sigma_{ij}^2}  - \sum_{j=1}^d \ln \sigma_{ij} + \ln P(\omega_i)- \cancel{\frac{d}{2} \ln (2\pi)}
\end{aligned}
$$
