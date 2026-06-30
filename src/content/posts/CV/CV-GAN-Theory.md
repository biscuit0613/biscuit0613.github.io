---
title: GAN理论基础：收敛性、最优解与WGAN
published: 2026-07-01
description: 'GAN极小极大博弈回顾、最优判别器解析解D*(x)、全局最优p_g=p_data与JSD视角、Mode Collapse问题、WGAN与Wasserstein-1距离、1-Lipschitz约束与梯度惩罚'
image: ''
tags: []
category: '计算机视觉'
order: 24
draft: false
lang: ''
---

最基本的 GAN 框架由一个生成器和一个判别器通过对抗训练构成。生成器 $G$ 将随机噪声 $z$ 映射为数据 $\hat{x}=G(z)$；判别器 $D$ 对真实样本 $x$ 和生成样本 $\hat{x}$ 输出 $[0,1]$ 间的真伪概率。两者的博弈由 Min-Max 目标函数定义（参见 ML 篇 `GAN-intro.md`）：

$$
\min_G \max_D V(D, G) = \mathbb{E}_{x\sim p_{\text{data}}}[\log D(x)] + \mathbb{E}_{z\sim p_z}[\log(1 - D(G(z)))]
$$

实践表明这个简单的框架训练起来极不稳定——对超参数敏感、容易崩塌。这一篇从理论上分析 GAN 的目标函数行为，解释问题根源和 WGAN 的改进方案。

## 最优判别器

先固定生成器 $G$，考虑判别器 $D$ 的最优形式。目标函数 $V$ 中对 $D$ 的优化可以写成积分形式：

$$
V = \int p_{\text{data}}(x) \log D(x) \, dx + \int p_g(x) \log(1 - D(x)) \, dx
$$

其中 $p_g$ 是生成器 $G$ 诱导的分布。对积分内的被积函数，对 $D(x)$ 求导并置零：

$$
\frac{\partial}{\partial D} \big[ p_{\text{data}} \log D + p_g \log(1 - D) \big] = \frac{p_{\text{data}}}{D} - \frac{p_g}{1 - D} = 0
$$

得到最优判别器的解析解：

$$
D^*(x) = \frac{p_{\text{data}}(x)}{p_{\text{data}}(x) + p_g(x)}
$$

这一形式有清晰的直观含义：在真实数据占主导的区域（$p_{\text{data}} \gg p_g$），判别器输出接近 1；在生成数据占主导的区域（$p_g \gg p_{\text{data}}$），输出接近 0；两者相当的地方输出 $1/2$。

## 全局最优

将 $D^*$ 代回目标函数，重写为：

$$
\begin{aligned}
V(D^*, G) &= \mathbb{E}_{x\sim p_{\text{data}}} \left[ \log \frac{p_{\text{data}}}{p_{\text{data}} + p_g} \right] + \mathbb{E}_{x\sim p_g} \left[ \log \frac{p_g}{p_{\text{data}} + p_g} \right] \\[4pt]
&= -\log 4 + 2 \cdot \text{JSD}(p_{\text{data}} \parallel p_g)
\end{aligned}
$$

其中 $\text{JSD}$ 是 Jensen-Shannon 散度。$p_{\text{data}} = p_g$ 时，$D^* = 1/2$，$\text{JSD}=0$，$V = -\log 4$ 取全局最小值。从理论上看，最优生成器应该完全复制真实分布。

## GAN 训练的两大问题

### 不收敛

$p_{\text{data}}$ 和 $p_g$ 在低维流形上不重叠（生成器输出流形通常维度远低于图像空间），JSD 在这些区域为常数（$\log 2$），不提供有意义的梯度。判别器在非重叠区域可以完美区分真假，梯度消失，生成器停止更新。

### 模式崩塌（Mode Collapse）

生成器发现只生成数据分布中的少数模式就能"欺骗"判别器后，逐步放弃对其他模式的覆盖。训练过程中生成的图像多样性不断下降，最终只产生一种或几种外观。

## WGAN

WGAN（Arjovsky et al., 2017）的核心理念是用 Wasserstein-1 距离（Earth Mover Distance）替代 JSD。Wasserstein 距离在分布不重叠时仍能提供有意义的梯度。

### Wasserstein-1 距离

两个分布之间的 Wasserstein-1 距离定义为将 $p_g$ 的"质量"搬运到 $p_{\text{data}}$ 的最小代价。通过 Kantorovich-Rubinstein 对偶，可以写成：

$$
W(p_{\text{data}}, p_g) = \sup_{\|f\|_L \leq 1} \mathbb{E}_{x\sim p_{\text{data}}}[f(x)] - \mathbb{E}_{x\sim p_g}[f(x)]
$$

其中 $f$ 是一个 1-Lipschitz 连续函数。判别器（critic）的目标不再是输出真伪概率，而是输出一个实数值，使其在真实样本上的期望最大化、在生成样本上的期望最小化。

### WGAN 目标函数

$$
\min_G \max_{D \in \text{1-Lipschitz}} \mathbb{E}_{x\sim p_{\text{data}}}[D(x)] - \mathbb{E}_{z\sim p_z}[D(G(z))]
$$

注意这里去掉了 $\log$，判别器输出是未经 sigmoid 的 logit。Lipschitz 约束是 WGAN 成立的关键。

### Weight Clipping 与梯度惩罚

原始 WGAN 通过将判别器权重的绝对值限制在 $[-c, c]$ 来近似 Lipschitz 约束。权值裁剪的问题是：它强制 Lipschitz 约束的同时也限制了判别器的表达能力。

WGAN-GP（Gulrajani et al., 2017）将权重裁剪替换为梯度惩罚项，在训练时直接惩罚判别器梯度偏离 1 的程度：

$$
\mathcal{L}_{\text{GP}} = \lambda \cdot \mathbb{E}_{\hat{x}\sim \text{interpolate}} \left[ (\|\nabla D(\hat{x})\|_2 - 1)^2 \right]
$$

$\hat{x}$ 在成对的真实样本和生成样本之间均匀采样。梯度惩罚使 WGAN-GP 的训练更稳定，无需权重裁剪的超参数调谐。
