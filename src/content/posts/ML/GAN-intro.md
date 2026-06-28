---
title: GAN-介绍
published: 2026-06-28
description: ''
image: ''
tags: []
category: '模式识别与机器学习'
order: 37
draft: false 
lang: ''
---

## 生成对抗网络（Generative Adversarial Network，GAN）

是一种深度学习模型，由 Ian Goodfellow 等人在 2014 年提出。GAN 的核心思想是通过两个神经网络的对抗训练来生成逼真的数据样本。

一个标准的GAN主要由这两部分组成：

- 生成器 ($G$)：输入一个随机噪声向量 $z$，输出生成的假样本 $G(z)$。

- 判别器 ($D$)：输入一个样本 $x$（真的或假的），输出一个概率 $D(x)$，表示该样本为真的可能性

极小极大博弈（Min-Max Game） 目标函数进行连接

$$
\min_G \max_D V(D, G) = \mathbb{E}_{x\sim p_{data}(x)}[\log D(x)] + \mathbb{E}_{z\sim p_z(z)}[\log(1 - D(G(z)))]
$$

- 判别器的目标是最大化 $V(D, G)$，就是最小化 $D(G(z))$，即尽可能正确地区分真实样本和生成样本。
- 生成器的目标是最小化 $V(D, G)$，就是最大化 $D(G(z))$，即尽可能欺骗判别器，让它认为生成样本是真实的。

GAN的思想很简单，但是有很多值得深入研究的变体，比如DCGAN、WGAN、StyleGAN等。

关于具体实现的部分，是计算机视觉方面的内容，放计算机视觉那一类讲了。
