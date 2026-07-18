---
title: GAN变体：DCGAN与条件GAN
published: 2026-07-01
description: 'DCGAN全卷积化架构指南（转置卷积、BN、LeakyReLU）、cGAN条件生成、GAN架构演进为StyleGAN铺路的逻辑'
image: ''
tags: []
category: '08-计算机视觉'
order: 25
draft: false
lang: ''
---

原始 GAN 使用全连接网络作为生成器和判别器，生成的图像质量有限。DCGAN（Radford et al., 2016）和 cGAN（Mirza & Osindero, 2014）分别从架构和条件控制两个方向推动了 GAN 的演进，直接为 StyleGAN 奠定了设计基础。

## DCGAN：全卷积化架构

DCGAN 将 GAN 从全连接网络迁移到全卷积网络，并提出一组经验性架构指南。这些设计被后续几乎所有 GAN 架构继承，包括 StyleGAN。

### 生成器设计

DCGAN 生成器从 100 维的随机噪声 $z$ 开始，通过一系列转置卷积（Transposed Conv）逐步上采样到输出尺寸（如 $64\times64$）。核心结构为：

```
z (100维) → Reshape → ConvTranspose4×4 → BN → ReLU → ...
→ ConvTranspose4×4 → BN → ReLU → ...
→ ConvTranspose4×4 → Tanh (输出图像)
```

每层转置卷积将特征图尺寸翻倍，通道数减半。

### 判别器设计

判别器是对称的下采样结构：

```
→ Conv4×4 → BN → LeakyReLU(α=0.2) → ...
→ Conv4×4 → BN → LeakyReLU → ...
→ Conv4×4 → Sigmoid(输出真伪概率)
```

### DCGAN 架构指南

| 原则 | 说明 | 影响 |
|------|------|------|
| 全卷积化 | 不使用池化层和全连接层 | 参数量可控，支持变尺寸输入 |
| BN 层 | 生成器和判别器（除输出层）都加 BN | 稳定训练分布，加速收敛 |
| 生成器输出用 Tanh | 将像素值限制在 $[-1, 1]$ | 比 Sigmoid 的梯度更平滑 |
| 判别器用 LeakyReLU | 防止判别器的梯度在负半轴消失 | 避免判别器过早饱和 |
| 对称结构 | 生成器的上采样层数和判别器的下采样层数对应 | 生成器和判别器的能力匹配 |

## cGAN：条件生成

标准 GAN 的生成器只接收随机噪声 $z$，无法控制生成的内容。cGAN 将额外条件信息 $c$ 同时输入到生成器和判别器：

### 生成器

$$
G(z, c) : \text{噪声 } z \text{ + 条件 } c \rightarrow \text{生成样本 } \hat{x}
$$

条件 $c$ 可以是类别标签（如"猫"）、文本描述、或另一张图像（如 pix2pix 中的语义地图）。

### 目标函数

$$
\min_G \max_D \mathbb{E}_{x\sim p_{\text{data}}}[\log D(x|c)] + \mathbb{E}_{z\sim p_z}[\log(1 - D(G(z|c)|c))]
$$

判别器同时接收样本和条件，判断"符合条件 $c$ 的真实样本 $(x, c)$"与"不符合条件的样本"。

### 应用与意义

cGAN 为 GAN 的实用化开辟了道路。pix2pix（Isola et al., 2017）将 cGAN 用于图像翻译（边缘图→照片），CycleGAN（Zhu et al., 2017）进一步将其扩展到无配对数据的场景。而条件控制的理念在 StyleGAN 的各个层级中得到深化——从简单的类别标签发展到逐层的风格条件注入。

## 从 DCGAN 到 StyleGAN

DCGAN 确立了全卷积 + BN + LeakyReLU 的骨架，cGAN 奠定了条件控制的范式。StyleGAN（Karras et al., 2019）在此基础上做了两个关键突破：

1. **用 Mapping Network 替代固定的噪声输入**：将随机向量 $z$ 映射到解耦的中间隐空间 $W$，实现了对生成过程的精细控制。
2. **用 AdaIN 替代 BN 的特征归一化**：在合成网络的每个分辨率层级注入风格信息，使不同层级的特征可以独立控制不同尺度的视觉属性。

这些突破构成了下一篇文章的核心内容。
